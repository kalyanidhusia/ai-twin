#!/usr/bin/env bash
# setup_motion_mac.sh — one-time LivePortrait setup on Apple Silicon.
# Adds head/expression motion to a static toon portrait BEFORE it goes into
# MuseTalk for lip-sync. Unlike MuseTalk, LivePortrait can use Apple's MPS
# (Metal) backend with a CPU fallback for unsupported ops — there's no
# documented pure-CPU flag, so expect it to try the GPU path on your Mac.
#
# HONESTY NOTE: unlike setup_avatar_mac.sh, this script has not been run
# end-to-end on real hardware yet — it's built from LivePortrait's own docs
# and verified community macOS forks, not from a working run here. Treat the
# first attempt like every other install in this repo: expect to hit a real
# error and fix it together, then this comment gets deleted and JOURNEY.md
# gets the real story.
#
# LICENSE NOTE: LivePortrait's own code+weights are MIT, but the face
# detection/landmark models it depends on (InsightFace buffalo_l) are
# non-commercial-research-only. Fine for this personal/tutorial project;
# worth knowing if anyone following the tutorial wants to commercialize.
#
# BEFORE running:
#   CONDA_SUBDIR=osx-arm64 conda env create -f environment-motion.yml
#   conda activate ai-twin-motion
#   conda config --env --set subdir osx-arm64
# THEN:  ./setup_motion_mac.sh
set -euo pipefail

echo "== sanity: must be arm64 python in the ai-twin-motion env =="
python -c "import platform,sys; print(sys.prefix); assert platform.machine()=='arm64', 'x86_64 python! recreate env with CONDA_SUBDIR=osx-arm64'"

echo "== 1/3 clone LivePortrait =="
[ -d LivePortrait ] || git clone https://github.com/KwaiVGI/LivePortrait.git
cd LivePortrait

echo "== 2/3 python deps (macOS-specific requirements file) =="
# X-Pose isn't supported on macOS and Animals mode needs it — we only need
# Human mode anyway, so this is a non-issue, not a workaround.
pip install -r requirements_macOS.txt

echo "== 3/3 pretrained weights (~size not confirmed yet — expect a few GB) =="
pip install "huggingface_hub[cli]==0.30.2"   # same pin as the voice/avatar envs, for the same reason
huggingface-cli download KwaiVGI/LivePortrait --local-dir pretrained_weights --exclude "*.git*" "README.md" "docs"

echo ""
echo "✅ Setup done. Smoke-test with their bundled example first (tests the"
echo "   install itself, before we point it at your toon portraits):"
echo "   PYTORCH_ENABLE_MPS_FALLBACK=1 python inference.py \\"
echo "     -s assets/examples/source/s9.jpg \\"
echo "     -d assets/examples/driving/d0.mp4"
echo ""
echo "   If that errors, paste the error — same process as every other"
echo "   install wall we've hit in this project."
