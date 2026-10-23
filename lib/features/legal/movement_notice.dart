import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/game_data.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';

/// Short notice shown before movement / health access is requested.
/// Returns true once access is allowed. Denying keeps the app usable, but
/// real movement earns no LP.
Future<bool> ensureMovementAccess(BuildContext context, WidgetRef ref) async {
  final current = ref.read(settingsProvider).movementAccess;
  if (current == MovementAccess.allowed) return true;
  final choice = await showModalBottomSheet<MovementAccess>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MovementNotice(denied: current == MovementAccess.denied),
  );
  if (choice == null) return false;
  ref.read(settingsProvider.notifier).setMovementAccess(choice);
  return choice == MovementAccess.allowed;
}

class _MovementNotice extends StatelessWidget {
  const _MovementNotice({required this.denied});

  final bool denied;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.movementNoticeTitle,
              style: kLeatherBuild
                  ? TreadSkin.of(context).display(22, color: TreadColors.brass)
                  : theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(l.movementNoticeBody, style: theme.textTheme.bodyMedium),
            if (denied) ...[
              const SizedBox(height: 10),
              Text(
                l.movementDeniedHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: TreadColors.copper,
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.privacy),
                child: Text(l.movementNoticePrivacyLink),
              ),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () => Navigator.pop(context, MovementAccess.allowed),
              child: Text(l.movementAllow),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context, MovementAccess.denied),
              child: Text(l.movementDeny),
            ),
          ],
        ),
      ),
    );
  }
}
