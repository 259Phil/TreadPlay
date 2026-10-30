import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('treadplay/screen_wake');

Future<void> _set(bool on) async {
  try {
    await _channel.invokeMethod<void>('set', on);
  } catch (_) {
    // No native side (tests, desktop): the run still works, just without lock.
  }
}

void enable() => _set(true);
void disable() => _set(false);
