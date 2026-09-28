#!/usr/bin/env bash
# IP guardrail (docs/TREADPLAY-V1.2-UMBAU.md §0a): forbidden terms in app code, assets, strings and store text.
set -euo pipefail
cd "$(dirname "$0")/.."

TERMS='STEPN|GST|GMT|Sneakers?|Walkers?|Joggers?|Runners?|Trainers?|Mystery Box|Gems?|Efficiency|Comfort|Resilience|Move-to-Earn|M2E|Mint|NFTs?|Crypto-Token|Boots?|Shoes?|Sohlen?|Cobble|Pikmin|Pok[eé]mon|Gotta|Gym|Incense|OpenSea|Wallets?|Ethereum|ETH|Blockchain|Cogsworth'
PATHS=()
for p in lib assets l10n store; do [[ -e $p ]] && PATHS+=("$p"); done
[[ ${#PATHS[@]} -eq 0 ]] && { echo "nothing to check"; exit 0; }

# Generated from lib/l10n/*.arb (which are checked); boilerplate mentions the iOS project name.
EXCLUDE=(-g '!lib/l10n/app_localizations*.dart')

status=0
if rg -n -i -w "${EXCLUDE[@]}" -e "$TERMS" "${PATHS[@]}"; then status=1; fi
# File names: match whole name parts separated by / _ . - or space.
if rg --files "${PATHS[@]}" | rg -i -e "(^|[/_. -])($TERMS)([/_. -]|$)"; then status=1; fi

if [[ $status -ne 0 ]]; then
  echo "Forbidden terms found (see docs/TREADPLAY-V1.2-UMBAU.md §0a)." >&2
  exit 1
fi
echo "OK: no forbidden terms in ${PATHS[*]}"
