# TREADPLAY — V1.1 MASTERPLAN (Devin)

*v1.1: IP-Abgrenzung zu STEPN eingearbeitet (siehe TREADPLAY-IP-CHECK.md und §0a).*

**Arbeitstitel:** Treadplay  
**Unterzeile (Store, nicht Icon):** Walk with your boots.  
**Plattform:** Flutter, iOS + Android parallel  
**Altersfreigabe:** 9+  
**Startsprache:** English. Settings-Schalter: English / Deutsch. Devin muss beide Strings von Tag 1 pflegen.  
**Netz:** Online-Pflicht für App-Nutzung (Markt-Drift, Sack-Roll, Shop). Tracking selbst lokal.  
**Server in V1:** keiner für Accounts. Kein Login. Kein Cloud-Save. Kein Spielerhandel.

---

## 0. Was V1 NICHT ist

- Keine NFTs, keine Blockchain, keine Wallet, kein Token, kein Auszahlen.
- Kein Spieler-zu-Spieler-Markt.
- Keine echten Schuhmarken, kein Swoosh, keine drei Streifen, kein STEPN-Pastell-Runner als Look.
- Keine Sprache, keine Kamerabilder.
- Keine Werbung außer: optional 1× täglich Rewarded Video für 10–15 LP + optional schmales Banner. Default: Video aus, bis User tippt.
- Keine Gesundheitsdaten an uns. HealthKit / Google Fit / Health Connect speichern beim Hersteller. Wir lesen nur Session-Werte. Datenschutzerklärung muss das sagen.

---

## 0a. IP-Leitplanken (Pflicht für jeden PR)

- **Verbotene Begriffe** in Code, Kommentaren, ARB/Strings, Store-Text, Keywords, Asset-Namen: STEPN, GST, GMT, Sneaker, Walker, Jogger, Runner, Trainer, Mystery Box, Gem, Efficiency, Comfort, Resilience, Move-to-Earn, M2E, Mint, NFT, Crypto-Token.
  - Ausnahme: der Satz „No crypto.“ im Store-Text.
  - Akzeptanz: `rg -i -w` (Wortgrenzen) über `lib/`, `assets/`, `l10n/`, Store-Texte = 0 Treffer (CI-Check).
- **Keine fremden Screens/Assets als Vorlage** (auch nicht als KI-Referenzbild). Prompts ohne Marken- oder Künstlernamen.
- **Eigener Look:** Schuhe in der App immer auf Welt-Podest/Diorama oder Regal, nie freischwebend auf neutralem Grau. Grau nur für die Asset-Produktion.
- **Assets:** Stiefel werden mit Grok (xAI) erzeugt und nachbearbeitet. Prompt + Datum pro Asset in `assets/boots/PROMPTS.md`. Alle Fremd-Assets (Sounds, Fonts, Icons) mit Lizenz in `ASSETS-LICENSES.md`. Credits-Seite in Settings: „Artwork created with Grok (xAI) and edited by Treadplay“, Font-/Sound-Lizenzen, Karten-Attribution.
- **Karte:** Attribution des Kartenanbieters sichtbar (z. B. „© OpenStreetMap contributors“), kein öffentlicher OSM-Tile-Server im Release.

---

## 1. Kernloop (muss zuerst stehen)

App öffnen → Cobble anhaben → Start → wirklich bewegen im Sweet Spot des Schuh-Typs → Puste des Schuhs tickt runter → LP kommen in Blöcken (Ka-ching) → Session Ende → Map + Stats lokal → Chance auf Sockensack + NPC-Blase → Sack mit LP öffnen oder im nächsten Lauf einlaufen.

Ohne Bewegung: 0 LP. Stehen nach Start zählt nicht. GPS + Schritt plausibel, sonst Session ungültig.

---

## 2. Währungen

### LP (Lauf Points)
Nur aus verifizierter Bewegung im gültigen Tempo.  
Ausgabe: Shop-Schuhe, Reparaturkits, Siegel (selten), Sockensack-Öffnen, Glut.

### Siegel (nicht „Kristalle“)
Ressource. Drei Nutzungen:
1. In Schnalle/Niete des Schuhs stecken → Stat-Boost
2. Schmieden: 2 gleiche Level + Glut → 1 nächstes Level (Risiko, siehe 7.3)
3. Drop aus Sockensack / sehr selten Shop

Level 1–5. Über Level 3 nur Schmieden, nicht Sack.

### Glut
Kleine Ressource für die Schmiede. Kleiner Drop am Ende jeder gültigen Session (nach km) und aus Säcken. Nicht im Shop kaufbar in V1.

### Puste (EN: Breath) – pro Schuh, keine globale Energie
**Jeder Schuh hat seinen eigenen Puste-Tank.** Größe nach Seltenheit + Grit (Common 6, Rare 8, Epic 10, Legendary 12 Punkte, vor Grit).  
Verbrauch nur während gültiger Bewegung (1 Punkt ≈ 250 m im Sweet Spot, nicht zeitbasiert).  
Regeneriert stetig: 1 Punkt / 90 min pro Schuh, auch wenn er nicht getragen wird.  
**Kein Bonus für Anzahl/Seltenheit der besessenen Schuhe.** Mehrere Schuhe lohnen sich, weil man wechseln kann, wenn einer außer Puste ist.  
Leer = keine LP mehr für diesen Schuh, Tracking der Fitnessdaten läuft trotzdem (User sieht km/Zeit). Schuhwechsel mitten im Lauf: nein (erst nach Stop).

---

## 3. Schuhe

### 3.1 Katalog
40 Basismodelle, Fantasy-3D-Collectible, gleiches Studio:
- ein Schuh, Dreiviertel, Spitze links
- Produktion: freigestellte PNG mit Alpha (mind. 1024 px, besser 2048, sRGB), Master mit grauem Hintergrund aufheben
- In der App: auf Welt-Podest/Diorama (Mittelalter-Pflaster, Weltraum-Asteroid, Roboter-Werkbank …), nicht auf neutralem Grau
- Spielzeug-Look
- kein Text, kein Logo

Welten: Mittelalter, Weltraum, Roboter, Rokoko, Pirat, Steampunk, Ägypten, Unterwasser, Dschungel, Süßigkeit.

**Asset-Stand:** 35 Stiefel in `assets/boots/` (Katalog: `assets/boots/catalog.csv`), Ziel 4 pro Welt (je Common/Rare/Epic/Legendary). Aussortiert: 5 Modelle (zu schlicht / zu nah an realen Schuhformen). Offen: Weltraum Epic + Legendary, Unterwasser Common, Roboter Legendary, Süßigkeit Epic (siehe `assets/boots/PROMPTS.md`).

Typen:
- **Stomper** — klobige Sohle / hoher Schaft — Sweet Spot 4,5 km/h (± 2,5)
- **Strider** — mittlere Sohle — Sweet Spot 7,5 km/h (± 2,5)
- **Dasher** — flacher, länger — Sweet Spot 11 km/h (± 4)

Sweet-Spot-Kurve statt fester Fenster: 100 % LP im Kern (± 40 % der Breite), danach weicher Abfall, außerhalb der Breite 0 LP (Tracking läuft).

Startschuh fest: **Cobble**, Common, Stomper. Geschenkt, unverkaufbar bis User ein zweites Paar hat (sonst Soft-Lock).

### 3.2 Seltenheit (Look, nicht anderer Render)

| Stufe | Look-Regel | Schnallen | Richtwert LP / Puste-Punkt |
|---|---|---|---|
| Common | schlicht, matt | 1 | 2.5 |
| Rare | ein klarer Gag mehr | 1–2 | 4.0 |
| Epic | reicher, mehr Teile | 2 | 7.0 |
| Legendary | Statement der Welt | 2–3 | 12.0 |

Zahlen sind Basis vor Level und Siegel. Pro Schuh-Instanz **leicht randomisieren** (±8 % auf Stride/Grit/Fortune bei Drop/Kauf), damit zwei Cobble nicht identisch sind. Modell bleibt gleich.

### 3.3 Mehrfach-Instanzen
Gleicher Look kann 2–4× im Markt vorkommen mit anderen Stat-Rollen. User sucht das passende Paar. Kein Baukasten, kein Crafting von Schuhen.

### 3.4 Stats
- **Stride** → LP je Puste-Punkt
- **Grit** → Puste-Tankgröße / Verbrauch
- **Fortune** → Sack-Farbe, NPC, Drop-Gewicht
- **Sohle** → 0–100 %. Unter 100 % nicht verkaufbar. Bei 0 % keine LP, nur noch Tracking.

Level 1–25.  
Kosten Level n → n+1: `100 × n²` LP **plus** Lauf-XP (siehe 4).  
Stat-Zuwachs ca. +4 % Stride-Äquivalent pro Level, gedämpft ab 18.

### 3.5 Verkauf / Markt
Interner Markt, nicht online zwischen Spielern.  
Preise driften alle 7–9 Stunden. **Kein Countdown** sichtbar. User soll reinschauen.  
Driftspanne pro Item ca. 100–500 LP.  
Legendary bleibt teuer genug, dass Common nicht inflationiert.  
Inventar-Cap V1: 12 Schuhe.  
Kaputte Schuhe: nicht auf den Markt. Erst reparieren.

---

## 4. XP und Level

XP nur durch echtes Gehen/Laufen. Verkauf, Shop, Schmieden, Ads geben 0 XP.

Schuh-Level 25 Cap. Progression quadratisch, bewusst lang:
- 1→2: 100 LP-Äquivalent Aufwand
- 10→11: 10 000
- Summe 1→25 sehr hoch (Monate, kein Wochenende)

Spieler-Profil-Level optional V1: gleich der Summe gelaufener km, rein kosmetisch / für NPC-Gewicht. Nicht Pay-to-Win.

---

## 5. Bewegung, Anti-Cheat, Privacy

- Schritte/Distanz/Tempo: HealthKit, Google Fit / Health Connect.
- Zusätzlich GPS-Session in der App für die lokale Map-Linie.
- Plausibilität: Tempo außerhalb des Typs + unmögliche Distanz → keine LP, Session als „ungültig“ markieren, Fitness-Anzeige trotzdem zeigen.
- Wir speichern keine Roh-GPS-Tracks auf einem Server. Lokal auf Gerät. Export nur User-initiiert (z. B. Bild der Route).
- Hinweis in Settings + Onboarding: Apple/Google speichern Health-Daten unabhängig von uns.

Ka-ching: bei jedem LP-Block (nicht jede Sekunde). Blockgröße hängt von Schuh + Level + Stride ab (z. B. 2.5 … 15 LP pro Puste-Punkt). Settings: Sound an/aus.

---

## 6. Reparatur

Drei Kits, alle im Shop, letzte zwei teuer. Selten Drop unterwegs / im Sack.

| Kit | Wirkung | Preis-Lage |
|---|---|---|
| Light | +kleiner Haltbarkeitsblock | günstig |
| Solid | +großer Block | mittel |
| Master | fast voll / voll | sehr teuer |

Assets: `assets/kits/kit_light.png` (Blechdose), `kit_solid.png` (Werkzeugkiste), `kit_master.png` (Runen-Truhe).

Reparatur erst sinnvoll nutzbar; Verkauf erst ab 100 %.  
Kein Würfel-Minispiel.

---

## 7. Siegel

### 7.1 Schnallen
Schuh hat 1–3 Schnallen/Nieten nach Seltenheit (nicht nach Level). Ein Siegel / Schnalle. Siegel sitzt sichtbar auf der Schnalle des Stiefels. Stecken = sofortiger Stat-Boost. Ziehen frei, kein Bruch beim Ziehen.

### 7.2 Shop
Siegel im Shop **selten und teuer**, Preis driftet wie der Rest. Hauptquelle = Laufen + Säcke.

### 7.3 Schmieden (Tab Forge)
- Genau **2 Siegel gleichen Levels + 1–5 Glut** → 1 Siegel Level+1
- Grundchance sinkt mit Level: L1→2 50 %, L2→3 40 %, L3→4 30 %, L4→5 20 %; **jede Glut +8 %** (Cap 90 %). Spieler entscheidet, wie viel Glut er riskiert.
- Glut wird immer verbraucht.
- Fail: **ein** Input-Siegel zerspringt in **3 Splitter**, das andere bleibt. **5 Splitter = 1 Siegel L1** (in der Schmiede).
- Kein L6 in V1.

### 7.4 Schmiede-UI
2D, dunkel. Mitte: Amboss + schwebender Hammer über Glut-Ofen (Lock-Asset).  
Links/rechts: 2 Siegel-Slots, unten: Glut-Schale (1–5) + Schmieden-Button mit Live-Chance in %.  
Animation (Devin, kein Pflicht-Video): Hammer 3× auf Amboss. Danach:
- Erfolg: Goldblitz, neues Siegel in der Mitte
- Fail: Rauch, ein Siegel zerspringt sichtbar in Splitter

Lock-Prompt Idle:

```
Dark 2D mobile game UI illustration of a cute fantasy forge, front-facing, centered.
Deep charcoal stone-cave background with faint circular stone texture.
Simple dark iron anvil on a low hexagonal stone furnace base.
Warm ember glow and coals in the furnace opening under the anvil.
Bronze toy hammer floating above the anvil, head slightly glowing, raised ready to strike.
Clean flat 2D, soft cel shading, phone-readable.
No character, no text, no logos, no photoreal 3D.
Empty space left and right for two seal slots, small ember bowl space below.
```

---

## 8. Sockensack (Truhenersatz)

### 8.1 Asset
**Ein Mesh für alle Farben.**  
Gestrickte Socke, Bündchen, Hanfkordel, eine Holzperle. Keine Sohle, kein Schuh.  
Referenz: gerippte braune Strick-Socke. In der App hängt sie an einer Wäscheleine.

Farbe = nur Gewicht, kein Garantieschein.

| Farbe | Gewicht |
|---|---|
| Braun | normale Siegel (L1) |
| Kupfer | etwas höher |
| Teal | deutlich höher |
| Navy | Chance auf höchstes Sack-Siegel (max L3) |

### 8.2 Fund
Während gültiger Bewegung, Fortune gewichtet.  
Nach Session: Home-Screen. **Wäscheleine mit 3 Klammern** über dem Diorama. Gefundene Säcke hängen dort. Leine voll = kein neuer Fund.  
Sofort-Sprechblase des NPC (kurz).  
Öffnen: **entweder** LP zahlen (teurer je Farbe) **oder** gratis „einlaufen“: Sack wärmt sich im nächsten gültigen Lauf auf (Braun 1 km, Kupfer 1,5 km, Teal 2 km, Navy 3 km) und öffnet sich danach.  
Ungeöffnet: nach 24 h verfallen (Inventar nicht vollmüllen).

### 8.3 Loot (random, 1–3 Slots)

- Slot = Siegel **oder** Kit **oder** Glut (1–3), nicht mehrere im selben Slot.
- Braun: oft 1–2× Siegel L1, selten Light-Kit. Nie L3+.
- Kupfer: oft L1 + Chance L2 oder Kit; manchmal 2× L1.
- Teal: typisch L2 oder L2+L1+Kit; kann auch „nur“ 2× L1 sein.
- Navy: höchstes Gewicht L2/L3 + Kit + L1 möglich. Kein Pflicht-Jackpot.
- Zwei gleiche L1 erlaubt.
- Kein L4/L5 aus Säcken.

### 8.4 NPC-Boten (Fortune × Welt)

Devin lokalisiert EN + DE.

| Welt | Bote | Fortune-Band | Blase EN | Sack-Gewicht |
|---|---|---|---|---|
| Mittelalter | Wendel | low | A wanderer from far away leaves you something. | Braun |
| Weltraum | Drift | low | A faint signal. For you. | Braun |
| Roboter | Bolt | low | System update: small reward. | Braun |
| Rokoko | Fleur | mid | The marquise sends a parcel. | Kupfer |
| Pirat | Barnacle | mid | The old salt left you a sock. | Kupfer |
| Steampunk | Tickwright | mid | Tick. A gift from the machine. | Kupfer |
| Ägypten | Sandscribe | high | The desert whispers your name. | Teal |
| Unterwasser | Brine | high | The deep noticed you. | Teal |
| Dschungel | Moss | high | The forest left something behind. | Teal |
| Süßigkeit | Bonbon | very high | The sugar spirit likes your pace. | Navy |

Gleicher Bote kann bei extremem Fortune eine Stufe höher rollen.

---

## 9. App-Struktur

### Tabs (5)
1. **Home / Dashboard** — aktiver Schuh auf Welt-Diorama, Wäscheleine mit Säcken, Level/XP, LP, Puste, großer Start, letzte Session-Karte klein
2. **Garage** — Spielzeug-Regal (Holzbretter) statt Karten-Grid, Filter Seltenheit/Typ, Detail: Stats, Schnallen, Level-up, Reparatur
3. **Forge** — dunkle Schmiede + 3 Slots
4. **Market** — Schuhe, Kits, seltene Siegel; Preise ohne Timer
5. **Settings** — EN/DE, Ka-ching, Credits/Lizenzen, Sound master, Health-Hinweis, Datenschutz, Restore Purchases (falls IAP später), kein Account

### Overlay Run
Vollbild nach Start: Distanz, Zeit, Tempo, LP-Ticker, Puste, Sweet-Spot-Anzeige, Stop.  
Keine Tabs. Punkte nur bei Bewegung. Nach Stop: Zusammenfassung + Sack-Felder + NPC.

### Onboarding
1. Sprache lassen (EN default)  
2. Health-Permission erklären  
3. Cobble schenken  
4. Erste geführte Mini-Session  

---

## 10. IAP / Ads V1

- Kein Pflicht-IAP für den Loop.
- Optional später: LP-Pakete / Cosmetic — nicht in Phase A.
- Rewarded Video 1× Tag, 10–15 LP, Button nicht aufdringlich.
- Banner optional, Settings-Toggle wenn Store erlaubt.

Google Play Billing / Apple IAP erst wenn Shop-Echtgeld wirklich kommt. V1 kann ohne.

---

## 11. Icon / Brand

Homescreen: goldenes **T**, Schaft = Weg, Mini-Piktogramm-Läufer (kein realistischer Mensch). Quadrat 1024.  
Königsschuh / Flagship nur In-Game und Store-Screenshots, nicht als App-Icon.

Asset: `assets/brand/app_icon_1024.png` (goldenes T, Schaft = Weg, endet in Stiefel, Piktogramm-Wanderer). Illustriertes Banner `art/brand/logo_artwork.jpg` nur für Splash/Store-Grafik.

---

## 12. Bau-Reihenfolge für Devin (nicht alles parallel)

**Phase A — Loop**  
Projekt, Navigation 5 Tabs leer, lokaler Store, Cobble, Start/Stop, Dummy-GPS+Health, Puste pro Schuh, LP-Blöcke, Ka-ching, Session-Summary, EN/DE Gerüst, CI-Check verbotene Begriffe (§0a).

**Phase B — Schuhe**  
Katalog-Daten 40 Modelle + Stat-Rollen, Garage, Equip, Sohle (Haltbarkeit), Level 1–25 Kosten.

**Phase C — Markt + Kits**  
Drift 7–9 h ohne UI-Timer, Kauf/Verkauf 100 %, Inventar 12.

**Phase D — Siegel + Schmiede**  
Schnallen, Glut, Schmieden (2 + Glut) inkl. Splitter bei Fail, 2D-Amboss + 3-Schlag.

**Phase E — Säcke + NPC**  
Ein Sock-Asset, 4 Farben, Loot-Tabellen, Wäscheleine 3 Klammern, Einlaufen-Öffnen, Blasen zweisprachig.

**Phase F — Polish**  
Anti-Cheat-Regeln, Offline-Fail-State (Netz weg → kein Markt/Sack-Roll, Tracking-Hinweis), Store-Texte, 9+, Privacy, Credits/Lizenzen, Karten-Attribution, Markenrecherche „Treadplay“ vor Einreichung.

Nicht die ganze App in einen PR.

---

## 13. Akzeptanz V1

- Kaltstart → Cobble → Lauf mit Bewegung → LP + Sound → Persistenz nach Kill.
- Stehen nach Start → 0 LP.
- Marktpreis nach 7–9 h anders, kein Countdown.
- 2× L1 + Glut schmieden kann failen; dann zerspringt genau ein Siegel in 3 Splitter.
- Sack-Farbe navy kann trotzdem schwach rollen.
- Sprache EN/DE komplett auf Kernscreens.
- Kein NFT-String irgendwo in UI oder Store-Text.
- CI-Check verbotene Begriffe (§0a) grün.
- Kein Schuh in der App auf neutralem Grau.

---

## 14. Store-Text (Skizze)

Treadplay is a walking and running game with collectible fantasy boots. Collect Lauf Points by actually moving. Upgrade boots, repair them, forge Seals, and open Sock Sacks you find on the road. No crypto. No cash-out. Your health data stays with Apple or Google.

Deutsch analog.

---

*Ende V1. Alles danach (mehr als 40 Looks, PvP, Cloud) ist V2 und nicht bauen, bis A–C stabil sind.*
