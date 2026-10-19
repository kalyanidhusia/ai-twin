#!/usr/bin/env bash
# prepare_audio.sh — turn any phone recording into a clean, training-ready WAV.
# Usage: ./prepare_audio.sh input.m4a output.wav
# What it does: mono, 44.1kHz, rumble filter (<60Hz), gentle denoise,
# loudness-normalize to -19 LUFS with -1.5dB true-peak ceiling.
set -euo pipefail
in="${1:?usage: prepare_audio.sh input.(m4a|wav|mp3) output.wav}"
out="${2:?usage: prepare_audio.sh input output.wav}"
ffmpeg -y -i "$in" -ac 1 -ar 44100 \
  -af "highpass=f=60,afftdn=nf=-28,loudnorm=I=-19:TP=-1.5:LRA=9" \
  "$out"
echo "--- levels check ---"
ffmpeg -i "$out" -af volumedetect -f null - 2>&1 | grep -E "mean_volume|max_volume"
echo "Good: mean around -19 dB, max <= -1.5 dB."
