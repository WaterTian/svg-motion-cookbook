#!/usr/bin/env bash
# Render a single frame of an animated SVG to PNG, using headless Chrome's
# --virtual-time-budget to advance the SMIL clock to a precise moment.
#
# Usage: ./scripts/render.sh <input.svg> [virtual-time-ms] [output.png]
#
# Defaults:
#   virtual-time-ms = 3500  (3.5s — bars usually full + a few cycle features visible)
#   output.png      = <input>.png next to the input

set -euo pipefail

INPUT="${1:?usage: render.sh <input.svg> [virtual-time-ms] [output.png]}"
VTIME="${2:-3500}"
OUTPUT="${3:-${INPUT%.svg}.png}"

# Resolve absolute paths — Chrome needs file:// URLs.
INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
OUTPUT_ABS="$(cd "$(dirname "$OUTPUT")" && pwd)/$(basename "$OUTPUT")"

# Detect Chrome — macOS, then common Linux paths.
if [[ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
  CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v google-chrome >/dev/null 2>&1; then
  CHROME="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
  CHROME="chromium"
else
  echo "error: Google Chrome / Chromium not found" >&2
  exit 1
fi

# Pull the viewBox dimensions to size the screenshot window appropriately.
# Falls back to 900x320 if the SVG has no viewBox attribute we can parse.
DIMS=$(grep -oE 'viewBox="[0-9. -]+"' "$INPUT_ABS" | head -1 | sed -E 's/viewBox="[0-9.-]+ +[0-9.-]+ +([0-9.]+) +([0-9.]+)"/\1x\2/' || true)
WIDTH=$(echo "${DIMS:-900x320}" | cut -dx -f1 | cut -d. -f1)
HEIGHT=$(echo "${DIMS:-900x320}" | cut -dx -f2 | cut -d. -f1)

"$CHROME" \
  --headless=new \
  --hide-scrollbars \
  --default-background-color=00000000 \
  --force-device-scale-factor=2 \
  --window-size="${WIDTH},${HEIGHT}" \
  --virtual-time-budget="$VTIME" \
  --screenshot="$OUTPUT_ABS" \
  "file://$INPUT_ABS" >/dev/null 2>&1

echo "✓ $OUTPUT_ABS  (${WIDTH}x${HEIGHT} @2x · t=${VTIME}ms)"
