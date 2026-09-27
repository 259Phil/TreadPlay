import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shoe.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../widgets/boot_placement.dart';
import '../../widgets/breath_ring.dart';
import '../../widgets/format.dart';

/// The boot shelf: every owned boot stands in its own cubby.
class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final selected = game.shoes.firstWhere(
      (s) => s.id == _selectedId,
      orElse: () => game.activeShoe,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.tabGarage)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _Shelf(
            shoes: game.shoes,
            selectedId: selected.id,
            activeId: game.activeShoeId,
            onSelect: (id) => setState(() => _selectedId = id),
          ),
          const SizedBox(height: 16),
          _Details(
            shoe: selected,
            equipped: selected.id == game.activeShoeId,
            onEquip: () => ref.read(gameProvider.notifier).equip(selected.id),
          ),
        ],
      ),
    );
  }
}

/// Shelf proportions shared by the painter and the boot layout.
class _ShelfGeometry {
  _ShelfGeometry(this.width, int shoeCount)
    : rows = max(2, (shoeCount / perRow).ceil());

  static const perRow = 2;

  final double width;
  final int rows;

  double get side => width * 0.045;
  double get crown => width * 0.06;
  double get innerWidth => width - 2 * side;
  double get slotWidth => innerWidth / perRow;
  double get rowHeight => innerWidth * 0.52;
  double get plankTopFace => rowHeight * 0.07;
  double get plankFront => rowHeight * 0.14;
  double get height => crown * 2 + rows * rowHeight;

  /// Y of the back line of plank [row]'s top face.
  double plankTop(int row) =>
      crown + (row + 1) * rowHeight - plankTopFace - plankFront;

  /// Y of the plank's front edge, where soles rest.
  double edge(int row) => plankTop(row) + plankTopFace;

  double slotCenter(int column) => side + slotWidth * (column + 0.5);
}

class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.shoes,
    required this.selectedId,
    required this.activeId,
    required this.onSelect,
  });

  final List<Shoe> shoes;
  final String selectedId;
  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _ShelfGeometry(box.maxWidth, shoes.length);
        return SizedBox(
          height: g.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: CustomPaint(painter: _ShelfPainter(g))),
              for (var i = 0; i < shoes.length; i++)
                ..._bootOnPlank(
                  g,
                  shoes[i],
                  row: i ~/ _ShelfGeometry.perRow,
                  column: i % _ShelfGeometry.perRow,
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _bootOnPlank(
    _ShelfGeometry g,
    Shoe shoe, {
    required int row,
    required int column,
  }) {
    final cx = g.slotCenter(column);
    final edge = g.edge(row);
    final seat = BootPlacement.seat(
      modelId: shoe.modelId,
      centerX: cx,
      soleY: edge,
      maxImageSize: g.slotWidth * 1.1,
      maxBootHeight: g.rowHeight * 0.56,
    );
    final selected = shoe.id == selectedId;
    final active = shoe.id == activeId;
    final slotTop = edge - g.rowHeight * 0.8;
    return [
      if (selected)
        Positioned(
          left: cx - g.slotWidth * 0.45,
          width: g.slotWidth * 0.9,
          top: slotTop,
          height: edge - slotTop,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.35),
                  radius: 0.5,
                  colors: [Color(0x55F3C874), Color(0x00F3C874)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
      Positioned(
        left: seat.boot.left + seat.boot.width * 0.06,
        width: seat.boot.width * 0.88,
        top: edge - g.plankTopFace,
        height: g.plankTopFace * 1.4,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x99000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
      ),
      Positioned.fromRect(
        rect: seat.image,
        child: IgnorePointer(
          child: Image.asset(shoe.imageAsset, fit: BoxFit.contain),
        ),
      ),
      Positioned(
        left: min(seat.boot.right - 8, cx + g.slotWidth / 2 - 34),
        top: max(slotTop, seat.boot.top - 10),
        width: 30,
        height: 30,
        child: IgnorePointer(
          child: BreathRing(breath: shoe.breath, tank: shoe.tankSize),
        ),
      ),
      Positioned(
        left: cx - g.slotWidth * 0.4,
        width: g.slotWidth * 0.8,
        top: edge + g.plankFront * 0.18,
        height: g.plankFront * 0.64,
        child: IgnorePointer(
          child: Center(
            child: _NamePlate(name: shoe.name, active: active),
          ),
        ),
      ),
      Positioned(
        left: cx - g.slotWidth / 2,
        width: g.slotWidth,
        top: slotTop,
        height: edge + g.plankFront - slotTop,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(shoe.id),
        ),
      ),
    ];
  }
}

class _NamePlate extends StatelessWidget {
  const _NamePlate({required this.name, required this.active});

  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? TreadColors.gold : const Color(0xFFB8955A),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF5E4420)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 12, color: Color(0xFF2A1D12)),
              const SizedBox(width: 2),
            ],
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2A1D12),
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  _ShelfPainter(this.g);

  final _ShelfGeometry g;

  static const _frame = Color(0xFF5A3F2A);
  static const _frameDark = Color(0xFF3B2918);
  static const _plankTop = Color(0xFFA27C53);
  static const _plankFront = Color(0xFF6E5036);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final back = Rect.fromLTRB(
      g.side,
      g.crown,
      w - g.side,
      size.height - g.crown,
    );
    canvas.drawRect(
      back,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E1610), Color(0xFF34261B)],
        ).createShader(back),
    );
    final seam = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 5; i++) {
      final x = back.left + back.width * i / 5;
      canvas.drawLine(Offset(x, back.top), Offset(x, back.bottom), seam);
    }

    for (var r = 0; r < g.rows; r++) {
      final top = g.plankTop(r);
      final shadow = Rect.fromLTRB(
        back.left,
        top - g.rowHeight * 0.18,
        back.right,
        top,
      );
      canvas.drawRect(
        shadow,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0x55000000)],
          ).createShader(shadow),
      );
      canvas.drawRect(
        Rect.fromLTRB(back.left, top, back.right, top + g.plankTopFace),
        Paint()..color = _plankTop,
      );
      final front = Rect.fromLTRB(
        g.side * 0.4,
        top + g.plankTopFace,
        w - g.side * 0.4,
        top + g.plankTopFace + g.plankFront,
      );
      canvas.drawRect(front, Paint()..color = _plankFront);
      canvas.drawLine(
        front.topLeft,
        front.topRight,
        Paint()
          ..color = const Color(0xFFC49A68)
          ..strokeWidth = 1.5,
      );
      final grain = Paint()
        ..color = const Color(0x22000000)
        ..strokeWidth = 1;
      for (final f in [0.35, 0.7]) {
        final y = front.top + front.height * f;
        canvas.drawLine(
          Offset(front.left + 6, y),
          Offset(front.right - 6, y),
          grain,
        );
      }
    }

    final sidePaint = Paint()..color = _frame;
    final edgePaint = Paint()
      ..color = _frameDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final rect in [
      Rect.fromLTWH(0, 0, g.side, size.height),
      Rect.fromLTWH(w - g.side, 0, g.side, size.height),
      Rect.fromLTWH(0, 0, w, g.crown),
      Rect.fromLTWH(0, size.height - g.crown, w, g.crown),
    ]) {
      canvas.drawRect(rect, sidePaint);
      canvas.drawRect(rect, edgePaint);
    }
  }

  @override
  bool shouldRepaint(_ShelfPainter old) =>
      old.g.width != g.width || old.g.rows != g.rows;
}

class _Details extends StatelessWidget {
  const _Details({
    required this.shoe,
    required this.equipped,
    required this.onEquip,
  });

  final Shoe shoe;
  final bool equipped;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shoe.name, style: theme.textTheme.headlineSmall),
            Text(
              '${rarityLabel(l, shoe.rarity)} · ${shoeTypeLabel(l, shoe.type)}'
              ' · ${l.sweetSpotAt(formatNumber(context, shoe.type.sweetSpotKmh))}',
            ),
            const SizedBox(height: 4),
            Text(
              '${l.breath} ${l.breathValue(formatNumber(context, shoe.breath), shoe.tankSize)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: equipped
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(l.equipped),
                    )
                  : FilledButton.icon(
                      onPressed: onEquip,
                      icon: const Icon(Icons.hiking),
                      label: Text(l.equip),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
