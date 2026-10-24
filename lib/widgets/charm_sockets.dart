import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../ui/skin.dart';
import 'recipe_text.dart';
import 'seal_art.dart';

export 'seal_art.dart' show sealIcon, sealStat;

/// One round metal socket per charm slot: dark and hollow when empty, the
/// painted seal with its stat bonus and level when filled. [onTap] gets the
/// slot and its seal (null when empty).
class CharmSockets extends StatelessWidget {
  const CharmSockets({
    super.key,
    required this.companion,
    this.onTap,
    this.size = 64,
    this.compact = false,
  });

  final Companion companion;
  final void Function(int slot, Seal? seal)? onTap;
  final double size;

  /// Smaller labels for the Forge header.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final charms = companion.charms;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < charms.length; i++)
          Flexible(
            child: _Socket(
              key: Key('charm-slot-$i'),
              seal: companion.sealAt(i),
              size: size,
              compact: compact,
              onTap: switch (onTap) {
                final tap? => () => tap(i, companion.sealAt(i)),
                null => null,
              },
            ),
          ),
      ],
    );
  }
}

class _Socket extends StatelessWidget {
  const _Socket({
    super.key,
    required this.seal,
    required this.size,
    this.compact = false,
    this.onTap,
  });

  final Seal? seal;
  final double size;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = seal;
    final ring = s == null
        ? (kLeatherBuild ? const Color(0xFF7A5E40) : const Color(0xFF59616B))
        : sealLevelMetal(s.level);
    final socket = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 1.3,
          height: size * 1.3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ring.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.3),
                    colors: kLeatherBuild
                        ? [Color(0xFF150E0A), Color(0xFF34251B)]
                        : [Color(0xFF15181C), Color(0xFF2A3038)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x99000000), blurRadius: 4),
                  ],
                ),
              ),
              if (s != null) SealArt(seal: s, size: size * 1.3),
            ],
          ),
        ),
        SizedBox(height: compact ? 1 : 4),
        Text(
          s == null ? l.charmSlotEmpty : _label(context, l, s),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: s == null ? ForgeColors.muted : ForgeColors.text,
            fontSize: compact ? 11 : 12.5,
            height: compact ? 1.15 : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (s != null)
          Text(
            l.sealLevel(s.level),
            style: TextStyle(
              color: sealLevelMetal(s.level),
              fontSize: compact ? 10.5 : 11.5,
              height: compact ? 1.15 : null,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
    // The compact header has a fixed height: shrink rather than overflow.
    final fitted = compact
        ? FittedBox(fit: BoxFit.scaleDown, child: socket)
        : socket;
    final tap = onTap;
    if (tap == null) return fitted;
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(size),
      child: Padding(padding: const EdgeInsets.all(2), child: fitted),
    );
  }

  static String _label(BuildContext context, AppLocalizations l, Seal s) {
    final pct = pctText(context, s.bonus);
    return s.combined
        ? '${sealStats(l, s)}\n${sealSplitText(context, s)}'
        : l.sealStatBonus(sealStat(l, s.type), pct);
  }
}
