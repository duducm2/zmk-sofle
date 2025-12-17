# Script to help find the correct ZMK version
Write-Host "=== Finding Correct ZMK Version ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "The error indicates that '3.2' is not a valid reference." -ForegroundColor Yellow
Write-Host ""
Write-Host "Options to fix:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Use 'main' branch (but this is unstable):" -ForegroundColor White
Write-Host "   uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@main" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Use a specific commit hash (most stable):" -ForegroundColor White
Write-Host "   - Go to: https://github.com/zmkfirmware/zmk/commits/main" -ForegroundColor Gray
Write-Host "   - Find a commit from ~2 weeks ago (Dec 1-3, 2024)" -ForegroundColor Gray
Write-Host "   - Copy the commit SHA (first 7-12 characters)" -ForegroundColor Gray
Write-Host "   - Use: uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@<commit-sha>" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Check for valid tags:" -ForegroundColor White
Write-Host "   - Visit: https://github.com/zmkfirmware/zmk/tags" -ForegroundColor Gray
Write-Host "   - Look for tags like 'v0.2', 'v3.2', etc." -ForegroundColor Gray
Write-Host ""
Write-Host "Recommended: Use option 2 (commit hash) for maximum stability" -ForegroundColor Green

