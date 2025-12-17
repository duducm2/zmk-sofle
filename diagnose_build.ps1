# ZMK Build Diagnostic Script
# Captures build configuration and potential issues

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
        runId = "diagnostic"
        hypothesisId = $hypothesisId
    } | ConvertTo-Json -Compress
    
    Add-Content -Path $logFile -Value $logEntry
}

Write-Host "=== ZMK Build Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Hypothesis A: ZMK version using unstable 'main' branch
Write-Host "[Hypothesis A] Checking ZMK version in west.yml..." -ForegroundColor Yellow
$westYmlPath = "config\west.yml"
if (Test-Path $westYmlPath) {
    $westContent = Get-Content $westYmlPath -Raw
    if ($westContent -match "(?s)name: zmk.*?revision:\s*(.+)") {
        $zmkRevision = $matches[1].Trim()
        Write-Host "  Found ZMK revision: $zmkRevision" -ForegroundColor $(if ($zmkRevision -eq "main") { "Red" } else { "Green" })
        Write-DebugLog -location "diagnose_build.ps1:hypothesis_a" -message "ZMK revision check" -data @{
            revision = $zmkRevision
            isMain = ($zmkRevision -eq "main")
            riskLevel = if ($zmkRevision -eq "main") { "HIGH" } else { "LOW" }
        } -hypothesisId "A"
        
        if ($zmkRevision -eq "main") {
            Write-Host "  WARNING: Using 'main' branch - unstable and may break!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ERROR: west.yml not found!" -ForegroundColor Red
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_a" -message "west.yml missing" -data @{exists = $false} -hypothesisId "A"
}

Write-Host ""

# Hypothesis B: GitHub Actions workflow using unstable '@main'
Write-Host "[Hypothesis B] Checking GitHub Actions workflow version..." -ForegroundColor Yellow
$workflowPath = ".github\workflows\build.yml"
if (Test-Path $workflowPath) {
    $workflowContent = Get-Content $workflowPath -Raw
    if ($workflowContent -match "uses:.*@(.+)") {
        $workflowVersion = $matches[1].Trim()
        Write-Host "  Found workflow version: $workflowVersion" -ForegroundColor $(if ($workflowVersion -eq "main") { "Red" } else { "Green" })
        Write-DebugLog -location "diagnose_build.ps1:hypothesis_b" -message "Workflow version check" -data @{
            version = $workflowVersion
            isMain = ($workflowVersion -eq "main")
            riskLevel = if ($workflowVersion -eq "main") { "HIGH" } else { "LOW" }
        } -hypothesisId "B"
        
        if ($workflowVersion -eq "main") {
            Write-Host "  WARNING: Using '@main' - may cause build failures!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ERROR: build.yml not found!" -ForegroundColor Red
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_b" -message "build.yml missing" -data @{exists = $false} -hypothesisId "B"
}

Write-Host ""

# Hypothesis C: Keymap file syntax issues
Write-Host "[Hypothesis C] Checking keymap file..." -ForegroundColor Yellow
$keymapPath = "config\eyelash_sofle.keymap"
if (Test-Path $keymapPath) {
    $keymapContent = Get-Content $keymapPath -Raw
    $hasCompatible = $keymapContent -match 'compatible\s*=\s*"zmk,keymap"'
    $fileSize = (Get-Item $keymapPath).Length
    $lineCount = (Get-Content $keymapPath).Count
    
    Write-Host "  Keymap file exists: YES" -ForegroundColor Green
    Write-Host "  Has 'compatible = zmk,keymap': $(if ($hasCompatible) { 'YES' } else { 'NO' })" -ForegroundColor $(if ($hasCompatible) { "Green" } else { "Red" })
    Write-Host "  File size: $fileSize bytes, Lines: $lineCount" -ForegroundColor White
    
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_c" -message "Keymap file check" -data @{
        exists = $true
        hasCompatible = $hasCompatible
        fileSize = $fileSize
        lineCount = $lineCount
    } -hypothesisId "C"
    
    # Check for common syntax issues
    $missingSemicolons = ([regex]::Matches($keymapContent, "bindings\s*=\s*<[^>]*>[^;]")).Count
    if ($missingSemicolons -gt 0) {
        Write-Host "  WARNING: Potential missing semicolons detected!" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ERROR: Keymap file not found!" -ForegroundColor Red
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_c" -message "Keymap file missing" -data @{exists = $false} -hypothesisId "C"
}

Write-Host ""

# Hypothesis D: Build configuration issues
Write-Host "[Hypothesis D] Checking build.yaml..." -ForegroundColor Yellow
$buildYamlPath = "build.yaml"
if (Test-Path $buildYamlPath) {
    $buildYamlContent = Get-Content $buildYamlPath -Raw
    $boardCount = ([regex]::Matches($buildYamlContent, "board:")).Count
    $shieldCount = ([regex]::Matches($buildYamlContent, "shield:")).Count
    
    Write-Host "  Build config exists: YES" -ForegroundColor Green
    Write-Host "  Board definitions: $boardCount" -ForegroundColor White
    Write-Host "  Shield definitions: $shieldCount" -ForegroundColor White
    
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_d" -message "Build config check" -data @{
        exists = $true
        boardCount = $boardCount
        shieldCount = $shieldCount
    } -hypothesisId "D"
} else {
    Write-Host "  ERROR: build.yaml not found!" -ForegroundColor Red
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_d" -message "build.yaml missing" -data @{exists = $false} -hypothesisId "D"
}

Write-Host ""

# Hypothesis E: Dependency version mismatches
Write-Host "[Hypothesis E] Checking dependency versions..." -ForegroundColor Yellow
if (Test-Path $westYmlPath) {
    $westContent = Get-Content $westYmlPath -Raw
    $projects = [regex]::Matches($westContent, "name:\s*(.+?)\s*\n.*?revision:\s*(.+)")
    Write-Host "  Dependencies found:" -ForegroundColor White
    foreach ($match in $projects) {
        $name = $match.Groups[1].Value.Trim()
        $rev = $match.Groups[2].Value.Trim()
        $color = if ($rev -eq "main") { "Red" } else { "Green" }
        Write-Host "    $name : $rev" -ForegroundColor $color
    }
    
    Write-DebugLog -location "diagnose_build.ps1:hypothesis_e" -message "Dependency check" -data @{
        projectCount = $projects.Count
    } -hypothesisId "E"
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Diagnostic information logged to: $logFile" -ForegroundColor White
Write-Host ""
Write-Host "Most likely issue: Version instability from using 'main' branches" -ForegroundColor Yellow
Write-Host "Recommended fix: Pin ZMK to a stable version tag" -ForegroundColor Green

