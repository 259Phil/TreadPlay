import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/messenger.dart';
import '../../domain/pouch.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../../state/providers.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/format.dart';
import '../../widgets/pouch_art.dart';
import '../../widgets/stock_art.dart';

const _ink = Color(0xFF3A2414);
const _inkSoft = Color(0xFF6B5034);

// ------------------------------------------------------------------ texts

/// The name players see; the enum value names are save ids only.
String messengerName(Messenger m) => switch (m) {
  Messenger.ruhu => 'Ruhu',
  Messenger.kolk => 'Krahni',
  Messenger.flimm => 'Glimmsel',
  Messenger.vesper => 'Sternuh',
};

String messengerTitle(AppLocalizations l, Messenger m) => switch (m) {
  Messenger.ruhu => l.msgTitleRuhu,
  Messenger.kolk => l.msgTitleKolk,
  Messenger.flimm => l.msgTitleFlimm,
  Messenger.vesper => l.msgTitleVesper,
};

String messengerRank(AppLocalizations l, Messenger m) => switch (m.color) {
  PouchColor.brown => l.msgRankBrown,
  PouchColor.copper => l.msgRankCopper,
  PouchColor.turquoise => l.msgRankTurquoise,
  PouchColor.navy => l.msgRankNavy,
};

String messengerGreet(AppLocalizations l, Messenger m, int i) => switch (m) {
  Messenger.ruhu => l.msgGreetRuhu('$i'),
  Messenger.kolk => l.msgGreetKolk('$i'),
  Messenger.flimm => l.msgGreetFlimm('$i'),
  Messenger.vesper => l.msgGreetVesper('$i'),
};

String messengerGiftLine(AppLocalizations l, Messenger m, int i) => switch (m) {
  Messenger.ruhu => l.msgGiftRuhu('$i'),
  Messenger.kolk => l.msgGiftKolk('$i'),
  Messenger.flimm => l.msgGiftFlimm('$i'),
  Messenger.vesper => l.msgGiftVesper('$i'),
};

String messengerTaskLine(AppLocalizations l, Messenger m, int i) => switch (m) {
  Messenger.ruhu => l.msgTaskRuhu('$i'),
  Messenger.kolk => l.msgTaskKolk('$i'),
  Messenger.flimm => l.msgTaskFlimm('$i'),
  Messenger.vesper => l.msgTaskVesper('$i'),
};

String taskLabel(BuildContext context, MessengerTask t) {
  final l = AppLocalizations.of(context);
  return switch (t.type) {
    TaskType.walk => l.msgTaskWalk(formatKm(context, t.target.toDouble())),
    TaskType.sweetSpotRuns => l.msgTaskSweet(t.target),
    TaskType.validRuns => l.msgTaskRuns(t.target),
    TaskType.openPouches => l.msgTaskOpen(t.target),
  };
}

String taskValue(BuildContext context, MessengerTask t) {
  final l = AppLocalizations.of(context);
  return t.type == TaskType.walk
      ? l.msgProgressKm(
          formatKm(context, t.progress.toDouble()),
          formatKm(context, t.target.toDouble()),
        )
      : l.msgProgress(t.progress, t.target);
}

// ------------------------------------------------------------- showing

/// Shows what the messengers have waiting (a visit, then a "task done"
/// note), one popup at a time. Placed on the run summary and on Home.
class MessengerWatcher extends ConsumerStatefulWidget {
  const MessengerWatcher({super.key});

  @override
  ConsumerState<MessengerWatcher> createState() => _MessengerWatcherState();
}

class _MessengerWatcherState extends ConsumerState<MessengerWatcher> {
  /// The watcher whose popup is up (Home and the summary share one).
  static _MessengerWatcherState? _showing;

  @override
  void dispose() {
    if (_showing == this) _showing = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(gameProvider.select((g) => g.messengers));
    if (_showing == null && (m.pending != null || m.done != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
    return const SizedBox.shrink();
  }

  Future<void> _show() async {
    if (_showing != null || !mounted) return;
    if (ref.read(runControllerProvider) != null) return;
    final m = ref.read(gameProvider).messengers;
    final notifier = ref.read(gameProvider.notifier);
    _showing = this;
    try {
      if (m.pending case final v?) {
        final r = await showMessengerDialog<_Choice>(
          context,
          MessengerLetter.visit(v),
        );
        if (v.kind == VisitKind.task) {
          r == _Choice.accept
              ? notifier.acceptMessengerTask()
              : notifier.declineMessengerTask();
        } else {
          notifier.dismissMessenger();
        }
        if (r == _Choice.leash && mounted) context.push(AppRoutes.pouches);
      } else if (m.done case final t?) {
        await showMessengerDialog<_Choice>(context, MessengerLetter.done(t));
        notifier.dismissMessengerDone();
      }
    } finally {
      if (_showing == this) _showing = null;
    }
  }
}

enum _Choice { accept, decline, close, leash }

Future<T?> showMessengerDialog<T>(BuildContext context, Widget letter) =>
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xB3000000),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: letter,
        ),
      ),
    );

// --------------------------------------------------------------- letter

enum _Mode { visit, done, open }

/// The one no-scroll letter of a messenger: who came, its lines and what
/// it brings, offers or paid.
class MessengerLetter extends StatelessWidget {
  const MessengerLetter.visit(MessengerVisit this.visit, {super.key})
    : task = null,
      _mode = _Mode.visit;

  const MessengerLetter.done(MessengerTask this.task, {super.key})
    : visit = null,
      _mode = _Mode.done;

  /// The open task, from the Aushang.
  const MessengerLetter.open(MessengerTask this.task, {super.key})
    : visit = null,
      _mode = _Mode.open;

  final MessengerVisit? visit;
  final MessengerTask? task;
  final _Mode _mode;

  Messenger get _m => visit?.messenger ?? task!.messenger;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final skin = TreadSkin.of(context);
    final m = _m;
    final v = visit;
    final t = task ?? v?.task;
    final accent = pouchAccent(m.color);
    final (String greet, String line) = switch (_mode) {
      _Mode.visit => (
        messengerGreet(l, m, v!.greet),
        switch (v.kind) {
          VisitKind.gift => messengerGiftLine(l, m, v.line),
          VisitKind.task => messengerTaskLine(l, m, v.line),
          VisitKind.leashFull => l.msgLineFull('${v.line}'),
        },
      ),
      _Mode.done => (l.msgDoneTitle, l.msgLineDone('${t!.line}')),
      _Mode.open => (l.msgBoard, messengerTaskLine(l, m, t!.line)),
    };
    final artH = 104.0 + 10 * m.index;
    return _Paper(
      accent: accent,
      child: Column(
        key: const Key('messenger-letter'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Art(m, height: artH),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RankRibbon(text: messengerRank(l, m), color: accent),
                    const SizedBox(height: 6),
                    Text(
                      messengerTitle(l, m),
                      style: skin.display(19, color: _ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greet,
                      style: const TextStyle(
                        color: _inkSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '„$line“',
            key: const Key('messenger-line'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ..._content(context, l, m, v, t),
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    AppLocalizations l,
    Messenger m,
    MessengerVisit? v,
    MessengerTask? t,
  ) {
    Widget pouchRow({int glut = 0}) => _Items(
      label: l.msgBrings,
      items: [
        (PouchArt(color: m.color, size: 40), pouchName(l, m.color)),
        if (glut > 0) (const GlutIcon(size: 26), '×$glut'),
      ],
    );
    Widget rewardRow(MessengerTask t) => _Items(
      label: l.msgReward,
      items: [
        (const GlutIcon(size: 26), '×${t.glut}'),
        (const SplitterIcon(size: 26), '×${t.splinters}'),
      ],
    );
    final close = SkinButton(
      onPressed: () => Navigator.of(context).pop(_Choice.close),
      label: _mode == _Mode.open ? l.msgClose : l.msgThanks,
      height: 44,
    );
    final toLeash = SkinButton.secondary(
      onPressed: () => Navigator.of(context).pop(_Choice.leash),
      label: l.summaryToLeash,
      height: 44,
    );
    Widget two(Widget a, Widget b) => Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
      ],
    );
    final foot = _Foot(l.msgFootnote);
    switch (_mode) {
      case _Mode.done:
        return [
          rewardRow(t!),
          _Note(l.msgDoneNote),
          const SizedBox(height: 12),
          close,
        ];
      case _Mode.open:
        return [
          _TaskBox(task: t!),
          const SizedBox(height: 10),
          rewardRow(t),
          const SizedBox(height: 12),
          close,
        ];
      case _Mode.visit:
        switch (v!.kind) {
          case VisitKind.gift:
            return [
              pouchRow(glut: v.glut),
              const SizedBox(height: 14),
              two(toLeash, close),
              foot,
            ];
          case VisitKind.leashFull:
            return [
              _Note(l.msgLeashFullNote, key: const Key('messenger-full')),
              const SizedBox(height: 12),
              two(toLeash, close),
              foot,
            ];
          case VisitKind.task:
            return [
              Text(
                l.msgTaskOptional.toUpperCase(),
                style: const TextStyle(
                  color: _inkSoft,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 4),
              _TaskBox(task: t!),
              const SizedBox(height: 8),
              rewardRow(t),
              _Note(l.msgTaskNote),
              const SizedBox(height: 12),
              two(
                SkinButton.secondary(
                  key: const Key('messenger-decline'),
                  onPressed: () => Navigator.of(context).pop(_Choice.decline),
                  label: l.msgPouchInstead,
                  height: 44,
                ),
                SkinButton(
                  key: const Key('messenger-accept'),
                  onPressed: () => Navigator.of(context).pop(_Choice.accept),
                  label: l.msgAccept,
                  height: 44,
                ),
              ),
              foot,
            ];
        }
    }
  }
}

// -------------------------------------------------------- Home: Aushang

/// The small notice on Home, only while a messenger task is open: that
/// messenger's portrait, its task line and the progress. Tap for details.
class MessengerNotice extends ConsumerWidget {
  const MessengerNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(gameProvider.select((g) => g.messengers.task));
    if (t == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final m = t.messenger;
    return Semantics(
      button: true,
      label: '${l.msgBoard} ${messengerName(m)}',
      child: GestureDetector(
        key: const Key('messenger-notice'),
        onTap: () =>
            showMessengerDialog<void>(context, MessengerLetter.open(t)),
        child: Container(
          height: 58,
          padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
          decoration: BoxDecoration(
            color: const Color(0xEE241912),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TreadColors.brassDark),
            boxShadow: const [
              BoxShadow(color: Color(0x99000000), blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              _Medallion(m, size: 46),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.msgBoard.toUpperCase()} · ${messengerName(m)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: TreadColors.brass,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          taskValue(context, t),
                          style: const TextStyle(
                            color: TreadColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '„${messengerTaskLine(l, m, t.line)}“ ${taskLabel(context, t)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TreadColors.text,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: t.share,
                        minHeight: 4,
                        backgroundColor: const Color(0x33E8D9B5),
                        color: pouchAccent(m.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- pieces

/// The painted messenger, rarer ones with a soft glow behind.
class _Art extends StatelessWidget {
  const _Art(this.m, {required this.height});
  final Messenger m;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: height * 1.05,
    height: height,
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (m.index >= 2)
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  pouchAccent(m.color).withValues(alpha: .55),
                  pouchAccent(m.color).withValues(alpha: 0),
                ],
              ),
            ),
            child: SizedBox.square(dimension: height),
          ),
        Image.asset(m.asset, height: height, fit: BoxFit.contain),
      ],
    ),
  );
}

class _Medallion extends StatelessWidget {
  const _Medallion(this.m, {required this.size});
  final Messenger m;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * .06),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: brassGradient,
    ),
    child: ClipOval(
      child: ColoredBox(
        color: const Color(0xFFE9D7AE),
        child: Padding(
          padding: EdgeInsets.all(size * .05),
          child: Image.asset(m.asset, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}

class _RankRibbon extends StatelessWidget {
  const _RankRibbon({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 2, 8, 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .22),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color),
    ),
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _ink,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

/// Parchment sheet in a brass frame with a rarity-coloured inner line.
class _Paper extends StatelessWidget {
  const _Paper({required this.child, required this.accent});
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: brassGradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 16)],
    ),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: accent, width: 2),
          gradient: const RadialGradient(
            center: Alignment(-.2, -.4),
            radius: 1.3,
            colors: [Color(0xFFF3E6C6), Color(0xFFE2CB9A), Color(0xFFC6A86E)],
            stops: [0, .65, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: child,
        ),
      ),
    ),
  );
}

class _TaskBox extends StatelessWidget {
  const _TaskBox({required this.task});
  final MessengerTask task;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('messenger-task'),
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
    decoration: BoxDecoration(
      color: const Color(0x22FFFFFF),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0x886B5034)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_outlined, size: 16, color: _inkSoft),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                taskLabel(context, task),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              taskValue(context, task),
              style: const TextStyle(
                color: _inkSoft,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: task.share,
            minHeight: 6,
            backgroundColor: const Color(0x336B5034),
            color: const Color(0xFF9A7A3E),
          ),
        ),
      ],
    ),
  );
}

class _Items extends StatelessWidget {
  const _Items({required this.label, required this.items});
  final String label;
  final List<(Widget, String)> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _inkSoft,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
      const SizedBox(width: 10),
      for (final (art, text) in items) ...[
        art,
        const SizedBox(width: 4),
        Flexible(
          flex: text.length,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ],
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: const TextStyle(color: _inkSoft, fontSize: 12.5, height: 1.3),
    ),
  );
}

class _Foot extends StatelessWidget {
  const _Foot(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _inkSoft, fontSize: 11),
    ),
  );
}
