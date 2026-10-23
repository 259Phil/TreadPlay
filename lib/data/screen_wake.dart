import 'screen_wake_stub.dart'
    if (dart.library.js_interop) 'screen_wake_web.dart'
    as impl;

/// Keeps the screen on during a run where the platform allows it (Web:
/// Screen Wake Lock API). Browsers pause location updates when the screen
/// locks or the tab is hidden, so this protects the GPS track.
abstract final class ScreenWake {
  static void enable() => impl.enable();
  static void disable() => impl.disable();
}
