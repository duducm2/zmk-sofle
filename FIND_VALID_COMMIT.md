# How to Find a Valid ZMK Commit Hash

## Current Problem
The commit hash `0820991` in your workflow is invalid or doesn't exist in the zmkfirmware/zmk repository, causing the workflow to fail immediately (0s duration).

## Solution: Find a Valid Commit from Before Zephyr 4.1

### Step 1: Go to ZMK Commits Page
Visit: https://github.com/zmkfirmware/zmk/commits/main

### Step 2: Find a Commit from Dec 1-8, 2024
- Scroll down to find commits from **December 1-8, 2024**
- Look for commits that are **before December 9, 2024** (before Zephyr 4.1 upgrade)
- Avoid commits that mention "Zephyr 4.1" or "upgrade to 4.1"

### Step 3: Get the Full Commit Hash
1. Click on a commit from the target date range
2. You'll see the commit details page
3. Copy the **FULL commit hash** (40 characters)
   - Example: `a1b2c3d4e5f6789012345678901234567890abcd`
   - GitHub Actions accepts the full hash or at least 7 characters, but full hash is safer

### Step 4: Verify the Commit Exists
- The commit page should load successfully
- Check that it's in the `zmkfirmware/zmk` repository
- Make sure the date is before Dec 9, 2024

### Step 5: Update Both Files

**Update `.github/workflows/build.yml`:**
```yaml
uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@<full-commit-hash>
```

**Update `config/west.yml`:**
```yaml
- name: zmk
  remote: zmkfirmware
  revision: <full-commit-hash>
  import: app/west.yml
```

**Important:** Use the **SAME commit hash** in both files!

## Quick Test Method

If you want to test quickly, you can use a known good commit. Here's how to find one:

1. Go to: https://github.com/zmkfirmware/zmk/commits/main?since=2024-12-01&until=2024-12-08
2. Look for a commit with a message like:
   - "Update Zephyr" (but NOT 4.1)
   - "Fix build"
   - Or any commit from that date range
3. Click it and copy the full hash

## Alternative: Use a Tag (if available)

If ZMK has release tags, you can use those instead:
1. Go to: https://github.com/zmkfirmware/zmk/tags
2. Find a tag from before Dec 9, 2024
3. Use the tag name (e.g., `v0.3`) in both files

## Current Status

- ✅ Workflow reverted to `@main` - should at least start now
- ⚠️ Still using Zephyr 4.1 (will fail during build)
- 🔄 Need to find valid commit hash to fix the Zephyr 4.1 issue

