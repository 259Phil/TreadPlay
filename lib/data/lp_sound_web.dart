import 'dart:js_interop';

import 'dart:ui_web' as ui_web;

import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

web.AudioContext? _ctx;
final Map<String, web.AudioBuffer> _buffers = {};
final Map<String, Future<web.AudioBuffer?>> _loading = {};
DateTime? _lastStart;
web.HTMLAudioElement? _previewEl;
final Map<String, web.HTMLAudioElement> _elements = {};

web.AudioContext? _context() {
  var ctx = _ctx;
  if (ctx != null) return ctx;
  try {
    ctx = _ctx = web.AudioContext();
  } catch (_) {
    // No Web Audio: the run works without sound.
  }
  return ctx;
}

void unlock(String asset) {
  final ctx = _context();
  if (ctx == null) return;
  try {
    // Inside the gesture: resume and play one silent frame, which is what
    // iOS Safari needs to let later, non-gesture sounds through.
    ctx.resume().toDart.catchError((Object _) => null);
    ctx.createBufferSource()
      ..buffer = ctx.createBuffer(1, 1, 22050)
      ..connect(ctx.destination)
      ..start();
  } catch (_) {}
  _load(ctx, asset);
}

Future<web.AudioBuffer?> _load(web.AudioContext ctx, String asset) {
  final have = _buffers[asset];
  if (have != null) return Future.value(have);
  return _loading[asset] ??= () async {
    try {
      final data = await rootBundle.load(asset);
      // decodeAudioData detaches the buffer it gets: hand it a copy.
      final copy = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      ).buffer.toJS;
      final b = await ctx.decodeAudioData(copy).toDart;
      _buffers[asset] = b;
      return b;
    } catch (_) {
      return null; // Missing or undecodable: stay silent.
    } finally {
      _loading.remove(asset);
    }
  }();
}

web.AudioBufferSourceNode? _start(
  web.AudioContext ctx,
  web.AudioBuffer buffer,
  double gain,
) {
  try {
    // iOS suspends the context after interruptions (call, tab switch).
    if (ctx.state != 'running') {
      ctx.resume().toDart.catchError((Object _) => null);
    }
    final g = ctx.createGain()..gain.value = gain;
    g.connect(ctx.destination);
    final src = ctx.createBufferSource()
      ..buffer = buffer
      ..connect(g)
      ..start();
    return src;
  } catch (_) {
    return null; // A missed sound is no reason to disturb the run.
  }
}

bool play(String asset, double gain, Duration minGap) {
  final ctx = _ctx;
  // Not unlocked yet: silent rather than a system click.
  if (ctx == null) return true;
  final buffer = _buffers[asset];
  if (buffer == null) {
    _load(ctx, asset);
    return true;
  }
  final now = DateTime.now();
  final last = _lastStart;
  if (last != null && now.difference(last) < minGap) return true;
  if (_start(ctx, buffer, gain) != null) _lastStart = now;
  return true;
}

web.HTMLAudioElement _element(String asset) =>
    _elements[asset] ??= web.HTMLAudioElement()
      ..src = ui_web.assetManager.getAssetUrl(asset)
      ..preload = 'auto';

/// Creates the audio elements ahead of a tap so the first preview starts
/// without a network wait (iOS may still load on the first play).
void preload(List<String> assets) {
  for (final a in assets) {
    try {
      _element(a);
    } catch (_) {}
  }
}

/// Settings preview: plays through an audio element, started synchronously
/// inside the tap, which iOS Safari allows even on a fresh page without any
/// earlier gesture. The same tap unlocks Web Audio for the run.
bool preview(String asset, double gain) {
  try {
    final el = _element(asset);
    final prev = _previewEl;
    if (prev != null) {
      prev.pause();
      if (prev != el) prev.currentTime = 0;
    }
    el
      ..volume = gain
      ..currentTime = 0;
    el.play().toDart.catchError((Object _) => null);
    _previewEl = el;
  } catch (_) {}
  unlock(asset);
  return true;
}
