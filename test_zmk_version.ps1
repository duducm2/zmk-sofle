# Test ZMK versions systematically to find stable commit with pointing support

param(
    [string]$CommitHash = ""
)

Write-Host "=== Testing ZMK Commit for Pointing Support ===" -ForegroundColor Cyan
Write-Host ""

if ($CommitHash -eq "") {
    Write-Host "Usage: .\test_zmk_version.ps1 -CommitHash <full-commit-hash>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To find a commit to test:" -ForegroundColor Cyan
    Write-Host "1. Visit: https://github.com/zmkfirmware/zmk/commits/main?since=2024-10-15&until=2024-11-15" -ForegroundColor White
    Write-Host "2. Pick a commit from Oct 20 - Nov 5, 2024" -ForegroundColor White
    Write-Host "3. Copy the full 40-character commit hash" -ForegroundColor White
    Write-Host "4. Run: .\test_zmk_version.ps1 -CommitHash <hash>" -ForegroundColor White
    Write-Host ""
    Write-Host "Recommended test sequence:" -ForegroundColor Green
    Write-Host "  Test 1: Nov 1, 2024 - Most recent stable" -ForegroundColor White
    Write-Host "  Test 2: Oct 25, 2024 - Well-tested" -ForegroundColor White
    Write-Host "  Test 3: Oct 20, 2024 - Very stable" -ForegroundColor White
    exit
}

Write-Host "Testing commit: $CommitHash" -ForegroundColor Yellow
Write-Host ""

# Update west.yml
$westYmlPath = "config\west.yml"
if (Test-Path $westYmlPath) {
    $content = Get-Content $westYmlPath -Raw
    $content = $content -replace "revision: main", "revision: $CommitHash"
    $content = $content -replace "revision: [0-9a-f]{40}", "revision: $CommitHash"
    Set-Content $westYmlPath -Value $content -NoNewline
    Write-Host "✓ Updated config/west.yml" -ForegroundColor Green
} else {
    Write-Host "✗ config/west.yml not found" -ForegroundColor Red
    exit 1
}

# Update build.yml
$buildYmlPath = ".github\workflows\build.yml"
if (Test-Path $buildYmlPath) {
    $content = Get-Content $buildYmlPath -Raw
    $content = $content -replace "@main", "@$CommitHash"
    $content = $content -replace "@[0-9a-f]{40}", "@$CommitHash"
    Set-Content $buildYmlPath -Value $content -NoNewline
    Write-Host "✓ Updated .github/workflows/build.yml" -ForegroundColor Green
} else {
    Write-Host "✗ .github/workflows/build.yml not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit and push these changes" -ForegroundColor White
Write-Host "2. Trigger a build in GitHub Actions" -ForegroundColor White
Write-Host "3. Check build logs for:" -ForegroundColor White
Write-Host "   - Build success" -ForegroundColor White
Write-Host "   - dt-bindings/zmk/pointing.h exists" -ForegroundColor White
Write-Host "   - No 'undefined node label mmv' errors" -ForegroundColor White
Write-Host ""

