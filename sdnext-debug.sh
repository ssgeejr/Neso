#!/bin/bash
LOGDIR="/opt/apps/neso/logs"
mkdir -p "$LOGDIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="$LOGDIR/sdnext_${TIMESTAMP}.log"

cd /opt/apps/neso/sd-next
./webui.sh --listen --server-name 0.0.0.0 --port 7860 --api --use-rocm 2>&1 | tee -a "$LOGFILE"
