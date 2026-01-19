# Save as comfyui-admin.ps1 in C:\dev\ai\neso

param(
    [string]$Action = "start"
)

$ComfyUIPath = "C:\dev\ai\neso\ComfyUI"
$ProcessName = "python"
$MainScript = "main.py"

function Start-ComfyUI {
    $running = Get-Process | Where-Object {$_.ProcessName -eq $ProcessName -and $_.CommandLine -like "*main.py*"}
    if ($running) {
        Write-Host "ComfyUI is already running (PID: $($running.Id))"
        return
    }
    Write-Host "Starting ComfyUI..."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $ComfyUIPath; .\venv\Scripts\activate; python main.py --directml" -WindowStyle Minimized
    Write-Host "ComfyUI started on http://localhost:8188"
}

function Stop-ComfyUI {
    $processes = Get-Process | Where-Object {$_.ProcessName -eq $ProcessName -and $_.CommandLine -like "*main.py*"}
    if (!$processes) {
        Write-Host "ComfyUI is not running"
        return
    }
    foreach ($proc in $processes) {
        Stop-Process -Id $proc.Id -Force
        Write-Host "Stopped process $($proc.Id)"
    }
}

switch ($Action.ToLower()) {
    "start" { Start-ComfyUI }
    "stop" { Stop-ComfyUI }
    default { Start-ComfyUI }
}