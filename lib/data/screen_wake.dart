import 'screen_wake_native.dart'
    if (dart.library.js_interop) 'screen_wake_web.dart'
    as impl;

/// Keeps the screen on during a run (Web: Screen Wake Lock API; Android:
/// FLAG_KEEP_SCREEN_ON; iOS: idle timer off). Location updates pause when
/// the screen locks, so this protects the GPS track.
abstract final class ScreenWake {
  static void enable() => impl.enable();
  static void disable() => impl.disable();
}
