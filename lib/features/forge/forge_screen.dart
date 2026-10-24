import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/companion.dart';
import '../../domain/forge.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/charm_sockets.dart';
import '../../widgets/companion_figure.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import '../../widgets/seal_art.dart';
import '../../widgets/stock_art.dart';
import '../../ui/skin.dart';

part 'forge_variants.dart';

enum _Mode { up, combine }

/// The Forge: buys seals L1, forges two equal seals up a level, combines
/// two different ones, melts splinters, and sets seals from the case into
/// the companion taken along.
///
/// Laid out to fit one phone screen without scrolling the page: a compact
/// companion header with its sockets, then four tabs (Forge up, Combine,
/// Case, Levels). Only the seal strips scroll, sideways.
class ForgeScreen extends ConsumerStatefulWidget {
  const ForgeScreen({super.key});

  @override
  ConsumerState<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends ConsumerState<ForgeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this)
    ..addListener(_onTab);
  _Mode _mode = _Mode.up;
  Seal? _first;
  Seal? _second;
  int _glut = 1;

  ForgeStep? get _step => switch (_mode) {
    _Mode.up => Forge.upgrades[_first?.level],
    _Mode.combine => Forge.combines[_first?.level],
  };

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _onTab() {
    final m = switch (_tabs.index) {
      0 => _Mode.up,
      1 => _Mode.combine,
      _ => _mode,
    };
    if (m != _mode) {
      setState(() {
        _mode = m;
        _second = null;
        _resetGlut();
      });
    } else {
      setState(() {});
    }
  }

  void _resetGlut() {
    final step = _step;
    if (step != null) _glut = step.minGlut;
  }

  void _pick(Seal s) => setState(() {
    if (_mode == _Mode.combine &&
        _first != null &&
        s != _first &&
        !s.combined &&
        !_first!.combined &&
        s.level == _first!.level) {
      _second = s;
    } else {
      _first = s;
      _second = null;
    }
    _resetGlut();
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    // Drop a selection that is no longer in the case.
    if (_first != null && game.forge.count(_first!) == 0) _first = null;
    if (_second != null && game.forge.count(_second!) == 0) _second = null;

    final skin = TreadSkin.of(context);
    final content = Column(
      children: [
        _Header(
          companion: game.activeCompanion,
          onTap: (slot, seal) => seal == null
              ? _pickForSocket(context, game)
              : _confirmClear(context, game.activeCompanion, slot, seal),
        ),
        const SizedBox(height: 2),
        SkinTabBar(
          key: const Key('forge-tabs'),
          controller: _tabs,
          tabs: [
            for (final (key, text) in [
              ('tab-up', l.forgeModeUp),
              ('tab-combine', l.forgeModeCombine),
              ('tab-case', l.forgeCase),
              ('tab-ladder', l.forgeLadder),
            ])
              Tab(
                key: Key(key),
                height: 40,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _kForgeVariant != 0 && key == 'tab-up'
                      ? _TabWithIcon(palette: _ember, text: text)
                      : _kForgeVariant != 0 && key == 'tab-combine'
                      ? _TabWithIcon(palette: _arcane, text: text)
                      : Text(text),
                ),
              ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _recipe(context, game, _Mode.up),
              _recipe(context, game, _Mode.combine),
              _caseTab(context, game),
              const _LadderTab(),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: skin.canvas,
      appBar: AppBar(
        backgroundColor: skin.canvas,
        title: Text(skin.displayText(l.tabForge), style: skin.display(26)),
        actions: lpActions(game.lp),
      ),
      // Very short screens fall back to scrolling instead of overflowing.
      body: LayoutBuilder(
        builder: (context, box) => box.maxHeight >= _minHeight
            ? content
            : SingleChildScrollView(
                child: SizedBox(height: _minHeight, child: content),
              ),
      ),
    );
  }

  static const _minHeight = _kForgeVariant == 1 ? 560.0 : 500.0;

  /// The Forge up or Combine tab: recipe, Glut, cost, fail chance, the
  /// case as a sideways strip and the action bar at the bottom.
  Widget _recipe(BuildContext context, GameData game, _Mode mode) {
    final l = AppLocalizations.of(context);
    final unlocks = game.unlocks;
    // The tab not shown keeps an empty recipe, so a swipe looks calm.
    final active = mode == _mode;
    final a = active ? _first : null;
    final b = active ? _second : null;
    final step = active ? _step : null;
    if (step != null) _glut = _glut.clamp(step.minGlut, step.maxGlut);

    final ForgeBlock? block = switch ((mode, a, b)) {
      (_, null, _) => null,
      (_Mode.up, final a?, _) => game.upgradeBlock(a, _glut),
      (_Mode.combine, final a?, final b?) => game.combineBlock(a, b, _glut),
      (_Mode.combine, final a?, null) =>
        a.combined || Forge.combines[a.level] == null
            ? ForgeBlock.badCombine
            : a.level > unlocks.combineLevel
            ? ForgeBlock.levelLocked
            : null,
    };
    final made = switch ((mode, a, b)) {
      (_Mode.up, final a?, _) => a.nextLevel,
      (_Mode.combine, final a?, final b?) when block != ForgeBlock.badCombine =>
        Seal.combined(a.type, b.type, a.level),
      _ => null,
    };
    final setBlock = a == null
        ? null
        : game.setBlock(game.activeCompanionId, a);

    String hint;
    if (!unlocks.forge) {
      hint = _lockedText(context);
    } else if (mode == _Mode.combine && a == null && unlocks.combineLevel < 3) {
      hint = l.forgeCombineLocked(
        3,
        waymarks.firstWhere((w) => w.unlock == WaymarkUnlock.combineL3).number,
      );
    } else if (a == null) {
      hint = game.forge.sealsInStock.isEmpty
          ? l.forgeCaseEmpty
          : l.forgePickSeal;
    } else if (block != null) {
      hint = _blockText(l, block, a);
    } else if (mode == _Mode.combine && b == null) {
      hint = l.forgePickPartner;
    } else {
      hint = step != null && step.minGlut != step.maxGlut
          ? l.forgeGlutRange(step.minGlut, step.maxGlut)
          : step != null
          ? l.forgeGlutFixed(step.minGlut)
          : '';
    }

    return _variantBackdrop(
      mode,
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          key: Key(mode == _Mode.up ? 'forge-up-tab' : 'forge-combine-tab'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_kForgeVariant != 0)
              _variantPanel(
                context,
                _RecipeParts(
                  mode: mode,
                  active: active,
                  a: a,
                  b: b,
                  made: made,
                  title: mode == _Mode.up
                      ? l.forgeUpTitle
                      : l.forgeCombineTitle,
                  costs: step == null
                      ? null
                      : _CostLine(
                          glut: _glut,
                          lp: formatNumber(context, step.lp * 1.0),
                        ),
                  slider: SizedBox(
                    height: 40,
                    child: step == null
                        ? null
                        : _GlutSlider(
                            glut: _glut,
                            step: step,
                            have: game.forge.glut,
                            onChanged: (g) => setState(() => _glut = g),
                          ),
                  ),
                  fail: SizedBox(
                    height: 16,
                    child: step == null
                        ? null
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l.forgeFailNote(
                                pctText(context, step.failChance(_glut)),
                              ),
                              key: const Key('forge-fail'),
                              style: const TextStyle(
                                color: ForgeColors.text,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                  ),
                  hint: SizedBox(
                    height: 28,
                    child: Text(
                      hint,
                      key: !active
                          ? null
                          : unlocks.forge
                          ? const Key('forge-hint')
                          : const Key('forge-block'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: block == null && unlocks.forge
                            ? ForgeColors.muted
                            : ForgeColors.ember,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              )
            else
              SkinPanel(
                key: active ? const Key('forge-panel') : null,
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      mode == _Mode.up ? l.forgeUpTitle : l.forgeCombineTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ForgeColors.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          _Input(seal: a),
                          const SizedBox(width: 4),
                          _Input(seal: mode == _Mode.up ? a : b),
                          const SizedBox(width: 6),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (step != null) ...[
                                    Text(
                                      l.forgeGlutCost(_glut),
                                      style: const TextStyle(
                                        color: ForgeColors.brass,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      l.forgeLpCost(
                                        formatNumber(context, step.lp * 1.0),
                                      ),
                                      style: const TextStyle(
                                        color: ForgeColors.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: ForgeColors.text,
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: made == null
                                ? null
                                : SealArt(
                                    key: const Key('forge-result'),
                                    seal: made,
                                    size: 70,
                                    showLevel: true,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: step == null
                          ? null
                          : _GlutSlider(
                              glut: _glut,
                              step: step,
                              have: game.forge.glut,
                              onChanged: (g) => setState(() => _glut = g),
                            ),
                    ),
                    SizedBox(
                      height: 16,
                      child: step == null
                          ? null
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l.forgeFailNote(
                                  pctText(context, step.failChance(_glut)),
                                ),
                                key: const Key('forge-fail'),
                                style: const TextStyle(
                                  color: ForgeColors.text,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 28,
                      child: Text(
                        hint,
                        key: !active
                            ? null
                            : unlocks.forge
                            ? const Key('forge-hint')
                            : const Key('forge-block'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: block == null && unlocks.forge
                              ? ForgeColors.muted
                              : ForgeColors.ember,
                          fontSize: 11.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _StoresLine(
              textKey: active ? const Key('forge-stores') : null,
              game: game,
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 76,
              child: _CaseStrip(game: game, selected: {?a, ?b}, onTap: _pick),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _kForgeVariant != 0
                      ? _TintButton(
                          key: active ? const Key('forge-go') : null,
                          palette: _paletteOf(mode),
                          height: 50,
                          label: mode == _Mode.up
                              ? l.forgeAction
                              : l.forgeCombineAction,
                          onPressed: a == null || block != null || made == null
                              ? null
                              : () => _forge(context),
                        )
                      : SkinButton(
                          key: active ? const Key('forge-go') : null,
                          height: 50,
                          label: mode == _Mode.up
                              ? l.forgeAction
                              : l.forgeCombineAction,
                          onPressed: a == null || block != null || made == null
                              ? null
                              : () => _forge(context),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SetButton(
                    key: active ? const Key('forge-set') : null,
                    game: game,
                    seal: a,
                    block: setBlock,
                    onSet: () => ref
                        .read(gameProvider.notifier)
                        .setSeal(game.activeCompanionId, a!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The Case tab: all loose seals, buying a seal L1 and melting splinters.
  Widget _caseTab(BuildContext context, GameData game) {
    final l = AppLocalizations.of(context);
    final a = _first;
    final setBlock = a == null
        ? null
        : game.setBlock(game.activeCompanionId, a);
    final lpShort = game.buySealBlock() == ForgeBlock.notEnoughLp;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        key: const Key('forge-case-tab'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StoresLine(textKey: const Key('case-stores'), game: game),
          if (!game.unlocks.forge)
            Text(
              _lockedText(context),
              maxLines: 2,
              style: const TextStyle(color: ForgeColors.ember, fontSize: 11.5),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: 146,
            child: _CaseStrip(
              game: game,
              rows: 2,
              selected: {?a},
              onTap: (s) => setState(() {
                _first = s;
                _second = null;
                _resetGlut();
              }),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: _SetButton(
              key: const Key('case-set'),
              game: game,
              seal: a,
              block: setBlock,
              onSet: () => ref
                  .read(gameProvider.notifier)
                  .setSeal(game.activeCompanionId, a!),
            ),
          ),
          const Spacer(),
          _BuyRow(
            title: l.forgeBuyTitle(formatNumber(context, Forge.sealCost * 1.0)),
            note: lpShort ? l.forgeNotEnoughLp : null,
            keyPrefix: 'buy',
            enabled: game.buySealBlock() == null,
            onBuy: (t) => ref.read(gameProvider.notifier).buySeal(t),
          ),
          const SizedBox(height: 6),
          _BuyRow(
            title: l.forgeMeltTitle,
            leading: const SplitterIcon(size: 20),
            keyPrefix: 'melt',
            enabled: game.meltBlock() == null,
            onBuy: (t) => ref.read(gameProvider.notifier).meltSplinters(t),
          ),
        ],
      ),
    );
  }

  String _lockedText(BuildContext context) => AppLocalizations.of(
    context,
  ).wwForgeLocked(formatNumber(context, waymarks[1].km, pattern: '0.0'));

  String _blockText(AppLocalizations l, ForgeBlock block, Seal a) {
    int wmOf(WaymarkUnlock u) =>
        waymarks.firstWhere((w) => w.unlock == u).number;
    return switch (block) {
      ForgeBlock.levelLocked when _mode == _Mode.up => l.forgeLevelLocked(
        a.level + 1,
        wmOf(switch (a.level + 1) {
          2 => WaymarkUnlock.forgeL2,
          3 => WaymarkUnlock.forgeL3,
          4 => WaymarkUnlock.forgeL4,
          _ => WaymarkUnlock.forgeL5,
        }),
      ),
      ForgeBlock.levelLocked => l.forgeCombineLocked(
        a.level,
        wmOf(a.level >= 5 ? WaymarkUnlock.combineL5 : WaymarkUnlock.combineL3),
      ),
      ForgeBlock.maxLevel => a.combined ? l.forgeComboFinal : l.forgeTopLevel,
      ForgeBlock.needsPair => l.forgeNeedsPair,
      ForgeBlock.badCombine => l.forgeBadCombine,
      ForgeBlock.notEnoughGlut || ForgeBlock.glutRange => l.forgeNeedsGlut,
      ForgeBlock.notEnoughLp => l.forgeNotEnoughLp,
      ForgeBlock.locked => _lockedText(context),
      _ => l.forgeNotEnoughLp,
    };
  }

  Future<void> _forge(BuildContext context) async {
    final notifier = ref.read(gameProvider.notifier);
    final a = _first!;
    final outcome = _mode == _Mode.up
        ? notifier.upgradeSeal(a, _glut)
        : notifier.combineSeals(a, _second!, _glut);
    if (outcome == null || !context.mounted) return;
    final made = outcome.made;
    if (made != null) {
      setState(() {
        _first = made;
        _second = null;
        _resetGlut();
      });
    }
    await showDialog<void>(
      context: context,
      builder: (context) => _ResultDialog(outcome: outcome),
    );
  }

  Future<void> _pickForSocket(BuildContext context, GameData game) async {
    final l = AppLocalizations.of(context);
    final stock = game.forge.sealsInStock;
    final picked = await showModalBottomSheet<Seal>(
      context: context,
      backgroundColor: kLeatherBuild ? null : ForgeColors.base,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.forgePickTitle, style: serifTitle.copyWith(fontSize: 20)),
              const SizedBox(height: 12),
              if (stock.isEmpty)
                Text(
                  l.forgeCaseEmpty,
                  style: const TextStyle(color: ForgeColors.muted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (s, n) in stock)
                      SizedBox(
                        width: 66,
                        height: 88,
                        child: _CaseTile(
                          seal: s,
                          count: n,
                          selected: false,
                          onTap: () => Navigator.pop(context, s),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    final ok = ref
        .read(gameProvider.notifier)
        .setSeal(game.activeCompanionId, picked);
    if (!ok && context.mounted) {
      final block = ref
          .read(gameProvider)
          .setBlock(game.activeCompanionId, picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            block == ForgeBlock.needsSpirit
                ? l.forgeNeedsSpirit
                : block == ForgeBlock.locked
                ? l.wwForgeLocked(waymarks[1].km.toStringAsFixed(1))
                : l.forgeNoSocket,
          ),
        ),
      );
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    Companion companion,
    int slot,
    Seal seal,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TreadSkin.of(context).surface,
        icon: SealArt(seal: seal, size: 88),
        title: Text(l.forgeClearTitle(sealTitle(l, seal))),
        content: Text(l.forgeClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.forgeClearKeep),
          ),
          FilledButton(
            key: const Key('forge-clear-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.forgeClearAction),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(gameProvider.notifier).clearSeal(companion.id, slot);
    }
  }
}

/// One empty or filled input slot of the forge recipe.
class _Input extends StatelessWidget {
  const _Input({required this.seal});

  final Seal? seal;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    final skin = TreadSkin.of(context);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: skin.base,
        border: Border.all(
          color: skin.style == TreadStyle.ironPlain
              ? skin.line
              : skin.brassDeep,
          width: 1.5,
        ),
        boxShadow: skin.style == TreadStyle.runeEmber
            ? [
                BoxShadow(
                  color: skin.accent.withValues(alpha: .3),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: s == null
          ? const Icon(Icons.add, color: ForgeColors.line)
          : Center(child: SealArt(seal: s, size: 56)),
    );
  }
}

/// Companion figure, name, totals and its sockets in one compact row.
class _Header extends StatelessWidget {
  const _Header({required this.companion, required this.onTap});

  final Companion companion;
  final void Function(int slot, Seal? seal) onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = companion;
    String n(double v) => formatNumber(context, v, pattern: '0.0');
    return SizedBox(
      key: const Key('forge-header'),
      height: 122,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
        child: Row(
          children: [
            SizedBox(width: 80, height: 112, child: CompanionArt(c.artKey)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.forgeCompanionLine(
                      c.name,
                      rarityLabel(l, c.rarity),
                      c.charms.length,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ForgeColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  FittedBox(
                    key: const Key('forge-totals'),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l.statStride} ${n(c.strideTotal)} · '
                      '${l.statGrit} ${n(c.gritTotal)} · '
                      '${l.statFortune} ${n(c.fortuneTotal)} · '
                      '${l.statSpirit} ${formatNumber(context, c.spirit)} %',
                      style: const TextStyle(
                        color: ForgeColors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: CharmSockets(
                      companion: c,
                      size: 36,
                      compact: true,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Splinters 4/5 · Glut 7" with the painted splinter and Glut icons.
class _StoresLine extends StatelessWidget {
  const _StoresLine({required this.game, this.textKey});

  final GameData game;

  /// Key of the line; its two texts get "-splinters" and "-glut".
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final k = textKey;
    final name = k is ValueKey<String> ? k.value : null;
    const style = TextStyle(
      color: ForgeColors.text,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    );
    Widget chip(Widget icon, String text, String suffix) => Flexible(
      child: SkinChip(
        padding: const EdgeInsets.fromLTRB(4, 2, 10, 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                text,
                key: name == null ? null : Key('$name-$suffix'),
                style: style.copyWith(color: TreadSkin.of(context).text),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      key: k,
      children: [
        chip(
          const SplitterIcon(size: 24),
          l.storesSplinters(game.forge.splinters),
          'splinters',
        ),
        const SizedBox(width: 8),
        chip(const GlutIcon(size: 24), l.storesGlut(game.forge.glut), 'glut'),
      ],
    );
  }
}

/// The loose seals as a sideways strip (one or two rows).
class _CaseStrip extends StatelessWidget {
  const _CaseStrip({
    required this.game,
    required this.selected,
    required this.onTap,
    this.rows = 1,
  });

  final GameData game;
  final Set<Seal> selected;
  final ValueChanged<Seal> onTap;
  final int rows;

  @override
  Widget build(BuildContext context) {
    final stock = game.forge.sealsInStock;
    if (stock.isEmpty) {
      final skin = TreadSkin.of(context);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: skin.style == TreadStyle.leather
              ? const Color(0xCC241A14)
              : ForgeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: skin.style == TreadStyle.leather
                ? skin.line
                : ForgeColors.line,
          ),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context).forgeCaseNone,
            style: TextStyle(color: skin.muted),
          ),
        ),
      );
    }
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: stock.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: rows,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 80 / 62,
      ),
      itemBuilder: (context, i) {
        final (s, n) = stock[i];
        return _CaseTile(
          seal: s,
          count: n,
          selected: selected.contains(s),
          onTap: () => onTap(s),
        );
      },
    );
  }
}

/// "Set into Gilt", with the reason underneath when it cannot be done.
class _SetButton extends StatelessWidget {
  const _SetButton({
    super.key,
    required this.game,
    required this.seal,
    required this.block,
    required this.onSet,
  });

  final GameData game;
  final Seal? seal;
  final ForgeBlock? block;
  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final note = switch (block) {
      ForgeBlock.noSocket => l.forgeNoSocket,
      ForgeBlock.needsSpirit => l.forgeNeedsSpirit,
      _ => null,
    };
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: seal != null && block == null ? onSet : null,
        style:
            skinButtonStyle(
              TreadSkin.of(context),
              SkinButtonKind.secondary,
              height: 50,
            ).copyWith(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l.forgeSetAction(game.activeCompanion.name),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (note != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(note, style: const TextStyle(fontSize: 10.5)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Glut for this try: a brass slider over the allowed range, with − and +.
class _GlutSlider extends StatelessWidget {
  const _GlutSlider({
    required this.glut,
    required this.step,
    required this.have,
    required this.onChanged,
  });

  final int glut;
  final ForgeStep step;
  final int have;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fixed = step.minGlut == step.maxGlut;
    final button = IconButton.styleFrom(
      foregroundColor: ForgeColors.brass,
      disabledForegroundColor: ForgeColors.line,
      minimumSize: const Size(34, 34),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Row(
      children: [
        IconButton(
          key: const Key('glut-minus'),
          style: button,
          onPressed: glut > step.minGlut ? () => onChanged(glut - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Expanded(
          child: fixed
              ? Center(
                  child: Text(
                    l.forgeGlutFixed(step.minGlut),
                    style: const TextStyle(
                      color: ForgeColors.muted,
                      fontSize: 12,
                    ),
                  ),
                )
              : SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: ForgeColors.ember,
                    inactiveTrackColor: ForgeColors.line,
                    thumbColor: ForgeColors.brass,
                    overlayColor: ForgeColors.brass.withValues(alpha: 0.15),
                    activeTickMarkColor: ForgeColors.base,
                    inactiveTickMarkColor: ForgeColors.muted,
                    trackHeight: 4,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    key: const Key('glut-slider'),
                    min: step.minGlut.toDouble(),
                    max: step.maxGlut.toDouble(),
                    divisions: step.maxGlut - step.minGlut,
                    value: glut.toDouble(),
                    label: '$glut',
                    onChanged: (v) => onChanged(v.round()),
                  ),
                ),
        ),
        IconButton(
          key: const Key('glut-plus'),
          style: button,
          onPressed: glut < step.maxGlut ? () => onChanged(glut + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
        const SizedBox(width: 2),
        const GlutIcon(size: 22),
        const SizedBox(width: 2),
        SizedBox(
          width: 50,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '$glut / $have',
              key: const Key('glut-value'),
              style: TextStyle(
                color: glut > have ? ForgeColors.ember : ForgeColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A loose seal in the case: painted art, level and count drawn by Flutter.
class _CaseTile extends StatelessWidget {
  const _CaseTile({
    required this.seal,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final Seal seal;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final metal = sealLevelMetal(seal.level);
    final skin = TreadSkin.of(context);
    final radius = BorderRadius.circular(skin.radius.clamp(3, 12));
    return Material(
      key: Key('case-${seal.code}'),
      color: selected ? skin.raised : skin.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected
              ? (skin.style == TreadStyle.runeEmber ? skin.accent : skin.brass)
              : (skin.style == TreadStyle.forgeBrass
                    ? skin.brassDeep
                    : skin.line),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) =>
                      SealArt(seal: seal, size: box.maxHeight.clamp(20, 54)),
                ),
              ),
              Text(
                '${l.sealLevelShort(seal.level)} ×$count',
                style: TextStyle(
                  color: metal,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                seal.combined
                    ? '${sealStat(l, seal.type).substring(0, 1)}+${sealStat(l, seal.partner!).substring(0, 1)}'
                    : sealStat(l, seal.type),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  color: ForgeColors.muted,
                  fontSize: 10,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A title and three buttons, one per stat, that make a seal L1 (bought or
/// melted).
class _BuyRow extends StatelessWidget {
  const _BuyRow({
    required this.title,
    required this.keyPrefix,
    required this.enabled,
    required this.onBuy,
    this.note,
    this.leading,
  });

  final String title;
  final String? note;
  final Widget? leading;
  final String keyPrefix;
  final bool enabled;
  final ValueChanged<SealType> onBuy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (leading case final w?) ...[w, const SizedBox(width: 4)],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ForgeColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            if (note case final n?) ...[
              const SizedBox(width: 8),
              Text(
                n,
                style: const TextStyle(color: ForgeColors.ember, fontSize: 11),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final t in SealType.values) ...[
              if (t != SealType.stride) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    key: Key('$keyPrefix-${t.name}'),
                    onPressed: enabled ? () => onBuy(t) : null,
                    style: TreadSkin.of(context).style == TreadStyle.leather
                        ? skinButtonStyle(
                            TreadSkin.of(context),
                            SkinButtonKind.secondary,
                            height: 40,
                          ).copyWith(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.fromLTRB(6, 0, 6, 3),
                            ),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : OutlinedButton.styleFrom(
                            foregroundColor: ForgeColors.text,
                            side: const BorderSide(color: ForgeColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SealArt(seal: Seal(t, 1), size: 28, dimmed: !enabled),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              sealStat(l, t),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.outcome});

  final ForgeOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final made = outcome.made;
    final broken = outcome.broken;
    return AlertDialog(
      key: Key(outcome.success ? 'forge-success' : 'forge-failed'),
      backgroundColor: ForgeColors.surface,
      icon: made != null
          ? SealArt(seal: made, size: 140, showLevel: true)
          : const SplitterIcon(size: 96),
      title: Text(outcome.success ? l.forgeSuccessTitle : l.forgeFailTitle),
      content: Text(
        made != null
            ? '${l.forgeSuccessBody(sealTitle(l, made))}\n${sealBonusText(context, made)}'
            : l.forgeFailBody(sealTitle(l, broken!)),
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          key: const Key('forge-result-ok'),
          onPressed: () => Navigator.pop(context),
          child: Text(l.forgeOk),
        ),
      ],
    );
  }
}

/// All seal levels side by side, so the climb from stone to crest is clear.
/// Each row takes an equal share of the tab, so nothing scrolls.
class _LadderTab extends StatelessWidget {
  const _LadderTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const label = TextStyle(
      color: ForgeColors.text,
      fontWeight: FontWeight.w700,
      fontSize: 12.5,
      height: 1.2,
    );
    Widget row(String title, List<Seal?> seals) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: label),
          Expanded(
            child: Row(
              children: [
                for (final s in seals)
                  Expanded(
                    child: s == null ? const SizedBox() : _LadderCell(seal: s),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return Padding(
      key: const Key('forge-ladder-tab'),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final t in SealType.values)
            row(sealStat(l, t), [for (var lv = 1; lv <= 5; lv++) Seal(t, lv)]),
          row(l.forgeModeCombine, [
            null,
            null,
            Seal.combined(SealType.stride, SealType.grit, 3),
            null,
            Seal.combined(SealType.stride, SealType.grit, 5),
          ]),
          const SizedBox(height: 4),
          Text(
            '${l.forgeLadderNote} ${l.forgeGlutSource} ${l.forgeSellNote} '
            '${l.forgeClearHint}',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ForgeColors.muted,
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// One level: art scaled to the space it gets, level and bonus below.
class _LadderCell extends StatelessWidget {
  const _LadderCell({required this.seal});

  final Seal seal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final art = (box.maxHeight - 28).clamp(14.0, box.maxWidth);
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SealArt(seal: seal, size: art),
              Text(
                l.sealLevel(seal.level),
                style: TextStyle(
                  color: sealLevelMetal(seal.level),
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                sealBonusText(context, seal),
                style: const TextStyle(
                  color: ForgeColors.text,
                  fontSize: 10.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
