#!/bin/bash
# Terminal 6: Process Monitoring
watch -n 2 'ps aux | grep -E "webui|python.*torch" | grep -v grep | head -20'
