import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
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
  });

  final Companion companion;
  final void Function(int slot, Seal? seal)? onTap;
  final double size;

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
    this.onTap,
  });

  final Seal? seal;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = seal;
    final ring = s == null ? const Color(0xFF59616B) : sealLevelMetal(s.level);
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
                    colors: [Color(0xFF15181C), Color(0xFF2A3038)],
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
        const SizedBox(height: 4),
        Text(
          s == null ? l.charmSlotEmpty : _label(context, l, s),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: s == null ? ForgeColors.muted : ForgeColors.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (s != null)
          Text(
            l.sealLevel(s.level),
            style: TextStyle(
              color: sealLevelMetal(s.level),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
    final tap = onTap;
    if (tap == null) return socket;
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(size),
      child: Padding(padding: const EdgeInsets.all(2), child: socket),
    );
  }

  static String _label(BuildContext context, AppLocalizations l, Seal s) {
    final pct = pctText(context, s.bonus);
    return s.combined
        ? '${sealStats(l, s)}\n${l.sealComboBonus(pct)}'
        : l.sealStatBonus(sealStat(l, s.type), pct);
  }
}
