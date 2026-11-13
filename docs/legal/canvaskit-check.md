# CanvasKit-Prüfung (Web-Build)

Stand: 13.11.2026. Prüfung an einem Release-Build mit Flutter 3.35.3:

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

Die Datenschutzerklärung (§ 8) verwendet deshalb den Satz der Variante A: Schriftarten und die Darstellungs-Engine (CanvasKit) werden mit der App ausgeliefert und nicht von Google-Servern nachgeladen.

## Schriftarten

Im Build sind gebündelt (FontManifest plus Dateien unter `build/web/assets/`):

- Inter (Regular, SemiBold, Bold) — Fließtext
- Cinzel (SemiBold, Bold) — Display in mehreren Skins
- BarlowSemiCondensed, AlegreyaSC, Metamorphous — weitere Skins
- MaterialIcons (tree-shaken)

Keine Font-CSS-Links zu `fonts.googleapis.com` in `index.html`. `googleapis.com` kommt im Build nicht vor.

## Glyph- und Roboto-Fallback (Laufzeit, 13.11.2026)

In `main.dart.js` setzt Flutter `fontFallbackBaseUrl` standardmäßig auf `https://fonts.gstatic.com/s/`. Fehlt in den registrierten Schriften ein Zeichen (Emoji, CJK, seltene Symbole), würde die Engine eine Ergänzung (Noto) von Google nachladen und dabei die IP übermitteln.

Zusätzlich gilt: Steht die Familie „Roboto“ nicht im FontManifest, hängt die Engine sie automatisch an und lädt sie von genau dieser Basis-URL (`…/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2`). Das ist unabhängig von fehlenden Glyphen.

Laufzeit-Check des Release-Builds (Headless-Chrome, Startbildschirm, Service Worker blockiert):

- CanvasKit kommt lokal von `/TreadPlay/canvaskit/` — **kein** Request an `www.gstatic.com/flutter-canvaskit`.
- **Ein** Request geht an `https://fonts.gstatic.com/s/roboto/v32/…woff2`. Ursache: Roboto ist nicht gebündelt, die Engine fügt sie als Standard-Fallback hinzu (Material-TextTheme-Defaults heißen intern weiter „Roboto“, auch wenn die App Inter/Cinzel setzt).
- `googleapis.com` und `fonts.googleapis.com` werden nicht aufgerufen.

Die gebündelten Schriften (Inter, Cinzel, BarlowSemiCondensed, AlegreyaSC, Metamorphous) werden lokal geladen. Einige ältere Titelstile nutzen noch `fontFamily: 'serif'` (`serifTitle` in `lib/theme.dart`, Wanderweg/Schmiede/Begleiter-Werte); das ist eine generische Familie und nicht im FontManifest.

Der öffentliche Satz der Variante A („Schriftarten und die Darstellungs-Engine (CanvasKit) werden mit der App ausgeliefert und nicht von Google-Servern nachgeladen“) trifft für CanvasKit und die App-Schriften zu. Er deckt den automatischen Roboto-Fallback der Engine nicht vollständig ab. Abhilfe später: Roboto lokal bündeln und im FontManifest registrieren, dann entfällt dieser eine Request. Die Datenschutzerklärung wurde nach dem Prüfungstext (Variante A) gesetzt; diese Abweichung ist hier festgehalten.
