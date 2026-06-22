#!/usr/bin/env bash
# Snapshot an animated SVG at multiple time points across one 6s cycle, so you
# can flip through the frames and verify each animation behaves as designed.
#
# Usage: ./scripts/render-frames.sh <input.svg> [output-dir]
#
# Defaults:
#   output-dir = /tmp/svg-frames-<basename>
#
# Outputs eight PNGs at t = 500, 1000, 1500, 2500, 3500, 4500, 5500, 5900 ms.

set -euo pipefail

INPUT="${1:?usage: render-frames.sh <input.svg> [output-dir]}"
BASE="$(basename "$INPUT" .svg)"
OUTDIR="${2:-/tmp/svg-frames-$BASE}"

mkdir -p "$OUTDIR"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RENDER="$SCRIPT_DIR/render.sh"

for t in 500 1000 1500 2500 3500 4500 5500 5900; do
  "$RENDER" "$INPUT" "$t" "$OUTDIR/$BASE-${t}ms.png"
done

echo ""
echo "Frames in $OUTDIR/"
ls -la "$OUTDIR/" | tail -n +2
