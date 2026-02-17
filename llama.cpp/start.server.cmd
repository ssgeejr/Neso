REM Or go even bigger depending on your VRAM:

REM --ctx-size 65536 (64k context)
REM --ctx-size 131072 (128k context)
REM --ctx-size 262144 (256k context - if you've got the juice!)


llama-server `
  --model "C:\opt\llama.cpp\models\TheDrummer_Behemoth-X-123B-v2-Q5_K_M-Combined.gguf" `
  --port 11434 `
  --host 0.0.0.0 `
  --n-gpu-layers 99 `
  --ctx-size 32768