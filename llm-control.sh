#!/bin/bash
# LLM Control Script for Midnight-Miqu-70B
# Manages llama-server.service systemd service

set -e

case "$1" in
  start)
    echo "Starting Midnight-Miqu-70B LLM service..."
    sudo systemctl start llama-server.service
    echo "Waiting for service to be ready..."
    sleep 3
    sudo systemctl status llama-server.service --no-pager
    ;;
  stop)
    echo "Stopping LLM service..."
    sudo systemctl stop llama-server.service
    echo "LLM service stopped"
    ;;
  restart)
    echo "Restarting LLM service..."
    sudo systemctl restart llama-server.service
    echo "Waiting for service to be ready..."
    sleep 3
    sudo systemctl status llama-server.service --no-pager
    ;;
  status)
    sudo systemctl status llama-server.service --no-pager
    echo ""
    echo "VRAM Usage:"
    radeontop -d - -l 1 2>/dev/null | grep -E "VRAM|GTT" || echo "radeontop not available"
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
