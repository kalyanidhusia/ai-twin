#!/usr/bin/env bash
# run_avatar_mac.sh — lip-sync YOUR audio onto YOUR base video with MuseTalk v1.5, on CPU.
# Run from the folder that CONTAINS MuseTalk/ (it cd's in), env ai-twin-avatar active.
# Usage: ./run_avatar_mac.sh <base_video.mp4> <cloned_audio.wav> <output_name>
# Example:
#   caffeinate -i ./run_avatar_mac.sh ~/ai-twin/clip/base.mp4 ~/ai-twin/out/twin_hi_test.wav twin_hi_v1
#   (caffeinate -i stops macOS from sleeping mid-render — use it for long runs)
set -euo pipefail
video="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
audio="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
name="${3:?usage: run_avatar_mac.sh video audio output_name [bbox_shift]}"
shift_val="${4:-0}"   # lip-sync strength knob; try -7..+7, watch the suggested range the run prints

cd MuseTalk
export FFMPEG_PATH="$(dirname "$(which ffmpeg)")"

cat > "configs/inference/${name}.yaml" <<EOF
task_0:
 video_path: "${video}"
 audio_path: "${audio}"
 bbox_shift: ${shift_val}
EOF

echo "Rendering '${name}' on CPU — slow is fine; it finishes."
python -m scripts.inference \
  --inference_config "configs/inference/${name}.yaml" \
  --result_dir "./results/${name}" \
  --unet_model_path "./models/musetalkV15/unet.pth" \
  --unet_config "./models/musetalkV15/musetalk.json" \
  --version v15 \
  --batch_size 2 \
  --ffmpeg_path "$FFMPEG_PATH"

echo ""
echo "✅ Output in MuseTalk/results/${name}/"
