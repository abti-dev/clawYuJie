---
name: clawYuJie-gen
description: Generate images using Doubao Seedream (Volcengine) and send to messaging channels via OpenClaw
allowed-tools: Bash(npm:*) Bash(npx:*) Bash(openclaw:*) Bash(curl:*) Read Write WebFetch
---

# ClawYuJie Generation

Generate images using Volcengine's Doubao Seedream model and distribute them across messaging platforms via OpenClaw.

## When to Use

- User says "send a pic", "send a selfie", "generate an image"
- User describes a scene: "show me a futuristic city..."
- User asks "what are you doing?" and you want to reply with a photo
- User wants to see you (Clawra) in a specific context

## Configuration

Required Environment Variable:
```bash
ARK_API_KEY=your_volcengine_api_key
```

## Step-by-Step Instructions

### Step 1: Construct the Prompt

**For Selfies/Portraits:**
Construct a detailed prompt describing the appearance and the scene.
Since this is a text-to-image model, you must describe the subject.
*Example:* "A photorealistic selfie of a young asian woman with long dark hair, wearing a casual hoodie, sitting in a sunny coffee shop, holding a latte, looking at the camera, high quality, 2k."

**For General Scenes:**
Use the user's description and enhance it with artistic keywords.
*Example (User: "Space train"):* "Star Interstellar, black hole, a retro train rushing out of the black hole, visual impact, blockbuster movie, doomsday sense, dynamic, contrasting colors, oc rendering, ray tracing, motion blur, depth of field, surrealism, deep blue, realistic texture, dark style background, artistic fantasy, exaggerated wide-angle perspective, flare, reflection, extreme light and shadow, strong gravity, swallowing"

### Step 2: Generate and Send

Use the `clawYuJie.sh` script to generate and send the image.

```bash
# Syntax
./scripts/clawYuJie.sh "<PROMPT>" "<CHANNEL>" "<CAPTION>"
```

**Example:**
```bash
./scripts/clawYuJie.sh "A cyberpunk city at night with neon lights" "#general" "Check out this view!"
```
