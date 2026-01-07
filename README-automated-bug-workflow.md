# Automated Bug Detection & Security Scanning Workflow

Complete multi-agent workflow for automated bug detection, **security vulnerability scanning**, GitHub issue creation, and auto-fixing across **6 languages**.

## 🎯 What It Does

1. **Detects errors** in your code (build, lint, type errors)
2. **Scans for security vulnerabilities** (CVEs, hardcoded secrets, SQL injection, XSS, etc.)
3. **Creates GitHub issues** automatically with full context
4. **Reviews & prioritizes** issues by severity and complexity
5. **Auto-fixes simple issues** (unused imports & variables only)
6. **Creates PRs** with fixes and enables auto-merge for safe changes

## 🚀 Quick Start

### First-Time Setup (Automatic)

**No manual setup required!** Just run:

```bash
# Option 1: Direct command
> /automated-bug-workflow scan

# Option 2: Helper script (shows step-by-step)
> ~/.claude/templates/automated-bug-workflow.sh scan
```

On first run, the workflow automatically:
- ✅ Checks GitHub CLI authentication
- ✅ Creates required GitHub labels (~25+ labels including security)
- ✅ Verifies git repository
- ✅ Ready to detect bugs and security issues!

### Daily Usage

```bash
# Full scan workflow (bugs + security)
> /automated-bug-workflow scan

# Or step-by-step (more control)
> Use bug-detector agent to scan and create GitHub issues
> Use issue-reviewer agent to review issues
> Use bug-fixer agent to fix eligible issues

# Fix specific issue
> /automated-bug-workflow fix 456

# Check status
> /automated-bug-workflow status
```

### Automatic Usage

Hooks auto-trigger on errors:
```bash
# Run any command - errors auto-detected
npm run build
go build
python main.py
```

## 📦 Supported Languages

✅ **TypeScript/JavaScript** - npm, tsc, eslint, npm audit, snyk
✅ **Go** - go build, go vet, govulncheck, gosec
✅ **Python** - py_compile, pylint, mypy, pip-audit, bandit
✅ **Rust** - cargo build, cargo clippy, cargo audit
✅ **PHP** - php -l, phpstan, composer audit
✅ **Swift** - swift build, swiftlint

## 🔐 Security Scanning (Integrated)

### What's Scanned

**Dependency Vulnerabilities (CVEs)**:
- npm audit (JavaScript/TypeScript)
- govulncheck (Go)
- pip-audit (Python)
- cargo audit (Rust)
- composer audit (PHP)

**Code Security Issues**:
- SQL injection patterns
- XSS vulnerabilities
- Hardcoded secrets (API keys, passwords, tokens)
- Dangerous functions (eval, exec, system)
- Insecure configurations
- Debug mode in production

**Priority Classification**:
- 🔴 **CRITICAL** (CVSS >= 9.0): Immediate fix required
- 🟠 **HIGH** (CVSS 7.0-8.9): Fix within 24-48 hours
- 🟡 **MEDIUM** (CVSS 4.0-6.9): Fix within 1 week
- 🟢 **LOW** (CVSS < 4.0): Fix when convenient

## 🔧 Configuration

### Detection Scope

**Errors only** (no warnings):
- Build/compilation errors
- Type errors
- Import errors
- Undefined references

### Auto-Fix Scope (Conservative)

**ONLY fixes**:
- ✅ Unused imports
- ✅ Unused variables

**Does NOT fix**:
- ❌ Formatting (manual review required)
- ❌ Type errors (manual review required)
- ❌ Logic errors (manual review required)
- ❌ Everything else (manual review required)

### Auto-Merge Blocklist

Never auto-merges:
- `package.json`, lock files
- `.env`, config files
- `/api/`, `/routes/`, `/auth/`, `/payment/`
- Database migrations
- Critical infrastructure

## 📁 Architecture

```
~/.claude/                          # Global config
├── agents/
│   ├── bug-detector/               # Detects errors (multi-language)
│   ├── issue-reviewer/             # Triages issues
│   └── bug-fixer/                  # Fixes simple issues
├── skills/
│   └── automated-bug-workflow/     # Orchestrates workflow
├── hooks/
│   └── detect-errors.sh            # Auto-triggers on errors
├── logs/
│   └── error-detection.log         # Audit trail
└── settings.json                   # Hook configuration

your-project/.github/workflows/     # GitHub Actions (optional)
├── bug-scan.yml                    # On push to main/develop
└── pr-analysis.yml                 # On PR events
```

## 🔐 Security Features

✅ **Hook script security**:
- Strict error handling (`set -euo pipefail`)
- Root user prevention
- Input sanitization (1MB limit)
- Secure logging (no sensitive data)
- 700 permissions (owner-only)
- No eval/dynamic code execution

✅ **GitHub Actions security**:
- Minimal permissions (least privilege)
- Fork attack prevention
- Pinned action versions (SHA)
- Rate limiting with exponential backoff

✅ **Auto-merge safety**:
- Blocklist protection
- Critical path detection
- Safety checks (syntax, tests, build)
- Audit trail (all actions logged)

## 📊 Workflow Example

```
User runs: npm run build
       ↓
Errors found → Hook detects
       ↓
bug-detector agent
  - Creates GitHub issue #456: "Unused import in src/app.ts:42"
       ↓
issue-reviewer agent
  - Analyzes: Simple fix, auto-fix eligible ✅
  - Labels: auto-fix-eligible, simple-fix
       ↓
bug-fixer agent
  - Removes unused import
  - Runs safety checks ✅
  - Creates PR #789
  - Enables auto-merge ✅
       ↓
CI checks pass → Auto-merges → Issue closes
```

## 🎨 Customization

### Per-Project Override

Create `.claude/` in your project:

```bash
your-project/
├── .claude/
│   ├── agents/
│   │   └── bug-detector/
│   │       └── AGENT.md          # Override global
│   └── settings.json              # Project-specific hooks
```

Example override:

```markdown
---
name: bug-detector
extends: global:bug-detector
---

# Project Overrides

## Languages
Only scan: TypeScript, Go

## Skip Directories
- test/
- vendor/

## Critical Paths (never auto-fix)
- src/core/**
- src/payment/**
```

## 📈 Metrics & Monitoring

### Daily Check

```bash
# View auto-detected issues
gh issue list --label "auto-detected" --state open

# View auto-fix PRs
gh pr list --label "auto-fix" --state open

# Check logs
tail -f ~/.claude/logs/error-detection.log
```

### Track Success Rate

```bash
# Auto-fix success rate
gh pr list --label "auto-fix" --state merged --json mergedAt | jq length

# Manual review rate
gh issue list --label "needs-manual-review" --state open --json number | jq length
```

## 💰 Cost Estimate

Per scan (10 errors, 5 auto-fixed):
- **API**: ~$0.16 (Sonnet) or ~$0.65 (Opus)
- **GitHub Actions**: Free (within 2000 min/month)

Monthly (on push only, ~20 pushes/day):
- **~$10-30/month** for active project (Sonnet)

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

## 📚 Setup Checklist

Global setup (done once):
- [x] Agents created (`~/.claude/agents/`)
- [x] Skills created (`~/.claude/skills/`)
- [x] Hooks configured (`~/.claude/hooks/`, `settings.json`)
- [x] GitHub CLI authenticated (`gh auth status`)

Per-project setup:
- [ ] GitHub labels configured (run label setup script)
- [ ] GitHub Actions workflows added (optional)
- [ ] Project overrides created (optional)
- [ ] Test with sample errors

## 🔄 GitHub Actions Setup (Optional)

Copy templates to your project:

```bash
# Copy workflow templates
mkdir -p your-project/.github/workflows
cp ~/.claude/templates/github-workflows/*.yml your-project/.github/workflows/

# Configure secrets
# Go to: GitHub > Settings > Secrets > Actions
# Add: ANTHROPIC_API_KEY

# Push and verify
git add .github/workflows/
git commit -m "Add automated bug detection workflows"
git push
```

## 📖 Advanced Usage

### Scan specific language

```bash
> Use bug-detector agent to scan TypeScript errors only
```

### Force manual review

```bash
> Use issue-reviewer agent to review issue #456 and mark for manual review
```

### Dry-run fix

```bash
> Use bug-fixer agent to verify fix for issue #456 (don't create PR)
```

## 🤝 Contributing

This is a local Claude Code setup. To share with team:

1. Export agents: `~/.claude/agents/`
2. Export skills: `~/.claude/skills/`
3. Export hooks: `~/.claude/hooks/`
4. Share settings: `~/.claude/settings.json` (hooks section)
5. Share workflows: `.github/workflows/`

Team members can import to their `~/.claude/` directory.

## 📝 License

Custom Claude Code configuration for personal/team use.

## 🆘 Support

- **Logs**: `~/.claude/logs/error-detection.log`
- **GitHub Issues**: Review auto-created issues
- **Hook test**: Test manually with sample error output

---

**Setup time**: ~5 minutes
**Maintenance**: ~15 min/week
**ROI**: Automates 50-70% of simple fixes (imports/unused only)

🤖 **Generated with Claude Code**
