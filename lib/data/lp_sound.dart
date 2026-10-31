import 'dart:math';

import 'package:flutter/services.dart';

import 'lp_sound_stub.dart'
    if (dart.library.js_interop) 'lp_sound_web.dart'
    as impl;

/// The sounds that can mark an LP payout (Settings → Ka-ching sound).
enum LpTone {
  pixel1('pixel_1', 'Pixel 1', -14.2),
  pixel2('pixel_2', 'Pixel 2', -13.8),

  /// Default: 8-bit arpeggio glitter C6-E6-G6-C7, ~0.42 s.
  pixel3('pixel_3', 'Pixel 3', -14.5),
  pixel4('pixel_4', 'Pixel 4', -16.9),
  cash1('cash_1', 'Cash 1', -18.3),
  cash2('cash_2', 'Cash 2', -18.3),
  cash3('cash_3', 'Cha-ching', -17.2);

  const LpTone(this.id, this.label, this.meanDb);

  static const LpTone standard = LpTone.pixel3;

  /// Stored in the settings.
  final String id;
  final String label;

  /// Mean loudness of the file, to play all sounds at about the same level.
  final double meanDb;

  String get asset => 'assets/sounds/lp_$id.mp3';

  /// Gain that brings this sound to the comfortable level of the default.
  double get gain => (LpSound.volume * pow(10, (standard.meanDb - meanDb) / 20))
      .clamp(0.1, 0.9);

  static LpTone byId(String? id) =>
      LpTone.values.firstWhere((t) => t.id == id, orElse: () => standard);
}

/// Plays the LP payout sound for every paid 50 m piece while the Ka-ching
/// setting is on.
///
/// Web: Web Audio. Browsers (iOS Safari above all) only allow audio after a
/// user gesture, so [unlock] must run synchronously inside a tap, e.g. on
/// "Start". Elsewhere it falls back to the system click.
abstract final class LpSound {
  /// Comfortable level for the default sound (it peaks at -7 dBFS).
  static const double volume = 0.55;

  /// A new sound starts only this long after the last one began, so quick
  /// payouts neither cut each other off nor stack up (files are ≤ 0.63 s).
  static const Duration minGap = Duration(milliseconds: 450);

  /// Call from a tap handler before anything is awaited; loads [tone].
  static void unlock(LpTone tone) => impl.unlock(tone.asset);

  /// Plays [tone] (skipped while the previous sound still starts up).
  static void play(LpTone tone) {
    if (!impl.play(tone.asset, tone.gain, minGap)) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Prepares the preview players (call when a sound choice is shown).
  static void preload() =>
      impl.preload([for (final t in LpTone.values) t.asset]);

  /// Plays [tone] at once from a tap (preview): must be called
  /// synchronously in the tap handler; also unlocks the run sound and stops
  /// a preview that is still ringing.
  static void preview(LpTone tone) {
    if (!impl.preview(tone.asset, tone.gain)) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
