# Acknowledgments

This project builds on remarkable open-source work. Nothing here would exist without
the projects below. Strengths and weaknesses are **our own field observations** from
building a bilingual (English + Hindi) AI twin on an Apple Silicon Mac, CPU-only —
they describe fit for *this* use case, not overall quality.

## Core models

### [Chatterbox Multilingual](https://github.com/resemble-ai/chatterbox) — Resemble AI
Voice cloning (both languages). **License: MIT** (models included).
- **Strengths:** zero-shot — no training step at all; 23 languages including Hindi
  with a dedicated Hindi finetune available; built-in Perth watermarking for
  responsible-AI provenance; quality we judged excellent on ~15s references.
- **Weaknesses observed:** pip package can lag the repo (V2 checkpoint, no `t3_model`
  arg); depends on `perth`, which imports the removed `pkg_resources`
  (fix: `setuptools<81`); output can be slightly hot — normalize before lip-sync.

### [MuseTalk](https://github.com/TMElyralab/MuseTalk) — Tencent Music Entertainment Lyra Lab
Audio-driven lip-sync onto real footage. **License: MIT (code); trained models
"available for any purpose, even commercially" (their README).**
- **Strengths:** no per-person training — one base video, then any audio forever;
  built-in CPU fallback made a no-CUDA Mac port possible; near-real-time even on
  M-series CPU (~5 it/s); gestures and identity come from your real footage.
- **Weaknesses observed:** heavy MMLab dependency chain (mmcv compiles from source
  on macOS, ~30 min, needs `-Wno-invalid-specialization` with modern clang);
  `download_weights.sh` uses removed `gdown --id` syntax; authors' own stated
  limits: 256×256 face region, lip shape/color not fully preserved, single-frame
  jitter; default `bbox_shift=0` left the mouth too open during speech pauses
  in our tests — tune it.

## Infrastructure

| Project | Role here | License |
|---|---|---|
| [ffmpeg](https://ffmpeg.org) | every audio/video prep step | LGPL/GPL |
| [OpenMMLab](https://openmmlab.com) (mmcv/mmdet/mmpose) | facial landmarks for MuseTalk | Apache-2.0 |
| [OpenAI Whisper](https://github.com/openai/whisper) (tiny) | MuseTalk's audio encoder | MIT |
| [sd-vae-ft-mse](https://huggingface.co/stabilityai/sd-vae-ft-mse) (Stability AI) | MuseTalk's latent codec | MIT |
| [DWPose](https://github.com/IDEA-Research/DWPose) | pose model in preprocessing | Apache-2.0 |
| [face-parsing.PyTorch](https://github.com/zllrunning/face-parsing.PyTorch), [S3FD](https://github.com/yxlijun/S3FD.pytorch), [face-alignment](https://github.com/1adrianb/face-alignment) | face detection/parsing | see repos |
| conda / [conda-forge](https://conda-forge.org) | reproducible environments | BSD |

## Citations

MuseTalk (per their repo):
```bib
@article{musetalk,
  title={MuseTalk: Real-Time High-Fidelity Video Dubbing via Spatio-Temporal Sampling},
  author={Zhang, Yue and Zhong, Zhizhou and Liu, Minhao and Chen, Zhaokang and Wu, Bin and Zeng, Yubin and Zhan, Chao and He, Yingjie and Huang, Junxin and Zhou, Wenjiang},
  journal={arxiv},
  year={2025}
}
```

## Giving back
Bugs we hit and fixed here are reported upstream where they belong — see the
issues linked from [docs/JOURNEY.md](docs/JOURNEY.md) as they're filed.
