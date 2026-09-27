# Treadplay – Check Urheber- & Markenrecht (STEPN-Abgrenzung)

Stand: 27.09.2026 · Grundlage: TREADPLAY-V1-MASTERPLAN.md + STEPN-Whitepaper (whitepaper.stepn.com)
Hinweis: technische/inhaltliche Einschätzung, keine Rechtsberatung. Vor Store-Launch Namensrecherche durch Markenanwalt empfohlen (siehe Abschnitt 5).

---

## 1. Kurzfazit

- **Urheberrecht:** Spielideen, Regeln und Mechaniken sind in DE/EU nicht urheberrechtlich geschützt (nur die konkrete Ausgestaltung: Grafik, UI-Screens, Texte, Sounds, Code). Euer Look (Fantasy-Stiefel, Socken-Sack, Schmiede) ist eigenständig. **Kein Problem, solange keine STEPN-Grafiken/Screens/Texte als Vorlage kopiert werden.**
- **Markenrecht:** Keine STEPN-/Schuhmarken im Plan. **Ein Problem gefunden: NPC „Cogsworth“** (Disney-Figur aus *Die Schöne und das Biest*, ebenfalls eine Uhr/Mechanik-Figur) → umbenennen. App-Name „Treadplay“ vor Launch prüfen lassen.
- **Das eigentliche Risiko ist die Summe:** Viele Regeln sind 1:1 STEPN (Typ-Namen, Tempo-Logik, Energie aus Sammlung, Level 30, 3-Gem-Fusion mit Fail-Verlust, Luck-Boxen in Slots, Sockel). Einzeln harmlos, zusammen riskant für:
  1. **Apple App Review 4.1 „Copycats“** („Don’t imitate the features and functionality of other apps / copy the look and feel“) → Ablehnung möglich.
  2. **UWG § 4 Nr. 3 (Nachahmung)** → nur bei Herkunftstäuschung/Rufausbeutung, eher gering, steigt aber mit jeder Übereinstimmung.
- **Lösung:** 7 gezielte Änderungen (Abschnitt 3). Kernloop bleibt gleich, Aufwand gering, da noch kein Code existiert.

---

## 2. Abgleich Plan ↔ STEPN (belegt aus dem Whitepaper)

| # | Element im Plan | STEPN | Risiko |
|---|---|---|---|
| 1 | Typen **Walker / Jogger / Runner** mit Tempo-Fenster | Walker 1–6, Jogger 4–10, Runner 8–20 km/h (+Trainer) | **hoch** – identische Namen + Logik |
| 2 | Stats **Effizienz, Luck**, Haltbarkeit | Efficiency, Luck, Comfort, Resilience; Durability/HP | **hoch** – gleiche Namen/Funktion |
| 3 | Energie-Max aus **Anzahl + Seltenheit der besessenen Schuhe** | exakt so (1 Schuh = 2, 3 = 4, … +1…+4 je Seltenheit) | **hoch** – Signature-Mechanik |
| 4 | Einheit „LP pro verbrauchter Energie“ | „GST / 1 Energy spent“ | mittel |
| 5 | Schuh-**Level 1–30** | Level 0–30 | mittel |
| 6 | **3 gleiche Level → 1 höheres**, Erfolg sinkt, Fail zerstört Inputs | 3 gleiche Level+Typ Gems, Fail = Gems weg | **hoch** |
| 7 | **Sockel** im Schuh, Stat-Boost | Gems & Sockets | mittel |
| 8 | Sack-Fund durch Luck, **4–5 Felder**, Öffnen kostet Währung, teurer je Qualität | Mystery Box, Luck-basiert, **4 Slots**, Öffnen kostet GST, teurer je Qualität | **hoch** |
| 9 | Home: ein schwebender Schuh auf hellgrau, Energie oben, großer Start | sehr ähnlicher STEPN-Homescreen | mittel |
| 10 | Seltenheit Common/Rare/Epic/Legendary | Common/Uncommon/Rare/Epic/Legendary | gering (Branchenstandard) |
| 11 | Reparatur, interner Markt, Preisdrift | Repair ja; Markt P2P | gering |
| 12 | Sockensack, Schmiede-UI, NPC-Boten, 24-h-Verfall, Kits, Welten | nicht vorhanden | **eigenständig** 👍 |

---

## 3. Konkrete Änderungen (Vorschlag – in Masterplan v1.1 bereits eingebaut)

**3.1 Schuh-Typen umbenennen + eigene Tempo-Logik**
- Walker → **Stomper** · Jogger → **Strider** · Runner → **Dasher**
- Statt fester „Optimal Speed“-Fenster: **Sweet-Spot-Kurve** je Typ (Mitte + Breite), LP fallen weich ab.
  - Stomper: Sweet Spot 4,5 km/h (± 2,5)
  - Strider: 7,5 km/h (± 2,5)
  - Dasher: 11 km/h (± 4)
- Außerhalb Sweet Spot ± 50 %: 0 LP (aber Tracking läuft).

**3.2 Stats umbenennen**
- Effizienz → **Stride** (LP je Puste) · Stamina → **Grit** · Luck → **Fortune** · Haltbarkeit → **Sohle**

**3.3 Energie → „Puste“ pro Schuh statt Sammlungs-Bonus**
- Jeder Schuh hat einen **eigenen Puste-Tank** (Größe nach Seltenheit + Grit).
- Regeneriert stetig (z. B. 1 Punkt / 90 min), nicht in Blöcken.
- Kein Bonus für „mehr Schuhe besitzen“. Anreiz für mehrere Schuhe entsteht natürlich: Schuh wechseln, wenn einer außer Puste ist.
- Anzeige: „Puste“ statt „Energy“.

**3.4 Level-Cap 25 statt 30**
- Kosten `100 × n²` LP bleiben (eure eigene Kurve), Stat-Dämpfung ab Level 18.

**3.5 Siegel-Fusion anders lösen (Schmiede bleibt!)**
- **2 gleiche Siegel + Glut** (neue kleine Ressource aus Läufen/Säcken) → Siegel +1.
- Mehr Glut einlegen = höhere Chance (Spieler-Entscheidung statt reines Würfeln).
- Fail: **ein** Input-Siegel **zerspringt in 3 Splitter**, das andere bleibt. 5 Splitter = 1 Siegel L1.
- Kein kompletter Verlust → eigene Mechanik, auch spielerfreundlicher (9+).

**3.6 Sockel → „Nieten“ / Schnallen**
- Siegel werden in die **Schnallen/Nieten** des Stiefels gesteckt (passt zum Asset: Riemen mit Niete). Anzahl 1–3 nach Seltenheit (war schon eigen, da STEPN nach Level freischaltet).

**3.7 Säcke: Wäscheleine statt Box-Slots**
- Gefundene Sockensäcke hängen an einer **Wäscheleine mit 3 Klammern** (statt 4–5 Felder oben rechts).
- Öffnen: **entweder** LP zahlen **oder** gratis durch „Einlaufen“ (nächster Lauf 1–3 km je Farbe, Sack wärmt sich auf).
- 24-h-Verfall bleibt (war schon eigen).

**3.8 Home-Screen / Look**
- Schuh **nicht** auf neutralem Grau schweben lassen, sondern auf **Welt-Podest/Diorama** (Mittelalter-Kopfsteinpflaster, Weltraum-Asteroid …).
- Garage als **Spielzeug-Regal**, nicht als Karten-Grid auf Weiß/Grau.
- Grauer Hintergrund nur intern für die Asset-Produktion.

---

## 4. Namen & Texte

| Name | Befund | Aktion |
|---|---|---|
| **Cogsworth** (Steampunk-NPC) | Disney-Figur (Uhr, *Die Schöne und das Biest*), Disney setzt Rechte aggressiv durch | **umbenennen → „Tickwright“** |
| Cobble (Startschuh **und** NPC Mittelalter) | kein Rechtsproblem, aber verwirrend | NPC → **„Wendel“** |
| Bolt (Roboter) | generisches Wort (auch Disney-Film, aber Wort allein unkritisch) | ok, optional „Rivet“ |
| Barnacle (Pirat) | generisches Wort | ok |
| Drift, Fleur, Sandscribe, Brine, Moss, Bonbon | generisch/eigen | ok |
| „Earn Lauf Points“ im Store-Text | „Earn“ + Bewegung = Move-to-Earn-/Krypto-Assoziation | → „**Collect** Lauf Points“ |
| Store-Text allgemein | nie „STEPN“, „like STEPN“, „move-to-earn“, „M2E“ – auch nicht in Keywords/ASO | Regel in Plan aufgenommen |

---

## 5. Sonst noch zu klären (vor Launch)

1. **App-Name „Treadplay“**: Websuche ergab keinen Treffer als App/Marke. Garmin hat „**Tread®**“ (Navigations-App). Andere Warenklasse, aber ähnlicher Wortstamm → vor Launch in **DPMA (dpma.de → DPMAregister), EUIPO (TMview), USPTO, WIPO Global Brand Database** für Klassen 9, 28, 41 prüfen; ggf. eigene Marke anmelden (EU-Marke ca. 850 € für 1 Klasse).
2. **Icon (goldenes T)**: nicht an bekannte T-Logos anlehnen (z. B. T-Mobile/Telekom-„T“ ist als Marke geschützt, auch in Magenta). Gold + Weg-Schaft + Läufer ist eigenständig genug.
3. **KI-generierte Bilder (Grok / xAI, Abo vorhanden)**:
   - Laut xAI-Consumer-Terms + FAQ (x.ai/legal/faq): **Outputs gehören euch, kommerzielle Nutzung erlaubt** (auch Bilder). 
   - xAI **bittet** um Namensnennung („generated with Grok“, siehe xAI Brand Guidelines) → in Settings > Credits / Impressum aufnehmen, kostet nichts.
   - xAI erhält selbst ein weitreichendes Nutzungsrecht an Inputs/Outputs → **keine Exklusivität**, andere könnten ähnliche Bilder erzeugen. Deshalb Stiefel nachbearbeiten (Farben, Details, Freistellen, Kombinieren) – das stärkt auch eure eigenen Rechte, da reine KI-Bilder in DE evtl. nicht urheberrechtlich geschützt sind.
   - Prompts **nie** mit „STEPN“, Marken- oder Künstlernamen, keine fremden Screenshots/Produktfotos als Referenzbild hochladen.
   - Prompt + Datum pro Schuh speichern (z. B. `assets/boots/PROMPTS.md`) → Nachweis eigener Erstellung.
   - Bilder auf erkennbare Marken-/Logo-Reste prüfen, bevor sie ins Repo gehen.
4. **Sounds (Ka-ching), Schriften, Icons**: nur eigene, CC0 oder mit Lizenz; Lizenzliste `ASSETS-LICENSES.md` im Repo führen.
5. **Karte**: bei OpenStreetMap Pflicht-Attribution „© OpenStreetMap contributors“; Tile-Server-Nutzungsbedingungen beachten (öffentlicher OSM-Server nicht für Apps mit vielen Nutzern → Anbieter wie MapTiler/Stadia oder Apple/Google-Maps-SDK).
6. **Patente**: Move-to-Earn-Patente nicht geprüft. Optional kurze Recherche auf Google Patents / Espacenet („Find Satoshi Lab“, „exercise reward virtual item“).
7. **Unabhängige Entwicklung dokumentieren**: Designentscheidungen datiert festhalten (Git-Historie reicht), kein „STEPN“ in Code/Kommentaren/Docs.

---

## 6. Checkliste für Devin (in Masterplan §0a übernommen)

- [ ] Keine Begriffe: STEPN, GST, GMT, Sneaker, Walker/Jogger/Runner/Trainer, Mystery Box, Gem, Efficiency/Comfort/Resilience, Move-to-Earn, Mint
- [ ] Keine STEPN-Screens/-Assets als Referenz
- [ ] Home & Garage mit Welt-Diorama, kein neutraler Grau-Hintergrund in der App
- [ ] Alle Asset-Lizenzen in `ASSETS-LICENSES.md`
- [ ] OSM-/Karten-Attribution sichtbar
- [ ] Akzeptanz: grep auf verbotene Begriffe in `lib/`, Store-Texten und ARB-Dateien = 0 Treffer
