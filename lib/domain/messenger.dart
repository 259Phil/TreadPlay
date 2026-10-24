import 'dart:math';

import 'pouch.dart';

/// The four messengers, one per pouch colour, the rarest last. Which one
/// comes is the colour roll of [Pouches.colorWeight], so Fortune makes the
/// rarer ones (and their rarer pouches) more likely.
///
/// Messengers never bring companions: those only come from the Market.
///
/// The value names are save ids and asset keys from before the trademark
/// pre-check; the names players see come from l10n (Krahni, Glimmsel,
/// Sternuh) and must not be derived from these ids.
enum Messenger {
  /// Brown: a small owl with a satchel.
  ruhu(PouchColor.brown, giftGlut: 0, taskGlut: 2, taskSplinters: 3),

  /// Copper: Krahni, a raven in a leather harness.
  kolk(PouchColor.copper, giftGlut: 1, taskGlut: 3, taskSplinters: 4),

  /// Turquoise: Glimmsel, a luna moth with a lantern.
  flimm(PouchColor.turquoise, giftGlut: 1, taskGlut: 4, taskSplinters: 6),

  /// Navy: Sternuh, the star owl in brass and velvet.
  vesper(PouchColor.navy, giftGlut: 2, taskGlut: 5, taskSplinters: 8);

  const Messenger(
    this.color, {
    required this.giftGlut,
    required this.taskGlut,
    required this.taskSplinters,
  });

  /// The pouch it brings.
  final PouchColor color;

  /// Glut it adds to its pouch on a plain delivery.
  final int giftGlut;

  /// Reward of a finished task (instead of the pouch).
  final int taskGlut;
  final int taskSplinters;

  String get asset => 'assets/npc/messenger_${color.name}_$name.webp';

  static Messenger of(PouchColor c) => values[c.index];

  static Messenger? tryParse(Object? name) =>
      name is String ? values.asNameMap()[name] : null;
}

/// What a messenger visit is.
enum VisitKind {
  /// It hung its pouch on the leash (plus [Messenger.giftGlut]).
  gift,

  /// It offers a small optional task; taking the pouch instead is fine.
  task,

  /// The leash was full: it shows up, but has nowhere to hang its pouch.
  leashFull,
}

enum TaskType { walk, sweetSpotRuns, validRuns, openPouches }

/// A small optional task a messenger brought. Progress only counts after
/// it was accepted.
class MessengerTask {
  const MessengerTask({
    required this.messenger,
    required this.type,
    required this.target,
    this.progress = 0,
    this.line = 0,
  });

  final Messenger messenger;
  final TaskType type;

  /// Metres for [TaskType.walk], else a count.
  final int target;
  final int progress;

  /// Which task line the messenger said (shown on the Aushang).
  final int line;

  bool get done => progress >= target;
  double get share => (progress / target).clamp(0.0, 1.0);
  int get glut => messenger.taskGlut;
  int get splinters => messenger.taskSplinters;

  MessengerTask advanced(int by) => by <= 0
      ? this
      : MessengerTask(
          messenger: messenger,
          type: type,
          target: target,
          progress: min(target, progress + by),
          line: line,
        );

  Map<String, Object?> toJson() => {
    'messenger': messenger.name,
    'type': type.name,
    'target': target,
    if (progress > 0) 'progress': progress,
    'line': line,
  };

  static MessengerTask? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final m = Messenger.tryParse(json['messenger']);
    final t = TaskType.values.asNameMap()[json['type']];
    final target = json['target'];
    if (m == null || t == null || target is! int || target <= 0) return null;
    final p = json['progress'];
    final line = json['line'];
    return MessengerTask(
      messenger: m,
      type: t,
      target: target,
      progress: p is int ? p.clamp(0, target) : 0,
      line: line is int ? line.clamp(0, Messengers.lines - 1) : 0,
    );
  }
}

/// One visit waiting to be shown (after a run, on the summary or Home).
class MessengerVisit {
  const MessengerVisit({
    required this.messenger,
    required this.kind,
    required this.at,
    this.greet = 0,
    this.line = 0,
    this.glut = 0,
    this.task,
  });

  final Messenger messenger;
  final VisitKind kind;
  final DateTime at;

  /// Index of the greeting and of the delivery / task / leash-full line.
  final int greet;
  final int line;

  /// Glut it added (gift only; already in the case).
  final int glut;

  /// The offered task ([VisitKind.task] only).
  final MessengerTask? task;

  Map<String, Object?> toJson() => {
    'messenger': messenger.name,
    'kind': kind.name,
    'at': at.toIso8601String(),
    'greet': greet,
    'line': line,
    if (glut > 0) 'glut': glut,
    if (task case final t?) 'task': t.toJson(),
  };

  static MessengerVisit? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final m = Messenger.tryParse(json['messenger']);
    final k = VisitKind.values.asNameMap()[json['kind']];
    final at = DateTime.tryParse(json['at'] as String? ?? '');
    if (m == null || k == null || at == null) return null;
    final task = MessengerTask.tryFromJson(json['task']);
    if (k == VisitKind.task && task == null) return null;
    int idx(String key) => (json[key] is int ? json[key] as int : 0).clamp(
      0,
      Messengers.lines - 1,
    );
    final glut = json['glut'];
    return MessengerVisit(
      messenger: m,
      kind: k,
      at: at,
      greet: idx('greet'),
      line: idx('line'),
      glut: glut is int ? max(0, glut) : 0,
      task: task,
    );
  }
}

/// The messenger side of a save.
class MessengerState {
  const MessengerState({
    this.met = 0,
    this.day,
    this.today = 0,
    this.pending,
    this.task,
    this.done,
    this.tasksDone = 0,
    this.lastLines = const {},
  });

  /// Visits seen (lifetime, leash-full visits too): Wanderweg "meet a
  /// messenger".
  final int met;

  /// Local day ('yyyy-mm-dd') that [today] counts.
  final String? day;

  /// Visits on [day] that count toward [Messengers.dailyCap].
  final int today;

  /// The visit not yet shown (at most one).
  final MessengerVisit? pending;

  /// The one open (accepted) task.
  final MessengerTask? task;

  /// A task just finished, waiting for its "done" note.
  final MessengerTask? done;

  final int tasksDone;

  /// Last line index per pool ('ruhu.greet', …), so a line never repeats
  /// right away.
  final Map<String, int> lastLines;

  int todayOn(String dayKey) => day == dayKey ? today : 0;

  MessengerState copyWith({
    int? met,
    String? day,
    int? today,
    MessengerVisit? Function()? pending,
    MessengerTask? Function()? task,
    MessengerTask? Function()? done,
    int? tasksDone,
    Map<String, int>? lastLines,
  }) => MessengerState(
    met: met ?? this.met,
    day: day ?? this.day,
    today: today ?? this.today,
    pending: pending == null ? this.pending : pending(),
    task: task == null ? this.task : task(),
    done: done == null ? this.done : done(),
    tasksDone: tasksDone ?? this.tasksDone,
    lastLines: lastLines ?? this.lastLines,
  );

  Map<String, Object?> toJson() => {
    'met': met,
    if (day case final d?) 'day': d,
    if (today > 0) 'today': today,
    if (pending case final p?) 'pending': p.toJson(),
    if (task case final t?) 'task': t.toJson(),
    if (done case final t?) 'done': t.toJson(),
    if (tasksDone > 0) 'tasksDone': tasksDone,
    if (lastLines.isNotEmpty) 'lastLines': lastLines,
  };

  /// Lenient: anything it can't read is left out, never an error.
  factory MessengerState.fromJson(Map<String, Object?> json) {
    int read(String k) => json[k] is int ? max(0, json[k] as int) : 0;
    final raw = json['lastLines'];
    return MessengerState(
      met: read('met'),
      day: json['day'] is String ? json['day'] as String : null,
      today: read('today'),
      pending: MessengerVisit.tryFromJson(json['pending']),
      task: MessengerTask.tryFromJson(json['task']),
      done: MessengerTask.tryFromJson(json['done']),
      tasksDone: read('tasksDone'),
      lastLines: {
        if (raw is Map)
          for (final e in raw.entries)
            if ((e.key, e.value) case (final String k, final int v))
              k: v.clamp(0, Messengers.lines - 1),
      },
    );
  }
}

/// Messenger rules. Numbers are start values, kept deliberately uneven.
class Messengers {
  /// Chance of a messenger after a valid run that used a full Breath tank
  /// and found no pouch of its own. Less Breath, smaller chance.
  static const double fullTankChance = .13;

  /// A run must be valid and at least this long.
  static const double minDistanceM = 1000;

  /// Messengers come from this waymark on (the Forge).
  static const int fromWaymark = 2;

  /// From this waymark on, the first messenger ever is sure (the next
  /// waymark asks to meet one).
  static const int sureFromWaymark = 5;

  /// Visits a day that count (leash-full visits don't).
  static const int dailyCap = 2;

  /// Share of visits that bring a task instead of the pouch (when no task
  /// is open).
  static const double taskShare = .2;

  /// Lines per pool (greetings, deliveries, tasks, leash full, done).
  static const int lines = 6;

  /// [fullTankChance] times the share of one tank used, times the Fortune
  /// factor; never above 100 %.
  static double chance({
    required double breathUsed,
    required int tankSize,
    double fortuneFactor = 1,
  }) {
    if (breathUsed <= 0 || tankSize <= 0) return 0;
    final share = min(1.0, breathUsed / tankSize);
    return min(1.0, fullTankChance * share * fortuneFactor);
  }

  /// Which messenger comes: a colour roll among [unlocked] with the pouch
  /// formula [Pouches.colorWeight] (no "new colour first" rule here).
  static Messenger pick(
    List<PouchColor> unlocked,
    Random random, {
    double fortuneFactor = 1,
  }) {
    final total = unlocked.fold(
      0.0,
      (n, c) => n + Pouches.colorWeight(c, fortuneFactor),
    );
    var roll = random.nextDouble() * total;
    for (final c in unlocked) {
      roll -= Pouches.colorWeight(c, fortuneFactor);
      if (roll < 0) return Messenger.of(c);
    }
    return Messenger.of(unlocked.last);
  }

  /// Task targets by rarity (brown … navy).
  static const Map<TaskType, List<int>> targets = {
    TaskType.walk: [2000, 3000, 4000, 5000],
    TaskType.sweetSpotRuns: [1, 1, 2, 2],
    TaskType.validRuns: [2, 2, 3, 3],
    TaskType.openPouches: [1, 1, 2, 2],
  };

  static MessengerTask rollTask(Messenger m, Random random, {int line = 0}) {
    final type = TaskType.values[random.nextInt(TaskType.values.length)];
    return MessengerTask(
      messenger: m,
      type: type,
      target: targets[type]![m.index],
      line: line,
    );
  }

  /// A line index for [pool] that is not the last one used there.
  static int pickLine(String pool, Map<String, int> last, Random random) {
    final prev = last[pool];
    if (prev == null) return random.nextInt(lines);
    final i = random.nextInt(lines - 1);
    return i >= prev ? i + 1 : i;
  }

  /// Local day key of [t].
  static String dayKey(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }
}
