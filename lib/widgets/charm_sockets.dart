import 'package:flutter/material.dart';

import '../domain/companion.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

IconData sealIcon(SealType type) => switch (type) {
  SealType.stride => Icons.directions_walk,
  SealType.grit => Icons.shield_outlined,
  SealType.fortune => Icons.auto_awesome,
};

String sealStat(AppLocalizations l, SealType type) => switch (type) {
  SealType.stride => l.statStride,
  SealType.grit => l.statGrit,
  SealType.fortune => l.statFortune,
};

/// One round metal socket per charm slot: steel and hollow when empty,
/// brass with the stat icon when a seal sits in it. With [onClear], a filled
/// socket can be tapped to remove its seal.
class CharmSockets extends StatelessWidget {
  const CharmSockets({super.key, required this.companion, this.onClear});

  final Companion companion;
  final void Function(int slot, SealType seal)? onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final charms = companion.charms;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < charms.length; i++)
          _Socket(
            key: Key('charm-slot-$i'),
            seal: SealType.values.asNameMap()[charms[i]],
            label: switch (SealType.values.asNameMap()[charms[i]]) {
              final t? => l.sealBonus(1, sealStat(l, t)),
              null => l.charmSlotEmpty,
            },
            onTap: switch ((SealType.values.asNameMap()[charms[i]], onClear)) {
              (final t?, final clear?) => () => clear(i, t),
              _ => null,
            },
          ),
      ],
    );
  }
}

class _Socket extends StatelessWidget {
  const _Socket({
    super.key,
    required this.seal,
    required this.label,
    this.onTap,
  });

  final SealType? seal;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = seal;
    final rim = s == null ? TreadColors.steel : TreadColors.brass;
    final socket = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rim, width: 3),
            gradient: RadialGradient(
              center: const Alignment(-0.2, -0.3),
              colors: s == null
                  ? const [Color(0xFF0C0E12), Color(0xFF2A3038)]
                  : const [Color(0xFFE2C98F), TreadColors.brassDark],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x99000000), blurRadius: 4),
            ],
          ),
          child: s == null
              ? null
              : Icon(sealIcon(s), color: TreadColors.iron, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: s == null ? TreadColors.muted : TreadColors.brass,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    final tap = onTap;
    if (tap == null) return socket;
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(padding: const EdgeInsets.all(4), child: socket),
    );
  }
}
