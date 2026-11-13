# CanvasKit-Prüfung (Web-Build)

Stand: 13.11.2026. Prüfung an einem Release-Build mit Flutter 3.35.3
(Zweig `grokbot/roboto-lokal`, nach dem Merge von PR #19):

```
flutter build web --release --base-href /TreadPlay/ --no-web-resources-cdn
```

Das Flag `--[no-]web-resources-cdn` ist in 3.35.3 vorhanden. Ohne `--no-web-resources-cdn` würde der Loader CanvasKit von `https://www.gstatic.com/flutter-canvaskit` holen, sobald `useLocalCanvasKit` nicht gesetzt ist (so der Befund der Prüfung vom 13.11. am damaligen Live-Build).

## Ergebnis: Variante A

`build/web/flutter_bootstrap.js` enthält:

```
_flutter.buildConfig = {
  "engineRevision": "ddf47dd3ff96dbde6d9c614db0d7f019d7c7a2b7",
  "builds": […],
  "useLocalCanvasKit": true
};
```

Die lokale Engine liegt unter `build/web/canvaskit/` (`canvaskit.js`, `canvaskit.wasm` und die Chromium-Variante). Der Loader wählt die lokale Basis-URL `"canvaskit"`, wenn `useLocalCanvasKit` wahr ist. Die Zeichenkette `https://www.gstatic.com/flutter-canvaskit` bleibt als Fallback-Zweig im Loader-Code stehen, wird in diesem Build aber nicht genommen.

Die Datenschutzerklärung (§ 8) verwendet den Satz der Variante A: Schriftarten und die Darstellungs-Engine (CanvasKit) werden mit der App ausgeliefert und nicht von Google-Servern nachgeladen. Der Laufzeit-Check unten bestätigt, dass dieser Satz jetzt zutrifft.

## Schriftarten (gebündelt)

Im Build sind gebündelt (FontManifest plus Dateien unter `build/web/assets/`):

- Inter (Regular, SemiBold, Bold) — Fließtext
- Cinzel (SemiBold, Bold) — Display in mehreren Skins
- BarlowSemiCondensed, AlegreyaSC, Metamorphous — weitere Skins
- Roboto (Regular/Medium/Bold, offiziell Google Fonts / roboto-3-classic v3.015, SIL OFL 1.1, unter `assets/fonts/roboto/`) — Material-Standardfamilie; ohne Registrierung im FontManifest würde die Engine sie automatisch von `fonts.gstatic.com` nachladen
- Noto Sans Symbols und Noto Sans Symbols 2 (offiziell Noto Project, SIL OFL 1.1; Glyphen-Teilmengen unter `assets/fonts/noto/`, nur die im UI vorkommenden Zeichen: ← → ↔ sowie ✓ ▸ ✦ ✧)
- MaterialIcons (tree-shaken)

Roboto-Kursiv ist nicht gebündelt: die App setzt `FontStyle.italic` auf Inter- und Display-Schriften, nicht auf Roboto; im Laufzeit-Check erschien kein Request nach einer Italic-Schnitt.

Die Theme- und Skin-Textstile setzen `fontFamilyFallback: [Roboto, NotoSansSymbols, NotoSansSymbols2]`, damit fehlende Glyphen zuerst aus den gebündelten Schriften kommen und die Engine keine Noto-Familie von Google holt.

Keine Font-CSS-Links zu `fonts.googleapis.com` in `index.html`. `googleapis.com` kommt im Build nicht vor.

Asset-Größe (Release-`build/web` gegenüber dem Stand vor dieser Bündelung, Merge-Commit 787f86d / vorheriger Legal-Build 158.720.842 Bytes): **+484.943 Bytes (473,6 KB)**. Davon etwa 462 KB die drei Roboto-TTF, der Rest Noto-Teilmengen (knapp 10 KB), Lizenz-/SOURCE-Dateien und Manifest.

## Glyph-Fallback der Engine (Codepfad)

In `main.dart.js` setzt Flutter `fontFallbackBaseUrl` weiterhin standardmäßig auf `https://fonts.gstatic.com/s/`. Dieser Zweig bleibt im Engine-Code stehen. Er wird nur ausgelöst, wenn ein Zeichen in keiner bereits geladenen, am Textstil hinterlegten Schrift vorkommt (Emoji, CJK, weitere Symbole). Im geprüften Umfang der App-Bildschirme tritt das nicht ein.

Emoji: das einzige Emoji in den Quellen (`👍`) steht nur in `docs/TREADPLAY-IP-CHECK.md`, nicht in der laufenden App. CJK-Zeichen kommen in den UI-Texten nicht vor. Ein generisches `fontFamily: 'serif'` (`serifTitle` in `lib/theme.dart`, Wanderweg/Schmiede/Begleiter-Werte) hat keine Anfrage an gstatic ausgelöst.

## Laufzeit-Check (Release-Build, 13.11.2026)

Headless-Chrome (Playwright, Service Worker blockiert, Locale `de`, `--no-sandbox --disable-gpu`). Geprüft wurden die Hash-Routen:

`#/home`, `#/run`, `#/settings`, `#/imprint`, `#/privacy` (durchgescrollt, inkl. § 8 und „Deine Rechte“), `#/terms`, `#/shelf` (Gehege), `#/wanderweg` (Karte), `#/forge`, `#/market`, `#/album`, `#/pouches`, `#/history`.

Vor der Roboto- und Noto-Bündelung (Live-Stand nach PR #19):

- CanvasKit kam lokal von `/TreadPlay/canvaskit/` — kein Request an `www.gstatic.com/flutter-canvaskit`.
- Ein Request an `https://fonts.gstatic.com/s/roboto/v32/…woff2`, weil Roboto nicht im FontManifest stand.
- Beim Scrollen der Datenschutzerklärung (Pfeil „→“ in „Einstellungen → Spielstand“) ein Request an `https://fonts.gstatic.com/s/notosanssymbols/v43/…woff2`.
- Auf dem Album-Schirm (✦ / ✧) ein Request an `https://fonts.gstatic.com/s/notosanssymbols2/v24/…woff2`.

Nach der Bündelung (dieser Build, lokal unter `/TreadPlay/` ausgeliefert):

- **Keine** Requests an einen fremden Host. Alle 170 erfassten Requests gingen an denselben lokalen Ursprung.
- Insbesondere **kein** Request an `fonts.gstatic.com`, `fonts.googleapis.com`, `www.gstatic.com` oder `googleapis.com`.
- CanvasKit und alle Schriftarten (Roboto, Inter, Display-Schriften, Noto-Teilmengen, MaterialIcons) kommen aus dem App-Bundle.

Damit trifft der öffentliche Satz der Variante A zu: „Schriftarten und die Darstellungs-Engine (CanvasKit) werden mit der App ausgeliefert und nicht von Google-Servern nachgeladen.“

Ein erneuter Check gegen die Live-Vorschau (GitHub Pages, gleicher Build) ist nach dem Ausrollen festgehalten, sobald er vorliegt; das erwartete Ergebnis ist identisch.
