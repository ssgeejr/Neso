#!/bin/bash
#
# OpenClaw Control Script
# Manages openclaw-gateway systemd user service
# Location: /opt/apps/openclaw
# Config: ~/.openclaw/openclaw.json
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
OPENCLAW_PATH="/opt/apps/openclaw"
CONFIG_PATH="$HOME/.openclaw/openclaw.json"
MEMORY_PATH="$HOME/.openclaw/MEMORY.md"

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if systemd user service exists
check_service_exists() {
    if ! systemctl --user list-unit-files | grep -q "openclaw-gateway.service"; then
        print_error "openclaw-gateway.service not found"
        print_status "Available user services:"
        systemctl --user list-unit-files | grep openclaw || echo "  (none found)"
        return 1
    fi
    return 0
}

# Get service status
get_status() {
    if ! check_service_exists; then
        return 1
    fi
    
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}    OpenClaw Gateway Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
    
    systemctl --user status openclaw-gateway.service --no-pager
    
    echo -e "\n${BLUE}Recent Logs (last 20 lines):${NC}"
    journalctl --user -u openclaw-gateway.service -n 20 --no-pager
    
    # Check if MEMORY.md exists and show last update
    if [[ -f "$MEMORY_PATH" ]]; then
        echo -e "\n${BLUE}Last MEMORY.md update:${NC}"
        ls -lh "$MEMORY_PATH"
        echo -e "\n${BLUE}Recent MEMORY.md entries:${NC}"
        tail -n 10 "$MEMORY_PATH"
    fi
}

# Start service
start_service() {
    print_status "Starting OpenClaw Gateway..."
    
    if ! check_service_exists; then
        return 1
    fi
    
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        print_warning "Service is already running"
        get_status
        return 0
    fi
    
    systemctl --user start openclaw-gateway.service
    sleep 2
    
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        print_success "OpenClaw Gateway started successfully"
        get_status
    else
        print_error "Failed to start service"
        systemctl --user status openclaw-gateway.service --no-pager
        return 1
    fi
}

# Stop service
stop_service() {
    print_status "Stopping OpenClaw Gateway..."
    
    if ! check_service_exists; then
        return 1
    fi
    
    if ! systemctl --user is-active --quiet openclaw-gateway.service; then
        print_warning "Service is not running"
        return 0
    fi
    
    systemctl --user stop openclaw-gateway.service
    sleep 2
    
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        print_error "Failed to stop service"
        return 1
    else
        print_success "OpenClaw Gateway stopped"
    fi
}

# Restart service
restart_service() {
    print_status "Restarting OpenClaw Gateway..."
    
    if ! check_service_exists; then
        return 1
    fi
    
    systemctl --user restart openclaw-gateway.service
    sleep 2
    
    if systemctl --user is-active --quiet openclaw-gateway.service; then
        print_success "OpenClaw Gateway restarted successfully"
        get_status
    else
        print_error "Failed to restart service"
        systemctl --user status openclaw-gateway.service --no-pager
        return 1
    fi
}

# Show logs
show_logs() {
    local lines=${1:-50}
    
    if ! check_service_exists; then
        return 1
    fi
    
    echo -e "\n${BLUE}OpenClaw Gateway Logs (last $lines lines):${NC}\n"
    journalctl --user -u openclaw-gateway.service -n "$lines" --no-pager
}

# Follow logs
follow_logs() {
    if ! check_service_exists; then
        return 1
    fi
    
    print_status "Following OpenClaw logs (Ctrl+C to stop)..."
    journalctl --user -u openclaw-gateway.service -f
}

# Check config
check_config() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}    OpenClaw Configuration${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
    
    if [[ ! -f "$CONFIG_PATH" ]]; then
        print_error "Config file not found: $CONFIG_PATH"
        return 1
    fi
    
    print_status "Config location: $CONFIG_PATH"
    
    # Show sanitized config (hide sensitive data)
    echo -e "\n${BLUE}Configuration (sensitive data hidden):${NC}\n"
    cat "$CONFIG_PATH" | grep -v '"apiKey"' | grep -v '"password"' | grep -v '"token"'
    
    # Show backend status
    echo -e "\n${BLUE}LLM Backend Check:${NC}"
    backend_url=$(cat "$CONFIG_PATH" | grep -o '"baseUrl":"[^"]*"' | cut -d'"' -f4)
    if [[ -n "$backend_url" ]]; then
        print_status "Backend URL: $backend_url"
        if curl -s --max-time 5 "${backend_url}/v1/models" > /dev/null 2>&1; then
            print_success "Backend is reachable"
        else
            print_warning "Backend may not be reachable"
        fi
    fi
}

# Show usage
usage() {
    cat << EOF

${BLUE}OpenClaw Control Script${NC}
${BLUE}═══════════════════════${NC}

Usage: $0 {start|stop|restart|status|logs|follow|config}

Commands:
  start       Start OpenClaw Gateway service
  stop        Stop OpenClaw Gateway service
  restart     Restart OpenClaw Gateway service
  status      Show service status and recent activity
  logs [N]    Show last N lines of logs (default: 50)
  follow      Follow logs in real-time (Ctrl+C to stop)
  config      Show configuration and backend status

Examples:
  $0 start
  $0 status
  $0 logs 100
  $0 follow

Environment:
  Service:    openclaw-gateway.service (systemd user)
  Config:     ~/.openclaw/openclaw.json
  Backend:    http://172.25.112.1:8080/v1
  WhatsApp:   +14696513610 (self-chat mode)

Notes:
  - WhatsApp outbound replies are currently broken (known bug)
  - Check MEMORY.md for task completion status
  - Backend must be running (llama.cpp service)

EOF
}

# Main logic
main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi
    
    case "$1" in
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        status)
            get_status
            ;;
        logs)
            show_logs "${2:-50}"
            ;;
        follow)
            follow_logs
            ;;
        config)
            check_config
            ;;
        -h|--help|help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown command: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"
