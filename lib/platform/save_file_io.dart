import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'save_file.dart';

/// Picking and handing out save files; overridden in tests.
class SaveFileIo {
  const SaveFileIo();

  /// Bytes of a picked `.json` file, or null when the picker was closed.
  Future<Uint8List?> pick() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final file = picked.files.single;
    return file.bytes ?? await file.xFile.readAsBytes();
  }

  Future<void> deliver(
    String name,
    Uint8List bytes, {
    required String subject,
  }) => deliverSaveFile(name, bytes, subject: subject);

  /// Removes the save copies kept in the app's own storage (export copy,
  /// share and picker caches). Never touches files saved elsewhere.
  Future<int> deleteLocalCopies() => deleteLocalSaveCopies();

  /// True on Web: the file is downloaded instead of shared.
  bool get downloads => deliversByDownload;
}

final saveFileIoProvider = Provider<SaveFileIo>((ref) => const SaveFileIo());
