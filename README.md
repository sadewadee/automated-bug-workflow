# Automated Bug Detection & Security Scanning Workflow

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-blue)](https://claude.com/claude-code)
[![GitHub Issues](https://img.shields.io/github/issues/sadewadee/issuetracker)](https://github.com/sadewadee/issuetracker/issues)

Complete multi-agent workflow for **automated bug detection**, **security vulnerability scanning**, GitHub issue creation, and auto-fixing across **6 programming languages**.

---

## 🎯 Features

- ✅ **Multi-Language Support** - TypeScript, JavaScript, Go, Python, Rust, PHP, Swift
- ✅ **Integrated Security Scanning** - CVEs, hardcoded secrets, SQL injection, XSS
- ✅ **GitHub Integration** - Auto-create issues with full context
- ✅ **Automated Fixing** - Auto-fix simple issues (imports + unused code)
- ✅ **Pull Request Automation** - Create PRs with auto-merge for safe changes
- ✅ **Zero Manual Setup** - Auto-creates labels on first run
- ✅ **Batch Mode** - No confirmation prompts, fully automatic

---

## 📦 What It Does

1. **Detects errors** in your code (build, lint, type errors)
2. **Scans for security vulnerabilities** (CVEs, secrets, injection attacks)
3. **Creates GitHub issues** automatically with full context
4. **Reviews & prioritizes** issues by severity and complexity
5. **Auto-fixes simple issues** (unused imports & variables only)
6. **QA validates fixes** (issue-reviewer checks bug-fixer's work)
7. **Creates PRs** with fixes and enables auto-merge for safe changes
8. **Auto-closes issues** when PRs are merged

### 🔄 QA Loop (Quality Assurance)

After bug-fixer creates a PR, issue-reviewer automatically validates:
- ✅ Fix targets correct file
- ✅ Changes match error type
- ✅ No unexpected modifications
- ✅ Single file changed (simple fix requirement)

**If QA passes**: PR approved, workflow complete
**If QA fails**: Bug-fixer retries with feedback

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/sadewadee/issuetracker.git
cd automated-bug-workflow

# Run installer
chmod +x install.sh
./install.sh
```

### First Run

```bash
# Option 1: Use the skill
> /issuetracker scan

# Option 2: Use the helper script
~/.claude/templates/issuetracker.sh scan
```

On first run, the workflow automatically:
- ✅ Checks GitHub CLI authentication
- ✅ Creates required GitHub labels (~25+ labels)
- ✅ Verifies git repository
- ✅ Ready to detect bugs and security issues!

---

## 🔧 Supported Languages

| Language | Build Tools | Linters | Security Scanners |
|----------|------------|---------|-------------------|
| **TypeScript/JavaScript** | npm, tsc | eslint | npm audit, snyk |
| **Go** | go build, go vet | golangci-lint | govulncheck, gosec |
| **Python** | py_compile | pylint, mypy | pip-audit, bandit |
| **Rust** | cargo build | cargo clippy | cargo audit |
| **PHP** | php -l | phpstan | composer audit |
| **Swift** | swift build | swiftlint | - |

---

## 🔐 Security Scanning

### Dependency Vulnerabilities (CVEs)
- npm audit (JavaScript/TypeScript)
- govulncheck (Go)
- pip-audit (Python)
- cargo audit (Rust)
- composer audit (PHP)

### Code Security Issues
- ✅ SQL injection patterns
- ✅ XSS vulnerabilities
- ✅ Hardcoded secrets (API keys, passwords, tokens)
- ✅ Dangerous functions (eval, exec, system)
- ✅ Insecure configurations
- ✅ Debug mode in production

### Priority Classification
- 🔴 **CRITICAL** (CVSS >= 9.0): Immediate fix required
- 🟠 **HIGH** (CVSS 7.0-8.9): Fix within 24-48 hours
- 🟡 **MEDIUM** (CVSS 4.0-6.9): Fix within 1 week
- 🟢 **LOW** (CVSS < 4.0): Fix when convenient

---

## 📖 Usage

### Full Scan Workflow

```bash
# Scan for bugs + security issues
> /issuetracker scan
```

This will:
1. Detect project languages
2. Run build/lint/security scans
3. Create GitHub issues for errors found
4. Review and classify issues
5. Auto-fix eligible issues (imports + unused code)
6. Create PRs with auto-merge enabled

### Fix Specific Issue

```bash
# Fix a single issue
> /issuetracker fix 456
```

### Override Manual Review

```bash
# Force fix a manual-review issue
> Use bug-fixer agent to fix issue #456 even if labeled needs-manual-review

# Batch fix all manual-review issues
> Use bug-fixer agent to fix all issues labeled needs-manual-review
```

### Check Status

```bash
# View workflow status
> /issuetracker status
```

Shows:
- Open auto-detected issues
- Auto-fix PRs in progress
- Recently closed issues

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Trigger Points                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Hooks (PostToolUse) - On error detection                │
│ 2. Manual - /issuetracker scan                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│           Orchestrator Skill                                │
│  - Coordinates multi-agent workflow                         │
│  - Auto-setup GitHub labels on first run                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
       ┌───────────┼────────────┐
       ▼           ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│  Bug     │ │  Issue   │ │   Bug    │
│ Detector │→│ Reviewer │→│  Fixer   │
│  Agent   │ │  Agent   │ │  Agent   │
└──────────┘ └────┬─────┘ └────┬─────┘
                  │            │
                  │            ▼
                  │    Creates PR with fix
                  │            │
                  │            ▼
                  └────→ QA Review (NEW!)
                         ├─ PASS → Approve
                         └─ FAIL → Retry fix
                              │
                              ▼
                         GitHub Issues/PRs
                         Auto-close on merge
```

---

## 🛡️ Safety Features

### Conservative Auto-Fix Scope
**ONLY fixes**:
- ✅ Unused imports
- ✅ Unused variables

**Does NOT fix** (requires manual review):
- ❌ Formatting issues
- ❌ Type errors
- ❌ Logic errors
- ❌ Security vulnerabilities

### Auto-Merge Blocklist
Never auto-merges changes to:
- `package.json`, lock files
- `.env`, config files
- `/api/`, `/routes/`, `/auth/`, `/payment/`
- Database migrations
- Critical infrastructure files

### Security Guarantees
- ✅ Secure hook scripts (strict error handling, input sanitization)
- ✅ Minimal GitHub permissions (least privilege)
- ✅ No secrets in logs
- ✅ Audit trail for all actions
- ✅ Rate limiting with exponential backoff

---

## 📊 Example Output

```
🔍 Running automated bug scan...

📊 Bug Detection Results:
  Languages detected: TypeScript, Go, Python

  TypeScript:
    - Build errors: 0
    - Type errors: 0
    - ESLint errors: 3 (2 unused imports, 1 unused variable)
    - npm audit: 2 high severity CVEs

  Go:
    - Build errors: 1
    - Unused imports: 2
    - gosec: 1 hardcoded secret detected

  Python:
    - Syntax errors: 0
    - Unused imports: 1
    - bandit: 1 SQL injection risk

  Total errors found: 10
  Security issues: 4
  GitHub issues created: 8 (2 duplicates skipped)

📋 Issue Review Results:
  Issue #456: unused-import in src/app.ts → Auto-fix eligible ✅
  Issue #457: unused-variable in src/utils.ts → Auto-fix eligible ✅
  Issue #458: build-error in main.go → Manual review required ⚠️
  Issue #459: CVE-2024-1234 in package.json → Manual review required 🔴
  Issue #460: hardcoded-secret in config.go → Manual review required 🔴

🔧 Auto-Fix Results:
  Issue #456: PR #789 created, auto-merge enabled ✅
  Issue #457: PR #790 created, auto-merge enabled ✅

  Auto-fixed: 2 (20%)
  Manual review required: 6 (60%)
  Duplicates: 2 (20%)

✅ Workflow complete!

View issues: https://github.com/org/repo/issues?q=is:issue+label:auto-detected
View PRs: https://github.com/org/repo/pulls?q=is:pr+label:auto-fix
```

---

## 🎨 Customization

### Per-Project Override

Create `.claude/agents/bug-detector/AGENT.md` in your project:

```markdown
---
name: bug-detector
extends: global:bug-detector
---

# Project-Specific Configuration

## Languages
Only scan: TypeScript, Go

## Skip Directories
- test/
- vendor/

## Critical Paths (never auto-fix)
- src/core/**
- src/payment/**
```

---

## 🔧 Configuration

### Hook Configuration

Hooks are automatically configured during installation. If you need to manually configure:

**`~/.claude/settings.json`**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/detect-errors.sh \"$ARGUMENTS\" \"$OUTPUT\"",
            "description": "Auto-detect errors in bash output"
          }
        ]
      }
    ]
  }
}
```

---

## 📈 Metrics & Monitoring

### Track Success Rate

```bash
# Auto-fix success rate
gh pr list --label "auto-fix" --state merged --json mergedAt | jq length

# Manual review rate
gh issue list --label "needs-manual-review" --state open --json number | jq length

# Security issues detected
gh issue list --label "security" --state all --json number | jq length
```

### View Logs

```bash
# View error detection logs
tail -f ~/.claude/logs/error-detection.log

# Check for security issues
grep "CRITICAL\|HIGH" ~/.claude/logs/error-detection.log
```

---

## 💰 Cost Estimate

### API Usage (Anthropic)
Per full scan (10 errors, 5 auto-fixed):
- **Sonnet**: ~$0.16 per scan
- **Opus**: ~$0.65 per scan

Monthly (20 pushes/day):
- **~$10-30/month** for active project (Sonnet)

### GitHub Actions
- Free: 2000 minutes/month (public repos)
- Each scan: ~5-10 minutes

---

## 🛠️ Troubleshooting

### Hook not triggering

```bash
# Check permissions
ls -la ~/.claude/hooks/detect-errors.sh
# Should be: -rwx------ (700)

# Test manually
~/.claude/hooks/detect-errors.sh "npm run build" "error TS2345"
```

### Auto-fix not working

```bash
# Verify issue labels
gh issue view 456 --json labels

# Should have: auto-fix-eligible, simple-fix
```

### Auto-merge blocked

Check:
1. File in blocklist? (`package.json`, `/api/`, etc)
2. CI checks passing?
3. Branch protection allows auto-merge?

---

## 📚 Documentation

- [Full Documentation](./README-automated-bug-workflow.md)
- [Installation Guide](./INSTALL.md)
- [Contributing Guide](./CONTRIBUTING.md)
- [License](./LICENSE)

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

---

## 📝 License

MIT License - see [LICENSE](./LICENSE) file for details.

---

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/sadewadee/issuetracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sadewadee/issuetracker/discussions)
- **Logs**: `~/.claude/logs/error-detection.log`

---

## ⭐ Show Your Support

If this project helped you, please give it a ⭐ on GitHub!

---

**Setup time**: ~5 minutes
**Maintenance**: ~15 min/week
**ROI**: Automates 50-70% of simple fixes (imports/unused only)

🤖 **Built with Claude Code**

---

Made with ❤️ by [sadewadee](https://github.com/sadewadee)
