import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/rewarded_ad_service.dart';
import '../../domain/video_rewards.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';

/// Small, calm button next to the LP pill for the optional rewarded video.
/// Hidden where no video exists (Web). Shows how many are left today; once
/// used up it stays dim, without any countdown.
class VideoButton extends ConsumerStatefulWidget {
  const VideoButton({super.key});

  @override
  ConsumerState<VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends ConsumerState<VideoButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(rewardedAdServiceProvider);
    if (!service.available) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final now = ref.watch(clockProvider)();
    final game = ref.watch(gameProvider);
    final left = game.videos.remaining(now);
    final reward = game.nextVideoReward(now);
    final usedUp = reward == null;

    return Tooltip(
      message: usedUp
          ? l.videoUsedUp
          : l.videoTooltip(formatNumber(context, reward), left),
      child: Semantics(
        button: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _busy ? null : () => _onTap(reward),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: TreadColors.plate,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: usedUp
                            ? const Color(0xFF2B2722)
                            : const Color(0xFF3A3328),
                      ),
                    ),
                    child: Center(
                      child: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TreadColors.brass,
                              ),
                            )
                          : Icon(
                              Icons.smart_display_outlined,
                              size: 20,
                              color: usedUp
                                  ? TreadColors.muted.withValues(alpha: 0.45)
                                  : TreadColors.brass,
                            ),
                    ),
                  ),
                ),
                if (!usedUp)
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: TreadColors.iron,
                        shape: BoxShape.circle,
                        border: Border.all(color: TreadColors.brassDark),
                      ),
                      child: Text(
                        '$left',
                        style: const TextStyle(
                          color: TreadColors.brass,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(double? reward) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

    if (reward == null) return say(l.videoUsedUp);
    messenger.removeCurrentSnackBar();
    final watch = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: TreadColors.plate,
      showDragHandle: true,
      builder: (context) => _VideoSheet(reward: reward),
    );
    if (watch != true || !mounted) return;
    setState(() => _busy = true);
    final outcome = await ref.read(rewardedAdServiceProvider).show();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case AdOutcome.earned:
        final paid = ref.read(gameProvider.notifier).claimVideo();
        if (paid) say(l.videoEarned(formatNumber(context, reward)));
      case AdOutcome.skipped:
        say(l.videoSkipped);
      case AdOutcome.failed:
        say(l.videoFailed);
    }
  }
}

class _VideoSheet extends StatelessWidget {
  const _VideoSheet({required this.reward});

  final double reward;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.videoTitle, style: serifTitle.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              l.videoBody(
                formatNumber(context, reward),
                VideoRewards.dailyLimit,
              ),
              style: const TextStyle(color: TreadColors.muted, fontSize: 15),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: TreadColors.brass,
                      foregroundColor: TreadColors.iron,
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.videoWatch),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
