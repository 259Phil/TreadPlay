# TreadPlay

Walking and running game: you move with one invented fantasy companion. Flutter (iOS + Android), EN/DE.

No crypto, no NFTs, no cash-out. Movement data stays on the device.

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Phase A (core loop) runs on simulated movement: start a run and set the demo speed on the run screen. GPS and Apple Health / Health Connect come later.

## Layout

| Path | Content |
|---|---|
| `lib/` | Flutter app (`domain/` rules, `data/` storage + movement source, `state/` Riverpod, `features/` screens) |
| `lib/l10n/` | EN/DE strings (ARB) |
| `docs/` | Masterplan v1.1, V1.2 companion rebuild plan, IP review |
| `assets/companions/` | Companion PNGs with transparency, `{species}_{c\|r\|e\|l}.png`; missing rarities fall back to a lower one |
| `assets/worlds/` | Home backdrops per world |
| `assets/` (other) | Repair kits, treat pouch, app icon |
| `lib/data/species.dart` | The ten companion species (world, type) |
| `scripts/gen_companion_art.sh` | Regenerates `lib/data/companion_art.dart` after adding companion art |
| `art/` | Master images with background (not bundled in the app) |
| `ASSETS-LICENSES.md` | Origin and license of all assets |
| `scripts/check_forbidden_terms.sh` | IP guardrail, runs in CI (V1.2 plan §0a) |
