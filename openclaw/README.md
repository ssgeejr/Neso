# OpenClaw Configuration Backup

## CRITICAL FAILURE RECOVERY
Pull this repo and restore files to their destinations.

## Crosswalk Table

| Backup Location | Restore To | Purpose |
|-----------------|------------|---------|
| `wsl-config/openclaw.json` | `~/.openclaw/openclaw.json` | OpenClaw main config (model, gateway, channels) |
| `wsl-config/USER.md` | `~/.openclaw/workspace/USER.md` | User preferences, project defaults |
| `skills/reset-session/SKILL.md` | `~/.openclaw/workspace/skills/reset-session/SKILL.md` | Session clear skill |
| `windows-service/llama-server-service.xml` | `C:\dev\ai\llama.cpp\build\bin\Release\llama-server-service.xml` | WinSW service config |
| `../wsl/.wslconfig` | `C:\Users\aiadmin\.wslconfig` | WSL2 idle timeout config |
| `../wsl-config/.bashrc` | `~/.bashrc` | Bash aliases (openclawtui, etc) |

## Quick Restore - WSL/Linux
```bash
cp /opt/apps/neso/openclaw/wsl-config/openclaw.json ~/.openclaw/
cp /opt/apps/neso/openclaw/wsl-config/USER.md ~/.openclaw/workspace/
mkdir -p ~/.openclaw/workspace/skills/reset-session
cp /opt/apps/neso/openclaw/skills/reset-session/SKILL.md ~/.openclaw/workspace/skills/reset-session/
cp /opt/apps/neso/wsl-config/.bashrc ~/
source ~/.bashrc
systemctl --user restart openclaw-gateway
```

## Quick Restore - Windows (PowerShell Admin)
```powershell
copy \\wsl$\Ubuntu\opt\apps\neso\openclaw\windows-service\llama-server-service.xml C:\dev\ai\llama.cpp\build\bin\Release\
copy \\wsl$\Ubuntu\opt\apps\neso\wsl\.wslconfig $HOME\
cd C:\dev\ai\llama.cpp\build\bin\Release
.\llama-server-service.exe stop
.\llama-server-service.exe uninstall
.\llama-server-service.exe install
.\llama-server-service.exe start
wsl --shutdown
```

## Key Settings

| Setting | Value |
|---------|-------|
| Context Window | 131072 (128k) |
| Parallel Slots | 1 |
| Model | Qwen3-Coder-Next Q6_K 79B |
| Gateway Port | 18789 |
| llama.cpp Port | 8080 |

## Commands

| Command | What it does |
|---------|--------------|
| `openclawtui` | Launch OpenClaw TUI |
| `/reset-session` | Clear context, start fresh |
