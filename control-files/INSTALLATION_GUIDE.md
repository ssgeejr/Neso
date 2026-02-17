# OpenClaw & llama.cpp Control Scripts - Installation Guide

## 📁 Files Created

1. **openclaw-control.sh** - Bash script for OpenClaw (WSL/Linux)
2. **llama-control.ps1** - PowerShell script for llama.cpp (Windows)

---

## 🐧 OpenClaw Control (Linux/WSL)

### Installation

```bash
# Copy script to /usr/local/bin for system-wide access
sudo cp openclaw-control.sh /usr/local/bin/openclaw
sudo chmod +x /usr/local/bin/openclaw

# OR keep it local in your path
mkdir -p ~/bin
cp openclaw-control.sh ~/bin/openclaw
chmod +x ~/bin/openclaw
# Add to ~/.bashrc: export PATH="$HOME/bin:$PATH"
```

### Usage

```bash
# Start OpenClaw
openclaw start

# Check status (shows logs, MEMORY.md updates)
openclaw status

# Stop OpenClaw
openclaw stop

# Restart OpenClaw
openclaw restart

# View logs (default: 50 lines)
openclaw logs
openclaw logs 100

# Follow logs in real-time
openclaw follow

# Check configuration and backend connectivity
openclaw config

# Show help
openclaw help
```

### Features

✓ Color-coded output (success/error/warning/info)
✓ Automatic service existence check
✓ Backend connectivity test (llama.cpp)
✓ MEMORY.md monitoring (workaround for WhatsApp bug)
✓ Sanitized config display (hides API keys)
✓ Recent activity summary

---

## 🪟 llama.cpp Control (Windows)

### Installation

```powershell
# Copy script to your profile scripts directory
$scriptPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Scripts"
New-Item -ItemType Directory -Path $scriptPath -Force
Copy-Item llama-control.ps1 $scriptPath\

# OR add to your PATH
# Place in C:\Scripts or any directory in your PATH

# Create alias (optional - add to $PROFILE)
Set-Alias llama "$scriptPath\llama-control.ps1"
```

### Usage

```powershell
# Start llama.cpp service (requires Admin)
.\llama-control.ps1 -Action Start

# Check status (shows process info, memory, endpoint test)
.\llama-control.ps1 -Action Status

# Stop service
.\llama-control.ps1 -Action Stop

# Restart service
.\llama-control.ps1 -Action Restart

# View logs (Event Log + log files)
.\llama-control.ps1 -Action Logs

# Test API endpoint only
.\llama-control.ps1 -Action Test

# Show help
.\llama-control.ps1 -Action Help

# Short form (if using alias)
llama Status
llama Start
llama Test
```

### Features

✓ Administrator privilege check
✓ Color-coded output
✓ Process monitoring (PID, memory, CPU, threads)
✓ API endpoint testing (/health, /v1/models, /v1/chat/completions)
✓ Event Log integration
✓ Log file parsing
✓ Model availability check

---

## 🔄 Typical Workflow

### Morning Startup

```bash
# Windows (PowerShell as Admin)
llama Start
llama Test

# WSL (after llama.cpp is confirmed running)
openclaw start
openclaw status
```

### Checking Status

```bash
# Quick check
openclaw status    # Shows if active + recent logs
llama Status       # Shows process info + endpoint test

# Deep dive
openclaw follow    # Watch logs in real-time
llama Logs         # Event Log + file logs
```

### Troubleshooting

```bash
# OpenClaw not responding?
openclaw config    # Check backend connectivity
openclaw restart   # Fresh start

# llama.cpp issues?
llama Stop         # Clean shutdown
llama Start        # Fresh start
llama Test         # Verify endpoints working

# Check MEMORY.md for OpenClaw task status
cat ~/.openclaw/MEMORY.md
tail -f ~/.openclaw/MEMORY.md  # Watch for updates
```

### Shutdown

```bash
# Graceful shutdown order
openclaw stop      # Stop client first
llama Stop         # Stop backend second
```

---

## 📊 What Each Script Shows

### openclaw-control.sh Status Output

```
═══════════════════════════════════════
    OpenClaw Gateway Status
═══════════════════════════════════════

● openclaw-gateway.service - OpenClaw Gateway
   Loaded: loaded
   Active: active (running) since...
   Main PID: 12345

Recent Logs (last 20 lines):
[timestamp] Starting OpenClaw...
[timestamp] Connected to backend: http://172.25.112.1:8080
[timestamp] WhatsApp session active

Last MEMORY.md update:
-rw-r--r-- 1 user user 4.2K Feb 16 10:30 MEMORY.md

Recent MEMORY.md entries:
Task: Repository audit
Status: In progress
Last update: 2024-02-16 10:30:15
```

### llama-control.ps1 Status Output

```
═══════════════════════════════════════
  llama.cpp Service Status
═══════════════════════════════════════

Service Name:    llama-server
Display Name:    llama.cpp LLM Server
Status:          Running
Start Type:      Automatic

Process Information:
PID:             8472
Memory (MB):     45234.56
CPU Time:        01:23:45
Threads:         16

Testing Endpoint: http://172.25.112.1:8080
Health Check: OK
Models Endpoint: OK

Available Models:
  • qwen3-coder-next

Completion Endpoint: OK (response received)
```

---

## 🐛 Known Issues & Workarounds

### OpenClaw WhatsApp Outbound Bug

**Problem:** OpenClaw receives WhatsApp messages but fails to send replies

**Workaround:**
```bash
# Monitor MEMORY.md for task completion
watch -n 5 'tail -20 ~/.openclaw/MEMORY.md'

# Or use the built-in status check
openclaw status  # Shows recent MEMORY.md updates
```

### llama.cpp Service Won't Start

**Troubleshooting:**
```powershell
# Check Event Log for errors
llama Logs

# Verify port 8080 is not in use
netstat -ano | findstr :8080

# Check GPU driver
# AMD Adrenalin should be 26.1.1
```

---

## 🔧 Customization

### OpenClaw Script

Edit these variables in `openclaw-control.sh`:

```bash
OPENCLAW_PATH="/opt/apps/openclaw"
CONFIG_PATH="$HOME/.openclaw/openclaw.json"
MEMORY_PATH="$HOME/.openclaw/MEMORY.md"
```

### llama.cpp Script

Edit these variables in `llama-control.ps1`:

```powershell
$ServiceName = "llama-server"
$LlamaCppPath = "C:\dev\ai\neso\llama.cpp"
$Endpoint = "http://172.25.112.1:8080"
```

---

## 📝 Notes

- **OpenClaw** requires the backend (llama.cpp) to be running first
- **llama.cpp** script requires Administrator privileges
- Both scripts include safety checks and won't break if services don't exist
- Color output works in modern terminals (Windows Terminal, WSL, most Linux terminals)
- Scripts are idempotent - safe to run multiple times

---

## 🚀 Quick Reference

```bash
# Start everything
llama Start && openclaw start

# Check everything
llama Status && openclaw status

# Watch OpenClaw activity
openclaw follow

# Stop everything
openclaw stop && llama Stop
```

Enjoy your AI infrastructure! 🤖
