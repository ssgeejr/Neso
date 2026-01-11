#!/bin/bash
# SD.Next Administration Script
# Manages Stable Diffusion image generation server

set -e

SDNEXT_DIR="/opt/apps/neso/sd-next"
PIDFILE="/tmp/sdnext.pid"

case "$1" in
  start)
    if [ -f "$PIDFILE" ]; then
      echo "SD.Next appears to be running (PID file exists)"
      exit 1
    fi
    echo "Starting SD.Next server..."
    cd "$SDNEXT_DIR"
    nohup ./webui.sh --listen --server-name 0.0.0.0 --port 7860 --api --use-rocm > /tmp/sdnext-output.log 2>&1 &
    echo $! > "$PIDFILE"
    echo "SD.Next started (PID: $(cat $PIDFILE))"
    echo "Access at: http://192.168.10.4:7860"
    echo "Logs: tail -f /tmp/sdnext-output.log"
    ;;
  stop)
    if [ ! -f "$PIDFILE" ]; then
      echo "SD.Next is not running (no PID file)"
      exit 1
    fi
    echo "Stopping SD.Next server..."
    PID=$(cat "$PIDFILE")
    kill "$PID" 2>/dev/null || true
    rm -f "$PIDFILE"
    echo "SD.Next stopped"
    ;;
  restart)
    echo "Restarting SD.Next..."
    $0 stop 2>/dev/null || true
    sleep 2
    $0 start
    ;;
  status)
    if [ -f "$PIDFILE" ]; then
      PID=$(cat "$PIDFILE")
      if ps -p "$PID" > /dev/null 2>&1; then
        echo "SD.Next is running (PID: $PID)"
        echo "Access at: http://192.168.10.4:7860"
        echo ""
        echo "Recent log output:"
        tail -n 10 /tmp/sdnext-output.log 2>/dev/null || echo "No logs available"
      else
        echo "SD.Next is not running (stale PID file)"
        rm -f "$PIDFILE"
      fi
    else
      echo "SD.Next is not running"
    fi
    ;;
  logs)
    echo "SD.Next logs (Ctrl+C to exit):"
    tail -f /tmp/sdnext-output.log
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs}"
    echo ""
    echo "  start   - Start SD.Next server"
    echo "  stop    - Stop SD.Next server"
    echo "  restart - Restart SD.Next server"
    echo "  status  - Check if SD.Next is running"
    echo "  logs    - Follow SD.Next logs"
    exit 1
    ;;
esac
