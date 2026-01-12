#!/bin/bash
# ComfyUI Management Script

COMFYUI_DIR="/opt/apps/neso/ComfyUI"
LOGDIR="/opt/apps/neso/logs"
PIDFILE="/tmp/comfyui.pid"

case "$1" in
  start)
    if [ -f "$PIDFILE" ]; then
      echo "ComfyUI appears to be running"
      exit 1
    fi
    echo "Starting ComfyUI..."
    cd "$COMFYUI_DIR"
    mkdir -p "$LOGDIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    nohup venv/bin/python main.py --listen 0.0.0.0 --port 8188 > "$LOGDIR/comfyui_${TIMESTAMP}.log" 2>&1 &
    echo $! > "$PIDFILE"
    echo "ComfyUI started on http://192.168.10.4:8188"
    ;;
  stop)
    if [ ! -f "$PIDFILE" ]; then
      echo "ComfyUI is not running"
      exit 1
    fi
    PID=$(cat "$PIDFILE")
    kill "$PID"
    rm -f "$PIDFILE"
    echo "ComfyUI stopped"
    ;;
  status)
    if [ -f "$PIDFILE" ]; then
      PID=$(cat "$PIDFILE")
      if ps -p "$PID" > /dev/null; then
        echo "ComfyUI is running (PID: $PID)"
      else
        echo "ComfyUI is not running (stale PID)"
        rm -f "$PIDFILE"
      fi
    else
      echo "ComfyUI is not running"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
