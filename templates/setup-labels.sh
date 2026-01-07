#!/bin/bash
# Setup GitHub labels for automated bug workflow
# Run this in your project repository: ./setup-labels.sh

set -euo pipefail

echo "🏷️  Setting up GitHub labels for automated bug detection workflow..."
echo ""

# Check if gh CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub CLI not authenticated"
  echo "Run: gh auth login"
  exit 1
fi

echo "✅ GitHub CLI authenticated"
echo ""

# Function to create label (skip if exists)
create_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  if gh label list --json name --jq '.[].name' | grep -q "^${name}$"; then
    echo "⏭️  Label exists: $name"
  else
    gh label create "$name" --color "$color" --description "$description"
    echo "✅ Created: $name"
  fi
}

echo "Creating auto-detection labels..."
create_label "auto-detected" "0E8A16" "Automatically detected by bug-detector agent"
create_label "auto-fix" "1D76DB" "Auto-fix PR created"
create_label "auto-fix-in-progress" "FBCA04" "Auto-fix in progress"
create_label "auto-fix-eligible" "0075CA" "Eligible for automated fixing"
create_label "needs-manual-review" "D93F0B" "Requires manual review"
create_label "simple-fix" "0075CA" "Simple fix eligible for auto-merge"
create_label "auto-fix-failed" "B60205" "Auto-fix attempt failed"
echo ""

echo "Creating language labels..."
create_label "typescript-error" "3178C6" "TypeScript error"
create_label "javascript-error" "F7DF1E" "JavaScript error"
create_label "go-error" "00ADD8" "Go error"
create_label "python-error" "3776AB" "Python error"
create_label "rust-error" "CE422B" "Rust error"
create_label "php-error" "777BB4" "PHP error"
create_label "swift-error" "FA7343" "Swift error"
echo ""

echo "Creating error type labels..."
create_label "build-error" "B60205" "Build/compilation error"
create_label "type-error" "D93F0B" "Type error"
create_label "lint-error" "FBCA04" "Linter error"
create_label "import-error" "FF9800" "Import/dependency error"
create_label "unused-import" "4CAF50" "Unused import (auto-fixable)"
create_label "unused-variable" "4CAF50" "Unused variable (auto-fixable)"
echo ""

echo "Creating priority labels..."
create_label "priority:critical" "B60205" "Blocks build/deployment"
create_label "priority:high" "D93F0B" "Breaks core functionality"
create_label "priority:medium" "FBCA04" "Type errors, significant issues"
create_label "priority:low" "0E8A16" "Minor issues, formatting"
echo ""

echo "Creating security labels..."
create_label "security" "D93F0B" "Security vulnerability"
create_label "cve" "B60205" "CVE vulnerability found"
create_label "critical-security" "B60205" "Critical security issue (CVSS >= 9.0)"
create_label "hardcoded-secret" "E11D21" "Hardcoded credentials/secrets"
create_label "sql-injection" "B60205" "SQL injection vulnerability"
create_label "xss" "D93F0B" "Cross-site scripting vulnerability"
create_label "rce" "B60205" "Remote code execution risk"
create_label "dependency-vulnerability" "FBCA04" "Vulnerable dependency"
echo ""

echo "Creating additional workflow labels..."
create_label "blocklist" "5319E7" "File in auto-merge blocklist"
create_label "critical-path" "E11D21" "Critical path (requires manual review)"
create_label "recently-modified" "FEF2C0" "File modified in last 24h"
create_label "uncertain" "EEEEEE" "Uncertain classification"
echo ""

echo "✅ All labels created successfully!"
echo ""
echo "View labels: gh label list"
echo "Or visit: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/labels"
