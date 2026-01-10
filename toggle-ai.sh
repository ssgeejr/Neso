#!/bin/bash
# Toggle AI Mode Script
# Switches between LLM mode and Image Generation mode

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in
  llm)
    echo "=== Switching to LLM Mode ==="
    echo "Stopping image generation..."
    "$SCRIPT_DIR/image-control.sh" stop
    echo ""
    sleep 2
    echo "Starting LLM service..."
    "$SCRIPT_DIR/llm-control.sh" start
    echo ""
    echo "=== LLM Mode Active ==="
    echo "Midnight-Miqu-70B available on port 11434"
    ;;
  image)
    echo "=== Switching to Image Generation Mode ==="
    echo "Stopping LLM service..."
    "$SCRIPT_DIR/llm-control.sh" stop
    echo ""
    sleep 2
    echo "Freeing VRAM..."
    sleep 3
    echo "Starting image generation..."
    "$SCRIPT_DIR/image-control.sh" start
    echo ""
    echo "=== Image Generation Mode Active ==="
    ;;
  status)
    echo "=== Current AI Status ==="
    echo ""
    echo "--- LLM Service ---"
    "$SCRIPT_DIR/llm-control.sh" status
    echo ""
    echo "--- Image Generation Service ---"
    "$SCRIPT_DIR/image-control.sh" status
    ;;
  *)
    echo "Usage: $0 {llm|image|status}"
    echo ""
    echo "  llm    - Switch to LLM mode (Midnight-Miqu-70B)"
    echo "  image  - Switch to Image Generation mode"
    echo "  status - Show current status of both services"
    exit 1
    ;;
esac
