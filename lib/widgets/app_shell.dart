import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../ui/skin.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = TreadSkin.of(context);
    final leather = s.style == TreadStyle.leather;
    NavigationDestination dest(
      String painted,
      IconData plain,
      IconData on,
      String label,
    ) => leather
        ? NavigationDestination(
            icon: _PaintedNavIcon(asset: painted, selected: false),
            selectedIcon: _PaintedNavIcon(asset: painted, selected: true),
            label: label,
          )
        : NavigationDestination(
            icon: Icon(plain),
            selectedIcon: Icon(on),
            label: label,
          );
    final bar = NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      height: leather ? 74 : null,
      indicatorColor: leather ? Colors.transparent : null,
      overlayColor: leather
          ? const WidgetStatePropertyAll(Colors.transparent)
          : null,
      destinations: [
        dest('start', Icons.landscape_outlined, Icons.landscape, l.tabHome),
        dest('regal', Icons.grid_view_outlined, Icons.grid_view, l.tabShelf),
        dest(
          'schmiede',
          Icons.local_fire_department_outlined,
          Icons.local_fire_department,
          l.tabForge,
        ),
        dest('markt', Icons.storefront_outlined, Icons.storefront, l.tabMarket),
        dest(
          'einstellungen',
          Icons.settings_outlined,
          Icons.settings,
          l.tabSettings,
        ),
      ],
    );
    final scaffold = Scaffold(
      backgroundColor: leather ? Colors.transparent : null,
      body: shell,
      bottomNavigationBar: leather
          ? CustomPaint(painter: _LeatherStrip(s), child: bar)
          : bar,
    );
    return leather ? SkinBackdrop(child: scaffold) : scaffold;
  }
}

/// Painted tab icon of style C. Selected sits on an embossed brass-rimmed
/// plate with a warm glow; unselected is slightly dimmed.
class _PaintedNavIcon extends StatelessWidget {
  const _PaintedNavIcon({required this.asset, required this.selected});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/nav/nav_$asset.webp',
      width: selected ? 34 : 30,
      height: selected ? 34 : 30,
      filterQuality: FilterQuality.medium,
    );
    if (!selected) {
      return SizedBox(
        width: 52,
        height: 38,
        child: Center(child: Opacity(opacity: .78, child: img)),
      );
    }
    return SizedBox(
      width: 52,
      height: 38,
      child: CustomPaint(
        painter: const _NavPlate(),
        child: Center(child: img),
      ),
    );
  }
}

class _NavPlate extends CustomPainter {
  const _NavPlate();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(
      r.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0xAA000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Warm glow behind the icon.
    canvas.drawRRect(
      r.inflate(2),
      Paint()
        ..color = const Color(0x66E8A850)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.2),
          radius: .9,
          colors: [Color(0xFF8A6440), Color(0xFF5A3E2A), Color(0xFF3A281C)],
        ).createShader(rect),
    );
    canvas.drawRRect(
      r.deflate(.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6E2AA), Color(0xFFD2B074), Color(0xFF7A6238)],
        ).createShader(rect),
    );
    canvas.drawLine(
      const Offset(10, 3.2),
      Offset(size.width - 10, 3.2),
      Paint()
        ..strokeWidth = 1
        ..color = const Color(0x80FFF3D0),
    );
  }

  @override
  bool shouldRepaint(_NavPlate old) => false;
}

/// The bottom bar of style C: a dark leather strip with a brass rail on
/// top and stitching along both edges.
class _LeatherStrip extends CustomPainter {
  _LeatherStrip(this.s);
  final TreadSkin s;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect.shift(const Offset(0, -4)),
      Paint()
        ..color = const Color(0x88000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A3424), Color(0xFF33231A), Color(0xFF22170F)],
          stops: [0, .45, 1],
        ).createShader(rect),
    );
    // Leather grain.
    var seed = 7919;
    double rnd() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    final dark = Paint()..color = const Color(0x26000000);
    final light = Paint()..color = const Color(0x12FFE6C0);
    final n = math.min(4000, (size.width * size.height / 50).toInt());
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(
        Offset(rnd() * size.width, rnd() * size.height),
        .5 + rnd() * 1.2,
        i.isEven ? dark : light,
      );
    }
    // Brass rail along the top edge.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 3),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0D598), Color(0xFFB58E52), Color(0xFF5E4523)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 3)),
    );
    canvas.drawLine(
      Offset(0, 3.5),
      Offset(size.width, 3.5),
      Paint()
        ..strokeWidth = 1
        ..color = const Color(0xFF140D08),
    );
    final stitch = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = s.accent.withValues(alpha: .7);
    for (var x = 6.0; x < size.width - 4; x += 8) {
      canvas.drawLine(Offset(x, 8.5), Offset(x + 4, 8.5), stitch);
    }
  }

  @override
  bool shouldRepaint(_LeatherStrip old) => old.s != s;
}
