# Check ZMK version compatibility
# This script helps identify version issues

Write-Host "=== ZMK Build Version Check ===" -ForegroundColor Cyan
Write-Host ""

# Check current west.yml configuration
Write-Host "1. Checking west.yml configuration..." -ForegroundColor Yellow
if (Test-Path "config\west.yml") {
    $westContent = Get-Content "config\west.yml" -Raw
    Write-Host "   Current ZMK revision:" -ForegroundColor White
    if ($westContent -match "name: zmk[\s\S]*?revision:\s*(.+)") {
        $zmkRev = $matches[1].Trim()
        Write-Host "   -> $zmkRev" -ForegroundColor $(if ($zmkRev -eq "main") { "Red" } else { "Green" })
        if ($zmkRev -eq "main") {
            Write-Host "   WARNING: Using 'main' branch may cause instability!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ERROR: west.yml not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Checking GitHub Actions workflow..." -ForegroundColor Yellow
if (Test-Path ".github\workflows\build.yml") {
    $workflowContent = Get-Content ".github\workflows\build.yml" -Raw
    Write-Host "   Workflow version:" -ForegroundColor White
    if ($workflowContent -match "uses:.*@(.+)") {
        $workflowVer = $matches[1]
        Write-Host "   -> $workflowVer" -ForegroundColor $(if ($workflowVer -eq "main") { "Red" } else { "Green" })
        if ($workflowVer -eq "main") {
            Write-Host "   WARNING: Using '@main' may cause build failures!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "   ERROR: build.yml not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking keymap file..." -ForegroundColor Yellow
$keymapFile = "config\eyelash_sofle.keymap"
if (Test-Path $keymapFile) {
    $keymapContent = Get-Content $keymapFile -Raw
    $hasCompatible = $keymapContent -match 'compatible\s*=\s*"zmk,keymap"'
    Write-Host "   Keymap file: EXISTS" -ForegroundColor Green
    $compatibleStatus = if ($hasCompatible) { 'YES' } else { 'NO' }
    $compatibleColor = if ($hasCompatible) { "Green" } else { "Red" }
    Write-Host "   Has 'compatible = zmk,keymap': $compatibleStatus" -ForegroundColor $compatibleColor
} else {
    Write-Host "   ERROR: Keymap file not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Recommendation ===" -ForegroundColor Cyan
Write-Host "If builds are failing, try pinning ZMK to a stable version:" -ForegroundColor White
Write-Host "1. Change 'revision: main' to 'revision: v3.2' (or latest stable)" -ForegroundColor Yellow
Write-Host "2. Change workflow '@main' to '@v3.2' (or matching version)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Check https://github.com/zmkfirmware/zmk/releases for stable versions" -ForegroundColor Cyan

