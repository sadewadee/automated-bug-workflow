#!/bin/bash
# Automated Bug Workflow - Installation Script
# Installs agents, skills, hooks, and templates to Claude Code

set -euo pipefail

echo "🤖 Automated Bug Detection & Security Scanning Workflow"
echo "=========================================================="
echo ""

# ============================================================================
# PREREQUISITES CHECK
# ============================================================================

echo "📋 Checking prerequisites..."
echo ""

# Check Claude Code installation
if [ ! -d "$HOME/.claude" ]; then
  echo "❌ Claude Code not found at ~/.claude"
  echo "Please install Claude Code first: https://claude.com/claude-code"
  exit 1
fi
echo "✅ Claude Code installed"

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI not found"
  echo ""
  echo "Install GitHub CLI:"
  echo "  macOS: brew install gh"
  echo "  Linux: sudo apt install gh"
  echo "  Windows: winget install GitHub.cli"
  echo ""
  exit 1
fi
echo "✅ GitHub CLI installed"

# Check GitHub CLI authentication
if ! gh auth status &> /dev/null; then
  echo "⚠️  GitHub CLI not authenticated"
  echo ""
  read -p "Authenticate now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh auth login
  else
    echo "❌ GitHub CLI authentication required"
    echo "Run: gh auth login"
    exit 1
  fi
fi
echo "✅ GitHub CLI authenticated"

echo ""

# ============================================================================
# INSTALLATION
# ============================================================================

echo "📦 Installing Automated Bug Workflow..."
echo ""

INSTALL_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create directories
mkdir -p "$INSTALL_DIR"/{agents,skills,hooks,templates,logs}

# Install agents
echo "Installing agents..."
cp -r "$SCRIPT_DIR/agents/bug-detector" "$INSTALL_DIR/agents/"
cp -r "$SCRIPT_DIR/agents/issue-reviewer" "$INSTALL_DIR/agents/"
cp -r "$SCRIPT_DIR/agents/bug-fixer" "$INSTALL_DIR/agents/"
echo "  ✅ bug-detector agent"
echo "  ✅ issue-reviewer agent"
echo "  ✅ bug-fixer agent"
echo ""

# Install skills
echo "Installing skills..."
cp -r "$SCRIPT_DIR/skills/automated-bug-workflow" "$INSTALL_DIR/skills/"
echo "  ✅ automated-bug-workflow skill"
echo ""

# Install hooks
echo "Installing hooks..."
cp "$SCRIPT_DIR/hooks/detect-errors.sh" "$INSTALL_DIR/hooks/"
chmod 700 "$INSTALL_DIR/hooks/detect-errors.sh"
echo "  ✅ detect-errors.sh hook (executable)"
echo ""

# Install templates
echo "Installing templates..."
cp "$SCRIPT_DIR/templates"/*.sh "$INSTALL_DIR/templates/"
chmod 700 "$INSTALL_DIR/templates"/*.sh
echo "  ✅ Helper scripts (executable)"
echo ""

# Secure permissions
echo "Setting secure permissions..."
chmod 700 "$INSTALL_DIR/hooks"
chmod 700 "$INSTALL_DIR/logs"
echo "  ✅ Hooks directory (700)"
echo "  ✅ Logs directory (700)"
echo ""

# ============================================================================
# CONFIGURATION
# ============================================================================

echo "⚙️  Configuring hooks..."
echo ""

SETTINGS_FILE="$INSTALL_DIR/settings.json"

# Backup existing settings
if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
  echo "  ✅ Backed up existing settings.json"
fi

# Check if hooks already configured
if [ -f "$SETTINGS_FILE" ] && grep -q "detect-errors.sh" "$SETTINGS_FILE" 2>/dev/null; then
  echo "  ℹ️  Hooks already configured in settings.json"
else
  # Create/update settings.json
  if [ ! -f "$SETTINGS_FILE" ]; then
    # Create new settings.json
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/detect-errors.sh \"$ARGUMENTS\" \"$OUTPUT\"",
            "description": "Auto-detect errors in bash output (multi-language)"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": ".*error.*|.*failed.*|.*FAIL.*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Error detected in notification. Run bug-detector agent to investigate and create issue if needed."
          }
        ]
      }
    ]
  }
}
EOF
    echo "  ✅ Created settings.json with hooks"
  else
    echo "  ⚠️  settings.json exists - manual hook configuration may be required"
    echo "  See: $INSTALL_DIR/README-automated-bug-workflow.md"
  fi
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo "✅ Installation complete!"
echo ""
echo "=========================================================="
echo "📚 What was installed:"
echo "=========================================================="
echo ""
echo "Agents:"
echo "  • bug-detector    - Multi-language bug + security scanner"
echo "  • issue-reviewer  - Issue triage and classification"
echo "  • bug-fixer       - Auto-fix for simple issues"
echo ""
echo "Skills:"
echo "  • automated-bug-workflow - Complete orchestration"
echo ""
echo "Hooks:"
echo "  • detect-errors.sh - Auto-trigger on errors"
echo ""
echo "Templates:"
echo "  • automated-bug-workflow.sh - Helper script"
echo "  • setup-labels.sh - GitHub label setup"
echo ""
echo "=========================================================="
echo "🚀 Quick Start"
echo "=========================================================="
echo ""
echo "1. Run your first scan:"
echo "   > /automated-bug-workflow scan"
echo ""
echo "2. Or use the helper script:"
echo "   > ~/.claude/templates/automated-bug-workflow.sh scan"
echo ""
echo "3. On first run, GitHub labels will be auto-created"
echo ""
echo "=========================================================="
echo "📖 Documentation"
echo "=========================================================="
echo ""
echo "Full documentation:"
echo "  $INSTALL_DIR/README-automated-bug-workflow.md"
echo ""
echo "View online:"
echo "  https://github.com/sadewadee/automated-bug-workflow"
echo ""
echo "=========================================================="
echo "🔧 Supported Languages"
echo "=========================================================="
echo ""
echo "✅ TypeScript/JavaScript - npm, tsc, eslint, npm audit"
echo "✅ Go                    - go build, vet, govulncheck, gosec"
echo "✅ Python                - py_compile, pylint, pip-audit, bandit"
echo "✅ Rust                  - cargo build, clippy, audit"
echo "✅ PHP                   - php -l, phpstan, composer audit"
echo "✅ Swift                 - swift build, swiftlint"
echo ""
echo "🔐 Security Scanning:"
echo "  • CVE detection"
echo "  • Hardcoded secrets"
echo "  • SQL injection"
echo "  • XSS vulnerabilities"
echo "  • Dangerous functions"
echo ""
echo "Happy bug hunting! 🐛🔍"
echo ""
