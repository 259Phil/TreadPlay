import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/battle.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../widgets/companion_figure.dart';
import '../../widgets/format.dart';
import '../../widgets/lp_pill.dart';
import 'arena_look.dart';
import 'arena_state.dart';

String abilityLabel(AppLocalizations l, BattleAbility a) => switch (a) {
  BattleAbility.mend => l.arenaAbilityMend,
  BattleAbility.rally => l.arenaAbilityRally,
  BattleAbility.volley => l.arenaAbilityVolley,
};

/// The Arena tab: the field you fight on, the practice opponent on the far
/// half, your line-up (3 front, 2 back) on the near half.
class ArenaScreen extends ConsumerWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final lineup = ref.watch(arenaLineupProvider);
    final teams = ref.watch(arenaTeamsProvider);
    final owned = {for (final c in game.companions) c.id: c};

    return Scaffold(
      backgroundColor: ArenaColors.night,
      appBar: AppBar(
        title: Text(l.tabArena),
        backgroundColor: ArenaColors.night,
        foregroundColor: ArenaColors.text,
        actions: lpActions(game.lp),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final geo = ArenaGeometry(box.biggest);
                Widget at(
                  BattleSide side,
                  BattleRow row,
                  int i,
                  int n,
                  Widget Function(double size) child,
                ) {
                  final size = geo.figure * ArenaGeometry.depth(side, row);
                  final feet = geo.feet(side, row, i, n);
                  return Positioned(
                    left: feet.dx - size / 2,
                    top: feet.dy - ArenaFigure.heightFor(size),
                    child: child(size),
                  );
                }

                return Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: ArenaPainter()),
                    ),
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(child: _Caption(l.arenaOpponent)),
                    ),
                    for (final (row, team) in [
                      (BattleRow.back, teams.enemyBack),
                      (BattleRow.front, teams.enemyFront),
                    ])
                      for (var i = 0; i < team.length; i++)
                        at(
                          BattleSide.enemy,
                          row,
                          i,
                          team.length,
                          (size) => ArenaFigure(
                            entry: team[i],
                            side: BattleSide.enemy,
                            size: size,
                          ),
                        ),
                    for (var slot = 0; slot < fieldSlots; slot++)
                      () {
                        final row = rowOfSlot(slot);
                        final i = row == BattleRow.front
                            ? slot
                            : slot - frontSlots;
                        final n = row == BattleRow.front
                            ? frontSlots
                            : backSlots;
                        final c = owned[lineup[slot]];
                        return at(
                          BattleSide.player,
                          row,
                          i,
                          n,
                          (size) => GestureDetector(
                            key: Key('arena-slot-$slot'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _pick(context, ref, slot),
                            child: c == null
                                ? EmptySlot(size: size, label: l.arenaEmptySlot)
                                : ArenaFigure(
                                    entry: ArenaEntry.of(c),
                                    side: BattleSide.player,
                                    size: size,
                                    knockedOut: !c.canBattle,
                                  ),
                          ),
                        );
                      }(),
                    for (final (row, label) in [
                      (BattleRow.front, l.arenaFront),
                      (BattleRow.back, l.arenaBack),
                    ])
                      Positioned(
                        left: 6,
                        top:
                            geo.feet(BattleSide.player, row, 0, 1).dy -
                            ArenaFigure.heightFor(geo.figure) * .55,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: _Caption(label),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          _Footer(
            ready: teams.ready,
            onReroll: () =>
                ref.read(arenaOpponentSeedProvider.notifier).reroll(),
            onStart: () => context.push(AppRoutes.arenaBattle),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, int slot) {
    final l = AppLocalizations.of(context);
    final game = ref.read(gameProvider);
    final current = ref.read(arenaLineupProvider)[slot];
    final lineup = ref.read(arenaLineupProvider.notifier);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: ArenaColors.dusk,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheet).height * .7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  l.arenaPick,
                  style: const TextStyle(
                    color: ArenaColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (current != null)
                ListTile(
                  key: const Key('arena-remove'),
                  leading: const Icon(
                    Icons.remove_circle_outline,
                    color: ArenaColors.muted,
                  ),
                  title: Text(
                    l.arenaRemove,
                    style: const TextStyle(color: ArenaColors.text),
                  ),
                  onTap: () {
                    lineup.clear(slot);
                    Navigator.pop(sheet);
                  },
                ),
              for (final c in game.companions)
                ListTile(
                  key: Key('arena-pick-${c.id}'),
                  enabled: c.canBattle,
                  leading: SizedBox(
                    width: 52,
                    height: 52,
                    child: CompanionArt(c.artKey),
                  ),
                  title: Text(
                    '${c.name} · ${l.levelShort(c.level)}',
                    style: const TextStyle(color: ArenaColors.text),
                  ),
                  subtitle: Text(
                    c.canBattle
                        ? '${typeLabel(l, c.type)} · '
                              '${abilityLabel(l, BattleAbility.forTempo(c.tempo))}'
                              ' · ${l.statSpirit} ${c.spirit.round()} %'
                        : l.arenaNoMut,
                    style: const TextStyle(color: ArenaColors.muted),
                  ),
                  trailing: c.id == current
                      ? const Icon(Icons.check, color: ArenaColors.brass)
                      : null,
                  onTap: () {
                    lineup.place(slot, c.id);
                    Navigator.pop(sheet);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xAA0C0A16),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: ArenaColors.brass.withValues(alpha: .6)),
    ),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: ArenaColors.brassLight,
        fontSize: 11,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.ready,
    required this.onReroll,
    required this.onStart,
  });

  final bool ready;
  final VoidCallback onReroll;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0806),
        border: Border(top: BorderSide(color: ArenaColors.brass, width: 1.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ready ? l.arenaPracticeHint : l.arenaNeedFront,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ArenaColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              TextButton.icon(
                key: const Key('arena-reroll'),
                onPressed: onReroll,
                style: TextButton.styleFrom(
                  foregroundColor: ArenaColors.brassLight,
                ),
                icon: const Icon(Icons.casino_outlined),
                label: Text(l.arenaNewOpponent),
              ),
              ArenaButton(
                key: const Key('arena-start'),
                label: l.arenaStart,
                icon: Icons.local_fire_department,
                onPressed: ready ? onStart : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
