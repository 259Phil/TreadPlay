import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: the save file is downloaded by the browser.
Future<void> deliverSaveFile(
  String name,
  Uint8List bytes, {
  required String subject,
}) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = name
    ..style.display = 'none';
  web.document.body?.append(a);
  a.click();
  a.remove();
  web.URL.revokeObjectURL(url);
}

bool get deliversByDownload => true;

/// Web: the app keeps no file copies (exports go to the browser's downloads,
/// picked files are only read in memory). Nothing to delete.
Future<int> deleteLocalSaveCopies() async => 0;
