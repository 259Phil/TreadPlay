import 'package:flutter/material.dart';

import '../../domain/pouch.dart';
import '../../theme.dart';
import '../../ui/skin.dart';
import '../../widgets/pouch_art.dart';
import '../../widgets/stock_art.dart';

/// Messenger concept mockups, chosen at build time with
/// `--dart-define=TREADPLAY_NPC=A|B|C`. Empty (default) shows nothing.
/// Mockups only – not final, no game logic, no rewards are granted.
const kNpcVariant = String.fromEnvironment('TREADPLAY_NPC');

const _ink = Color(0xFF3A2414);
const _inkSoft = Color(0xFF6B5034);
const _wax = Color(0xFF9E2B25);

bool _de(BuildContext c) => Localizations.localeOf(c).languageCode == 'de';
String _t(BuildContext c, String de, String en) => _de(c) ? de : en;

/// The Home-screen marker for the mock variant: where a waiting messenger
/// shows up. Tapping it opens the letter.
class MessengerHomeHint extends StatelessWidget {
  const MessengerHomeHint({super.key});

  @override
  Widget build(BuildContext context) => switch (kNpcVariant) {
    'A' => _CourierHint(onTap: () => _open(context, const _CourierLetter())),
    'B' => _BoardHint(onTap: () => _open(context, const _BoardLetter())),
    'C' => _CreatureHint(onTap: () => _open(context, const _CreatureNote())),
    _ => const SizedBox.shrink(),
  };

  static Future<void> _open(BuildContext context, Widget letter) =>
      showDialog<void>(
        context: context,
        barrierColor: const Color(0xB3000000),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: letter,
        ),
      );
}

// ----------------------------------------------------------------- shared

/// Round painted portrait in a brass ring.
class _Medallion extends StatelessWidget {
  const _Medallion(this.asset, {required this.size, this.dot = false});
  final String asset;
  final double size;
  final bool dot;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * .06),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: brassGradient,
            boxShadow: [BoxShadow(color: Color(0xAA000000), blurRadius: 6)],
          ),
          child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
        ),
        if (dot) const Positioned(right: -2, top: -2, child: _WaxDot(size: 18)),
      ],
    ),
  );
}

class _WaxDot extends StatelessWidget {
  const _WaxDot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _wax,
      border: Border.all(color: const Color(0xFF5E1612), width: 1.5),
      boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 3)],
    ),
  );
}

/// Parchment sheet in a brass/leather frame: the letter body.
class _Paper extends StatelessWidget {
  const _Paper({required this.child});
  final Widget child;

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
          gradient: const RadialGradient(
            center: Alignment(-.2, -.4),
            radius: 1.3,
            colors: [Color(0xFFF3E6C6), Color(0xFFE2CB9A), Color(0xFFC6A86E)],
            stops: [0, .65, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: child,
        ),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text, {this.sub});
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final skin = TreadSkin.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: skin.display(20, color: _ink)),
        if (sub != null)
          Text(
            sub!,
            style: const TextStyle(
              color: _inkSoft,
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

Widget _body(String text) => Text(
  text,
  style: const TextStyle(
    color: _ink,
    fontSize: 14.5,
    height: 1.35,
    fontStyle: FontStyle.italic,
  ),
);

/// Ink-ruled box with a task line and progress.
class _Task extends StatelessWidget {
  const _Task({required this.label, required this.progress, this.value});
  final String label;
  final double progress;
  final String? value;

  @override
  Widget build(BuildContext context) => Container(
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
                label,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
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
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0x336B5034),
            color: const Color(0xFF9A7A3E),
          ),
        ),
      ],
    ),
  );
}

/// "Reward" row: painted items with counts.
class _Rewards extends StatelessWidget {
  const _Rewards(this.items);
  final List<(Widget, String)> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        _t(context, 'Lohn', 'Reward'),
        style: const TextStyle(
          color: _inkSoft,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .6,
        ),
      ),
      const SizedBox(width: 10),
      for (final (art, label) in items) ...[
        art,
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
      ],
    ],
  );
}

Widget _buttons(BuildContext context, String primary, {String? secondary}) =>
    Row(
      children: [
        if (secondary != null) ...[
          Expanded(
            child: SkinButton.secondary(
              onPressed: () => Navigator.of(context).pop(),
              label: secondary,
              height: 44,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: SkinButton(
            onPressed: () => Navigator.of(context).pop(),
            label: primary,
            height: 44,
          ),
        ),
      ],
    );

Widget _footnote(String text) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(color: _inkSoft, fontSize: 11),
  ),
);

/// Leather speech plate next to a Home marker.
class _HintPlate extends StatelessWidget {
  const _HintPlate(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 170),
    padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
    decoration: BoxDecoration(
      color: const Color(0xEE241912),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: TreadColors.brassDark),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: TreadColors.text,
        fontSize: 12.5,
        height: 1.25,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ------------------------------------------------------- A: the courier

const _wendel = 'assets/npc/npc_a_wendel.webp';

class _CourierHint extends StatelessWidget {
  const _CourierHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Wendel',
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Medallion(_wendel, size: 64, dot: true),
          const SizedBox(width: 8),
          _HintPlate(
            _t(
              context,
              'Wendel wartet am Tor. Er hat einen Brief für dich.',
              'Wendel waits at the gate. He has a letter for you.',
            ),
          ),
        ],
      ),
    ),
  );
}

class _CourierLetter extends StatelessWidget {
  const _CourierLetter();

  @override
  Widget build(BuildContext context) => _Paper(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _Medallion(_wendel, size: 84),
            const SizedBox(width: 12),
            Expanded(
              child: _Title(
                _t(context, 'Brief von Wendel', 'A letter from Wendel'),
                sub: _t(
                  context,
                  'Reisender Bote · 3. Brief',
                  'Travelling courier · letter 3',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _body(
          _t(
            context,
            '„Drei Täler bin ich gelaufen, und überall fragt man nach dir. '
                'Halte morgen dein Tempo, dann lasse ich dir da, was in meiner '
                'Tasche klappert.“',
            '“Three valleys I walked, and everywhere they ask about you. '
                'Keep your pace tomorrow and I’ll leave you what rattles in '
                'my satchel.”',
          ),
        ),
        const SizedBox(height: 12),
        _Task(
          label: _t(context, '2 km im Sweet Spot', '2 km in the Sweet Spot'),
          value: '0,6 / 2 km',
          progress: .3,
        ),
        const SizedBox(height: 10),
        _Rewards([
          (const PouchArt(color: PouchColor.copper, size: 34), ''),
          (const GlutIcon(size: 26), '×2'),
        ]),
        const SizedBox(height: 14),
        _buttons(
          context,
          _t(context, 'Annehmen', 'Accept'),
          secondary: _t(context, 'Später', 'Later'),
        ),
        _footnote(
          _t(
            context,
            'Kommt nach einem Lauf · ein Brief zur Zeit · keine Frist',
            'Arrives after a run · one letter at a time · no deadline',
          ),
        ),
      ],
    ),
  );
}

// ----------------------------------------------- B: the cast of places

class _Npc {
  const _Npc(this.asset, this.name, this.placeDe, this.placeEn);
  final String asset;
  final String name;
  final String placeDe;
  final String placeEn;
}

const _cast = [
  _Npc('assets/npc/npc_b_brannik.webp', 'Brannik', 'Schmiede', 'Forge'),
  _Npc('assets/npc/npc_b_fleur.webp', 'Fleur', 'Markt', 'Market'),
  _Npc('assets/npc/npc_b_quill.webp', 'Quill', 'Wanderweg', 'Trail'),
  _Npc('assets/npc/npc_b_hollis.webp', 'Hollis', 'Gehege', 'Den'),
];

class _BoardHint extends StatelessWidget {
  const _BoardHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: _t(context, 'Aushang', 'Notice board'),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: const Color(0xEE241912),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TreadColors.brassDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, n) in _cast.indexed)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _Medallion(n.asset, size: 36, dot: i == 0),
              ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t(context, 'Aushang', 'Notice board'),
                  style: TreadSkin.of(
                    context,
                  ).display(13, color: TreadColors.brass),
                ),
                Text(
                  _t(context, '1 neuer Auftrag', '1 new task'),
                  style: const TextStyle(
                    color: TreadColors.text,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _BoardLetter extends StatefulWidget {
  const _BoardLetter();

  @override
  State<_BoardLetter> createState() => _BoardLetterState();
}

class _BoardLetterState extends State<_BoardLetter> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final n = _cast[_sel];
    final (body, task, value, progress, rewards, cta) = switch (_sel) {
      0 => (
        _t(
          context,
          '„Meine Esse wird kalt. Bring mir 3 Glut aus deinen Läufen, '
              'und ich gieße dir daraus 5 Splitter.“',
          '“My hearth is going cold. Bring me 3 Glut from your runs and '
              'I’ll cast you 5 splinters from it.”',
        ),
        _t(context, '3 Glut abgeben', 'Hand over 3 Glut'),
        '2 / 3',
        2 / 3,
        <(Widget, String)>[(const SplitterIcon(size: 26), '×5')],
        _t(context, 'Glut abgeben', 'Hand over'),
      ),
      1 => (
        _t(
          context,
          '„Ein neuer Gefährte sucht ein Zuhause. Hol ihn aus meinem Markt, '
              'und ich lege dir etwas Glänzendes dazu.“',
          '“A new companion is looking for a home. Take one from my market '
              'and I’ll add something shiny.”',
        ),
        _t(context, '1 Gefährten kaufen', 'Buy 1 companion'),
        '0 / 1',
        0.0,
        <(Widget, String)>[(const LpCoin(size: 22), '60 LP')],
        _t(context, 'Zum Markt', 'To the market'),
      ),
      2 => (
        _t(
          context,
          '„Hinter der dritten Wegmarke fehlt mir ein Stück Karte. '
              'Lauf 3 km, und erzähl mir, was du siehst.“',
          '“Past the third waymark my map has a gap. Walk 3 km and tell '
              'me what you see.”',
        ),
        _t(context, '3 km laufen', 'Walk 3 km'),
        '1,2 / 3 km',
        .4,
        <(Widget, String)>[
          (const PouchArt(color: PouchColor.copper, size: 34), ''),
        ],
        _t(context, 'Annehmen', 'Accept'),
      ),
      _ => (
        _t(
          context,
          '„Die Kleinen werden unruhig. Nimm drei verschiedene mit hinaus, '
              'je einen Lauf, dann schlafen sie besser.“',
          '“The little ones are restless. Take three different ones out, '
              'one run each, and they’ll sleep better.”',
        ),
        _t(context, '3 Gefährten je 1 Lauf', '3 companions, 1 run each'),
        '1 / 3',
        1 / 3,
        <(Widget, String)>[(const GlutIcon(size: 26), '×3')],
        _t(context, 'Annehmen', 'Accept'),
      ),
    };
    return _Paper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, c) in _cast.indexed)
                GestureDetector(
                  onTap: () => setState(() => _sel = i),
                  child: Opacity(
                    opacity: i == _sel ? 1 : .55,
                    child: Column(
                      children: [
                        _Medallion(
                          c.asset,
                          size: i == _sel ? 66 : 54,
                          dot: i == 0 && _sel != 0,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          c.name,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: i == _sel
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const Divider(color: Color(0x886B5034), height: 18),
          _Title(n.name, sub: _de(context) ? n.placeDe : n.placeEn),
          const SizedBox(height: 8),
          SizedBox(height: 82, child: _body(body)),
          _Task(label: task, value: value, progress: progress),
          const SizedBox(height: 10),
          _Rewards(rewards),
          const SizedBox(height: 14),
          _buttons(context, cta, secondary: _t(context, 'Später', 'Later')),
          _footnote(
            _t(
              context,
              'Je Ort ein Auftrag · neue Aufträge nach Läufen · keine Frist',
              'One task per place · new ones after runs · no deadline',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------- C: creature messengers

const _kolk = 'assets/npc/npc_c_kolk.webp';
const _ruhu = 'assets/npc/npc_c_ruhu.webp';
const _flimm = 'assets/npc/npc_c_flimm.webp';

class _CreatureHint extends StatelessWidget {
  const _CreatureHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Kolk',
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(_kolk, height: 96),
              const Positioned(right: 0, top: 4, child: _WaxDot(size: 16)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _HintPlate(
              _t(
                context,
                'Kraa! Kolk hat etwas für dich.',
                'Kraa! Kolk brought you something.',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CreatureNote extends StatelessWidget {
  const _CreatureNote();

  @override
  Widget build(BuildContext context) => _Paper(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(_kolk, height: 112),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Title(
                  _t(context, 'Kolk ist gelandet', 'Kolk has landed'),
                  sub: _t(
                    context,
                    'Rabe · bringt Funde vom Wegrand',
                    'Raven · brings finds from the wayside',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _body(
          _t(
            context,
            '„Kraa! Lag am Wegrand, glänzte, gehört jetzt dir. '
                'Bleib im Takt, dann komm ich wieder.“',
            '“Kraa! Lay by the path, it shone, now it’s yours. '
                'Keep the beat and I’ll be back.”',
          ),
        ),
        const SizedBox(height: 12),
        _Rewards([
          (const GlutIcon(size: 26), '×1'),
          (const SplitterIcon(size: 26), '×2'),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x886B5034)),
          ),
          child: Row(
            children: [
              Image.asset(_ruhu, height: 34),
              const SizedBox(width: 4),
              Image.asset(_flimm, height: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t(
                    context,
                    'Abends fliegt Ruhu, nachts Flimm. Wer kommt, hängt '
                        'von Tageszeit und Fortune ab.',
                    'Ruhu flies in the evening, Flimm at night. Who comes '
                        'depends on time of day and Fortune.',
                  ),
                  style: const TextStyle(color: _inkSoft, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buttons(context, _t(context, 'Nehmen', 'Take it')),
        _footnote(
          _t(
            context,
            'Landet nach einem Lauf · Geschenk sofort · max. 1 pro Tag',
            'Lands after a run · gift right away · at most 1 a day',
          ),
        ),
      ],
    ),
  );
}
