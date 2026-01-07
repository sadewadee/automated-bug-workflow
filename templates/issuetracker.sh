#!/bin/bash
# Automated Bug Workflow - Main Orchestrator
# Usage: issuetracker.sh [scan|fix|status]

set -euo pipefail

COMMAND="${1:-scan}"

# ============================================================================
# STEP 0: PRE-FLIGHT CHECKS
# ============================================================================

echo "🚀 Automated Bug Workflow"
echo ""

# Check GitHub CLI
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub CLI not authenticated"
  echo "Run: gh auth login"
  exit 1
fi
echo "✅ GitHub CLI authenticated"

# Check git repository
if ! git remote -v >/dev/null 2>&1; then
  echo "⚠️  Not a git repository (issues won't be created)"
fi

# Auto-setup labels (first run)
echo ""
echo "🏷️  Checking GitHub labels..."
if ! gh label list --json name --jq '.[].name' 2>/dev/null | grep -q "auto-detected"; then
  echo "📦 First run - setting up labels..."

  gh label create "auto-detected" --color "0E8A16" --description "Auto-detected" 2>/dev/null || true
  gh label create "auto-fix" --color "1D76DB" --description "Auto-fix PR" 2>/dev/null || true
  gh label create "auto-fix-eligible" --color "0075CA" --description "Eligible for auto-fix" 2>/dev/null || true
  gh label create "needs-manual-review" --color "D93F0B" --description "Manual review" 2>/dev/null || true
  gh label create "typescript-error" --color "3178C6" --description "TypeScript" 2>/dev/null || true
  gh label create "go-error" --color "00ADD8" --description "Go" 2>/dev/null || true
  gh label create "python-error" --color "3776AB" --description "Python" 2>/dev/null || true
  gh label create "priority:high" --color "D93F0B" --description "High" 2>/dev/null || true
  gh label create "priority:medium" --color "FBCA04" --description "Medium" 2>/dev/null || true
  gh label create "unused-import" --color "4CAF50" --description "Unused import" 2>/dev/null || true
  gh label create "unused-variable" --color "4CAF50" --description "Unused variable" 2>/dev/null || true

  echo "✅ Labels created"
else
  echo "✅ Labels ready"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# COMMAND ROUTING
# ============================================================================

case "$COMMAND" in
  scan)
    echo "📊 Running full bug scan workflow..."
    echo ""
    echo "This will:"
    echo "1. Detect errors in your code"
    echo "2. Create GitHub issues for each error"
    echo "3. Review and triage issues"
    echo "4. Auto-fix eligible issues (imports + unused code only)"
    echo "5. Create PRs with fixes"
    echo ""
    echo "Invoke Claude Code agents:"
    echo "  > Use bug-detector agent to scan for errors and create GitHub issues"
    echo "  > Use issue-reviewer agent to review created issues"
    echo "  > Use bug-fixer agent to fix auto-fixable issues"
    ;;

  fix)
    ISSUE_NUMBER="${2:-}"
    if [ -z "$ISSUE_NUMBER" ]; then
      echo "Usage: issuetracker.sh fix <issue-number>"
      exit 1
    fi

    echo "🔧 Fixing issue #$ISSUE_NUMBER..."
    echo ""
    echo "Invoke Claude Code agents:"
    echo "  > Use issue-reviewer agent to review issue #$ISSUE_NUMBER"
    echo "  > Use bug-fixer agent to fix issue #$ISSUE_NUMBER if eligible"
    ;;

  status)
    echo "📊 Workflow Status"
    echo ""

    echo "Open auto-detected issues:"
    gh issue list --label "auto-detected" --state open --json number,title --jq '.[] | "  #\(.number): \(.title)"' || echo "  None"

    echo ""
    echo "Auto-fix PRs:"
    gh pr list --label "auto-fix" --state open --json number,title --jq '.[] | "  #\(.number): \(.title)"' || echo "  None"

    echo ""
    echo "Recently closed (last 10):"
    gh issue list --label "auto-detected" --state closed --limit 10 --json number,title,closedAt --jq '.[] | "  #\(.number): \(.title) (closed: \(.closedAt))"' || echo "  None"
    ;;

  *)
    echo "Usage: issuetracker.sh [scan|fix|status]"
    exit 1
    ;;
esac
