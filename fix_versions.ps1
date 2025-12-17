# Fix ZMK version pinning
# This script helps pin ZMK to a stable version

Write-Host "=== ZMK Version Pinning Fix ===" -ForegroundColor Cyan
Write-Host ""

# Option 1: Pin to a specific version tag (recommended)
# Check https://github.com/zmkfirmware/zmk/releases for latest stable version
$suggestedVersion = "3.2"  # Update this based on latest stable release

Write-Host "Recommended approach:" -ForegroundColor Yellow
Write-Host "1. Check https://github.com/zmkfirmware/zmk/releases for latest stable version" -ForegroundColor White
Write-Host "2. Update config/west.yml: change 'revision: main' to 'revision: v$suggestedVersion'" -ForegroundColor White
Write-Host "3. Update .github/workflows/build.yml: change '@main' to '@v$suggestedVersion'" -ForegroundColor White
Write-Host ""

# Show current configuration
Write-Host "Current configuration:" -ForegroundColor Yellow
$westYml = Get-Content "config\west.yml" -Raw
if ($westYml -match "name: zmk[\s\S]*?revision:\s*(.+)") {
    Write-Host "  west.yml ZMK revision: $($matches[1].Trim())" -ForegroundColor Red
}

$workflow = Get-Content ".github\workflows\build.yml" -Raw
if ($workflow -match "uses:.*@(.+)") {
    Write-Host "  Workflow version: $($matches[1].Trim())" -ForegroundColor Red
}

Write-Host ""
Write-Host "Would you like to apply the fix automatically? (This will backup your files)" -ForegroundColor Cyan

