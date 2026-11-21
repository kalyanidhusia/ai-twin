#!/usr/bin/env bash
# run_sadtalker_mac.sh — single-stage image+audio -> talking-head video, on CPU/MPS.
# Run from the folder that CONTAINS SadTalker/ (it cd's in), env ai-twin-sadtalker active.
# Usage: ./run_sadtalker_mac.sh <portrait.png> <cloned_audio.wav> <output_name>
set -euo pipefail

image="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
audio="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"

[ -f "$image" ] || { echo "❌ image not found: $1"; exit 1; }
[ -f "$audio" ] || { echo "❌ audio not found: $2"; exit 1; }
name="${3:?usage: run_sadtalker_mac.sh image audio output_name}"

cd SadTalker

echo "Rendering '${name}' — still mode, full-crop preprocessing, gfpgan enhancer."
python inference.py \
  --driven_audio "$audio" \
  --source_image "$image" \
  --result_dir "./results/${name}" \
  --still \
  --preprocess full \
  --enhancer gfpgan

out_file="$(find "results/${name}" -name "*.mp4" 2>/dev/null | head -1)"
if [ -n "$out_file" ]; then
  echo ""
  echo "✅ Output: SadTalker/${out_file}"
else
  echo ""
  echo "❌ No output video produced — scroll up for the real error."
  exit 1
fi
