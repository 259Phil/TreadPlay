import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/data/game_data.dart';
import 'package:treadplay/data/lp_sound.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default is the pixel glitter, unknown ids fall back to it', () {
    expect(LpTone.standard, LpTone.pixel3);
    expect(const AppSettings().lpSound, LpTone.standard.id);
    expect(LpTone.byId(null), LpTone.pixel3);
    expect(LpTone.byId('gone'), LpTone.pixel3);
    expect(LpTone.byId('cash_3'), LpTone.cash3);
    expect(LpTone.cash3.label, 'Cha-ching');
  });

  test('the choice survives a save', () {
    final s = const AppSettings().copyWith(lpSound: 'pixel_1');
    expect(AppSettings.fromJson(s.toJson()).lpSound, 'pixel_1');
  });

  test('all sounds play at about the same comfortable level', () {
    for (final t in LpTone.values) {
      expect(t.gain, inInclusiveRange(0.4, 0.9), reason: t.id);
    }
    expect(LpTone.standard.gain, LpSound.volume);
  });

  test('every sound is bundled', () async {
    for (final t in LpTone.values) {
      final data = await rootBundle.load(t.asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: t.asset);
    }
  });
}
