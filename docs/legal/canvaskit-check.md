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

## Glyph-Fallback (Restbemerkung)

In `main.dart.js` setzt Flutter `fontFallbackBaseUrl` standardmäßig auf `https://fonts.gstatic.com/s/`. Das ist der eingebaute Noto-/Roboto-Fallback der Engine: fehlt in den registrierten Schriften ein Zeichen (Emoji, CJK, seltene Symbole), würde der Browser die Ergänzung von Google laden und dabei die IP übermitteln.

Die normale DE-/EN-Oberfläche nutzt die gebündelten Schriften (Inter für den Fließtext; Cinzel und die Skin-Schriften für Titel). Inter und die übrigen Familien decken die lateinische Schrift inkl. Umlaute ab. Ein automatischer Google-Request ist dort nicht zu erwarten.

Einige ältere Titelstile verwenden noch `fontFamily: 'serif'` (generische CSS-Familie, nicht im FontManifest; u. a. `serifTitle` in `lib/theme.dart`, genutzt auf dem Wanderweg, in der Schmiede und an den Begleiter-Werten). Ob CanvasKit dafür ein System-Serif nimmt oder den Noto-Fallback auslöst, ist nicht fest zugesichert. Beim Laufzeit-Check der rechtlichen Seiten und des Startbildschirms darf deshalb kein Request an `gstatic.com` / `fonts.gstatic.com` erscheinen; ein solcher Request auf Wanderweg oder Schmiede wäre ein Restpunkt, kein Widerspruch zur lokalen CanvasKit-Auslieferung.

Diese Restbemerkung ändert den öffentlichen Satz der Variante A nicht. Die Engine selbst kommt lokal.
