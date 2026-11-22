import torch
from diffusers import StableDiffusionXLImg2ImgPipeline
from PIL import Image

dtype = torch.float16  # switch to torch.float32 if output is black/garbled

pipe = StableDiffusionXLImg2ImgPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=dtype,
    use_safetensors=True,
)
pipe.load_lora_weights("ntc-ai/SDXL-LoRA-slider.pixar-style")
pipe = pipe.to("mps")

init_image = Image.open("media/toon/kate_pixar_raw2.png").convert("RGB").resize((768, 1344))

prompt = (
    "pixar style 3d animated character portrait, same woman, long curly dark hair, "
    "black v-neck top, silver pendant necklace, soft studio lighting, smiling"
)
negative_prompt = "photorealistic, photo, realistic skin pores, blurry, distorted face, extra limbs"

# (strength, lora_scale, output_filename) — bracketing mild to aggressive
variations = [
    (0.50, 1.4, "kate_pixar_stylized_v2a_mild.png"),
    (0.65, 1.8, "kate_pixar_stylized_v2b_medium.png"),
    (0.80, 2.2, "kate_pixar_stylized_v2c_strong.png"),
]

for strength, scale, filename in variations:
    # Fixed seed for a controlled comparison. Using a CPU generator even though the
    # pipeline runs on mps — MPS's own generator reproducibility isn't reliable in
    # diffusers, CPU generator is the documented workaround.
    generator = torch.Generator(device="cpu").manual_seed(42)

    result = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        image=init_image,
        strength=strength,
        guidance_scale=7.0,
        cross_attention_kwargs={"scale": scale},
        generator=generator,
    ).images[0]

    result.save(filename)
    print(f"saved {filename}  (strength={strength}, lora_scale={scale})")

print("done — all 3 variations saved")
