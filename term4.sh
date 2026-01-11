#!/bin/bash
# Terminal 4: Memory + VRAM Watch
watch -n 1 'free -h && echo "---VRAM---" && radeontop -d - -l 1 | grep -E "VRAM|GTT"'
