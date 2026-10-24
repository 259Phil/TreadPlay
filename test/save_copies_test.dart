import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:treadplay/platform/save_file_native.dart';

void main() {
  late Directory root;
  late Directory docs;
  late Directory temp;

  setUp(() {
    root = Directory.systemTemp.createTempSync('tp-copies-');
    docs = Directory('${root.path}/docs')..createSync();
    temp = Directory('${root.path}/tmp')..createSync();
  });
  tearDown(() => root.deleteSync(recursive: true));

  File put(String path) => File('${root.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync('{}');

  test('removes the export copy and the share/picker caches', () async {
    final export = put('docs/exports/treadplay-save-2026-10-24T08-00-00.json');
    final shared = put(
      'tmp/share_plus/treadplay-save-2026-10-24T08-00-00.json',
    );
    final picked = put('tmp/file_picker/1729756800/my-backup.json');
    final iosPick = put('tmp/renamed.json');
    final other = put('docs/notes.txt');
    final tempOther = put('tmp/flutter_engine.bin');

    final n = await deleteSaveCopiesIn(docs: docs, temp: temp, sandboxed: true);

    expect(n, 4);
    for (final f in [export, shared, picked, iosPick]) {
      expect(f.existsSync(), isFalse, reason: f.path);
    }
    expect(Directory('${docs.path}/exports').existsSync(), isFalse);
    expect(other.existsSync(), isTrue);
    expect(tempOther.existsSync(), isTrue);
  });

  test('keeps foreign files in the exports folder', () async {
    put('docs/exports/treadplay-save-a.json');
    final foreign = put('docs/exports/holiday.pdf');
    final n = await deleteSaveCopiesIn(docs: docs, temp: temp, sandboxed: true);
    expect(n, 1);
    expect(foreign.existsSync(), isTrue);
  });

  test('outside a sandbox the temp folder is left alone', () async {
    final shared = put('tmp/share_plus/treadplay-save-a.json');
    final loose = put('tmp/x.json');
    final n = await deleteSaveCopiesIn(
      docs: docs,
      temp: temp,
      sandboxed: false,
    );
    expect(n, 0);
    expect(shared.existsSync(), isTrue);
    expect(loose.existsSync(), isTrue);
  });

  test('works when no copy and no folder exists', () async {
    expect(
      await deleteSaveCopiesIn(docs: docs, temp: temp, sandboxed: true),
      0,
    );
    expect(
      await deleteSaveCopiesIn(docs: null, temp: null, sandboxed: true),
      0,
    );
    temp.deleteSync();
    expect(
      await deleteSaveCopiesIn(docs: docs, temp: temp, sandboxed: true),
      0,
    );
  });
}
