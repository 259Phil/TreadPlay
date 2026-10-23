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
