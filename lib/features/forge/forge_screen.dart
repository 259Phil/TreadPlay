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
import '../../widgets/companion_stats.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import '../../widgets/seal_art.dart';

enum _Mode { up, combine }

/// The Forge: buys seals L1, forges two equal seals up a level, combines
/// two different ones, melts splinters, and sets seals from the case into
/// the companion taken along.
class ForgeScreen extends ConsumerStatefulWidget {
  const ForgeScreen({super.key});

  @override
  ConsumerState<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends ConsumerState<ForgeScreen> {
  _Mode _mode = _Mode.up;
  Seal? _first;
  Seal? _second;
  int _glut = 1;

  ForgeStep? get _step => switch (_mode) {
    _Mode.up => Forge.upgrades[_first?.level],
    _Mode.combine => Forge.combines[_first?.level],
  };

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

  void _setMode(_Mode m) => setState(() {
    _mode = m;
    _second = null;
    _resetGlut();
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final c = game.activeCompanion;
    final stock = game.forge.sealsInStock;
    // Drop a selection that is no longer in the case.
    if (_first != null && game.forge.count(_first!) == 0) _first = null;
    if (_second != null && game.forge.count(_second!) == 0) _second = null;
    final locked = !game.unlocks.forge;

    return Scaffold(
      backgroundColor: ForgeColors.base,
      appBar: AppBar(
        backgroundColor: ForgeColors.base,
        title: Text(l.tabForge),
        actions: [
          TextButton.icon(
            key: const Key('forge-ladder'),
            onPressed: () => _showLadder(context),
            icon: const Icon(Icons.layers_outlined, size: 18),
            label: Text(l.forgeLadder),
            style: TextButton.styleFrom(foregroundColor: ForgeColors.brass),
          ),
          ...lpActions(game.lp),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          SizedBox(height: 170, child: CompanionArt(c.artKey)),
          const SizedBox(height: 6),
          Text(
            l.forgeCompanionLine(
              c.name,
              rarityLabel(l, c.rarity),
              c.charms.length,
            ),
            style: const TextStyle(color: ForgeColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          CharmSockets(
            companion: c,
            size: 66,
            onTap: (slot, seal) => seal == null
                ? _pickForSocket(context, game)
                : _confirmClear(context, c, slot, seal),
          ),
          const SizedBox(height: 4),
          Text(
            l.forgeClearHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          CompanionStats(companion: c),
          if (locked) ...[
            const SizedBox(height: 14),
            _Banner(
              key: const Key('forge-block'),
              text: l.wwForgeLocked(
                formatNumber(context, waymarks[1].km, pattern: '0.0'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _panel(context, game),
          const SizedBox(height: 20),
          Text(
            l.forgeCase,
            style: serifTitle.copyWith(fontSize: 19, color: ForgeColors.text),
          ),
          const SizedBox(height: 8),
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
                  _CaseTile(
                    seal: s,
                    count: n,
                    selected: s == _first || s == _second,
                    onTap: () => _pick(s),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Text(
            l.forgeStores(game.forge.splinters, game.forge.glut),
            key: const Key('forge-stores'),
            style: const TextStyle(
              color: ForgeColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            l.forgeGlutSource,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          _BuyRow(
            title: l.forgeBuyTitle(formatNumber(context, Forge.sealCost * 1.0)),
            keyPrefix: 'buy',
            enabled: game.buySealBlock() == null,
            onBuy: (t) => ref.read(gameProvider.notifier).buySeal(t),
          ),
          if (game.forge.splinters >= Forge.splintersPerSeal) ...[
            const SizedBox(height: 12),
            _BuyRow(
              title: l.forgeMeltTitle,
              keyPrefix: 'melt',
              enabled: game.meltBlock() == null,
              onBuy: (t) => ref.read(gameProvider.notifier).meltSplinters(t),
            ),
          ],
          if (game.buySealBlock() == ForgeBlock.notEnoughLp) ...[
            const SizedBox(height: 6),
            Text(
              l.forgeNotEnoughLp,
              style: const TextStyle(color: ForgeColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            l.forgeRule,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Text(
            l.forgeSellNote,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context, GameData game) {
    final l = AppLocalizations.of(context);
    final unlocks = game.unlocks;
    final canCombine = unlocks.combineLevel >= 3;
    if (!canCombine && _mode == _Mode.combine) _mode = _Mode.up;
    final a = _first;
    final b = _second;
    final step = _step;
    if (step != null) _glut = _glut.clamp(step.minGlut, step.maxGlut);

    final ForgeBlock? block = switch ((_mode, a, b)) {
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
    final made = switch ((_mode, a, b)) {
      (_Mode.up, final a?, _) => a.nextLevel,
      (_Mode.combine, final a?, final b?) when block != ForgeBlock.badCombine =>
        Seal.combined(a.type, b.type, a.level),
      _ => null,
    };
    final setBlock = a == null
        ? null
        : game.setBlock(game.activeCompanionId, a);

    String? hint;
    if (a == null) {
      hint = l.forgePickSeal;
    } else if (_mode == _Mode.combine && b == null && block == null) {
      hint = l.forgePickPartner;
    } else if (block != null) {
      hint = _blockText(l, block, a);
    }

    return DecoratedBox(
      key: const Key('forge-panel'),
      decoration: BoxDecoration(
        color: ForgeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ForgeColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canCombine) ...[
              SegmentedButton<_Mode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _Mode.up,
                    label: Text(l.forgeModeUp, key: const Key('mode-up')),
                  ),
                  ButtonSegment(
                    value: _Mode.combine,
                    label: Text(
                      l.forgeModeCombine,
                      key: const Key('mode-combine'),
                    ),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => _setMode(s.first),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              _mode == _Mode.up ? l.forgeUpTitle : l.forgeCombineTitle,
              style: const TextStyle(
                color: ForgeColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 96,
              child: Row(
                children: [
                  _Input(seal: a),
                  const SizedBox(width: 6),
                  _Input(seal: _mode == _Mode.up ? a : b),
                  const SizedBox(width: 8),
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
                  const Icon(Icons.arrow_forward, color: ForgeColors.text),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: made == null
                        ? null
                        : SealArt(
                            key: const Key('forge-result'),
                            seal: made,
                            size: 96,
                            showLevel: true,
                          ),
                  ),
                ],
              ),
            ),
            if (step != null) ...[
              const SizedBox(height: 4),
              _GlutStepper(
                glut: _glut,
                step: step,
                onChanged: (g) => setState(() => _glut = g),
              ),
              Text(
                l.forgeFailNote(pctText(context, step.failChance(_glut))),
                key: const Key('forge-fail'),
                style: const TextStyle(
                  color: ForgeColors.muted,
                  fontSize: 12.5,
                ),
              ),
            ],
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint,
                key: const Key('forge-hint'),
                style: TextStyle(
                  color: block == null ? ForgeColors.muted : ForgeColors.ember,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                key: const Key('forge-go'),
                style: FilledButton.styleFrom(
                  backgroundColor: ForgeColors.brass,
                  foregroundColor: ForgeColors.base,
                  disabledBackgroundColor: ForgeColors.raised,
                  disabledForegroundColor: ForgeColors.muted,
                ),
                onPressed: a == null || block != null || made == null
                    ? null
                    : () => _forge(context),
                child: Text(
                  _mode == _Mode.up ? l.forgeAction : l.forgeCombineAction,
                ),
              ),
            ),
            if (a != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('forge-set'),
                onPressed: setBlock == null
                    ? () => ref
                          .read(gameProvider.notifier)
                          .setSeal(game.activeCompanionId, a)
                    : null,
                child: Text(l.forgeSetAction(game.activeCompanion.name)),
              ),
              if (setBlock == ForgeBlock.noSocket ||
                  setBlock == ForgeBlock.needsSpirit)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    setBlock == ForgeBlock.noSocket
                        ? l.forgeNoSocket
                        : l.forgeNeedsSpirit,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ForgeColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

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
      ForgeBlock.locked => l.wwForgeLocked(waymarks[1].km.toStringAsFixed(1)),
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
      backgroundColor: ForgeColors.base,
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
                      _CaseTile(
                        seal: s,
                        count: n,
                        selected: false,
                        onTap: () => Navigator.pop(context, s),
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
        backgroundColor: ForgeColors.surface,
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

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: ForgeColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: ForgeColors.stop),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: ForgeColors.brass, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: ForgeColors.text)),
          ),
        ],
      ),
    ),
  );
}

/// One empty or filled input slot of the forge recipe.
class _Input extends StatelessWidget {
  const _Input({required this.seal});

  final Seal? seal;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ForgeColors.base,
        border: Border.all(color: ForgeColors.line, width: 1.5),
      ),
      child: s == null
          ? const Icon(Icons.add, color: ForgeColors.line)
          : Center(child: SealArt(seal: s, size: 56)),
    );
  }
}

class _GlutStepper extends StatelessWidget {
  const _GlutStepper({
    required this.glut,
    required this.step,
    required this.onChanged,
  });

  final int glut;
  final ForgeStep step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fixed = step.minGlut == step.maxGlut;
    return Row(
      children: [
        IconButton(
          key: const Key('glut-minus'),
          onPressed: glut > step.minGlut ? () => onChanged(glut - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: ForgeColors.brass,
          disabledColor: ForgeColors.line,
        ),
        Text(
          l.forgeGlutCost(glut).replaceFirst('+ ', ''),
          style: const TextStyle(
            color: ForgeColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          key: const Key('glut-plus'),
          onPressed: glut < step.maxGlut ? () => onChanged(glut + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: ForgeColors.brass,
          disabledColor: ForgeColors.line,
        ),
        Expanded(
          child: Text(
            fixed
                ? l.forgeGlutFixed(step.minGlut)
                : l.forgeGlutRange(step.minGlut, step.maxGlut),
            style: const TextStyle(color: ForgeColors.muted, fontSize: 11.5),
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
    return Material(
      key: Key('case-${seal.code}'),
      color: selected ? ForgeColors.raised : ForgeColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? ForgeColors.brass : ForgeColors.line,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 66,
          height: 94,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SealArt(seal: seal, size: 54),
              const SizedBox(height: 4),
              Text(
                '${l.sealLevelShort(seal.level)} ×$count',
                style: TextStyle(
                  color: metal,
                  fontSize: 11.5,
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
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three buttons, one per stat, that make a seal L1 (bought or melted).
class _BuyRow extends StatelessWidget {
  const _BuyRow({
    required this.title,
    required this.keyPrefix,
    required this.enabled,
    required this.onBuy,
  });

  final String title;
  final String keyPrefix;
  final bool enabled;
  final ValueChanged<SealType> onBuy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ForgeColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final t in SealType.values) ...[
              if (t != SealType.stride) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: Key('$keyPrefix-${t.name}'),
                  onPressed: enabled ? () => onBuy(t) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ForgeColors.text,
                    side: const BorderSide(color: ForgeColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Column(
                    children: [
                      SealArt(seal: Seal(t, 1), size: 40, dimmed: !enabled),
                      Text(
                        sealStat(l, t),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ],
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
          : const Icon(
              Icons.broken_image_outlined,
              color: ForgeColors.stop,
              size: 56,
            ),
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
Future<void> _showLadder(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ForgeColors.base,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        key: const Key('forge-ladder-sheet'),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.forgeLadderTitle, style: serifTitle.copyWith(fontSize: 21)),
            const SizedBox(height: 10),
            for (final t in SealType.values) ...[
              Text(
                sealStat(l, t),
                style: const TextStyle(
                  color: ForgeColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  for (var lv = 1; lv <= 5; lv++)
                    Expanded(child: _LadderCell(seal: Seal(t, lv))),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              l.forgeModeCombine,
              style: const TextStyle(
                color: ForgeColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: _LadderCell(
                    seal: Seal.combined(SealType.stride, SealType.grit, 3),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: _LadderCell(
                    seal: Seal.combined(SealType.stride, SealType.grit, 5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.forgeLadderNote,
              style: const TextStyle(color: ForgeColors.muted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LadderCell extends StatelessWidget {
  const _LadderCell({required this.seal});

  final Seal seal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) =>
              SealArt(seal: seal, size: box.maxWidth.clamp(40, 120)),
        ),
        Text(
          l.sealLevel(seal.level),
          style: TextStyle(
            color: sealLevelMetal(seal.level),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          sealBonusText(context, seal),
          style: const TextStyle(color: ForgeColors.text, fontSize: 11),
        ),
      ],
    );
  }
}
