# Update the Rabbit - SD.Next ROCm Installation Guide

## System Information
- **Hardware**: GMKtec EVO-X2
- **CPU**: AMD Ryzen AI Max+ 395 (16 cores/32 threads)
- **GPU**: AMD Radeon 8060S (RDNA 3.5, gfx1151, 40 compute units)
- **Memory**: 128GB LPDDR5X
- **VRAM**: 64GB UMA (configured in BIOS)
- **OS**: Ubuntu 24.04 (Kernel 6.14.0-37)
- **ROCm**: 7.1.0
- **Mesa/Vulkan**: 25.0.7

## Architecture Overview

### Dual AI Stack
1. **LLM Stack** (Text Generation)
   - Engine: llama.cpp
   - Backend: Vulkan (GGML)
   - Model: Midnight-Miqu-70B-v1.5.Q5_K_M.gguf
   - Service: llama-server.service (systemd)
   - Port: 11434
   - VRAM Usage: ~56GB

2. **Image Generation Stack**
   - Engine: SD.Next (Automatic1111 fork)
   - Backend: PyTorch with ROCm 6.2
   - Framework: Diffusers
   - Port: 7860
   - VRAM Usage: Variable (8-12GB typical)

### Why This Configuration?
- **llama.cpp with Vulkan**: GGML has mature, optimized Vulkan support for LLM inference
- **SD.Next with ROCm**: PyTorch's ROCm backend is the official, optimized path for diffusion models on AMD
- Both leverage full 64GB UMA without conflicts

## Initial Setup Issues Encountered

### Problem 1: ROCm Auto-Detection
SD.Next detected ROCm 7.1 on the system and attempted to install ROCm PyTorch automatically, but the installation process was interrupted when we used `--skip-torch` flag.

### Problem 2: CPU Fallback
When bypassing automatic ROCm installation, SD.Next installed CUDA PyTorch (2.9.1+cu128) which doesn't work with AMD GPUs, causing fallback to CPU-only mode.

### Problem 3: VRAM Allocation Myths
Initial concern about ROCm only supporting 8GB VRAM was unfounded. Testing confirmed:
- ROCm sees: 64GB (68,719,476,736 bytes)
- Vulkan sees: 62.44GB (67,039,866,880 bytes)
- Both have full UMA access

## Installation Steps

### Step 1: Project Setup
```bash
cd /opt/apps/neso

# Add SD.Next to .gitignore (it's a large external dependency)
echo "sd-next/" >> .gitignore

# Clone SD.Next
git clone https://github.com/vladmandic/automatic.git sd-next
```

### Step 2: Initial Launch Attempt
```bash
cd sd-next

# This will fail/be incomplete, but sets up the base venv
./webui.sh --listen --server-name 0.0.0.0 --port 7860 --api --skip-torch
```

**Result**: Installed dependencies but used CPU-only PyTorch.

### Step 3: Stop Any Running Instance
```bash
# Use the sdnext-admin.sh script (if already created)
cd /opt/apps/neso
./sdnext-admin.sh stop

# Or manually kill the process
pkill -f "webui.sh"
```

### Step 4: Fix PyTorch Installation
```bash
cd /opt/apps/neso/sd-next
source venv/bin/activate

# Remove CUDA PyTorch
pip uninstall torch torchvision torchaudio -y

# Install ROCm PyTorch (using ROCm 6.2 builds - compatible with ROCm 7.1)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2

# Verify installation
python3 -c "import torch; print(f'Torch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'Device count: {torch.cuda.device_count()}'); print(f'Device name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"

deactivate
```

**Expected Output**:
```
Torch: 2.5.1+rocm6.2
CUDA available: True
Device count: 1
Device name: AMD Radeon Graphics
```

**Note**: You may see dependency warnings about `timm` and `numpy` versions. These are non-critical and won't prevent SD.Next from functioning.

### Step 5: Verify ROCm Detection
```bash
cd /opt/apps/neso
./sdnext-admin.sh start

# Wait 30 seconds for startup, then check
grep -i "engine\|compute\|device" /tmp/sdnext-output.log | head -20
```

**Expected Output**:
```
Engine: backend=Backend.DIFFUSERS compute=rocm device=cuda
```

### Step 6: Download Models
Models go in: `/opt/apps/neso/sd-next/models/Stable-diffusion/`

#### Option A: Flux.1 Dev (Recommended - Best Quality)
```bash
cd /opt/apps/neso/sd-next/models/Stable-diffusion
wget https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors
```
- Size: ~12GB
- VRAM: ~12GB during inference
- Best for: Highest quality, photorealism, complex prompts

#### Option B: SDXL Base
```bash
cd /opt/apps/neso/sd-next/models/Stable-diffusion
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```
- Size: ~7GB
- VRAM: ~8GB during inference
- Best for: Good quality, faster than Flux

#### Option C: RealVisXL (Photorealism Specialist)
```bash
cd /opt/apps/neso/sd-next/models/Stable-diffusion
wget https://huggingface.co/SG161222/RealVisXL_V4.0/resolve/main/RealVisXL_V4.0.safetensors
```
- Size: ~7GB
- VRAM: ~8GB during inference
- Best for: Maximum photorealism

#### Option D: Stable Diffusion 1.5 (Lightweight)
```bash
cd /opt/apps/neso/sd-next/models/Stable-diffusion
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
```
- Size: ~4GB
- VRAM: ~4GB during inference
- Best for: Running alongside LLM with reduced layers

### Step 7: Restart and Test
```bash
cd /opt/apps/neso
./sdnext-admin.sh restart

# Access web UI
# http://192.168.10.4:7860
```

## Management Scripts

### llm-quick.sh
Basic LLM service management (superseded by llm-control.sh but kept for quick operations).

```bash
./llm-quick.sh start   # Start llama-server.service
./llm-quick.sh stop    # Stop llama-server.service
./llm-quick.sh status  # Check status
```

### llm-control.sh
Full-featured LLM service management with VRAM monitoring.

```bash
./llm-control.sh start    # Start Midnight-Miqu-70B
./llm-control.sh stop     # Stop LLM service
./llm-control.sh restart  # Restart LLM service
./llm-control.sh status   # Show status + VRAM usage
```

### sdnext-admin.sh
SD.Next service management with background operation.

```bash
./sdnext-admin.sh start    # Start SD.Next with ROCm
./sdnext-admin.sh stop     # Stop SD.Next
./sdnext-admin.sh restart  # Restart SD.Next
./sdnext-admin.sh status   # Check status + recent logs
./sdnext-admin.sh logs     # Follow live logs
```

### toggle-ai.sh
Switch between LLM and image generation modes.

```bash
./toggle-ai.sh llm     # Stop images, start LLM
./toggle-ai.sh image   # Stop LLM, start images
./toggle-ai.sh status  # Show both services
```

## Usage Patterns

### Pattern 1: Full Image Generation Mode
When you need maximum image quality and don't need the LLM:

```bash
./toggle-ai.sh image
# Full 64GB VRAM available for image generation
# Use Flux.1 or SDXL models
```

### Pattern 2: Full LLM Mode
When working on policy documents or requiring the 70B model:

```bash
./toggle-ai.sh llm
# Midnight-Miqu-70B loaded with 99 GPU layers (~56GB VRAM)
# Docker agent on port 11434 available
```

### Pattern 3: Hybrid Mode (Advanced)
Run lightweight image generation alongside LLM by reducing LLM layers:

1. Edit `/etc/systemd/system/llama-server.service`
2. Change `--n-gpu-layers 99` to `--n-gpu-layers 60`
3. Restart: `sudo systemctl restart llama-server.service`
4. This frees ~20-25GB VRAM for SD 1.5 or lightweight SDXL

## Troubleshooting

### Issue: SD.Next shows "compute=cpu"
**Cause**: Wrong PyTorch version (CUDA instead of ROCm)

**Fix**:
```bash
cd /opt/apps/neso/sd-next
source venv/bin/activate
pip uninstall torch torchvision torchaudio -y
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2
deactivate
./sdnext-admin.sh restart
```

### Issue: "No models found"
**Cause**: No model files in the Stable-diffusion directory

**Fix**:
```bash
cd /opt/apps/neso/sd-next/models/Stable-diffusion
# Download a model (see Step 6)
./sdnext-admin.sh restart
```

### Issue: LLM won't start after using SD.Next
**Cause**: VRAM still allocated to image generation

**Fix**:
```bash
./sdnext-admin.sh stop
sleep 5  # Wait for VRAM to clear
./llm-control.sh start
```

### Issue: Dependency warnings during PyTorch install
**Symptom**: 
```
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed.
open-clip-torch 3.2.0 requires timm>=1.0.17, but you have timm 1.0.16
dctorch 0.1.2 requires numpy<2.0.0, but you have numpy 2.1.2
```

**Impact**: Non-critical. SD.Next will function normally.

**Explanation**: These are version mismatches in transitive dependencies. The actual functionality is not affected because SD.Next's core requirements are met.

## Verification Commands

### Check ROCm Status
```bash
rocm-smi --showmeminfo vram
rocminfo | grep -i "gfx"
```

### Check Vulkan Status
```bash
vulkaninfo | grep -A 20 "VkPhysicalDeviceMemoryProperties:"
```

### Check PyTorch ROCm Integration
```bash
cd /opt/apps/neso/sd-next
source venv/bin/activate
python3 -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
deactivate
```

### Check Running Services
```bash
# LLM
systemctl status llama-server.service

# SD.Next
./sdnext-admin.sh status

# Both
./toggle-ai.sh status
```

### Check VRAM Usage
```bash
radeontop  # Interactive view
# Or for snapshot:
radeontop -d - -l 1 | grep VRAM
```

## Integration with Open WebUI

### Configuration
1. Open Open WebUI v0.6.41
2. Navigate to: Settings → Images
3. Configure backend:
   - **API Type**: Automatic1111
   - **API URL**: `http://192.168.10.4:7860`
   - **API Key**: (leave blank)
4. Test connection
5. Select model from dropdown

### Workflow
1. Start SD.Next: `./sdnext-admin.sh start`
2. Use Open WebUI interface to generate images
3. Switch back to LLM when needed: `./toggle-ai.sh llm`

## Technical Notes

### Why ROCm 6.2 PyTorch with ROCm 7.1 System?
- PyTorch's official ROCm builds lag behind system ROCm versions
- ROCm 6.2 PyTorch is compatible with ROCm 7.1 drivers
- The HIP runtime provides backward compatibility
- gfx1151 is supported in both versions

### Why Vulkan for LLM but ROCm for Images?
- **GGML (llama.cpp)**: Has mature, hand-optimized Vulkan compute kernels
- **PyTorch (SD.Next)**: ROCm is the official AMD backend, better maintained
- Different engines have different optimal backends
- Both access the same 64GB UMA pool

### UMA (Unified Memory Architecture)
- System RAM is shared with GPU
- No discrete VRAM pool
- Configured in BIOS (64GB allocated)
- Both ROCm and Vulkan see the full allocation
- More flexible than discrete VRAM but slightly slower bandwidth

## Performance Expectations

### Image Generation (Flux.1 Dev)
- **Resolution**: 1024x1024
- **Steps**: 20-30
- **Time**: ~30-60 seconds (first generation slower due to model loading)
- **VRAM**: ~12GB

### Image Generation (SDXL)
- **Resolution**: 1024x1024
- **Steps**: 20-30
- **Time**: ~20-40 seconds
- **VRAM**: ~8GB

### LLM Inference (Midnight-Miqu-70B)
- **Context**: 32K tokens
- **Speed**: ~15-20 tokens/sec
- **VRAM**: ~56GB (99 layers on GPU)

## File Structure
```
/opt/apps/neso/
├── .gitignore              # Excludes sd-next/
├── README.md               # Project overview
├── INSTALL.md              # Installation guide
├── UPDATE_THE_RABBIT.md    # This file
├── llm-control.sh          # LLM management (full)
├── llm-quick.sh            # LLM management (simple)
├── sdnext-admin.sh         # SD.Next management
├── toggle-ai.sh            # Mode switcher
└── sd-next/                # Git ignored
    ├── venv/               # Python virtual environment
    ├── models/
    │   └── Stable-diffusion/  # Model files go here
    ├── outputs/            # Generated images
    └── webui.sh            # Main launcher
```

## Credits and References
- **SD.Next**: https://github.com/vladmandic/automatic
- **llama.cpp**: https://github.com/ggerganov/llama.cpp
- **ROCm**: https://rocm.docs.amd.com/
- **PyTorch ROCm**: https://pytorch.org/get-started/locally/

## Change Log

### 2026-01-10
- Initial installation and configuration
- Resolved PyTorch CUDA vs ROCm conflict
- Verified full 64GB VRAM access on both stacks
- Created management scripts for service control
- Documented complete workflow

---

**Resume Summary:**
- **LLM Stack**: llama.cpp → Vulkan compute → AMD RDNA 3.5 (gfx1151) → 64GB UMA
- **Image Stack**: SD.Next → PyTorch 2.5.1+ROCm6.2 → AMD RDNA 3.5 (gfx1151) → 64GB UMA
- **OS**: Ubuntu 24.04, Kernel 6.14, ROCm 7.1, Mesa 25.0.7
