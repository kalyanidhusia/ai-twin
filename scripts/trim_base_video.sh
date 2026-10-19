#!/usr/bin/env bash
# trim_base_video.sh — cut a static 60–90s segment out of a longer video,
# re-encode to MuseTalk-friendly format: 1080p max, 25fps, H.264, modest size.
# Usage: ./trim_base_video.sh input.mp4 START DURATION output.mp4
# Example: ./trim_base_video.sh lecture.mp4 00:02:10 75 base_video.mp4
set -euo pipefail
in="${1:?usage: trim_base_video.sh input START DURATION output}"
start="${2:?start time, e.g. 00:02:10}"
dur="${3:?duration in seconds, e.g. 75}"
out="${4:?output file}"
ffmpeg -y -ss "$start" -i "$in" -t "$dur" \
  -vf "scale='min(1920,iw)':-2,fps=25" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
  -c:a aac -b:a 128k -ac 1 \
  "$out"
ls -lh "$out"
echo "If this is >100MB, raise -crf to 23 and rerun."
