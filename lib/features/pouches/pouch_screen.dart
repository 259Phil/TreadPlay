import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../domain/pouch.dart';
import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import '../../widgets/pouch_art.dart';
import '../../ui/skin.dart';

/// The leash with the found pouches: pick one, see what it holds and how
/// far it is walked warm, open it (free when warm, else for LP) and see
/// the contents in place. Fits one screen without scrolling.
class PouchScreen extends ConsumerStatefulWidget {
  const PouchScreen({super.key});

  @override
  ConsumerState<PouchScreen> createState() => _PouchScreenState();
}

class _PouchScreenState extends ConsumerState<PouchScreen> {
  int? _selected;
  PouchColor? _openedColor;
  List<PouchReward>? _rewards;

  int? _pick(GameData game) {
    final leash = game.pouches.leash;
    if (leash.isEmpty) return null;
    final s = _selected;
    if (s != null && s < leash.length) return s;
    final ready = leash.indexWhere((p) => p.ready);
    return ready >= 0 ? ready : 0;
  }

  void _open(int index) {
    final game = ref.read(gameProvider);
    final color = game.pouches.leash[index].color;
    final rewards = ref.read(gameProvider.notifier).openPouch(index);
    if (rewards == null) return;
    setState(() {
      _openedColor = color;
      _rewards = rewards;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final selected = _pick(game);
    final skin = TreadSkin.of(context);
    final scaffold = Scaffold(
      backgroundColor: skin.canvas,
      appBar: AppBar(
        backgroundColor: skin.canvas,
        title: Text(skin.displayText(l.pouchTitle), style: skin.display(26)),
        actions: lpActions(game.lp),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, box) {
            final content = _content(context, game, selected, box.maxHeight);
            // Only absurdly short windows scroll; phones and desktops don't.
            return box.maxHeight >= _minHeight
                ? content
                : SingleChildScrollView(
                    child: SizedBox(height: _minHeight, child: content),
                  );
          },
        ),
      ),
    );
    return SkinBackdrop(child: scaffold);
  }

  static const _minHeight = 520.0;

  Widget _content(
    BuildContext context,
    GameData game,
    int? selected,
    double height,
  ) {
    final l = AppLocalizations.of(context);
    final h = height < _minHeight ? _minHeight : height;
    final artSize = (h * .11).clamp(58.0, 84.0);
    final colors = game.unlocks.pouchColors;
    final rewards = _rewards;
    final opened = _openedColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        key: const Key('pouch-screen'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      l.pouchLeash(game.pouches.leash.length, game.leashClips),
                      key: const Key('pouch-leash-count'),
                      style: const TextStyle(
                        color: ForgeColors.brass,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l.pouchCounts(
                              game.pouches.foundTotal,
                              game.pouches.openedTotal,
                            ),
                            style: const TextStyle(
                              color: ForgeColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LeashRail(
                  key: const Key('pouch-leash'),
                  leash: game.pouches.leash,
                  clips: game.leashClips,
                  artSize: artSize,
                  selected: rewards == null ? selected : null,
                  labels: true,
                  keyPrefix: 'pouch-clip',
                  onTap: (i) => setState(() {
                    _selected = i;
                    _rewards = null;
                    _openedColor = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _Panel(
              child: rewards != null && opened != null
                  ? _Reveal(color: opened, rewards: rewards)
                  : colors.isEmpty
                  ? _Note(
                      l.pouchLocked(
                        formatNumber(
                          context,
                          waymarks
                              .firstWhere(
                                (w) => w.unlock == WaymarkUnlock.brownPouch,
                              )
                              .km,
                          pattern: '0.0',
                        ),
                      ),
                    )
                  : selected == null
                  ? _Note(l.pouchEmpty)
                  : _Detail(
                      pouch: game.pouches.leash[selected],
                      now: ref.read(clockProvider)(),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _chanceLine(context, game),
            key: const Key('pouch-chance'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 12),
          ),
          if (game.unlocks.pouchColors.length > 1)
            Text(
              _colorLine(context, game),
              key: const Key('pouch-colors'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: ForgeColors.muted, fontSize: 12),
            ),
          const SizedBox(height: 2),
          Text(
            l.pouchRule,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ForgeColors.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 8),
          if (rewards != null)
            _revealActions(context)
          else
            _openButton(context, game, selected),
        ],
      ),
    );
  }

  String _chanceLine(BuildContext context, GameData game) {
    final l = AppLocalizations.of(context);
    final c = game.activeCompanion;
    final f = c.fortuneFactor;
    final chance = Pouches.chance(
      breathUsed: game.breathCap.toDouble(),
      tankSize: game.breathCap,
      fortuneFactor: f,
    );
    final pct = '${formatNumber(context, chance * 100, pattern: '0')} %';
    final line = l.pouchChance(pct);
    return f > 1
        ? '$line · ${l.pouchFortune(formatNumber(context, f, pattern: '0.00'))}'
        : line;
  }

  /// "Colours: Brown 52 % · Copper 25 % · …" with the Fortune tilt.
  String _colorLine(BuildContext context, GameData game) {
    final l = AppLocalizations.of(context);
    final shares = Pouches.colorShares(
      game.unlocks.pouchColors,
      game.activeCompanion.fortuneFactor,
    );
    final parts = [
      for (final MapEntry(key: c, value: v) in shares.entries)
        l.pouchColorShare(
          pouchShortName(l, c),
          '${formatNumber(context, v * 100, pattern: '0')} %',
        ),
    ];
    return l.pouchColorOdds(parts.join(' · '));
  }

  Widget _openButton(BuildContext context, GameData game, int? selected) {
    final l = AppLocalizations.of(context);
    final pouch = selected == null ? null : game.pouches.leash[selected];
    final block = selected == null ? null : game.openPouchBlock(selected);
    final label = pouch == null
        ? l.pouchOpenFree
        : pouch.ready
        ? l.pouchOpenFree
        : l.pouchOpenLp(pouch.openLp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (block == PouchBlock.notEnoughLp)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l.pouchNotEnoughLp,
              key: const Key('pouch-no-lp'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: ForgeColors.ember, fontSize: 12.5),
            ),
          ),
        SkinButton(
          key: const Key('pouch-open'),
          height: 50,
          label: label,
          onPressed: pouch == null || block != null
              ? null
              : () => _open(selected!),
        ),
      ],
    );
  }

  Widget _revealActions(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: SkinButton.secondary(
            key: const Key('pouch-to-forge'),
            height: 50,
            label: l.pouchToForge,
            onPressed: () => context.go(AppRoutes.forge),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SkinButton(
            key: const Key('pouch-continue'),
            height: 50,
            label: l.pouchContinue,
            onPressed: () => setState(() {
              _rewards = null;
              _openedColor = null;
            }),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SkinPanel(child: child);
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      key: const Key('pouch-note'),
      textAlign: TextAlign.center,
      style: const TextStyle(color: ForgeColors.text, fontSize: 14.5),
    ),
  );
}

/// The picked pouch: art, name, what it holds and its warm progress.
class _Detail extends StatelessWidget {
  const _Detail({required this.pouch, required this.now});

  final Pouch pouch;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = pouch.color;
    String km(double m) => formatNumber(context, m / 1000, pattern: '0.0');
    final hours = (pouch.fadesAt.difference(now).inMinutes / 60).ceil().clamp(
      1,
      24,
    );
    return Column(
      key: const Key('pouch-detail'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Center(
              child: PouchArt(
                color: c,
                size: box.maxHeight.clamp(40.0, 220.0),
                glow: pouch.ready,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          pouchName(l, c),
          key: const Key('pouch-name'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: pouchAccent(c),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pouchContents(l, c),
          key: const Key('pouch-contents'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: ForgeColors.text, fontSize: 13.5),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pouch.warmShare,
            minHeight: 8,
            backgroundColor: ForgeColors.base,
            valueColor: AlwaysStoppedAnimation(
              pouch.ready ? ForgeColors.brass : ForgeColors.ember,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          pouch.ready
              ? l.pouchReady
              : '${l.pouchWarm(km(pouch.warmedM), km(c.walkM))}\n'
                    '${l.pouchFades(hours)}',
          key: const Key('pouch-status'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: pouch.ready ? ForgeColors.brass : ForgeColors.muted,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

/// What came out of the opened pouch, shown in place.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.color, required this.rewards});

  final PouchColor color;
  final List<PouchReward> rewards;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      key: const Key('pouch-reveal'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.pouchOpened(pouchName(l, color)),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: pouchAccent(color),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Center(
              child: Opacity(
                opacity: .9,
                child: PouchArt(
                  color: color,
                  size: (box.maxHeight * .9).clamp(32.0, 150.0),
                  glow: true,
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < rewards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: PouchRewardTile(
                  key: Key('pouch-reward-$i'),
                  reward: rewards[i],
                  size: 52,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l.pouchIntoCase,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ForgeColors.muted, fontSize: 12.5),
        ),
      ],
    );
  }
}
