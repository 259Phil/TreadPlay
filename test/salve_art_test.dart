import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/domain/salve.dart';
import 'package:treadplay/widgets/salve_art.dart';

void main() {
  test('every salve has its painted icon in the bundle', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/items/'));
    for (final s in Salve.values) {
      expect(File(salveAsset(s)).existsSync(), isTrue, reason: s.name);
    }
  });

  testWidgets('salve art shows the icon at the asked size', (tester) async {
    await tester.pumpWidget(
      const Center(child: SalveArt(salve: Salve.medium, size: 48)),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, salveAsset(Salve.medium));
    expect(tester.getSize(find.byType(SalveArt)), const Size(48, 48));
  });

  testWidgets('the drawn container stands in for a missing icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      Center(
        child: Image.asset(
          'assets/items/missing.webp',
          errorBuilder: (_, _, _) =>
              const DrawnSalveArt(salve: Salve.large, size: 40),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DrawnSalveArt), findsOneWidget);
  });
}
