import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/wanderweg.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import 'wanderweg_text.dart';

/// Small brass chip on Home: signpost and reached / total. Opens the trail.
class TrailChip extends ConsumerWidget {
  const TrailChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final progress = ref.watch(gameProvider.select((g) => g.wanderweg));
    return Semantics(
      button: true,
      label: l.wwTitle,
      child: InkWell(
        key: const Key('trail-chip'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(AppRoutes.wanderweg),
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: kLeatherBuild
                ? const Color(0xE6241912)
                : const Color(0xFF1A1D22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TreadColors.brassDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              skinIcon(
                context,
                Icons.signpost_outlined,
                SkinIcons.waymark,
                size: 15,
                color: TreadColors.brass,
              ),
              const SizedBox(width: 5),
              Text(
                '${progress.reached}/${waymarks.length}',
                style: const TextStyle(
                  color: TreadColors.brass,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (progress.unseen > 0) ...[
                const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE08A3C),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiet note once a waymark is reached: tap opens the trail, × dismisses.
/// Nothing is pushed to the device.
class WaymarkReachedBubble extends ConsumerWidget {
  const WaymarkReachedBubble({super.key, this.dismissible = true});

  final bool dismissible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final progress = ref.watch(gameProvider.select((g) => g.wanderweg));
    if (progress.unseen == 0) return const SizedBox.shrink();
    final last = progress.last!;
    final text = progress.unseen == 1
        ? l.wwReachedOne(last.number, unlockLabel(l, last.unlock))
        : l.wwReachedMany(progress.unseen);
    return Material(
      key: const Key('waymark-bubble'),
      color: const Color(0xF01A1D22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: TreadColors.brassDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.wanderweg),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                size: 18,
                color: Color(0xFFE08A3C),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE8E0D0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (dismissible)
                IconButton(
                  key: const Key('waymark-bubble-close'),
                  visualDensity: VisualDensity.compact,
                  tooltip: l.wwClose,
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: TreadColors.muted,
                  ),
                  onPressed: () =>
                      ref.read(gameProvider.notifier).markWanderwegSeen(),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: TreadColors.brass,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
