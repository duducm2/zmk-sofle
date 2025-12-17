# Finding Stable ZMK Version with Pointing Support

## Current Status

- ❌ Using `main` branch (may have Zephyr 4.1/Kconfig issues)
- ❌ Previous commit `0820991901a95ab7a0eb1f1cc608a631d514e26c` (no pointing support)
- ✅ Keymap configured for pointing (mmv behavior)
- ✅ CONFIG_ZMK_POINTING=y enabled

## Target

Find a commit that:

1. Has pointing device support (mmv, msc, mkp behaviors)
2. Is stable (before Zephyr 4.1 issues in Dec 2024)
3. Works with your board configuration

## Testing Strategy

### Step 1: Find Candidate Commits

Go to: https://github.com/zmkfirmware/zmk/commits/main?since=2024-10-15&until=2024-11-15

**Recommended test order:**

1. **Early November (Nov 1-5, 2024)** - Most recent stable, likely has all features
2. **Late October (Oct 25-31, 2024)** - Well-tested, stable
3. **Mid October (Oct 15-20, 2024)** - Very stable, conservative choice

### Step 2: Test Each Commit

For each candidate commit:

1. **Update files:**

   - `config/west.yml`: Set `revision: <commit-hash>`
   - `.github/workflows/build.yml`: Set `@<commit-hash>`

2. **Commit and push**

3. **Trigger build and check:**

   - ✅ Build succeeds
   - ✅ No "undefined node label 'mmv'" errors
   - ✅ `dt-bindings/zmk/pointing.h` exists
   - ✅ No Zephyr/Kconfig errors

4. **If successful:** Test mouse movement on keyboard
5. **If failed:** Try next candidate commit

### Step 3: Verify Pointing Support

After a successful build, verify:

- Mouse movement keys work in layer 1
- No build errors related to pointing
- Firmware functions correctly

## Quick Test Script

Use the PowerShell script to update files:

```powershell
.\test_zmk_version.ps1 -CommitHash <commit-hash>
```

## Expected Results

**Good commit will:**

- Build successfully
- Include `dt-bindings/zmk/pointing.h`
- Support `&mmv`, `&msc`, `&mkp` behaviors
- Work with your board configuration

**Bad commit will show:**

- "undefined node label 'mmv'" errors
- Missing `dt-bindings/zmk/pointing.h` file
- Zephyr/Kconfig errors
- Build failures

## Success Criteria

When you find the right commit:

1. ✅ Build succeeds
2. ✅ Mouse movement works in layer 1
3. ✅ All keyboard functionality works
4. ✅ No errors in build logs

Then pin this commit in both files for future builds.
