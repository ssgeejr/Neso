# REM Or go even bigger depending on your VRAM:
# REM --ctx-size 65536 (64k context)
# REM --ctx-size 131072 (128k context)
# REM --ctx-size 262144 (256k context - if you've got the juice!)
# 32768

# start-behemoth.ps1
llama-server --model "C:\dev\ai\models\thedrummer\Moistral-11B-v3-f16.gguf" --port 11434 --host 0.0.0.0 --n-gpu-layers 99 --ctx-size 4096
