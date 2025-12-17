# Fix for ZMK Build Failure - Zephyr 4.1 Kconfig Error

## Problem Identified

Your build is failing with this error:

```
Kconfig.zephyr:29: '/tmp/tmp.ip0ZmJmtUI/Kconfig/soc/Kconfig.defconfig' not found
CMake Error at kconfig.cmake:396: command failed with return code 1
```

**Root Cause:** Zephyr 4.1.0 upgrade (released Dec 9, 2024) broke the Kconfig step. Your build is using Zephyr 4.1.0, which has breaking changes.

## Solution: Pin to Pre-Zephyr 4.1 Commit

You need to pin both `west.yml` and `build.yml` to a commit hash from **before December 9, 2024**.

### Step 1: Find a Stable Commit

1. Go to: https://github.com/zmkfirmware/zmk/commits/main
2. Scroll to commits from **December 1-8, 2024** (before Zephyr 4.1 upgrade)
3. Look for a commit that says something like:
   - "Update Zephyr to 3.x" (NOT 4.1)
   - Or any commit from Dec 1-8, 2024
4. Click on the commit
5. Copy the **commit SHA** (first 7-12 characters, e.g., `a1b2c3d`)

### Step 2: Update config/west.yml

Change this:

```yaml
- name: zmk
  remote: zmkfirmware
  revision: main
  import: app/west.yml
```

To this (replace `<commit-hash>` with the actual hash):

```yaml
- name: zmk
  remote: zmkfirmware
  revision: <commit-hash> # e.g., a1b2c3d
  import: app/west.yml
```

### Step 3: Update .github/workflows/build.yml

Change this:

```yaml
uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@main
```

To this (use the SAME commit hash):

```yaml
uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@<commit-hash>
```

### Step 4: Test

Push the changes and trigger a new build. It should work with the pinned commit.

## Why This Works

- Commit hashes are immutable - they never change
- You're pinning to a version that worked before the breaking Zephyr 4.1 changes
- Both files use the same commit, ensuring consistency
- The Kconfig system will work correctly with the older Zephyr version

## Alternative: Use a Known Good Date

If you know your builds were working on a specific date (e.g., Dec 3, 2024), you can:

1. Go to: https://github.com/zmkfirmware/zmk/commits/main?since=2024-12-01&until=2024-12-08
2. Find a commit from that date range
3. Use that commit hash

## Important Notes

- **Both files must use the same commit hash** - don't mix different commits
- **Don't use `main`** - it will pull the latest (broken) version
- **Test after pinning** - verify the build works before making other changes
