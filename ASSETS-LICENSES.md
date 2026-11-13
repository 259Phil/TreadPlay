# Asset licenses

| Assets | Source | License / terms | Attribution |
|---|---|---|---|
| `assets/companions`, `assets/worlds`, `assets/kits`, `assets/pouch`, `assets/seals`, `assets/leash`, `assets/nav`, `assets/npc` (messengers), `assets/icons/ui_*`, `assets/backdrop`, `assets/wanderweg` (leather trail map, made from the generated trail art and `assets/backdrop` leather), `assets/brand`, `art/` | Generated with Grok (xAI), edited by TreadPlay | xAI Consumer Terms: outputs owned by the user, commercial use permitted. Record the plan and terms version at release. | Credits screen: "Artwork created with Grok (xAI) and edited by TreadPlay" |
| `assets/fonts` (Inter, Cinzel, Barlow Semi Condensed, Alegreya SC, Metamorphous; static TTF, latin subset via Fontsource) | Google Fonts / Fontsource | SIL Open Font License 1.1, texts in `assets/fonts/OFL-*.txt` | None required in app; keep OFL texts with the files |
| `assets/fonts/roboto` (Roboto Regular/Medium/Bold, v3.015) | Official Google Fonts upstream, [roboto-3-classic v3.015](https://github.com/googlefonts/roboto-3-classic/releases/tag/v3.015) (`web/static` files) | SIL Open Font License 1.1, text in `assets/fonts/roboto/OFL.txt` | None required in app; keep OFL with the files. Bundled so Flutter Web does not fetch Roboto from fonts.gstatic.com. |
| `assets/fonts/noto` (Noto Sans Symbols / Noto Sans Symbols 2 Regular, glyph subsets: arrows, check, triangle, four-pointed stars) | Official Noto Project, [notofonts/symbols](https://github.com/notofonts/symbols) releases v2.003 and v2.008 | SIL Open Font License 1.1, texts in `assets/fonts/noto/OFL-*.txt` | None required in app; keep OFL with the files. Bundled so Flutter Web does not fetch these families from fonts.gstatic.com for symbols used in the app. |

Fonts, sounds, map tiles: add a row per source before use.
