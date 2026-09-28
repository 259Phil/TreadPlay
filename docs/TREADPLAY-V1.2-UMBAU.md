# TREADPLAY V1.2 — Devin Umbau-Plan

Stand: 2026-09-28  
Auftrag: bestehendes Treadplay-Flutter-Repo umbauen. Kein neues Spiel, kein Stackport.  
Schuhe raus. Collectible = erfundene Fantasy-Gefährten. Regal/Markt = Sammelkarten-Optik (Rahmen baut **Devin**, nicht das PNG).

Baut auf: TREADPLAY-V1.1-MASTERPLAN.md + TREADPLAY-IP-CHECK.md.  
Art: TREADPLAY-ASSET-PROMPTS.md (separat).

---

## 0. Produkt in einem Satz

Treadplay: du läufst mit **einem** erfundenen Gefährten. Echte Bewegung im Sweet Spot füllt LP. Puste sitzt im Gefährten. Sammlung als Karten im Regal. Kein Crypto, kein NFT, kein Schuh.

**Store-Name:** Treadplay  
**Unterzeile EN:** Walk with a companion.  
**Unterzeile DE:** Lauf mit einem Gefährten.  
**Startsprache:** English. Settings: EN / DE.  
**9+.** Lokal. Kein Konto. Kein Server für Saves.

---

## 0a. Pflicht-Leitplanken (jeder PR)

### Verbotene Wörter
CI-Skript erweitern. 0 Treffer in `lib/`, `assets/`, `l10n/`, Store-Texten (Wortgrenzen):

STEPN, GST, GMT, Sneaker, Walker, Jogger, Runner, Trainer, Mystery Box, Gem, Efficiency, Comfort, Resilience, Move-to-Earn, M2E, Mint, NFT, Crypto-Token, Boot, Shoe, Sohle, Cobble (außer Stein-Textur), Pikmin, Pokémon, Pokemon, Gotta, Gym, Incense, OpenSea, Wallet, Ethereum, ETH, Blockchain.

Ausnahme: Satz „No crypto.“ im Store-Text.

### Look / Verhalten
- Kein Schuh-Asset mehr referenzieren.
- Home: **ein** Gefährte steht auf dem **Weltboden** (Foto oder World-BG). Nicht schweben. Nicht auf Grau. Nicht als Riesenkarte.
- Kein Schwarm, kein AR, keine wilden Spawns auf der echten Karte.
- Keine Evolutionskette.
- Kein Token-ID, kein `#0123`, kein QR auf Karten.
- Keine fremden Screens als KI-Referenz.

### Karten-Regel
PNG = nur Wesen + transparent/grau.  
Rahmen, Name, Level, Stats, Seltenheit **nur Flutter**.

---

## 1. Was am Code bleiben darf

- Flutter-Projekt, 5-Tab-Gerüst, EN/DE arb.
- Run-Loop: Start/Stop, Dummy-Tempo-Slider + 10× (Phase A), später HealthKit/GPS.
- LP nur bei plausibler Bewegung. Stehen = 0 LP.
- Puste **pro ausgerüstetem Collectible**, Regen 1 Punkt / 90 min, kein Sammlungs-Bonus.
- Sweet-Spot-Kurve (Kern 100 %, weicher Abfall, außerhalb Breite 0 LP).
- Level 1–25, Kosten `100 × n²` LP + Lauf-XP.
- Siegel-Schmiede: 2 gleiche Level + 1–5 Glut, Fail = 1 Input → 3 Splitter, 5 Splitter = 1 Siegel L1.
- Leine 3 Klammern, 24-h-Verfall, Öffnen LP oder Einlaufen.
- Markt intern, Drift 7–9 h, **kein** Countdown.
- Inventar-Cap 12.
- CI: format, analyze, forbidden-terms, tests.

---

## 2. Rename-Tabelle (Pflicht, erster PR-Teil)

| Alt | EN UI | DE UI | Code-ID |
|---|---|---|---|
| Boot / Shoe | Companion | Gefährte | `companion` |
| Cobble | Pebble | Pebble | `pebble` |
| Stomper | Moss | Moos | `moss` |
| Strider | Brook | Bach | `brook` |
| Dasher | Gale | Bö | `gale` |
| Sohle / sole | Spirit | Mut | `spirit` |
| Schnalle | Charm | Schmuck | `charm` |
| Sockensack | Treat pouch | Leckerbeutel | `pouch` |
| Anhaben / equip | Take along | Mitnehmen | `takeAlong` |
| Garage | Shelf | Regal | `shelf` |
| assets/boots/ | — | — | `assets/companions/` |

Alte Schuh-PNGs nicht mehr laden. Ordner `boots` darf liegen bleiben, bis Assets da sind — UI darf sie nicht zeigen.

---

## 3. Katalog V1 (10 Arten × 4 Stufen = 40 Karten)

Nicht 40 Anatomien. **10 Körper**, je Common / Rare / Epic / Legendary.

Rare+ = gleiches Skelett + Extra (Kamm, Glow, Rückengrat). Legendary = größere/klarere Silhouette derselben Art.

Pro Instanz Stats ±8 % (Stride / Grit / Fortune) bei Kauf/Drop.

| id | Welt | Typ | Silhouette (kurz) |
|---|---|---|---|
| pebble | medieval | moss | Brotlaib, 6 kurze Füße, Mooshaut |
| lumen | space | brook | Langer Hals, 6 dünne Beine, Sternenpunkte |
| coil | robot | moss | Segment-Leib, 4 Stummelbeine, Fühler-Schwanz |
| gilt | rococo | brook | Hoher Bogen-Rücken, 4 schmale Beine, Puder-Flaum |
| hookfin | pirate | gale | Flacher Leib, 4 Lauf-Flossen, Hakenkamm |
| valve | steampunk | moss | Rund, 6 kurze Beine, Atem-Schlitze (kein Metallpanzer) |
| dune | egypt | gale | Keilkörper, 4 lange Beine, Sandkamm |
| brine | water | brook | Flach, 5 Flossfüße, Glasgrat |
| vine | jungle | moss | Niedrig, 6 Greiffüße, Blattkamm |
| glaze | candy | gale | Leicht, 4 dünne Beine, Glasur-Rücken |

Starter: **Pebble**, Common, Moss. Geschenkt. Unverkaufbar, bis ein zweiter Gefährte existiert.

Neue Gefährten V1: **nur Markt (LP)**. Optional sehr seltener Welt-Drop nach langer gültiger Session. **Nicht** aus dem Leckerbeutel.

---

## 4. Stats, Tempo, Puste

### Typen

| Typ | Sweet Spot |
|---|---|
| Moss | 4,5 km/h ± 2,5 |
| Brook | 7,5 km/h ± 2,5 |
| Gale | 11 km/h ± 4 |

Kurve wie V1.1. Außerhalb Breite: 0 LP, Tracking läuft.

### Werte

- **Stride** — LP je Puste-Punkt  
- **Grit** — Tank / Verbrauch  
- **Fortune** — Beutel-Farbe, NPC, Drop-Gewicht  
- **Spirit** — 0–100 % Haltbarkeit. 0 % = keine LP. Kits wie bisher (Light / Solid / Master).

Puste-Tank vor Grit: Common 6 · Rare 8 · Epic 10 · Legendary 12.

LP / Puste-Punkt Basis: 2.5 / 4.0 / 7.0 / 12.0.

Level: +~4 % Stride-Äquivalent / Stufe, Dämpfung ab 18. Cap 25.

Wechsel des Gefährten nur außerhalb eines Laufs.

---

## 5. Screens

### 5.1 Home
- Welt-BG vollflächig (unten begehbarer Boden).
- Ein ausgerüsteter Gefährte **steht auf dem Boden**, PNG mit Alpha.
- Puste-Badge am Gefährten (`6/6`).
- Eisenstange-Leine oben, 3 Klammern, Leckerbeutel.
- Dünne Metall-Leiste oben: LP + Mini-Status.
- Runder Messing-**Start** unten rechts (nicht vollbreit mittig).
- Letzte Session als kleine integrierte Karte, kein STEPN-HUD.

### 5.2 Run-Overlay
Distanz, Zeit, Tempo, LP-Ticker, Puste, Sweet-Spot-Nadel, Stop.  
Portrait des aktuellen Gefährten klein, kein Schuh-Icon.  
Nach Stop: Summary + Beutel-Chance + NPC-Blase.

### 5.3 Shelf (ex-Garage)
Kartenraster. Jede Zelle = Flutter-Rahmen + Companion-PNG.  
Rahmenfarbe = Seltenheit (Eisen / Messing / Kupfer / Messing+Glow).  
Unten auf der Zelle (Flutter-Text): Name, Typ, Level.  
Tap → Detail: Stats, Charms, Level-up, Repair, Take along.  
Filter: Welt / Typ / Seltenheit.

### 5.4 Forge
Unverändert 2D-Amboss, 2 Siegel + Glut-Schale, Live-%.  
Siegel sitzt am Charm des Gefährten (Detail-Screen).

### 5.5 Market
Karten wie Shelf. Preise in LP, Drift ohne Timer.  
Verkauf nur bei Spirit 100 %.

### 5.6 Settings
EN/DE, Sound, Credits („Artwork created with Grok (xAI) and edited by Treadplay“), Health-Hinweis, Privacy, Karten-Attribution.

### UI-Metall
`#1A1D22` Grund · `#2A3038` Fläche · `#E8E0D0` Text · `#C4A36A` Messing · `#8B3A3A` Stop.  
Kein Pastell, kein Pink, kein Weiß als Fläche.

---

## 6. Leckerbeutel (ex-Sack)

Ein Mesh, 4 Farben = Gewicht (Braun / Kupfer / Teal / Navy) wie V1.1 §8.  
Leine voll (3) = kein neuer Fund. 24 h Verfall.  
Öffnen: LP oder Einlaufen (1 / 1.5 / 2 / 3 km).  
Loot: Siegel, Kit, Glut. **Kein Gefährte.**

NPC-Boten aus V1.1 §8.4 (Wendel, Drift, Bolt, Fleur, Barnacle, Tickwright, Sandscribe, Brine, Moss, Bonbon). Cogsworth bleibt verboten.

NPC „Moss“ (Dschungel-Bote) darf den **Typ-Namen** Moss nicht in der UI verwechseln — Bote intern `npc_canopy` oder Anzeige „Canopy“. Optional umbenennen zu **Canopy**.

---

## 7. Datenmodell (Vorschlag)

```
CompanionInstance
  id, speciesId, rarity, level
  stride, grit, fortune, spirit
  charmSlots[], equipped
  worldId, type  // type denormalisiert von species
```

Species-Katalog als statische Datei `lib/data/species.dart` (10 Einträge).  
Rarity nur Rahmen + Basiswerte + Extra-Flag für Asset-Variante (`pebble_c`, `pebble_r`, `pebble_e`, `pebble_l`).

---

## 8. Bau-Reihenfolge (nicht alles in einen PR)

**U0 — Rename + Guard**  
Modell Boot→Companion, Strings, forbidden-terms, Cobble→Pebble. CI grün. Schuh nicht mehr auf Home (Platzhalter-PNG ok).

**U1 — Home-Diorama**  
Welt-BG + Gefährte auf Boden + Badge + runder Start + Leine-Platzhalter. Metall-Chrome.

**U2 — Shelf-Karten**  
Flutter-Rahmen, Raster, Detail, Take along. Dummy-PNGs falls Art noch fehlt.

**U3 — Run-Loop anpassen**  
Portrait, Typ Moss/Brook/Gale, Spirit statt Sohle. Bestehende Tests umbiegen.

**U4 — Markt + Inventar 12**  
Karten, Drift, Pebble-Lock.

**U5 — Forge + Beutel + NPC**  
Wie V1.1, neue Copy.

**U6 — Echte Assets einhängen**  
`assets/companions/masters/{id}_{rarity}.png` + World-BGs.  
Fehlende Rarity darf Common-PNG tinten, nicht crashen.

Nicht U5 vor U1.

---

## 9. Tests / Akzeptanz

- Kaltstart → Pebble → simulierter Lauf → LP + Persistenz.
- Stehen → 0 LP.
- Coaster-Typ falsch: Gale-Route/Tempo außerhalb → 0 LP.
- Pebble unverkäuflich ohne Zweiten.
- 2× L1 + Glut kann failen; genau 1 Siegel → 3 Splitter.
- Shelf-Karte hat Text von Flutter, nicht aus dem PNG.
- Grep verbotene Wörter = 0.
- EN/DE Kernscreens.
- Kein Schuh sichtbar.
- Kein NFT-String.

---

## 10. Store-Text (Skizze)

EN: Treadplay is a walking game with invented fantasy companions. Collect Lauf Points by actually moving. Take one companion along, upgrade it, forge Seals, and open treat pouches you find on the road. No crypto. No cash-out. Health data stays with Apple or Google.

DE analog. Nie „like STEPN“, nie „NFT-Karten“, nie „Sneaker“.

---

## 11. Erstes Ticket (copy an Devin)

Rebuild Treadplay collectible layer: remove shoes. Companion species Pebble is the starter (Moss). Rename types Moss/Brook/Gale, durability spirit, garage→shelf as card grid whose chrome is Flutter-drawn (PNGs have no frame and no text). Home: one companion standing on world ground, breath badge, round brass Start bottom-right, metal UI palette in the plan. Keep run loop, breath-per-item, LP blocks, EN/DE. Extend forbidden-terms. Do not add swarms, AR, evolution, or blockchain chrome. Stop after U0+U1 if assets are still placeholders.
