# AI Twin — journey log
*Raw record of every step, decision, and dead end. This becomes the free public tutorial once the twin meets Kalyani's bar. $0 rule: everything here uses free tools; any paid detour gets declared explicitly.*

## Ground rules
- Self-hosted / open-source (Path C). Voice samples and models stay in Kalyani's control.
- Bilingual: every video ships as two full versions, Hindi and English. No code-mixing.
- Nothing posted anywhere without explicit approval.
- Budget: $0. Free compute order of preference: local Mac (prep) → Google Colab free tier (GPU smoke tests) → NRP (real GPU runs).

## Stack decisions
| Piece | Tool | Why | License |
|---|---|---|---|
| Voice clone | GPT-SoVITS | trains on ~1 min; strong Hindi when Hindi is in the training set | MIT |
| Avatar (footage route) | MuseTalk v1.5 | lip-sync onto real footage of yourself; no per-person training | check before commercial use — field unasserted |
| Avatar (photo fallback) | SadTalker | single photo → talking head; clean Apache-2.0 license for the tutorial | Apache-2.0 |
| Audio/video prep | ffmpeg | everything | LGPL/GPL |
| Subtitles | Whisper (local) | free, good Hindi + English | MIT |

## Hardware plan (macOS reality)
- **Mac (local, conda env):** all data prep — audio cleanup, video trimming/25fps conversion, subtitle generation. GPT-SoVITS *inference* can run on Apple Silicon (slow but works).
- **GPT-SoVITS training:** needs CUDA for good results (Mac-trained models are known lower quality). → Colab free tier first; NRP when ready.
- **MuseTalk:** CUDA-only in practice. → Colab free / NRP.

## Log

### 2026-10-18 — project start
- Voice samples in hand (~4.7 min total): 72s English (postdoc story), 162s English (strategic-communication piece), 49s Hindi (film-lyrics recitation).
- 162s English + 49s Hindi samples cleaned and normalized → `prepared/voice/*.wav` (mono 44.1kHz, -19 LUFS, denoised, no clipping, no dead gaps). 72s sample still to be run through `scripts/prepare_audio.sh`.
- Decisions: start local on Mac with conda env; NRP later for GPU; $0 until declared otherwise; journey logged for the eventual public tutorial.
- 2021 YouTube lecture considered as avatar base footage — likely unsuitable (webinar framing, small webcam region); fresh phone video preferred. Base video still the main blocker.
- Scripts written: `prepare_audio.sh`, `trim_base_video.sh`, `check_base_video.sh`; `environment.yml` for the Mac conda env.

### next up
- [ ] Kalyani: install conda env, run `prepare_audio.sh` on the 72s English sample (or upload it)
- [ ] Kalyani: shoot or trim one static 60–90s chest-up clip → run `check_base_video.sh` → upload
- [ ] Colab free: GPT-SoVITS smoke test on the three cleaned samples
- [ ] Compare clone against pilot-script lines (EN + HI)
- [ ] MuseTalk first render on the base video
