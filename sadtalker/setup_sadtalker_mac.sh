#!/usr/bin/env bash
# setup_sadtalker_mac.sh — clone SadTalker + install its (non-conda) deps + fetch checkpoints.
# Run from the project root, with `ai-twin-sadtalker` conda env already created and active:
#   conda env create -f sadtalker/environment-sadtalker.yml
#   conda activate ai-twin-sadtalker
#   ./sadtalker/setup_sadtalker_mac.sh
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -d "SadTalker" ]; then
  git clone https://github.com/OpenTalker/SadTalker.git
else
  echo "SadTalker/ already exists, skipping clone."
fi

cd SadTalker

# dlib comes from conda-forge (installed by environment-sadtalker.yml), not pip —
# pip's dlib build fails on Apple Silicon. Strip it from requirements.txt so a
# version-pin mismatch can't make pip try to rebuild it from source anyway.
grep -vi '^dlib' requirements.txt > requirements.nodlib.txt

# Everything else in requirements.txt (face-alignment, imageio, etc.) isn't on
# conda-forge reliably for this project — pip is the documented, justified path
# for those, not a shortcut around conda-first.
pip install -r requirements.nodlib.txt

# Official checkpoint download script (pulls from GitHub Releases / HF — no
# manual Google Drive steps needed on current main).
bash scripts/download_models.sh

echo ""
echo "✅ SadTalker cloned + checkpoints downloaded."
echo "Check SadTalker/LICENSE yourself before relying on any license claim —"
echo "mirrors disagree (MIT vs. an Apache-2.0-with-non-commercial-clause-removed claim)."
