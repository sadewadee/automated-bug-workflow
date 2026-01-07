---
name: automated-bug-workflow
description: Complete workflow for detecting, reviewing, and fixing bugs across multiple languages. Use when running builds, on errors, or on-demand scans.
---

# Automated Bug Workflow Skill

## Overview
Orchestrates multi-agent workflow for automated bug detection and fixing:
1. **bug-detector** → Scans code for errors (multi-language)
2. **issue-reviewer** → Triages and prioritizes issues
3. **bug-fixer** → Fixes simple issues (imports + unused code only)

## Supported Languages
✅ TypeScript/JavaScript (Node.js)
✅ Go
✅ Python
✅ Rust
✅ PHP
✅ Swift

## Usage

Invoke with: `/automated-bug-workflow [scan|fix|status]`

### Commands

#### `/automated-bug-workflow scan`
Full automated scan and fix workflow:
```
1. Detect project languages
2. Run bug-detector agent
3. Create GitHub issues for errors found
4. Run issue-reviewer agent on new issues
5. Run bug-fixer agent on eligible issues
6. Report summary
```

**Example**:
```bash
> /automated-bug-workflow scan
```

#### `/automated-bug-workflow fix <issue-number>`
Fix specific issue:
```
1. Run issue-reviewer on issue
2. If eligible, run bug-fixer
3. Create PR with fix
```

**Example**:
```bash
> /automated-bug-workflow fix 456
```

#### `/automated-bug-workflow status`
Show status of automated bug fixes:
```
- Open auto-detected issues
- PRs in progress
- Recently fixed issues
- Auto-merge status
```

**Example**:
```bash
> /automated-bug-workflow status
```

## Complete Workflow Diagram

```
User triggers scan
       ↓
┌──────────────────────────────────────┐
│  Step 1: Bug Detection               │
│  → bug-detector agent                │
│     - Detects languages              │
│     - Runs build/lint per language   │
│     - Parses errors                  │
│     - Creates GitHub issues          │
└──────────────────┬───────────────────┘
                   │
                   ▼
            Errors found?
                   │
        ┌──────────┴──────────┐
       NO                    YES
        │                      │
        ▼                      ▼
  Report: All ✅      ┌────────────────────────────┐
                      │  Step 2: Issue Review      │
                      │  → issue-reviewer agent    │
                      │     - Analyze each issue   │
                      │     - Classify complexity  │
                      │     - Determine auto-fix   │
                      └────────────┬───────────────┘
                                   │
                              Auto-fixable?
                                   │
                        ┌──────────┴──────────┐
                       NO                    YES
                        │                      │
                        ▼                      ▼
              Add "needs-manual-review"  ┌─────────────────────┐
                                         │  Step 3: Auto-Fix   │
                                         │  → bug-fixer agent  │
                                         │     - Read file     │
                                         │     - Apply fix     │
                                         │     - Verify safety │
                                         │     - Create PR     │
                                         └──────────┬──────────┘
                                                    │
                                               Simple fix?
                                                    │
                                         ┌──────────┴──────────┐
                                        YES                    NO
                                         │                      │
                                         ▼                      ▼
                              Enable auto-merge      Requires manual review
                              (imports/unused only)  (critical path/blocklist)
```

## Workflow Steps Detail

### Step 0: First-Run Setup (Automatic)

```bash
# On first run, auto-setup GitHub labels
echo "🔍 Checking GitHub labels..."

# Check if labels exist
if ! gh label list --json name --jq '.[].name' | grep -q "auto-detected"; then
  echo "📦 First run detected - setting up GitHub labels..."

  # Auto-create required labels
  gh label create "auto-detected" --color "0E8A16" --description "Automatically detected" 2>/dev/null || true
  gh label create "auto-fix" --color "1D76DB" --description "Auto-fix PR" 2>/dev/null || true
  gh label create "auto-fix-eligible" --color "0075CA" --description "Eligible for auto-fix" 2>/dev/null || true
  gh label create "needs-manual-review" --color "D93F0B" --description "Manual review required" 2>/dev/null || true
  gh label create "simple-fix" --color "0075CA" --description "Simple fix" 2>/dev/null || true

  # Language labels
  gh label create "typescript-error" --color "3178C6" --description "TypeScript error" 2>/dev/null || true
  gh label create "go-error" --color "00ADD8" --description "Go error" 2>/dev/null || true
  gh label create "python-error" --color "3776AB" --description "Python error" 2>/dev/null || true
  gh label create "rust-error" --color "CE422B" --description "Rust error" 2>/dev/null || true
  gh label create "php-error" --color "777BB4" --description "PHP error" 2>/dev/null || true
  gh label create "swift-error" --color "FA7343" --description "Swift error" 2>/dev/null || true

  # Priority labels
  gh label create "priority:critical" --color "B60205" --description "Critical priority" 2>/dev/null || true
  gh label create "priority:high" --color "D93F0B" --description "High priority" 2>/dev/null || true
  gh label create "priority:medium" --color "FBCA04" --description "Medium priority" 2>/dev/null || true
  gh label create "priority:low" --color "0E8A16" --description "Low priority" 2>/dev/null || true

  # Error type labels
  gh label create "unused-import" --color "4CAF50" --description "Unused import" 2>/dev/null || true
  gh label create "unused-variable" --color "4CAF50" --description "Unused variable" 2>/dev/null || true
  gh label create "build-error" --color "B60205" --description "Build error" 2>/dev/null || true
  gh label create "type-error" --color "D93F0B" --description "Type error" 2>/dev/null || true

  # Security labels
  gh label create "security" --color "D93F0B" --description "Security vulnerability" 2>/dev/null || true
  gh label create "cve" --color "B60205" --description "CVE vulnerability found" 2>/dev/null || true
  gh label create "critical-security" --color "B60205" --description "Critical security issue (CVSS >= 9.0)" 2>/dev/null || true
  gh label create "hardcoded-secret" --color "E11D21" --description "Hardcoded credentials/secrets" 2>/dev/null || true
  gh label create "sql-injection" --color "B60205" --description "SQL injection vulnerability" 2>/dev/null || true
  gh label create "xss" --color "D93F0B" --description "Cross-site scripting vulnerability" 2>/dev/null || true
  gh label create "rce" --color "B60205" --description "Remote code execution risk" 2>/dev/null || true
  gh label create "dependency-vulnerability" --color "FBCA04" --description "Vulnerable dependency" 2>/dev/null || true

  echo "✅ GitHub labels configured!"
else
  echo "✅ GitHub labels already exist"
fi
```

### Step 1: Bug Detection

```bash
# Invoke bug-detector agent
echo "🔍 Starting automated bug scan..."

# Agent will:
# 1. Detect languages in project
# 2. Run appropriate commands per language
# 3. Parse errors (errors only, no warnings)
# 4. Check for duplicate issues
# 5. Create GitHub issues

# Expected output:
# {
#   "languages_detected": ["typescript", "go"],
#   "errors_found": 5,
#   "issues_created": 4,
#   "duplicates_skipped": 1
# }
```

### Step 2: Issue Review

```bash
# For each new issue created, invoke issue-reviewer

for issue in $(gh issue list --label "auto-detected" --state open --json number --jq '.[].number'); do
  echo "📋 Reviewing issue #$issue..."

  # Agent will:
  # 1. Analyze issue context
  # 2. Determine severity
  # 3. Classify complexity
  # 4. Check auto-fix eligibility (ONLY imports/unused code)
  # 5. Add appropriate labels

  # Eligible issues get delegated to bug-fixer
done
```

### Step 3: Auto-Fix (Conservative)

```bash
# For auto-fix eligible issues only

# Agent will:
# 1. Read affected file
# 2. Apply fix (remove unused import/variable)
# 3. Run safety checks
# 4. Create PR
# 5. Enable auto-merge (if not in blocklist/critical path)
```

## Configuration

### Auto-Fix Scope (Conservative)
**ONLY fixes**:
- ✅ Unused imports
- ✅ Unused variables

**Does NOT fix**:
- ❌ Formatting
- ❌ Type errors
- ❌ Logic errors
- ❌ Everything else → Manual review

### Auto-Merge Blocklist
Never auto-merge changes to:
- `package.json`, lock files
- `.env`, config files
- `/api/`, `/routes/`, `/auth/`, `/payment/`
- Database migrations
- Critical infrastructure files

## Example Output

```
🔍 Running automated bug scan...

📊 Bug Detection Results:
  Languages detected: TypeScript, Go, Python

  TypeScript:
    - Build errors: 0
    - Type errors: 0
    - ESLint errors: 3 (2 unused imports, 1 unused variable)

  Go:
    - Build errors: 1
    - Unused imports: 2

  Python:
    - Syntax errors: 0
    - Unused imports: 1

  Total errors found: 7
  GitHub issues created: 5 (2 duplicates skipped)

📋 Issue Review Results:
  Issue #456: unused-import in src/app.ts → Auto-fix eligible ✅
  Issue #457: unused-variable in src/utils.ts → Auto-fix eligible ✅
  Issue #458: build-error in main.go → Manual review required ⚠️
  Issue #459: unused-import in pkg/server.go → Auto-fix eligible ✅
  Issue #460: unused-import in main.py → Auto-fix eligible ✅

🔧 Auto-Fix Results:
  Issue #456: PR #789 created, auto-merge enabled ✅
  Issue #457: PR #790 created, auto-merge enabled ✅
  Issue #459: PR #791 created, auto-merge enabled ✅
  Issue #460: PR #792 created, auto-merge enabled ✅

  Auto-merge enabled: 4
  Manual review required: 1

✅ Workflow complete!

📊 Summary:
  - Total errors: 7
  - Auto-fixed: 4 (57%)
  - Manual review: 1 (14%)
  - Duplicates: 2 (29%)

View issues: https://github.com/org/repo/issues?q=is:issue+label:auto-detected+is:open
View PRs: https://github.com/org/repo/pulls?q=is:pr+label:auto-fix+is:open
```

## Pre-Flight Checks (Automatic)

The skill automatically handles setup on first run:

✅ **Auto-checks**:
- GitHub CLI authentication (`gh auth status`)
- Git repository exists (`git remote -v`)
- **Auto-creates GitHub labels** (if missing)

⚠️ **Optional** (for full functionality):
- CI/CD pipeline running (for auto-merge)
- Branch protection configured (optional)
- Language tools installed (tsc, go, python, etc.)

**No manual setup required!** Just run `/automated-bug-workflow scan`

## Label Setup (Automatic on First Run)

```bash
# Auto-detection labels
gh label create "auto-detected" --color "0E8A16"
gh label create "auto-fix" --color "1D76DB"
gh label create "auto-fix-in-progress" --color "FBCA04"
gh label create "needs-manual-review" --color "D93F0B"
gh label create "simple-fix" --color "0075CA"

# Error type labels
gh label create "typescript-error" --color "3178C6"
gh label create "go-error" --color "00ADD8"
gh label create "python-error" --color "3776AB"
gh label create "rust-error" --color "CE422B"
gh label create "php-error" --color "777BB4"
gh label create "swift-error" --color "FA7343"

# Priority labels
gh label create "priority:critical" --color "B60205"
gh label create "priority:high" --color "D93F0B"
gh label create "priority:medium" --color "FBCA04"
gh label create "priority:low" --color "0E8A16"
```

## Per-Project Customization

Create `.claude/skills/automated-bug-workflow/SKILL.md` in your project:

```markdown
---
name: automated-bug-workflow
extends: global:automated-bug-workflow
---

# Project-Specific Configuration

## Languages
Only scan: TypeScript, Go

## Skip Directories
- test/
- vendor/
- node_modules/

## Critical Paths (never auto-fix)
- src/core/**
- src/payment/**

## Custom Error Patterns
- `CUSTOM_ERROR:` → Critical priority
```

## Advanced Usage

### Scan Specific Language

```bash
> Use bug-detector agent to scan TypeScript errors only
```

### Re-scan After Manual Fix

```bash
> Use bug-detector agent to verify fixes for issue #456
```

### Review Without Auto-Fix

```bash
> Use issue-reviewer agent to review all auto-detected issues (don't auto-fix yet)
```

### Force Manual Review for Specific Issue

```bash
> Use issue-reviewer agent to review issue #456 and mark for manual review
```

## Integration Points

### Hooks
Automatically triggered on error detection:
```bash
# When you run: npm run build
# If errors found → workflow auto-starts
```

### GitHub Actions
Runs on every push:
```yaml
on:
  push:
    branches: [main, develop]
```

### Manual Trigger
Direct invocation:
```bash
> /automated-bug-workflow scan
```

## Safety Guarantees

1. **Conservative scope**: Only fixes imports + unused code
2. **Blocklist protection**: Critical files require manual review
3. **Safety checks**: Syntax, linter, tests verified before PR
4. **Audit trail**: All actions logged in GitHub
5. **Rollback ready**: Failed fixes automatically rolled back
6. **Rate limited**: Respects GitHub API limits with backoff

## Cost Estimate

Per full scan (assuming 10 errors, 5 auto-fixed):

**API Usage** (Anthropic):
- bug-detector: ~5K input, ~2K output
- issue-reviewer (5 issues): ~15K input, ~5K output
- bug-fixer (5 fixes): ~40K input, ~15K output
- **Total**: ~82K tokens ≈ $0.65 (Opus) or **$0.16 (Sonnet)**

**Frequency**:
- On push only (no scheduled scans)
- Variable cost based on push frequency
- ~$5-20/month for typical active project (Sonnet)

## Troubleshooting

### No errors detected but build fails
Check language detection - may need to add language-specific files

### Auto-fix not triggering
Verify issue has `auto-fix-eligible` label from reviewer

### Auto-merge not working
Check:
1. Branch protection settings
2. CI checks passing
3. File not in blocklist
4. Not in critical path

### Duplicate issues created
Deduplication checks last 100 issues - may need manual cleanup

## Next Steps

After first run:
1. Review created issues
2. Check PR quality
3. Adjust thresholds if needed
4. Add project-specific overrides
5. Monitor auto-merge success rate

---

**Maintenance**: ~15 min/week (review metrics)
**ROI**: Automates ~50-70% of simple fixes (imports/unused only)
