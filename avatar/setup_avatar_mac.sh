#!/usr/bin/env bash
# setup_avatar_mac.sh — one-time MuseTalk setup on Apple Silicon (CPU inference).
# Mirrors MuseTalk's official pins (py3.10, torch 2.0.1, mmcv 2.0.1) exactly —
# this combination is known-good; don't "upgrade" any of it.
#
# BEFORE running:
#   CONDA_SUBDIR=osx-arm64 conda create -n ai-twin-avatar python=3.10 ffmpeg -c conda-forge
#   conda activate ai-twin-avatar
#   conda config --env --set subdir osx-arm64
# THEN:  ./setup_avatar_mac.sh
#
# Expect: ~30-60 min total. The mmcv step COMPILES FROM SOURCE on Mac —
# 20-40 min of warnings is normal, not failure. Weights download ~6GB.
set -euo pipefail

echo "== sanity: must be arm64 python in the ai-twin-avatar env =="
python -c "import platform,sys; print(sys.prefix); assert platform.machine()=='arm64', 'x86_64 python! recreate env with CONDA_SUBDIR=osx-arm64'"

echo "== 1/5 torch 2.0.1 (CPU/arm64) =="
pip install torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2

echo "== 2/5 clone MuseTalk =="
[ -d MuseTalk ] || git clone https://github.com/TMElyralab/MuseTalk.git
cd MuseTalk

echo "== 3/5 python deps (skipping tensorflow/tensorboard — unused at inference, broken pins on arm64) =="
grep -v -E "^(tensorflow|tensorboard)" requirements.txt > /tmp/req_mac.txt
pip install -r /tmp/req_mac.txt

echo "== 4/5 MMLab stack (mmcv compiles from source: 20-40 min, be patient) =="
# mmcv's build script needs pkg_resources, which modern setuptools removed.
# Fix: older setuptools from conda-forge + --no-build-isolation so the build
# uses the env's toolchain instead of an isolated one with new setuptools.
conda install -y -c conda-forge "setuptools<81" wheel ninja
pip install --no-cache-dir -U openmim
mim install mmengine
# -Wno-invalid-specialization: torch 2.0.1's headers specialize std::is_arithmetic,
# which modern clang (Xcode 15.3+) treats as an error. Downgrade it back to a warning.
CFLAGS="-Wno-invalid-specialization" CXXFLAGS="-Wno-invalid-specialization" \
  pip install "mmcv==2.0.1" --no-build-isolation -f https://download.openmmlab.com/mmcv/dist/cpu/torch2.0.0/index.html
mim install "mmdet==3.1.0"
# chumpy (mmpose dep from 2015) does `import pip` in its build script — absent
# in pip's isolated build env. Install it first with the env's own toolchain.
pip install chumpy==0.70 --no-build-isolation
# xtcocotools (another mmpose dep) imports numpy in its build script — same cure.
conda install -y -c conda-forge cython
pip install "xtcocotools>=1.12" --no-build-isolation
mim install "mmpose==1.1.0"

echo "== 5/5 model weights (~6GB from Hugging Face) =="
# Pin hub to MuseTalk's own requirement — hub 2.x renamed huggingface-cli away
# and breaks transformers 4.39's pins. (Upstream's -U flag is a trap.)
pip install "huggingface_hub[cli]==0.30.2" gdown
mkdir -p models/musetalkV15 models/dwpose models/face-parse-bisent models/sd-vae models/whisper
huggingface-cli download TMElyralab/MuseTalk --local-dir models --include "musetalkV15/musetalk.json" "musetalkV15/unet.pth"
huggingface-cli download stabilityai/sd-vae-ft-mse --local-dir models/sd-vae --include "config.json" "diffusion_pytorch_model.bin"
huggingface-cli download openai/whisper-tiny --local-dir models/whisper --include "config.json" "pytorch_model.bin" "preprocessor_config.json"
huggingface-cli download yzd-v/DWPose --local-dir models/dwpose --include "dw-ll_ucoco_384.pth"
gdown --id 154JgKpzCPW82qINcVieuPH3fZ2e0P812 -O models/face-parse-bisent/79999_iter.pth || \
  echo "!! gdown rate-limited — download 79999_iter.pth manually (link in MuseTalk README) into models/face-parse-bisent/"
curl -L https://download.pytorch.org/models/resnet18-5c106cde.pth -o models/face-parse-bisent/resnet18-5c106cde.pth

echo ""
echo "✅ Setup done. Smoke-test with their sample first:"
echo "   ../run_avatar_mac.sh data/video/yongen.mp4 data/audio/yongen.wav sample_test"
