# Contributing to Automated Bug Workflow

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/sadewadee/issuetracker/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Claude Code version
   - Operating system
   - Relevant logs from `~/.claude/logs/error-detection.log`

### Suggesting Enhancements

1. Check [Discussions](https://github.com/sadewadee/issuetracker/discussions) for existing suggestions
2. Create a new discussion with:
   - Clear use case
   - Expected benefit
   - Implementation ideas (optional)

### Adding Language Support

To add support for a new language:

1. Fork the repository
2. Add language detection in `agents/bug-detector/AGENT.md`:
   ```bash
   # New Language
   if [[ -f "language-config-file" ]]; then
     langs+=("newlang")
   fi
   ```
3. Add build/lint commands:
   ```bash
   newlang)
     # Build & lint
     newlang-build && newlang-lint

     # Security scanning (if available)
     newlang-security-scan || true
     ;;
   ```
4. Add error patterns
5. Add security scanner patterns (if available)
6. Test thoroughly
7. Submit pull request

### Improving Security Scanners

To add new security patterns:

1. Edit `agents/bug-detector/AGENT.md`
2. Add patterns to "Universal Security Patterns" or language-specific sections
3. Test with real-world examples
4. Document in PR

## 📋 Development Setup

### Prerequisites

- Claude Code installed
- GitHub CLI authenticated
- Test repository for validation

### Installation

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/issuetracker.git
cd automated-bug-workflow

# Install to Claude Code
./install.sh

# Test
> /issuetracker scan
```

### Testing

Before submitting PR:

1. Test on at least 2 different projects
2. Verify GitHub labels creation
3. Test issue creation
4. Test PR creation
5. Test auto-merge (if applicable)
6. Check security: `grep -r "API_KEY\|PASSWORD" agents/ hooks/`

## 🎨 Code Style

### Bash Scripts
- Use `set -euo pipefail`
- Quote variables: `"$VAR"`
- Use long flags: `--flag` instead of `-f`
- Add comments for complex logic
- Test on macOS and Linux

### Markdown
- Use consistent heading levels
- Add code blocks with language tags
- Keep line length < 120 chars
- Use bullet points for lists

### Agent Definitions
- Follow existing structure
- Add clear examples
- Document error patterns
- Include security checks

## 🔒 Security Guidelines

### Do NOT commit:
- API keys or tokens
- GitHub credentials
- Test repository URLs
- Personal information

### Always:
- Sanitize inputs in hooks
- Use `|| true` for optional commands
- Implement rate limiting
- Add audit logging
- Use secure file permissions (700)

## 📝 Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** with clear messages:
   ```bash
   git commit -m "feat(detector): add Ruby language support"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Create** pull request with:
   - Clear description
   - Link to related issue (if any)
   - Test results
   - Screenshots (if UI changes)

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): add new feature
fix(scope): fix bug
docs(scope): update documentation
test(scope): add tests
refactor(scope): refactor code
chore(scope): maintenance tasks
```

Examples:
- `feat(detector): add PHP security scanning with phpstan`
- `fix(fixer): handle multi-line unused imports correctly`
- `docs(readme): add troubleshooting section`

## 🧪 Testing Checklist

Before submitting PR:

- [ ] Tested on macOS
- [ ] Tested on Linux (optional but recommended)
- [ ] No hardcoded paths
- [ ] No secrets in code
- [ ] Hooks have 700 permissions
- [ ] Scripts are executable
- [ ] All agents work independently
- [ ] Skill orchestrates correctly
- [ ] GitHub labels auto-create
- [ ] Issues created correctly
- [ ] PRs created correctly
- [ ] Auto-merge works (if applicable)
- [ ] Security patterns detect known issues
- [ ] No false positives
- [ ] Documentation updated

## 🎯 Priority Areas

We especially welcome contributions in:

1. **Language Support**
   - Ruby
   - Java
   - C#
   - Kotlin
   - Dart/Flutter

2. **Security Scanners**
   - More CVE databases
   - SAST tool integrations
   - Custom security patterns

3. **Auto-Fix Scope**
   - Simple type annotations
   - Missing return types
   - Basic null checks
   (Conservative approach - avoid complex logic)

4. **Documentation**
   - Tutorials
   - Video guides
   - Example projects
   - Troubleshooting tips

5. **Testing**
   - Unit tests for patterns
   - Integration tests
   - E2E tests

## 📞 Questions?

- Open a [Discussion](https://github.com/sadewadee/issuetracker/discussions)
- Ask in [Issues](https://github.com/sadewadee/issuetracker/issues)

## 🙏 Thank You!

Your contributions make this project better for everyone!

---

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy

### Not Acceptable

- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Unethical or unprofessional conduct

### Enforcement

Violations may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report violations to: sadewadee@gmail.com

---

Made with ❤️ by the community
