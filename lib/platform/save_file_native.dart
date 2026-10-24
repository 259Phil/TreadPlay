import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes the save file into the app folder and offers it via the share sheet
/// (Files, AirDrop, mail …). Nothing is uploaded by the app.
Future<void> deliverSaveFile(
  String name,
  Uint8List bytes, {
  required String subject,
}) async {
  final docs = (await getApplicationDocumentsDirectory()).path;
  final dir = Directory('$docs/exports');
  await dir.create(recursive: true);
  final out = File('${dir.path}/$name');
  await out.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(out.path)], subject: subject),
  );
}

/// Only true on Web, where the file lands in the browser's downloads.
bool get deliversByDownload => false;

/// "Delete save game": removes every save copy the app keeps in its own
/// storage. Files the player saved elsewhere are not touched.
Future<int> deleteLocalSaveCopies() async {
  Directory? docs;
  Directory? temp;
  try {
    docs = await getApplicationDocumentsDirectory();
  } catch (_) {}
  try {
    temp = await getTemporaryDirectory();
  } catch (_) {}
  return deleteSaveCopiesIn(
    docs: docs,
    temp: temp,
    sandboxed: Platform.isAndroid || Platform.isIOS,
  );
}

final RegExp _saveName = RegExp(r'^treadplay-save-.*\.json$');

/// Deletes the app-internal save copies below [docs] and [temp] and returns
/// how many files went:
/// - `docs/exports/treadplay-save-*.json`: the copy written on every export
///   (the folder goes too once it is empty);
/// - only when [sandboxed] (Android, iOS: both folders belong to the app):
///   `temp/share_plus/` (Android share cache), `temp/file_picker/` (Android
///   copies of picked import files) and loose `*.json` files in `temp`
///   (iOS moves picked import files there).
Future<int> deleteSaveCopiesIn({
  required Directory? docs,
  required Directory? temp,
  required bool sandboxed,
}) async {
  var removed = 0;
  Future<void> drop(FileSystemEntity e) async {
    try {
      if (e is File) {
        await e.delete();
        removed++;
      } else if (e is Directory) {
        final files = await e
            .list(recursive: true)
            .where((f) => f is File)
            .length;
        await e.delete(recursive: true);
        removed += files;
      }
    } catch (_) {}
  }

  if (docs != null) {
    final exports = Directory('${docs.path}/exports');
    if (await exports.exists()) {
      await for (final e in exports.list()) {
        if (e is File && _saveName.hasMatch(e.uri.pathSegments.last)) {
          await drop(e);
        }
      }
      try {
        if (await exports.list().isEmpty) await exports.delete();
      } catch (_) {}
    }
  }
  if (sandboxed && temp != null && await temp.exists()) {
    for (final name in ['share_plus', 'file_picker']) {
      final dir = Directory('${temp.path}/$name');
      if (await dir.exists()) await drop(dir);
    }
    await for (final e in temp.list()) {
      if (e is File && e.path.toLowerCase().endsWith('.json')) await drop(e);
    }
  }
  return removed;
}
