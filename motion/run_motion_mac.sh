#!/usr/bin/env bash
# run_motion_mac.sh — animate ONE toon portrait with ONE driving video via
# LivePortrait, on Apple Silicon (MPS, falls back to CPU for unsupported ops).
# Run from the folder that CONTAINS LivePortrait/ (it cd's in), env
# ai-twin-motion active.
#
# Usage: ./run_motion_mac.sh <portrait.png> <driving_video.mp4> <label>
# Example (reuse an existing real talking-head clip as the driving source —
# you already have several from the avatar work, e.g. Avatarbase_25fpsprepped.mp4):
#   ./run_motion_mac.sh portraits/redshirt_toon.png driving/Avatarbase_25fpsprepped.mp4 redshirt_v1
#
# OUTPUT PATH CAVEAT: LivePortrait's own default output location isn't
# confirmed here (first real run will tell us). This script doesn't guess a
# fixed path — it just checks whether ANY new .mp4 showed up anywhere under
# LivePortrait/ after the run, the same fail-fast principle as
# run_avatar_mac.sh. Once we see the real path, this gets tightened.
set -euo pipefail
portrait="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
driving="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
[ -f "$portrait" ] || { echo "❌ portrait not found: $1"; exit 1; }
[ -f "$driving" ] || { echo "❌ driving video not found: $2"; exit 1; }
label="${3:?usage: run_motion_mac.sh portrait.png driving_video.mp4 label}"

cd LivePortrait
start_marker="$(mktemp)"

echo "Animating '${label}' — this is a first real run, watch for the actual error if it fails."
PYTORCH_ENABLE_MPS_FALLBACK=1 python inference.py -s "$portrait" -d "$driving"

out_file="$(find . -newer "$start_marker" -name '*.mp4' -print 2>/dev/null | head -1)"
rm -f "$start_marker"

if [ -n "$out_file" ]; then
  echo ""
  echo "✅ Output: LivePortrait/${out_file#./}"
  echo "   (rename/move it somewhere under motion/ so the next run doesn't"
  echo "   confuse it with this one — naming convention still TBD)"
else
  echo ""
  echo "❌ No new .mp4 appeared anywhere under LivePortrait/ — scroll up for"
  echo "   the real error. inference.py may have printed something useful"
  echo "   even if it didn't produce a clean exit."
  exit 1
fi
