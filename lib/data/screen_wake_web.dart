import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

web.WakeLockSentinel? _sentinel;
bool _wanted = false;
JSFunction? _onVisibility;

bool get _supported => (web.window.navigator as JSObject).has('wakeLock');

Future<void> _request() async {
  if (!_wanted || !_supported || web.document.hidden) return;
  if (_sentinel != null && !_sentinel!.released) return;
  try {
    _sentinel = await web.window.navigator.wakeLock.request('screen').toDart;
  } catch (_) {
    // Denied (e.g. battery saver): the run still works, just without lock.
  }
}

void enable() {
  _wanted = true;
  // The browser drops the lock when the tab is hidden; ask again on return.
  _onVisibility ??= ((web.Event _) {
    _request();
  }).toJS;
  web.document.addEventListener('visibilitychange', _onVisibility);
  _request();
}

void disable() {
  _wanted = false;
  final cb = _onVisibility;
  if (cb != null) web.document.removeEventListener('visibilitychange', cb);
  final s = _sentinel;
  _sentinel = null;
  if (s != null && !s.released) {
    s.release().toDart.catchError((Object _) => null);
  }
}
