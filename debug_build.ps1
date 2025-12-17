# ZMK Build Debug Script
# This script captures build errors and logs them for debugging

$ErrorActionPreference = "Continue"
$logFile = ".cursor\debug.log"

# Ensure log directory exists
if (-not (Test-Path ".cursor")) {
    New-Item -ItemType Directory -Path ".cursor" | Out-Null
}

# Function to log to NDJSON format
function Write-DebugLog {
    param(
        [string]$location,
        [string]$message,
        [hashtable]$data,
        [string]$hypothesisId = "A"
    )
    
    $logEntry = @{
        id = "log_$(Get-Date -Format 'yyyyMMddHHmmss')_$(Get-Random)"
        timestamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
        location = $location
        message = $message
        data = $data
        sessionId = "debug-session"
        runId = "build-debug"
        hypothesisId = $hypothesisId
    } | ConvertTo-Json -Compress
    
    Add-Content -Path $logFile -Value $logEntry
}

Write-DebugLog -location "debug_build.ps1:start" -message "Build debug script started" -data @{timestamp = Get-Date -Format "o"} -hypothesisId "A"

# Hypothesis A: Check ZMK version in west.yml
Write-DebugLog -location "debug_build.ps1:hypothesis_a" -message "Checking west.yml ZMK version" -data @{} -hypothesisId "A"
$westYml = Get-Content "config\west.yml" -Raw
if ($westYml -match "revision:\s*(.+)") {
    $zmkRevision = $matches[1].Trim()
    Write-DebugLog -location "debug_build.ps1:hypothesis_a" -message "ZMK revision found" -data @{revision = $zmkRevision} -hypothesisId "A"
}

# Hypothesis B: Check GitHub Actions workflow version
Write-DebugLog -location "debug_build.ps1:hypothesis_b" -message "Checking GitHub Actions workflow version" -data @{} -hypothesisId "B"
if (Test-Path ".github\workflows\build.yml") {
    $workflow = Get-Content ".github\workflows\build.yml" -Raw
    if ($workflow -match "@(.+)") {
        $workflowVersion = $matches[1]
        Write-DebugLog -location "debug_build.ps1:hypothesis_b" -message "Workflow version found" -data @{version = $workflowVersion} -hypothesisId "B"
    }
}

# Hypothesis C: Check keymap file syntax
Write-DebugLog -location "debug_build.ps1:hypothesis_c" -message "Checking keymap file exists" -data @{} -hypothesisId "C"
$keymapFile = "config\eyelash_sofle.keymap"
if (Test-Path $keymapFile) {
    $keymapContent = Get-Content $keymapFile -Raw
    $hasKeymapCompatible = $keymapContent -match 'compatible\s*=\s*"zmk,keymap"'
    Write-DebugLog -location "debug_build.ps1:hypothesis_c" -message "Keymap file check" -data @{
        exists = $true
        hasCompatible = $hasKeymapCompatible
        fileSize = (Get-Item $keymapFile).Length
    } -hypothesisId "C"
} else {
    Write-DebugLog -location "debug_build.ps1:hypothesis_c" -message "Keymap file missing" -data @{exists = $false} -hypothesisId "C"
}

# Hypothesis D: Check build.yaml configuration
Write-DebugLog -location "debug_build.ps1:hypothesis_d" -message "Checking build.yaml configuration" -data @{} -hypothesisId "D"
if (Test-Path "build.yaml") {
    $buildYaml = Get-Content "build.yaml" -Raw
    $boardCount = ([regex]::Matches($buildYaml, "board:")).Count
    Write-DebugLog -location "debug_build.ps1:hypothesis_d" -message "Build config check" -data @{
        exists = $true
        boardCount = $boardCount
    } -hypothesisId "D"
}

# Hypothesis E: Check for west workspace
Write-DebugLog -location "debug_build.ps1:hypothesis_e" -message "Checking west workspace" -data @{} -hypothesisId "E"
if (Test-Path ".west") {
    Write-DebugLog -location "debug_build.ps1:hypothesis_e" -message "West workspace exists" -data @{exists = $true} -hypothesisId "E"
} else {
    Write-DebugLog -location "debug_build.ps1:hypothesis_e" -message "West workspace missing" -data @{exists = $false} -hypothesisId "E"
}

Write-DebugLog -location "debug_build.ps1:end" -message "Build debug script completed" -data @{} -hypothesisId "A"

Write-Host "Debug information logged to $logFile"
Write-Host "Please check the log file for detailed information."

