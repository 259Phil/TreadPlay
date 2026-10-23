import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/ui/skin.dart';

void main() {
  test('style C is the default and every backdrop asset exists', () {
    const define = String.fromEnvironment('TREADPLAY_STYLE');
    if (define.isEmpty) expect(buildStyle, TreadStyle.leather);
    for (final bg in [1, 2, 3]) {
      final s = TreadSkin.leather(bg);
      expect(s.backdrop, 'assets/backdrop/bg$bg.jpg');
      expect(File(s.backdrop!).existsSync(), isTrue);
    }
  });

  test('every painted nav icon exists', () {
    for (final n in ['start', 'regal', 'schmiede', 'markt', 'einstellungen']) {
      expect(File('assets/nav/nav_$n.webp').existsSync(), isTrue, reason: n);
    }
  });
}
