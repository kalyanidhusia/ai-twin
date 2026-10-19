#!/usr/bin/env bash
# check_base_video.sh — verify a candidate avatar base video before using it.
# Usage: ./check_base_video.sh video.mp4
# Checks: duration, resolution, fps, codec. Prints pass/fix-needed notes.
set -euo pipefail
in="${1:?usage: check_base_video.sh video.mp4}"
echo "=== $in ==="
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,r_frame_rate:format=duration \
  -of default=noprint_wrappers=1 "$in"
echo ""
echo "Targets for MuseTalk base video:"
echo "  duration : 60-120 s"
echo "  fps      : 25 (convert with trim_base_video.sh if not)"
echo "  framing  : chest-up, face large in frame, camera locked, no burned-in text"
echo "  the face region gets processed at 256x256 - a big, steady face wins"
