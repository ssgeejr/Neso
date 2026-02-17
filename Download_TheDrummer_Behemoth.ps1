# PowerShell Script to Download TheDrummer Behemoth Model
# Converted from bash script

<#
.SYNOPSIS
    Downloads and merges the TheDrummer Behemoth model from HuggingFace.

.DESCRIPTION
    Downloads a 3-part GGUF model, then uses llama-gguf-split to merge the parts properly.
    Requires llama-gguf-split (from llama.cpp) to be in your PATH.

.PARAMETER TargetDir
    Directory where the model will be saved. Default: C:\models\TheDrummer_Behemoth

.PARAMETER MaxSpeed
    Maximum download speed (e.g., "75M", "100M"). Default: 75M

.EXAMPLE
    .\Download_TheDrummer_Behemoth.ps1
    
.EXAMPLE
    .\Download_TheDrummer_Behemoth.ps1 -TargetDir "D:\AI\models\Behemoth" -MaxSpeed "100M"
#>

param(
    [string]$TargetDir = "C:\opt\llama.cpp\models",
    [string]$MaxSpeed = "100M"
)

# Use provided target directory
$TARGET_DIR = $TargetDir

# Create directory if it doesn't exist
if (-not (Test-Path $TARGET_DIR)) {
    New-Item -ItemType Directory -Path $TARGET_DIR -Force | Out-Null
}

Write-Host "[START] Starting download for TheDrummer Behemoth (Bartowski Q5_K_M)..." -ForegroundColor Cyan
Write-Host "[INFO] Saving to: $TARGET_DIR" -ForegroundColor Cyan

# URLs
$URL1 = "https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf"
$URL2 = "https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00002-of-00003.gguf"
$URL3 = "https://huggingface.co/bartowski/TheDrummer_Behemoth-X-123B-v2-GGUF/resolve/main/TheDrummer_Behemoth-X-123B-v2-Q5_K_M/TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00003-of-00003.gguf"

# File paths
$FILE1 = Join-Path $TARGET_DIR "TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00001-of-00003.gguf"
$FILE2 = Join-Path $TARGET_DIR "TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00002-of-00003.gguf"
$FILE3 = Join-Path $TARGET_DIR "TheDrummer_Behemoth-X-123B-v2-Q5_K_M-00003-of-00003.gguf"

# Function to download with resume capability and rate limiting
function Download-FileWithCurl {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$PartNumber
    )
    
    Write-Host "[DOWNLOAD] Downloading Part $PartNumber of 3..." -ForegroundColor Yellow
    
    # Using curl (built into Windows 10/11) with rate limiting and resume
    # --limit-rate for speed limit, -C - for resume, -L for follow redirects
    $curlArgs = @(
        "--limit-rate", $MaxSpeed,
        "-C", "-",
        "-L",
        "-o", $OutputPath,
        $Url
    )
    
    & curl.exe $curlArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Error downloading part $PartNumber" -ForegroundColor Red
        return $false
    }
    return $true
}

# Download all three parts
$success = $true
$success = $success -and (Download-FileWithCurl -Url $URL1 -OutputPath $FILE1 -PartNumber "1")
$success = $success -and (Download-FileWithCurl -Url $URL2 -OutputPath $FILE2 -PartNumber "2")
$success = $success -and (Download-FileWithCurl -Url $URL3 -OutputPath $FILE3 -PartNumber "3")

if (-not $success) {
    Write-Host "[ERROR] Download failed. Please check your internet connection and try again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[MERGE] Merging parts using llama-gguf-split (The Proper Way)..." -ForegroundColor Cyan

# Define input and output files
$inputFile = $FILE1  # Point to the first part
$outputFile = Join-Path $TARGET_DIR "TheDrummer_Behemoth-X-123B-v2-Q5_K_M-Combined.gguf"

# Check if llama-gguf-split is available
try {
    $llamaGGUFSplit = Get-Command llama-gguf-split -ErrorAction Stop
    Write-Host "[OK] Found llama-gguf-split at: $($llamaGGUFSplit.Source)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error: llama-gguf-split not found in PATH." -ForegroundColor Red
    Write-Host "        Please ensure llama.cpp is built and llama-gguf-split.exe is in your PATH." -ForegroundColor Yellow
    Write-Host "        The split files have been kept at: $TARGET_DIR" -ForegroundColor Yellow
    exit 1
}

Write-Host "[MERGE] Running merge operation..." -ForegroundColor Yellow

# Run llama-gguf-split to merge the files
& llama-gguf-split --merge $inputFile $outputFile

# Check if merge was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Proper Combined file created: $TARGET_DIR\TheDrummer_Behemoth-X-123B-v2-Q5_K_M-Combined.gguf" -ForegroundColor Green
    Write-Host "[CLEANUP] Cleaning up the 3 split parts to save space..." -ForegroundColor Yellow
    
    Remove-Item $FILE1 -Force
    Remove-Item $FILE2 -Force
    Remove-Item $FILE3 -Force
    
    Write-Host "[DONE] All done! Ready to share." -ForegroundColor Green
} else {
    Write-Host "[ERROR] Merge failed. I kept the split files just in case." -ForegroundColor Red
    Write-Host "        Split files are located at: $TARGET_DIR" -ForegroundColor Yellow
}
