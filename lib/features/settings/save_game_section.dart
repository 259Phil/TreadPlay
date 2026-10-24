import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/save_game.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/save_file_io.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/format.dart';
import '../history/history_screen.dart' show formatRunDate;

/// Export, import and delete of the local save game, like GrowCall's backup
/// block: export as a file, import with an overwrite check, delete with two
/// confirmations; deleting also removes the app's own export copies.
class SaveGameSection extends ConsumerStatefulWidget {
  const SaveGameSection({super.key});

  @override
  ConsumerState<SaveGameSection> createState() => _SaveGameSectionState();
}

class _SaveGameSectionState extends ConsumerState<SaveGameSection> {
  bool _busy = false;

  void _snack(String text) {
    final m = ScaffoldMessenger.of(context);
    m.removeCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } catch (e) {
      if (mounted) _snack(AppLocalizations.of(context).saveError('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run(() async {
    final l = AppLocalizations.of(context);
    final io = ref.read(saveFileIoProvider);
    final now = ref.read(clockProvider)();
    final bytes = SaveGame.encode(ref.read(gameProvider), now);
    await io.deliver(
      SaveGame.fileName(now),
      bytes,
      subject: l.saveShareSubject,
    );
    ref.read(settingsProvider.notifier).markExported(now);
    if (mounted) _snack(io.downloads ? l.saveDownloaded : l.saveExported);
  });

  Future<void> _import() => _run(() async {
    final l = AppLocalizations.of(context);
    if (ref.read(runControllerProvider) != null) {
      _snack(l.saveErrorDuringRun);
      return;
    }
    final bytes = await ref.read(saveFileIoProvider).pick();
    if (bytes == null || !mounted) return;
    final LoadedSave save;
    try {
      save = SaveGame.decode(bytes);
    } on SaveGameException catch (e) {
      _snack(switch (e.error) {
        SaveGameError.notASave => l.saveErrorNotASave,
        SaveGameError.newerVersion => l.saveErrorNewer,
        SaveGameError.damaged => l.saveErrorDamaged,
      });
      return;
    }
    final g = save.game;
    final ok = await _confirm(
      title: l.saveImportTitle,
      body: l.saveImportSummary(
        g.companions.length,
        formatNumber(context, g.lp),
        g.runs.length,
        save.exportedAt == null
            ? '–'
            : formatRunDate(context, save.exportedAt!),
      ),
      action: l.saveReplace,
    );
    if (!ok || !mounted) return;
    final done = ref.read(gameProvider.notifier).importGame(g);
    _snack(done ? l.saveImported : l.saveErrorDuringRun);
  });

  Future<void> _wipe() => _run(() async {
    final l = AppLocalizations.of(context);
    if (ref.read(runControllerProvider) != null) {
      _snack(l.saveErrorDuringRun);
      return;
    }
    final first = await _confirm(
      title: l.saveDeleteTitle,
      body: l.saveDeleteBody,
      action: l.saveDelete,
    );
    if (!first || !mounted) return;
    final second = await _confirm(
      title: l.saveDeleteReallyTitle,
      body: l.saveDeleteReallyBody,
      action: l.saveDeletePermanently,
    );
    if (!second || !mounted) return;
    final done = ref.read(gameProvider.notifier).wipe();
    if (done) await ref.read(saveFileIoProvider).deleteLocalCopies();
    _snack(done ? l.saveDeleted : l.saveErrorDuringRun);
  });

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            style: dangerButtonStyle(context),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastExport = ref.watch(
      settingsProvider.select((s) => s.lastExportAt),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.settingsSaveGame,
                style: TreadSkin.of(context).style == TreadStyle.leather
                    ? TreadSkin.of(
                        context,
                      ).display(16, color: TreadColors.brass)
                    : theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(l.saveHint, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        ListTile(
          key: const Key('save-export'),
          leading: skinIcon(
            context,
            Icons.upload_outlined,
            SkinIcons.export,
            size: 28,
            color: TreadColors.brass,
          ),
          title: Text(l.saveExport),
          subtitle: Text(
            lastExport == null
                ? l.saveNoExportYet
                : l.saveLastExport(formatRunDate(context, lastExport)),
          ),
          enabled: !_busy,
          onTap: _export,
        ),
        ListTile(
          key: const Key('save-import'),
          leading: skinIcon(
            context,
            Icons.download_outlined,
            SkinIcons.import,
            size: 28,
            color: TreadColors.brass,
          ),
          title: Text(l.saveImport),
          subtitle: Text(l.saveImportSub),
          enabled: !_busy,
          onTap: _import,
        ),
        ListTile(
          key: const Key('save-delete'),
          leading: skinIcon(
            context,
            Icons.delete_forever_outlined,
            SkinIcons.delete,
            size: 28,
            color: TreadColors.copper,
          ),
          title: Text(
            l.saveDelete,
            style: const TextStyle(color: TreadColors.copper),
          ),
          enabled: !_busy,
          onTap: _wipe,
        ),
      ],
    );
  }
}
