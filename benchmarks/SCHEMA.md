# Benchmark Harness Schema

Living document. One row in `results_template.csv` per model run. Fill in
real numbers only — if something wasn't actually measured, write
`not measured`, never a guess.

## Columns

| Column | Meaning |
|---|---|
| `model` | Name of the model/tool tested (e.g. SadTalker, LivePortrait+MuseTalk) |
| `version` | Commit hash, release tag, or date of the clone used |
| `source_url` | GitHub/HF link to the exact tool tested |
| `input_type` | image+audio / image+video+audio / etc. |
| `character_style` | real-photo / toon-2d / toon-3d-pixar-style / etc. |
| `runtime_seconds` | Wall-clock time for the test clip, if timed |
| `hardware` | Mac (CPU) / Mac (MPS) / Colab T4 / NRP A100 / etc. |
| `peak_memory_gb` | Peak RAM/VRAM used, if measured |
| `output_resolution` | e.g. 2304x4096, from ffprobe |
| `output_fps` | from ffprobe |
| `output_duration_s` | from ffprobe — should match input audio duration |
| `lip_sync_score` | Any formal sync metric used (Sync-C/Sync-D, etc.), or "not measured" |
| `identity_similarity_score` | Any formal identity metric, or "not measured" |
| `temporal_stability_notes` | Jitter/flicker/drift, visually assessed if no metric exists |
| `visual_quality_notes` | Plain-language verdict, e.g. "sharper but same grafted-mouth issue" |
| `human_rating_1_to_5` | Kalyani's own subjective rating, or "not rated" |
| `license_type` | Pull from docs/LICENSES.md — don't re-derive here |
| `license_commercial_ok` | yes / no / disputed / unverified |
| `failure_notes` | Specific, concrete failure mode observed |
| `date_tested` | YYYY-MM-DD |
| `tester` | Who ran it |

## Rules
- Never commit the actual test video/audio — `results/`, `*.mp4`, `*.wav`
  are already in `.gitignore`. Only the metrics row goes in git.
- A blank or guessed number is worse than "not measured" — this table is
  only useful if every filled cell is something that was actually checked.
- Re-run the *same* input image + audio pair across every model being
  compared — the whole point is apples-to-apples, not best-case-per-model.
