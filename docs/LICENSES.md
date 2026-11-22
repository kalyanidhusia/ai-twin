# License Tracking

Living document, last updated 2026-11-21. Consolidates everything checked
across this project's research so far. **Status** column: `Verified` =
checked directly against a primary source in this project; `Disputed` =
checked, but sources disagree; `Not verified` = flagged, needs a direct
check before relying on it — especially before any public sharing, given
this project's goal of a fully traceable public tutorial.

| Tool | Code license | Weights/model license | Commercial use | Notes | Status |
|---|---|---|---|---|---|
| LivePortrait (KwaiVGI) | MIT | Depends on InsightFace `buffalo_l` — non-commercial, research-only | ⚠️ Code is MIT but the face-detection model it depends on isn't | The InsightFace dependency is the real constraint, not LivePortrait's own code | Verified |
| MuseTalk (TMElyralab) | MIT | Weights usable "for any purpose, even commercially" per README; **test data is non-commercial-only** | ✅ code + weights; ⚠️ test data only | — | Verified |
| SadTalker (OpenTalker) | Disputed — one mirror: MIT/Tencent AI Lab 2023; another claims updated Apache-2.0 with non-commercial clause removed | same as code | Uncertain | **Action: check your own clone's LICENSE file directly** — never resolved definitively in research | Disputed |
| LatentSync (ByteDance) | Apache-2.0, no disclaimer found | same | ✅ appears clean | Real 2025 release activity (v1.5 Mar 2025, v1.6 Jun 2025) | Verified |
| AniPortrait | Apache-2.0 per Hugging Face tag | Not independently confirmed on GitHub directly | Likely OK, unconfirmed | — | Partially verified |
| V-Express (Tencent AI Lab) | Hugging Face tag says Apache-2.0; GitHub README says weights are non-commercial-research-only | same | ❌ treat as non-commercial until resolved | Maintainer's own clarification attempt left this unresolved | Disputed |
| EchoMimicV2 | Apache-2.0 tag, but README disclaims "academic research" use | same | ❌ treat as non-commercial | — | Disputed |
| DreamTalk | MIT tag vs. README's "RESEARCH/NON-COMMERCIAL USE ONLY" | same | ❌ non-commercial | Abandoned — no commits since Jan 2024, checkpoints no longer downloadable | Verified (and abandoned) |
| Hallo / Hallo2 / Hallo3 | Not found in research | Not found | Unknown | — | **Not verified** |
| Wav2Lip + derivatives | Not retrieved in research | Not retrieved | Unknown | — | **Not verified** |
| Rhubarb Lip Sync (DanielSWolf) | MIT License | MIT (third-party deps are MIT/BSD/similar permissive) | Confirmed commercial-OK — LICENSE.md states "you can use Rhubarb Lip Sync in almost any way you want, including the creation of commercial software based on it" | Verified directly against LICENSE.md, 2026-11-21 | Verified |
| HunyuanVideo-Avatar (Tencent) | Tencent Hunyuan Community License Agreement — custom, not OSI-standard | same | ⚠️ Excludes EU/UK/South Korea from authorized use; doesn't block US use but is non-standard | Also ruled out on hardware — 24–96GB VRAM, infeasible for this project regardless of license | Verified |
| IP-Adapter FaceID / InstantID / PhotoMaker | Not confirmed in research | Not confirmed | Unknown | Already ruled out on technical grounds — all three depend on real-face-recognition backbones unsuited to toon input | **Not verified — low priority, already disqualified** |

## Standing rule
When a license is disputed or unverified, default to the strictest
reading (treat as non-commercial / no public redistribution) until a
direct check of the actual LICENSE file resolves it. This matters most
before anything is published as part of the public tutorial — not for
private local testing.
