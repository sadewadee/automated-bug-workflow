---
name: issuetracker
description: Complete workflow for detecting, reviewing, and fixing bugs across multiple languages. Use when running builds, on errors, or on-demand scans.
---

# Issue Tracker Workflow

## INSTRUCTIONS: When this skill is invoked

**Command Format:**
- `/issuetracker` or `/issuetracker scan` - Full scan workflow
- `/issuetracker fix <number>` - Fix specific issue
- `/issuetracker status` - Show workflow status

### Default behavior (no args) or `scan` arg:

1. **Immediately** use the Task tool to invoke the bug-detector agent:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - description: "Deep bug analysis and detection"
   - prompt: "THINK HARDER - Deep Bug Analysis Mode:

You are now operating in extended thinking mode. Take your time to thoroughly investigate this codebase.

Your mission:
1. Read and understand the bug-detector agent definition (AGENT.md)
2. Execute ALL detection categories (14 categories, 100+ bug types):
   - Core: build, lint, type, security
   - Extended: performance, code quality, testing, accessibility, documentation, best practices, dependencies, database, git, configuration
3. For EACH error found:
   - Analyze root cause deeply
   - Understand file context and relationships
   - Identify patterns and anti-patterns
   - Consider edge cases and potential side effects
   - Read related code to understand impact
4. Create detailed GitHub issues with:
   - Clear title and description
   - Root cause analysis
   - File path and line numbers
   - Suggested fix with reasoning
   - Priority and severity labels
5. Work in batch mode (no confirmations, create all issues automatically)

Report final summary:
- Total errors found (by category)
- Issues created (with numbers)
- Issues skipped (duplicates)
- Recommendations for manual review

Take as much time as needed for thorough analysis. Quality over speed."
   ```

2. **After bug-detector completes**, check the output:
   - If 0 errors found: Report "✅ No errors found" and STOP
   - If errors found: Continue to step 3

3. **Ask user permission**:
   "Found X issues. Would you like me to review and auto-fix eligible ones? (yes/no)"

   - If user says NO: STOP and show GitHub issues link
   - If user says YES: Continue to step 4

4. **Immediately** use the Task tool to invoke issue-reviewer agent:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - description: "Review auto-detected issues"
   - prompt: "THINK HARDER - Issue Review Mode:

Use the issue-reviewer agent to review all issues with label 'auto-detected'.

For each issue:
1. Read the issue details and file context
2. Determine complexity (simple vs complex)
3. Check if auto-fix eligible (ONLY unused imports/variables)
4. Add appropriate labels:
   - 'auto-fix-eligible' for simple unused code
   - 'needs-manual-review' for everything else
5. Add priority labels (critical/high/medium/low)

CRITICAL: After reviewing ALL issues, you MUST report:
- Total issues reviewed: X
- Auto-fix eligible: Y (list issue numbers)
- Needs manual review: Z (list issue numbers)

THEN IMMEDIATELY continue to bug-fixer if Y > 0. Do NOT stop or ask for permission."
   ```

5. **After issue-reviewer completes**, check the output:
   - If 0 auto-fix eligible: Report "No auto-fixable issues. All require manual review." and STOP
   - If auto-fix eligible found: **IMMEDIATELY continue to step 6 without asking permission**

6. **Immediately** use the Task tool to invoke bug-fixer agent:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - description: "Auto-fix eligible issues"
   - prompt: "THINK HARDER - Bug Fix Mode:

Use the bug-fixer agent to fix all issues with label 'auto-fix-eligible'.

For each issue:
1. Read the issue details and affected file
2. Understand the error context
3. Apply the fix (remove unused import/variable)
4. Verify fix doesn't break anything
5. Create a PR with clear description
6. Close the original issue with reference to PR

CRITICAL: After fixing ALL eligible issues, you MUST:
- Report how many PRs were created
- Report how many issues were closed
- List all PR numbers and their corresponding issue numbers

Do NOT stop until all auto-fix-eligible issues are processed."
   ```

7. **Report final summary**:
   ```
   ✅ Issue Tracker Workflow Complete!

   📊 Summary:
   - Total errors detected: X
   - Auto-fixed: Y
   - Manual review required: Z
   - PRs created: A

   🔗 View Issues: https://github.com/{org}/{repo}/issues?q=is:issue+label:auto-detected
   🔗 View PRs: https://github.com/{org}/{repo}/pulls?q=is:pr+label:auto-fix
   ```

### If invoked with `fix` arg and issue number:

1. **Extract issue number** from the command

2. **Immediately** use the Task tool to invoke issue-reviewer:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - description: "Review single issue"
   - prompt: "Use issue-reviewer agent to review issue #{issue-number} and determine if it's auto-fix eligible."
   ```

3. **After review**, check if auto-fix eligible:
   - If NOT eligible: Report "Issue #{issue-number} requires manual review" and STOP
   - If eligible: Continue to step 4

4. **Ask user permission**:
   "Issue #{issue-number} is auto-fix eligible. Proceed? (yes/no)"

   - If NO: STOP
   - If YES: Continue to step 5

5. **Immediately** use the Task tool to invoke bug-fixer:
   ```
   Task tool with:
   - subagent_type: "general-purpose"
   - description: "Fix single issue"
   - prompt: "Use bug-fixer agent to fix issue #{issue-number}, create a PR, and trigger QA review."
   ```

6. **Report result**:
   ```
   ✅ Issue #{issue-number} fixed!

   📝 PR created: #{pr-number}
   🔗 View PR: {pr-url}
   ```

### If invoked with `status` arg:

1. **Immediately** run these bash commands to get status:
   ```bash
   gh issue list --label "auto-detected" --state open --json number,title
   gh pr list --label "auto-fix" --state open --json number,title
   gh issue list --label "auto-detected" --state closed --limit 10 --json number,title,closedAt
   ```

2. **Display formatted status**:
   ```
   📊 Issue Tracker Status

   Open Issues: X
   {list of open issues}

   Open PRs: Y
   {list of open PRs}

   Recently Closed: Z
   {list of recently closed}
   ```

## IMPORTANT NOTES

- **Skill arguments**: Parse any text after skill name as command (scan, fix, status)
- **Always use the Task tool** to invoke agents (bug-detector, issue-reviewer, bug-fixer)
- **Never just describe** what should happen - actually invoke the agents
- **Ask for permission** before issue-reviewer and bug-fixer (but NOT before bug-detector)
- **Show progress** at each step
- **Report summaries** after each agent completes

## Command Examples

```bash
# Full scan (default)
/issuetracker
/issuetracker scan

# Fix specific issue
/issuetracker fix 456

# Check status
/issuetracker status
```

**Example**:
```bash
> /issuetracker fix 456
```

#### `/issuetracker status`
Show status of automated bug fixes:
```
- Open auto-detected issues
- PRs in progress
- Recently fixed issues
- Auto-merge status
```

**Example**:
```bash
> /issuetracker status
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

**No manual setup required!** Just run `/issuetracker scan`

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

Create `.claude/skills/issuetracker/SKILL.md` in your project:

```markdown
---
name: automated-bug-workflow
extends: global:issuetracker
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
> /issuetracker scan
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
