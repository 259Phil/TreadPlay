import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/game_data.dart';
import '../../domain/salve.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../../widgets/salve_art.dart';

/// The Mutsalben in the Vorrat: one chip per size with its count. A tap
/// applies one to the companion taken along.
class SalveStrip extends ConsumerWidget {
  const SalveStrip({super.key, required this.game});

  final GameData game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = game.activeCompanion;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ForgeColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ForgeColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l.salveVorratTitle} · ${l.statSpirit} ${formatNumber(context, c.spirit)} %',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ForgeColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    game.salves.isEmpty
                        ? l.salveVorratEmpty
                        : l.salveVorratHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ForgeColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            for (final s in Salve.values)
              _Chip(
                key: ValueKey('vorrat-salve-${s.name}'),
                salve: s,
                count: game.salves.count(s),
                onTap: game.useSalveBlock(c.id, s) == null
                    ? () {
                        if (!ref
                            .read(gameProvider.notifier)
                            .useSalve(c.id, s)) {
                          return;
                        }
                        final after = ref.read(gameProvider).activeCompanion;
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          SnackBar(
                            content: Text(
                              l.salveApplied(
                                c.name,
                                formatNumber(context, after.spirit),
                              ),
                            ),
                          ),
                        );
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.salve,
    required this.count,
    required this.onTap,
  });

  final Salve salve;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: '${salveName(l, salve)} · ${salveEffect(l, salve)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Opacity(
          opacity: count > 0 ? 1 : .4,
          child: SizedBox(
            width: 46,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SalveArt(salve: salve, size: 24),
                Text(
                  '×$count',
                  style: TextStyle(
                    color: count > 0 ? salveTint(salve) : ForgeColors.muted,
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
