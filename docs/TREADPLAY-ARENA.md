# TreadPlay Arena — Plan

Stand: 2026-11-15, mit Philip abgestimmt.

Zwei Wege zu LP: **Laufen** (wie bisher) oder **Kämpfen** (Missionen + Turniere). Alles offline gegen Computer-Gegner, kein Server, kein PvP.

## Kampf

- Automatisch mit Herz-Leiste und Animation; der Spieler wählt nur die Aufstellung.
- Feld: 3 Plätze vorne, 2 hinten. Am Anfang 1 Platz, weitere über Missionen.
- Vorne greift an und nimmt Schaden. Hinten wird erst getroffen, wenn vorne alle gefallen sind; solange vorne jemand steht, nutzt hinten seine Fähigkeit.
- Werte: Stride → Angriff · Grit → Herz · Fortune → Volltreffer (×1,5) und Ausweichen · Level und Siegel zählen mit.
- Die Lebensleiste heißt **Herz**, nie „LP“ (LP = Lauf Points).
- Gangart: wer zuerst zieht (Galopp, Trab, Schritt) und Kreis-Bonus +15 %: Schritt schlägt Galopp, Galopp schlägt Trab, Trab schlägt Schritt.
- Fähigkeit von hinten (vorerst je Gangart, später je Art): Schritt heilt, Trab stärkt die vordere Reihe (+10 %), Galopp wirft (60 % Angriff).
- Höchstens 30 Runden, danach gewinnt, wer anteilig mehr Herz hat; Gleichstand = Gegner.
- **Jeder Kampf kostet Mut** (wie 3 Puste-Punkte Laufen, Grit mildert), K.o. doppelt. Salben kosten LP. Bei 0 % Mut kein Kampf. Kämpfe geben keine XP (XP nur vom Laufen).
- Yu-Gi-Oh nur als Gefühl: keine Begriffe wie Duell, Beschwören, Friedhof, keine Sterne, eigenes Kartenlayout.

## Missionen

Kampagne pro Welt, spielbar schon nur mit Mossik. Belohnung LP, Glut, Splitter, ab und zu ein Beutel. Begleiter weiter nur im Market.

Darstellung als **Missionsbaum** wie der Stufen-Tab der Schmiede: Er wächst mit jeder geschafften Mission (neue Äste, freigeschaltete Feldplätze).

## Turniere

8er-Baum, ab 3 Karten, eins pro Welt, zusätzlich zu den Missionen.

## Navigation

Neuer Tab **Arena**.

## Kampfbereich-Look (Schritt 2)

Der Arena-Tab und der Kampf heben sich vom warmen Leder der restlichen App ab: Nachtgrube aus dunklem Stein, Fackeln, Messingrand und der Gangart-Kreis als leuchtender Runenring im Boden (Grün Schritt, Türkis Trab, Orange Galopp). Die Begleiter stehen als Freisteller auf Stein-Sockeln mit Glühen in ihrer Gangart-Farbe. Der Gegner steht oben, du unten. Vorerst ist alles gemalt (CustomPainter). Die Grok-Art ersetzt das später unter festen Namen:

| Datei | Inhalt |
| --- | --- |
| `assets/arena/arena_floor.webp` | Kampfboden hochkant (1080×1920), Gegner oben, Spieler unten, Mitte frei für Runenring |
| `assets/arena/pedestal_{moss,brook,gale}.webp` | Sockel je Gangart, 512×160, transparent |
| `assets/arena/fx_hit.webp`, `fx_crit.webp`, `fx_mend.webp`, `fx_ko.webp` | Treffer, Volltreffer, Heilung, K.o.-Staub, 256×256, transparent |
| `assets/arena/orb_{moss,brook,gale}.webp` | Wurf-Geschoss je Gangart, 128×128 |
| `assets/nav/nav_arena.webp` | Tab-Icon im Stil der anderen Nav-Icons |
| `assets/companions/{art}_back.png` | Rückansicht je Art für die Spielerseite (wie Odyssey) |

Übungskämpfe in Schritt 2 kosten noch keinen Mut und bringen nichts; alle 5 Plätze sind offen. Mut-Kosten, Belohnungen und Platz-Freischaltung kommen mit den Missionen (Schritt 3).

## Mehr Begleiter

28 neue Wesen aus Odyssey (`grok/art-monsters`, `assets/monsters/ody_*.webp`, 512 px, transparent, mit Rückansicht) → 58 Arten. Vorher Namens-Check, Welt + Gangart zuteilen; fehlende Seltenheiten getönt.

## Bau-Schritte (je ein PR)

1. Kampfregeln + Engine + Tests (`lib/domain/battle.dart`)
2. Arena-Tab, Kampf-Screen mit Aufstellung und Animation
3. Missionen Welt 1, Mut-Kosten anwenden, Belohnungen
4. 28 Odyssey-Wesen einbauen
5. Missionen Welten 2–10
6. Turniere
7. Grok-Art: Arena-Hintergründe, Effekte, Bosse
