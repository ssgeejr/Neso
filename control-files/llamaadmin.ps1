#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    llama.cpp Service Control Script
    
.DESCRIPTION
    Manages llama.cpp Windows service for Qwen3-Coder-Next local LLM
    Service Name: llama-server
    Location: C:\dev\ai\neso\llama.cpp
    Model: Qwen3-Coder-Next Q6_K (79B parameters, ~48-52GB)
    Endpoint: http://172.25.112.1:8080
    
.PARAMETER Action
    Action to perform: Start, Stop, Restart, Status, Logs, Test
    
.EXAMPLE
    .\llama-control.ps1 -Action Start
    
.EXAMPLE
    .\llama-control.ps1 -Action Status
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [ValidateSet('Start', 'Stop', 'Restart', 'Status', 'Logs', 'Test', 'Help')]
    [string]$Action = 'Help'
)

# Configuration
$ServiceName = "llama-server"
$LlamaCppPath = "C:\dev\ai\neso\llama.cpp"
$Endpoint = "http://172.25.112.1:8080"
$ModelInfo = "Qwen3-Coder-Next Q6_K (79B)"

# Color output helpers
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Error"   { "Red" }
        "Warning" { "Yellow" }
        "Info"    { "Cyan" }
        "Header"  { "Blue" }
        default   { "White" }
    }
    
    $prefix = switch ($Type) {
        "Success" { "[OK]" }
        "Error"   { "[X]" }
        "Warning" { "[!]" }
        "Info"    { "[i]" }
        "Header"  { "===" }
        default   { "   " }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "=======================================" -Type Header
    Write-ColorOutput "  $Title" -Type Header
    Write-ColorOutput "=======================================" -Type Header
    Write-Host ""
}

# Check if service exists
function Test-ServiceExists {
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-ColorOutput "Service '$ServiceName' not found!" -Type Error
        Write-ColorOutput "Available services matching 'llama':" -Type Info
        Get-Service | Where-Object { $_.Name -like "*llama*" } | Format-Table -AutoSize
        return $false
    }
    return $true
}

# Get service status
function Get-ServiceStatus {
    if (-not (Test-ServiceExists)) {
        return
    }
    
    Write-Header "llama.cpp Service Status"
    
    $service = Get-Service -Name $ServiceName
    
    # Service info
    Write-ColorOutput "Service Name:    $($service.Name)" -Type Info
    Write-ColorOutput "Display Name:    $($service.DisplayName)" -Type Info
    Write-ColorOutput "Status:          $($service.Status)" -Type $(if ($service.Status -eq 'Running') { 'Success' } else { 'Warning' })
    Write-ColorOutput "Start Type:      $($service.StartType)" -Type Info
    
    # Process info if running
    if ($service.Status -eq 'Running') {
        Write-Host ""
        Write-ColorOutput "Process Information:" -Type Header
        
        $processId = (Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'").ProcessId
        if ($processId) {
            $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if ($process) {
                Write-ColorOutput "PID:             $($process.Id)" -Type Info
                $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
                Write-ColorOutput "Memory (MB):     $memoryMB" -Type Info
                Write-ColorOutput "CPU Time:        $($process.TotalProcessorTime)" -Type Info
                Write-ColorOutput "Threads:         $($process.Threads.Count)" -Type Info
            }
        }
    }
    
    # Test endpoint
    Write-Host ""
    Write-ColorOutput "Testing Endpoint: $Endpoint" -Type Header
    Test-Endpoint -Detailed
    
    # Show recent Event Log entries
    Write-Host ""
    Write-ColorOutput "Recent Event Log Entries:" -Type Header
    Get-EventLog -LogName Application -Source $ServiceName -Newest 5 -ErrorAction SilentlyContinue | 
        Format-Table TimeGenerated, EntryType, Message -AutoSize -Wrap
}

# Start service
function Start-ServiceWrapper {
    if (-not (Test-ServiceExists)) {
        return
    }
    
    Write-ColorOutput "Starting llama.cpp service..." -Type Info
    
    $service = Get-Service -Name $ServiceName
    
    if ($service.Status -eq 'Running') {
        Write-ColorOutput "Service is already running" -Type Warning
        Get-ServiceStatus
        return
    }
    
    try {
        Start-Service -Name $ServiceName
        Start-Sleep -Seconds 5
        
        $service.Refresh()
        if ($service.Status -eq 'Running') {
            Write-ColorOutput "Service started successfully" -Type Success
            Get-ServiceStatus
        } else {
            Write-ColorOutput "Service failed to start" -Type Error
            Get-EventLog -LogName Application -Source $ServiceName -Newest 3 -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-ColorOutput "Failed to start service: $_" -Type Error
    }
}

# Stop service
function Stop-ServiceWrapper {
    if (-not (Test-ServiceExists)) {
        return
    }
    
    Write-ColorOutput "Stopping llama.cpp service..." -Type Info
    
    $service = Get-Service -Name $ServiceName
    
    if ($service.Status -ne 'Running') {
        Write-ColorOutput "Service is not running" -Type Warning
        return
    }
    
    try {
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 3
        
        $service.Refresh()
        if ($service.Status -eq 'Stopped') {
            Write-ColorOutput "Service stopped successfully" -Type Success
        } else {
            Write-ColorOutput "Service failed to stop" -Type Error
        }
    }
    catch {
        Write-ColorOutput "Failed to stop service: $_" -Type Error
    }
}

# Restart service
function Restart-ServiceWrapper {
    Write-ColorOutput "Restarting llama.cpp service..." -Type Info
    
    Stop-ServiceWrapper
    Start-Sleep -Seconds 2
    Start-ServiceWrapper
}

# Show logs
function Show-Logs {
    if (-not (Test-ServiceExists)) {
        return
    }
    
    Write-Header "llama.cpp Service Logs"
    
    # Event Log
    Write-ColorOutput "Application Event Log:" -Type Header
    Get-EventLog -LogName Application -Source $ServiceName -Newest 20 -ErrorAction SilentlyContinue |
        Format-Table TimeGenerated, EntryType, Message -AutoSize -Wrap
    
    # Check for log files
    if (Test-Path $LlamaCppPath) {
        Write-Host ""
        Write-ColorOutput "Log Files in llama.cpp directory:" -Type Header
        Get-ChildItem -Path $LlamaCppPath -Filter "*.log" -ErrorAction SilentlyContinue |
            ForEach-Object {
                $sizeMB = [math]::Round($_.Length / 1MB, 2)
                Write-ColorOutput "$($_.Name) ($sizeMB MB)" -Type Info
                Write-Host "Last 10 lines:"
                Get-Content $_.FullName -Tail 10
                Write-Host ""
            }
    }
}

# Test endpoint
function Test-Endpoint {
    param([switch]$Detailed)
    
    try {
        # Test /health endpoint
        $health = Invoke-RestMethod -Uri "$Endpoint/health" -TimeoutSec 5 -ErrorAction Stop
        Write-ColorOutput "Health Check: OK" -Type Success
        
        if ($Detailed) {
            # Test /v1/models endpoint
            try {
                $models = Invoke-RestMethod -Uri "$Endpoint/v1/models" -TimeoutSec 5
                Write-ColorOutput "Models Endpoint: OK" -Type Success
                
                if ($models.data) {
                    Write-Host ""
                    Write-ColorOutput "Available Models:" -Type Info
                    $models.data | ForEach-Object {
                        Write-Host "  - $($_.id)"
                    }
                }
            }
            catch {
                Write-ColorOutput "Models Endpoint: Failed" -Type Warning
            }
            
            # Test completion endpoint
            try {
                $testPayload = @{
                    model = "qwen3-coder-next"
                    messages = @(
                        @{
                            role = "user"
                            content = "test"
                        }
                    )
                    max_tokens = 5
                } | ConvertTo-Json -Depth 10
                
                $response = Invoke-RestMethod -Uri "$Endpoint/v1/chat/completions" `
                    -Method Post `
                    -ContentType "application/json" `
                    -Body $testPayload `
                    -TimeoutSec 10
                
                Write-ColorOutput "Completion Endpoint: OK (response received)" -Type Success
            }
            catch {
                Write-ColorOutput "Completion Endpoint: $($_.Exception.Message)" -Type Warning
            }
        }
    }
    catch {
        Write-ColorOutput "Endpoint Unreachable: $($_.Exception.Message)" -Type Error
        Write-ColorOutput "Make sure the service is running and port 8080 is accessible" -Type Warning
    }
}

# Show help
function Show-Help {
    Write-Header "llama.cpp Service Control"
    
    Write-Host "Usage: .\llama-control.ps1 -Action [Action]"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  Start       Start the llama.cpp service"
    Write-Host "  Stop        Stop the llama.cpp service"
    Write-Host "  Restart     Restart the llama.cpp service"
    Write-Host "  Status      Show service status and test endpoint"
    Write-Host "  Logs        Show recent logs from Event Log and log files"
    Write-Host "  Test        Test the API endpoint"
    Write-Host "  Help        Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\llama-control.ps1 -Action Start"
    Write-Host "  .\llama-control.ps1 -Action Status"
    Write-Host "  .\llama-control.ps1 Status          # -Action is optional"
    Write-Host ""
    Write-Host "Configuration:"
    Write-Host "  Service:    $ServiceName"
    Write-Host "  Location:   $LlamaCppPath"
    Write-Host "  Model:      $ModelInfo"
    Write-Host "  Endpoint:   $Endpoint"
    Write-Host "  GPU:        AMD Radeon 8060S (96GB VRAM allocated)"
    Write-Host ""
    Write-Host "Performance:"
    Write-Host "  Tokens/sec: ~38 (with full GPU offload)"
    Write-Host "  Layers:     49/49 offloaded to GPU"
    Write-Host "  Context:    32K tokens"
    Write-Host ""
    Write-Host "Notes:"
    Write-Host "  - Requires Administrator privileges"
    Write-Host "  - Service must be registered with Windows Service Manager"
    Write-Host "  - Check GPU driver: AMD Adrenalin 26.1.1"
    Write-Host "  - VRAM allocation: 32GB system + 96GB GPU via UMA"
    Write-Host ""
}

# Main execution
function Main {
    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-ColorOutput "This script requires Administrator privileges" -Type Error
        Write-ColorOutput "Please run PowerShell as Administrator" -Type Warning
        exit 1
    }
    
    switch ($Action) {
        'Start'   { Start-ServiceWrapper }
        'Stop'    { Stop-ServiceWrapper }
        'Restart' { Restart-ServiceWrapper }
        'Status'  { Get-ServiceStatus }
        'Logs'    { Show-Logs }
        'Test'    { Test-Endpoint -Detailed }
        'Help'    { Show-Help }
        default   { Show-Help }
    }
}

# Run main
Main