#!/bin/bash
# Pre-publish Verification Script
# Run this before pushing to GitHub

set -euo pipefail

echo "🔍 Pre-Publish Verification"
echo "=============================="
echo ""

ERRORS=0

# Check required files
echo "📋 Checking required files..."
REQUIRED_FILES=(
  "README.md"
  "LICENSE"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  ".gitignore"
  "install.sh"
  "agents/bug-detector/AGENT.md"
  "agents/issue-reviewer/AGENT.md"
  "agents/bug-fixer/AGENT.md"
  "skills/issuetracker/SKILL.md"
  "hooks/detect-errors.sh"
  "templates/issuetracker.sh"
  "templates/setup-labels.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (MISSING)"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# Check for secrets
echo "🔒 Checking for secrets..."
# Exclude documentation patterns and examples
if grep -rn "sk-ant-\|ghp_\|ANTHROPIC_API_KEY.*sk-ant" agents/ hooks/ skills/ templates/ --exclude="*.md" 2>/dev/null; then
  echo "  ❌ Potential real secrets found!"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ No secrets found"
fi
echo ""

# Check permissions
echo "🔐 Checking file permissions..."
if [ ! -x "install.sh" ]; then
  echo "  ❌ install.sh not executable"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ install.sh executable"
fi

if [ ! -x "hooks/detect-errors.sh" ]; then
  echo "  ⚠️  hooks/detect-errors.sh not executable (will be fixed on install)"
else
  echo "  ✅ hooks/detect-errors.sh executable"
fi
echo ""

# Check for TODO/FIXME
echo "📝 Checking for unfinished work..."
if grep -rn "TODO\|FIXME\|XXX" agents/ hooks/ skills/ templates/ README.md 2>/dev/null | grep -v "TodoWrite"; then
  echo "  ⚠️  Found TODO/FIXME comments"
else
  echo "  ✅ No TODO/FIXME found"
fi
echo ""

# Check for test files
echo "🧪 Checking for test artifacts..."
if find . -name "*.test.log" -o -name "test-errors.ts" -o -name "build.log" 2>/dev/null | grep -q .; then
  echo "  ⚠️  Test artifacts found - remove before publishing"
else
  echo "  ✅ No test artifacts"
fi
echo ""

# Check line endings
echo "📄 Checking line endings..."
if file * | grep -q "CRLF"; then
  echo "  ⚠️  CRLF line endings found - should be LF"
else
  echo "  ✅ Line endings OK"
fi
echo ""

# Summary
echo "=============================="
if [ $ERRORS -eq 0 ]; then
  echo "✅ All checks passed!"
  echo ""
  echo "Next steps:"
  echo "1. git init"
  echo "2. git add ."
  echo "3. git commit -m \"Initial commit: Automated Bug Workflow v1.0.0\""
  echo "4. git remote add origin https://github.com/sadewadee/issuetracker.git"
  echo "5. git push -u origin main"
  echo ""
  echo "Then create a release:"
  echo "  gh release create v1.0.0 --title \"v1.0.0 - Initial Release\" --notes-file CHANGELOG.md"
else
  echo "❌ $ERRORS error(s) found - fix before publishing"
  exit 1
fi
