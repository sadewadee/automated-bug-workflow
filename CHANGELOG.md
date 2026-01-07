# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-08

### Added
- Initial release
- Multi-language bug detection (TypeScript, JavaScript, Go, Python, Rust, PHP, Swift)
- Integrated security scanning (CVE detection, hardcoded secrets, SQL injection, XSS)
- GitHub issue auto-creation with full context
- Issue review and classification (bug-detector, issue-reviewer, bug-fixer agents)
- Auto-fix for simple issues (unused imports and variables only)
- **QA Loop**: issue-reviewer validates bug-fixer's work
  - Verifies fix targets correct file
  - Checks changes match error type
  - Detects unexpected modifications
  - Ensures single file changed
  - Auto-retry on QA failure
- PR automation with auto-merge support
- Auto-close issues when PRs merge (GitHub keyword integration)
- Batch mode operation (no confirmation prompts)
- Override manual-review via explicit user prompts
- Zero-setup installation (auto-creates GitHub labels)
- Secure hook system with input sanitization
- Multi-language security scanners:
  - npm audit (JavaScript/TypeScript)
  - govulncheck, gosec (Go)
  - pip-audit, bandit (Python)
  - cargo audit (Rust)
  - composer audit (PHP)
- Universal security pattern detection (hardcoded secrets, dangerous functions)
- CVSS-based priority classification
- Auto-merge blocklist for critical files
- Comprehensive documentation

### Security
- Implemented secure hook scripts (700 permissions)
- Input sanitization (1MB limit)
- No secrets in logs
- Audit trail for all actions
- Rate limiting with exponential backoff
- Minimal GitHub permissions (least privilege)

## [Unreleased]

### Planned
- Ruby language support
- Java language support
- C# language support
- Additional auto-fix patterns (simple type annotations, return types)
- GitHub Actions workflow templates
- Web dashboard for metrics
- Slack/Discord notifications
- Advanced deduplication algorithms

---

## Version History

- **1.0.0** - Initial public release with QA loop

---

For upgrade instructions, see [UPGRADING.md](./UPGRADING.md)
