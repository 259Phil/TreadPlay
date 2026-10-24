import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/salve.dart';
import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../theme.dart';
import 'format.dart';
import 'salve_art.dart';

/// Opens the salve picker for [companionId]: every salve in the Vorrat
/// with its count and an Apply button.
Future<void> showSalveSheet(BuildContext context, String companionId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SalveSheet(companionId: companionId),
    );

class SalveSheet extends ConsumerWidget {
  const SalveSheet({super.key, required this.companionId});

  final String companionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final c = game.companions.where((c) => c.id == companionId).firstOrNull;
    if (c == null) return const SizedBox.shrink();
    final mut = formatNumber(context, c.spirit);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.salveSheetTitle(c.name),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              c.spirit >= 100 ? l.salveFull : l.salveSheetSpirit(mut),
              style: const TextStyle(color: TreadColors.muted),
            ),
            const SizedBox(height: 12),
            for (final s in Salve.values)
              _SalveRow(
                key: ValueKey('salve-use-${s.name}'),
                salve: s,
                owned: game.salves.count(s),
                onUse: game.useSalveBlock(c.id, s) == null
                    ? () {
                        final ok = ref
                            .read(gameProvider.notifier)
                            .useSalve(c.id, s);
                        if (!ok) return;
                        final after = ref
                            .read(gameProvider)
                            .companions
                            .firstWhere((o) => o.id == c.id);
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
                        if (after.spirit >= 100) Navigator.of(context).pop();
                      }
                    : null,
              ),
            if (game.salves.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.salveNoneHint,
                  style: const TextStyle(color: TreadColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SalveRow extends StatelessWidget {
  const _SalveRow({
    super.key,
    required this.salve,
    required this.owned,
    required this.onUse,
  });

  final Salve salve;
  final int owned;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Opacity(
            opacity: owned > 0 ? 1 : .45,
            child: SalveArt(salve: salve, size: 48),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(salveName(l, salve)),
                Text(
                  '${salveEffect(l, salve)} · ${l.salveOwned(owned)}',
                  style: TextStyle(color: salveTint(salve), fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton.tonal(onPressed: onUse, child: Text(l.salveUse)),
        ],
      ),
    );
  }
}
