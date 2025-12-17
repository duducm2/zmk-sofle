# Finding a Stable ZMK Commit with Pointing Support

## Goal

Find a ZMK commit that:

1. ✅ Has pointing device support (mmv behavior)
2. ✅ Is stable (before Zephyr 4.1 issues in Dec 2024)
3. ✅ Works with your board configuration

## Strategy

### Step 1: Find Commits from October-Early November 2024

These should have pointing support but avoid Zephyr 4.1 issues.

1. Go to: https://github.com/zmkfirmware/zmk/commits/main
2. Look for commits from **October 15 - November 15, 2024**
3. Find a commit with a message like:
   - "Fix" or "feat" related to pointing
   - General stability fixes
   - NOT "Zephyr 4.1" or "upgrade"
4. Copy the full commit hash (40 characters)

### Step 2: Test the Commit

Update both files with the same commit hash:

- `config/west.yml`: Set `revision: <commit-hash>`
- `.github/workflows/build.yml`: Set `@<commit-hash>`

### Step 3: Verify Pointing Support

After the build succeeds, check that:

- `dt-bindings/zmk/pointing.h` exists
- `&mmv` behavior is available
- Mouse movement works in layer 1

## Testing Multiple Commits

If the first commit doesn't work, try:

1. **Earlier commits** (September 2024) - more stable but may lack recent fixes
2. **Later commits** (mid-November 2024) - more features but closer to Zephyr 4.1
3. **Bisect approach** - try commits in the middle and adjust based on results

## Known Good Date Range

Based on the documentation:

- ❌ **Before October 2024**: May lack pointing support
- ✅ **October - Early November 2024**: Should have pointing + stability
- ❌ **December 2024 (after Dec 8)**: Zephyr 4.1 issues
- ⚠️ **Current main**: May have Zephyr 4.1 issues
