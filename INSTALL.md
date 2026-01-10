# Neso Installation Guide

Neso is the image generation companion to your Midnight-Miqu-70B LLM setup on gravitydrive.

## System Info
- **Hardware**: GMKtec EVO-X2 (AMD Ryzen AI Max+ 395, Radeon 8060S, 128GB RAM)
- **VRAM**: 64GB unified memory (UMA)
- **OS**: Linux (Ubuntu-based)
- **Backend**: Vulkan (RADV GFX1151)

## Current Setup
- **LLM**: Midnight-Miqu-70B-v1.5 (Q5_K_M) - Uses ~56GB VRAM
- **Service**: llama-server.service (systemd)
- **Port**: 11434

## Scripts

### llm-control.sh
Manages the Midnight-Miqu-70B LLM service:
```bash
./llm-control.sh start   # Start LLM service
./llm-control.sh stop    # Stop LLM service
./llm-control.sh restart # Restart LLM service
./llm-control.sh status  # Check status
```

### image-control.sh
Manages the image generation service (to be configured):
```bash
./image-control.sh start   # Start image gen
./image-control.sh stop    # Stop image gen
./image-control.sh status  # Check status
```

### toggle-ai.sh
Switch between LLM and image generation modes:
```bash
./toggle-ai.sh llm     # Switch to LLM mode
./toggle-ai.sh image   # Switch to image generation mode
./toggle-ai.sh status  # Show both services status
```

## Installation Steps

### 1. Make scripts executable
```bash
cd /opt/apps/neso
chmod +x llm-control.sh image-control.sh toggle-ai.sh
```

### 2. Install Image Generation Backend

#### Option A: SD.Next (Automatic1111 fork with Vulkan)
```bash
# Install dependencies
sudo apt update
sudo apt install python3-pip python3-venv git

# Clone SD.Next
cd /opt/apps/neso
git clone https://github.com/vladmandic/automatic.git sd-next
cd sd-next

# Install
./webui.sh --use-cpu=none
```

#### Option B: ComfyUI (More flexible)
```bash
# Clone ComfyUI
cd /opt/apps/neso
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# Install
pip install torch torchvision
python main.py
```

### 3. Download Models

Recommended models for your VRAM:

#### Stable Diffusion 1.5 (~4GB, leaves room for LLM)
```bash
cd /opt/apps/neso/models
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```

#### SDXL (~8GB, use when LLM is stopped)
```bash
cd /opt/apps/neso/models
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

### 4. Configure Open WebUI

1. Open Open WebUI (v0.6.41)
2. Go to Settings → Images
3. Set backend to Automatic1111 or ComfyUI
4. Set API URL (e.g., `http://localhost:7860`)
5. Test connection

## Usage Patterns

### Pattern 1: LLM for document work, then switch to images
```bash
# Start with LLM
./toggle-ai.sh llm

# Work on policies/documents with Midnight-Miqu-70B
# When done, switch to image generation

./toggle-ai.sh image
# Generate images
```

### Pattern 2: Check what's running
```bash
./toggle-ai.sh status
```

### Pattern 3: Quick image generation (lighter model alongside LLM)
If you install SD 1.5, it can run alongside the LLM with reduced layers:
```bash
# Edit /etc/systemd/system/llama-server.service
# Change --n-gpu-layers 99 to --n-gpu-layers 60
# This frees ~20GB for SD 1.5
```

## Next Steps

1. Choose image generation backend (SD.Next or ComfyUI)
2. Install and test
3. Update `image-control.sh` with actual commands
4. Create systemd service for image generation (optional)
5. Test toggle functionality

## Notes

- Your Docker agent depends on llama-server port 11434
- UMA gives you 64GB VRAM to work with
- Vulkan backend is native and performs well on AMD
- All changes go to `/opt/apps/neso` and get committed to git
