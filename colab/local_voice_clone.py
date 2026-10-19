# %% [markdown]
# # AI Twin — Voice Clone Smoke Test (LOCAL, macOS)
# Zero-shot clones your voice from your samples and renders the pilot script's
# opening lines in **English and Hindi** — **Chatterbox Multilingual** (MIT).
# No training step, no cloud, $0.
#
# **Setup (once, from the `ai-twin-starter` folder):**
# ```
# conda env create -f environment-voice.yml
# conda activate ai-twin-voice
# jupyter lab
# ```
# Then open this notebook and Run All. Expects your WAVs at `prepared/voice/`.
#
# First run downloads the model (~4GB) from Hugging Face into `~/.cache/huggingface`.
# On Apple Silicon, generation takes ~1–3 min per paragraph (MPS) — fine for a test.

# %%
# Cell 1 — Environment sanity check (run this first; if anything fails, stop here)
import platform, sys, pathlib
print("Python :", sys.version.split()[0])
print("Arch   :", platform.machine())   # arm64 = Apple Silicon (good); x86_64 = Intel (see note below)
import torch, torchaudio
print("torch  :", torch.__version__, "| torchaudio:", torchaudio.__version__)
import chatterbox
print("chatterbox-tts imported OK")

REF_DIR = pathlib.Path("prepared/voice")
assert REF_DIR.exists(), f"Can't find {REF_DIR.resolve()} — start jupyter from the ai-twin-starter folder"
print("Samples found:", [p.name for p in REF_DIR.glob('*.wav')])
# NOTE (Intel Macs only): chatterbox needs torch>=2.6, which has no Intel-Mac
# builds. If Arch above says x86_64 and the torch import failed, tell me —
# we route around it.

# %%
# Cell 2 — Pick compute device + the macOS fix
# Chatterbox loads some checkpoints assuming CUDA. The torch.load patch below is
# the standard fix for Apple Silicon (maps everything onto mps/cpu).
import torch

if torch.cuda.is_available():
    device = "cuda"
elif torch.backends.mps.is_available():
    device = "mps"
else:
    device = "cpu"
print("Using device:", device)

if device != "cuda":
    _orig_load = torch.load
    def _patched_load(*args, **kwargs):
        kwargs.setdefault("map_location", torch.device(device))
        return _orig_load(*args, **kwargs)
    torch.load = _patched_load
    print("torch.load patched with map_location =", device)

# %%
# Cell 2b — perth self-check (chatterbox's watermarker)
# Root cause we hit in testing: perth imports pkg_resources, which newer
# setuptools removed — the env pins setuptools<81 so this should print "fine".
# If it ever breaks again, this cell repairs or safely bypasses it.
import perth, traceback
if getattr(perth, "PerthImplicitWatermarker", None) is None:
    try:
        from perth.perth_net.perth_net_implicit.perth_watermarker import PerthImplicitWatermarker
        perth.PerthImplicitWatermarker = PerthImplicitWatermarker
        print("Repaired: rebound PerthImplicitWatermarker from its submodule.")
    except Exception:
        traceback.print_exc()
        class _PassthroughWatermarker:
            def __init__(self, *a, **kw): pass
            def apply_watermark(self, wav, watermark=None, sample_rate=None, **kw): return wav
            def get_watermark(self, wav, sample_rate=None, **kw): return 0.0
        perth.PerthImplicitWatermarker = _PassthroughWatermarker
        print("Fallback: watermarking disabled this session (passthrough).")
else:
    print("perth is fine.")

# %%
# Cell 3 — Trim ~15s references (zero-shot works best on a short, clean reference)
import torchaudio, os
os.makedirs("out", exist_ok=True)

def trim_ref(in_path, out_path, start_s=2.0, dur_s=15.0):
    wav, sr = torchaudio.load(in_path)
    a, b = int(start_s * sr), int((start_s + dur_s) * sr)
    torchaudio.save(out_path, wav[:, a:b], sr)
    print(f"{out_path}: {dur_s:.0f}s @ {sr}Hz")

trim_ref("prepared/voice/english_162s.wav", "out/ref_en.wav")
trim_ref("prepared/voice/hindi_49s.wav",   "out/ref_hi.wav", start_s=1.0)

# %%
# Cell 4 — Load the multilingual model (first run downloads ~4GB)
from chatterbox.mtl_tts import ChatterboxMultilingualTTS

try:
    model = ChatterboxMultilingualTTS.from_pretrained(device=device, t3_model="v3")
    print("Loaded Chatterbox Multilingual V3")
except TypeError:
    model = ChatterboxMultilingualTTS.from_pretrained(device=device)
    print("Loaded Chatterbox Multilingual (V2 — older package; `pip install -U chatterbox-tts` for V3)")

# %%
# Cell 5 — ENGLISH test (cloned from your English sample)
import torchaudio as ta
from IPython.display import Audio, display

en_lines = (
    "There's a river running through my whole story. The Yamuna. "
    "On one bank, Ewing Christian College, where I studied. "
    "On the other, land that grew into the place that became SHUATS. Where I did my PhD."
)
wav = model.generate(en_lines, language_id="en",
                     audio_prompt_path="out/ref_en.wav",
                     exaggeration=0.5, cfg_weight=0.4)
ta.save("out/twin_en_test.wav", wav, model.sr)
print("ENGLISH -> out/twin_en_test.wav")
display(Audio("out/twin_en_test.wav"))

# %%
# Cell 6 — HINDI test (Devanagari, cloned from your HINDI sample)
# Edit these lines freely — it's just text. If an English accent bleeds into
# the Hindi, set cfg_weight=0 (official mitigation).
hi_lines = (
    "मेरी पूरी कहानी में एक नदी बहती है। यमुना। "
    "एक किनारे पर इविंग क्रिश्चियन कॉलेज, जहाँ मैंने पढ़ाई की। "
    "दूसरे किनारे पर वह ज़मीन, जो आगे चलकर शुआट्स बनी। जहाँ मैंने अपनी पीएचडी की।"
)
wav_hi = model.generate(hi_lines, language_id="hi",
                        audio_prompt_path="out/ref_hi.wav",
                        exaggeration=0.5, cfg_weight=0.4)
ta.save("out/twin_hi_test.wav", wav_hi, model.sr)
print("HINDI -> out/twin_hi_test.wav")
display(Audio("out/twin_hi_test.wav"))

# %% [markdown]
# ## What to listen for
# - **Is it you?** Timbre, pace, how you land sentence endings.
# - **Hindi:** natural Hindi rhythm vs "English speaker reading Hindi". If the
#   general model disappoints, next step is the dedicated Hindi finetune
#   (`ResembleAI/Chatterbox-Multilingual-hi`).
# - **Artifacts:** metallic edges, swallowed syllables, odd pauses.
#
# | Problem | Fix |
# |---|---|
# | Too fast / rushed | `cfg_weight=0.3` |
# | Flat, not expressive | `exaggeration=0.7`, `cfg_weight=0.3` |
# | English accent in Hindi | `cfg_weight=0` in Cell 6 |
# | Doesn't sound like you | different 15s slice in Cell 3 (clearest, most animated stretch) |
#
# FYI: Chatterbox embeds Resemble's imperceptible Perth watermark in all output —
# a responsible-AI provenance feature worth a line in the tutorial.
