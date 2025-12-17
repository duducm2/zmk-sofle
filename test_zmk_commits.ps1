# Script to help find a stable ZMK commit with pointing support
# Tests commits from October-November 2024 (should have pointing, before Zephyr 4.1)

Write-Host "=== Finding Stable ZMK Commit with Pointing Support ===" -ForegroundColor Cyan
Write-Host ""

# Known problematic commit (before pointing support)
$oldCommit = "0820991901a95ab7a0eb1f1cc608a631d514e26c"
Write-Host "Previous commit (no pointing support): $oldCommit" -ForegroundColor Yellow

Write-Host ""
Write-Host "Target Date Range: October 15 - November 15, 2024" -ForegroundColor Green
Write-Host "This range should have:" -ForegroundColor White
Write-Host "  - Pointing device support (mmv behavior)" -ForegroundColor White
Write-Host "  - Stability (before Zephyr 4.1 issues)" -ForegroundColor White
Write-Host ""

Write-Host "To find a commit:" -ForegroundColor Cyan
Write-Host "1. Go to: https://github.com/zmkfirmware/zmk/commits/main?since=2024-10-15&until=2024-11-15" -ForegroundColor White
Write-Host "2. Look for a commit with a stable-looking message" -ForegroundColor White
Write-Host "3. Click on it and copy the FULL commit hash (40 characters)" -ForegroundColor White
Write-Host "4. Update config/west.yml and .github/workflows/build.yml with that hash" -ForegroundColor White
Write-Host ""

Write-Host "Recommended test commits to try (in order):" -ForegroundColor Cyan
Write-Host "1. Early November 2024 (around Nov 1-5) - most recent stable" -ForegroundColor White
Write-Host "2. Late October 2024 (around Oct 25-31) - stable, well-tested" -ForegroundColor White
Write-Host "3. Mid October 2024 (around Oct 15-20) - very stable" -ForegroundColor White
Write-Host ""

Write-Host "After updating, trigger a build and check:" -ForegroundColor Cyan
Write-Host "  - Does the build succeed?" -ForegroundColor White
Write-Host "  - Does dt-bindings/zmk/pointing.h exist?" -ForegroundColor White
Write-Host "  - Does &mmv behavior work?" -ForegroundColor White
Write-Host ""

