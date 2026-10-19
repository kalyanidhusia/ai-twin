#!/usr/bin/env bash
# qc_frames.sh — make a small contact sheet (1 frame/sec) from a candidate video
# so framing/steadiness can be reviewed without sharing the video itself.
# Usage: ./qc_frames.sh myclip.mp4   ->  myclip_contactsheet.jpg (a few hundred KB)
set -euo pipefail
in="${1:?usage: qc_frames.sh video.mp4}"
out="${in%.*}_contactsheet.jpg"
n=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in" | cut -d. -f1)
cols=5; rows=$(( (n + cols - 1) / cols )); [ "$rows" -lt 1 ] && rows=1
ffmpeg -y -v error -i "$in" -vf "fps=1,scale=220:-2,tile=${cols}x${rows}" "$out"
ls -lh "$out"
echo "Upload $out to the chat — it's tiny. The video stays on your machine."
