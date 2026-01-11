#!/bin/bash
case "$1" in
  stop)
    sudo systemctl stop llama-server.service
    echo "LLM stopped"
    ;;
  start)
    sudo systemctl start llama-server.service
    echo "LLM started"
    ;;
  status)
    sudo systemctl status llama-server.service --no-pager
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
