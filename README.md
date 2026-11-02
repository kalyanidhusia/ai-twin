# ai-twin — clone your own voice and face for $0

Build a bilingual (English + Hindi) AI twin of yourself with open-source tools,
on your own machine. No subscriptions, no uploads of your voice or face to
anyone's cloud. This repo is both a working pipeline and a journey log — the
dead ends are documented on purpose, in [docs/JOURNEY.md](docs/JOURNEY.md).

**Status:** voice cloning works · avatar lip-sync works (tuned via a
`bbox_shift` sweep) · full bilingual pilot videos in progress.

## See it in action

<!--
  HOW TO FILL THIS IN — without ever committing a video/audio file to git:
  1. Edit this file on github.com (pencil icon).
  2. Drag a short clip into the editor (free-plan limit: 10MB — trim/compress
     each clip to a few seconds for this table; the full videos can live
     elsewhere, e.g. an unlisted YouTube link).
  3. GitHub uploads it to its own asset host and inserts a link that looks like
     https://user-images.githubusercontent.com/<id>/<name>.mp4 (or
     https://github.com/user-attachments/assets/<id>).
  4. Copy that URL into the matching src= below, then replace this comment.
  The file never enters git history this way — it's hosted by GitHub's asset
  CDN, not tracked as a repo blob. Same privacy rule as everywhere else in
  this repo: the clip is still becoming public the moment you upload it, so
  only do this with footage/audio you're fine sharing.
-->

<table>
<tr>
<th>Base video</th>
<th>AI twin — human</th>
<th>AI twin — toon</th>
</tr>
<tr>
<td><video src="PASTE_BASE_VIDEO_URL_HERE" controls width="260"></video></td>
<td><video src="PASTE_HUMAN_TWIN_URL_HERE" controls width="260"></video></td>
<td><video src="PASTE_TOON_TWIN_URL_HERE" controls width="260"></video></td>
</tr>
<tr>
<td>Real footage, unmodified</td>
<td>MuseTalk lip-sync on real footage + Chatterbox-cloned voice</td>
<td>Same pipeline on a stylized portrait — no real face, same cloned voice</td>
</tr>
</table>

*If the table doesn't render a player for you, GitHub's HTML sanitizer can be
inconsistent inside tables — fall back to three separate `<video>` blocks
stacked vertically instead.*

## What you need
- A Mac (Apple Silicon) or Linux machine — or any machine plus a free GPU
  (a research platform like NRP, or Colab if you don't mind the quota limits)
- ~5 minutes of clean recordings of your own voice (phone voice memos are fine);
  include a sample in each language you want the twin to speak
- One short video of yourself (a few seconds, steady framing, decent light)
  for the avatar step
- conda (Miniconda/Miniforge)

## Quick start — voice
```bash
# 1. prep env (audio cleanup tools)
conda env create -f environment.yml

# 2. voice env — the CONDA_SUBDIR prefix is REQUIRED on Apple Silicon if your
#    conda is the Intel build (check: `uname -m` vs `python -c "import platform; print(platform.machine())"`)
CONDA_SUBDIR=osx-arm64 conda env create -f environment-voice.yml
conda activate ai-twin-voice
conda config --env --set subdir osx-arm64

# 3. clean your recordings into training-ready WAVs
./scripts/prepare_audio.sh my_recording.m4a prepared/voice/my_sample.wav

# 4. run the notebook
jupyter lab   # open colab/local_voice_clone.ipynb, Run All
```

## Quick start — avatar (lip-synced video)
```bash
# one-time setup (~30-60 min on Apple Silicon — one dependency compiles from
# source; that's expected, not a failure. Details: docs/JOURNEY.md)
CONDA_SUBDIR=osx-arm64 conda create -n ai-twin-avatar python=3.10 ffmpeg -c conda-forge
conda activate ai-twin-avatar
conda config --env --set subdir osx-arm64
cd avatar && ./setup_avatar_mac.sh

# render: your base video + a cloned-voice WAV -> lip-synced video
caffeinate -i ./run_avatar_mac.sh your_video.mp4 your_cloned_audio.wav twin_v1 -5
# -5 is the bbox_shift value that worked best in our own testing (default is 0);
# if your footage differs, the run prints a suggested range to try instead.
```

## The stack (all free)
| Piece | Tool | License |
|---|---|---|
| Voice clone (23 languages incl. Hindi) | [Chatterbox Multilingual](https://github.com/resemble-ai/chatterbox) (Resemble AI) | MIT (models included) |
| Lip-synced avatar | [MuseTalk](https://github.com/TMElyralab/MuseTalk) (TMElyralab) | MIT code; models usable commercially |
| Audio/video prep | ffmpeg | LGPL/GPL |
| Subtitles (coming) | Whisper | MIT |

Strengths and weaknesses we actually hit for each (not marketing copy —
field notes): [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md)

## Repo layout
```
ai-twin/
├── colab/        # voice-clone notebooks — run locally in Jupyter, not Colab
│                 #   (name is a holdover from the very first attempt;
│                 #    see docs/JOURNEY.md)
├── avatar/       # MuseTalk setup + render scripts for macOS (CPU)
├── scripts/      # audio/video prep utilities
├── docs/JOURNEY.md        # the full build log — dead ends included, dated
├── ACKNOWLEDGMENTS.md     # every upstream project this depends on, credited honestly
├── environment.yml        # prep env (conda)
└── environment-voice.yml  # voice-clone env (conda)
```
MuseTalk itself is cloned by `setup_avatar_mac.sh`, not vendored in this repo.

## Ethics, non-negotiable
- Clone **only your own voice and face**, or with the explicit, informed
  consent of the person being cloned.
- Keep your raw samples, generated audio, and source footage private — they
  are biometric identity, cloned audio included. This repo's `.gitignore`
  blocks all of that from ever being committed; keep it that way, including
  in the demo clips above (they're hosted outside git on purpose — see the
  comment in that section).
- Chatterbox watermarks its voice output (Resemble Perth) — leave that on.

## Giving back
Bugs found while building this get reported upstream, not just worked around
locally — e.g. [MuseTalk #427](https://github.com/TMElyralab/MuseTalk/issues/427).
More context on each dependency's rough edges: [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

## License
This repo has no `LICENSE` file yet — add one before calling it done (MIT
would keep it in the spirit of everything it depends on). Upstream project
licenses are listed in [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

## Journey log
Every step, fix, and dead end, dated: [docs/JOURNEY.md](docs/JOURNEY.md)
