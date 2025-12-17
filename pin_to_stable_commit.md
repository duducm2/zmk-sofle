# How to Pin ZMK to a Stable Commit

## Current Status
Both files are temporarily set to `main` to fix the invalid reference error. However, `main` is unstable and may break again.

## Solution: Pin to a Specific Commit Hash

### Step 1: Find a Stable Commit
1. Go to: https://github.com/zmkfirmware/zmk/commits/main
2. Scroll to commits from **December 1-3, 2024** (approximately 2 weeks ago, before Zephyr 4.1 upgrade)
3. Look for a commit that says something like "Update Zephyr" or check commit dates
4. Find a commit from **before December 9, 2024** (before the Zephyr 4.1 upgrade)
5. Click on the commit to view its details
6. Copy the **commit SHA** (the long hash, you only need the first 7-12 characters)

### Step 2: Update Both Files

**Update `.github/workflows/build.yml`:**
```yaml
uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@<your-commit-hash>
```

**Update `config/west.yml`:**
```yaml
revision: <your-commit-hash>
```

### Step 3: Test
Push the changes and trigger a new build. It should work with the pinned commit.

## Alternative: Use a Known Good Commit

If you know the exact date your builds were working, you can:
1. Go to: https://github.com/zmkfirmware/zmk/commits/main?since=2024-12-01&until=2024-12-10
2. Find a commit from that date range
3. Use that commit hash

## Why This Works
- Commit hashes are immutable - they never change
- You're pinning to a version that worked before the breaking changes
- Both files use the same commit, ensuring consistency

