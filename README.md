# TreadPlay

Walking and running game with collectible fantasy boots. Flutter (iOS + Android), EN/DE.

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
| `docs/` | Masterplan v1.1 and IP review |
| `assets/` | App-ready PNGs with transparency (boots, repair kits, sock sack, app icon) |
| `assets/boots/catalog.csv` | Boot catalog: world, rarity, type, name |
| `art/` | Master images with background (not bundled in the app) |
| `ASSETS-LICENSES.md` | Origin and license of all assets |
| `scripts/check_forbidden_terms.sh` | IP guardrail, runs in CI (masterplan §0a) |
