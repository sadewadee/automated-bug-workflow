#!/bin/bash
# Error detection hook script (Multi-Language)
# SECURITY: System-safe error detection with input validation

set -euo pipefail  # Strict error handling

# ============================================================================
# SECURITY VALIDATIONS
# ============================================================================

# 1. Validate script is not running as root
if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: This script should not run as root" >&2
  exit 1
fi

# 2. Validate environment
if [ -z "${HOME:-}" ]; then
  echo "ERROR: HOME environment variable not set" >&2
  exit 1
fi

# 3. Sanitize inputs - prevent command injection
COMMAND="${1:-}"
OUTPUT="${2:-}"

# Limit output size to prevent DoS (max 1MB)
MAX_OUTPUT_SIZE=1048576
OUTPUT_SIZE=${#OUTPUT}
if [ "$OUTPUT_SIZE" -gt "$MAX_OUTPUT_SIZE" ]; then
  echo "WARNING: Output too large ($OUTPUT_SIZE bytes), truncating to 1MB" >&2
  OUTPUT="${OUTPUT:0:$MAX_OUTPUT_SIZE}"
fi

# 4. Validate Claude Code environment (optional safety check)
if [ ! -d "$HOME/.claude" ]; then
  echo "WARNING: Claude Code config directory not found" >&2
  # Continue anyway - might be first run
fi

# ============================================================================
# ERROR DETECTION LOGIC - MULTI-LANGUAGE
# ============================================================================

# Define error patterns by language (read-only array)
# ERRORS ONLY - NO WARNINGS (per configuration)
readonly ERROR_PATTERNS=(
  # TypeScript/JavaScript
  "error TS[0-9]+"                 # TypeScript compiler errors
  "[0-9]+:[0-9]+\\s+error"         # ESLint errors
  "ERROR in"                       # Webpack/Vite build errors
  "Module not found"               # Missing dependencies
  "Cannot find module"             # Import errors

  # Go
  "# command-line-arguments"       # Build errors
  "undefined:"                     # Undefined references
  "cannot use"                     # Type mismatches
  "imported but not used"          # Unused imports (auto-fixable)

  # Python
  "SyntaxError:"                   # Syntax errors
  "ImportError:"                   # Import failures
  "ModuleNotFoundError:"           # Missing modules
  "NameError:"                     # Undefined names
  "E[0-9]{4}:"                     # Pylint error codes (errors only)

  # Rust
  "error\\[E[0-9]+\\]:"            # Compiler errors
  "cannot find"                    # Missing types/modules
  "mismatched types"               # Type errors

  # PHP
  "Parse error:"                   # Syntax errors
  "Fatal error:"                   # Fatal errors
  "Call to undefined"              # Undefined functions/methods

  # Swift
  "error:.*\\.swift:"              # Swift compiler errors

  # Generic patterns
  "FAIL"                           # Test failures
  "FAILED"                         # Build failures
  "fatal:"                         # Git fatal errors
)

# Log file (secure location)
readonly LOG_DIR="$HOME/.claude/logs"
readonly LOG_FILE="$LOG_DIR/error-detection.log"

# Create log directory if doesn't exist (with secure permissions)
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
  chmod 700 "$LOG_DIR"  # Only user can read/write
fi

# Function: Log with timestamp
log() {
  local level="$1"
  shift
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
}

# Function: Safely escape for logging (prevent log injection)
escape_for_log() {
  # Remove control characters and limit length
  echo "$1" | tr -d '\000-\037' | head -c 500
}

# Function: Detect language from error pattern
detect_language() {
  local pattern="$1"

  case "$pattern" in
    *"TS"*|*"eslint"*|*"ERROR in"*)
      echo "typescript"
      ;;
    *"command-line-arguments"*|*"imported but not used"*)
      echo "go"
      ;;
    *"SyntaxError"*|*"ImportError"*|*"E[0-9]"*)
      echo "python"
      ;;
    *"error["*|*"cargo"*)
      echo "rust"
      ;;
    *"Parse error"*|*"Fatal error"*)
      echo "php"
      ;;
    *".swift"*)
      echo "swift"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# ============================================================================
# MAIN DETECTION LOGIC
# ============================================================================

log "INFO" "Hook triggered for command: $(escape_for_log "$COMMAND")"

# Check if output contains error patterns
ERRORS_FOUND=0
DETECTED_PATTERNS=()
DETECTED_LANGUAGES=()

for pattern in "${ERROR_PATTERNS[@]}"; do
  # Use grep with safety options:
  # -q: quiet (don't output matches)
  # -E: extended regex
  # -m 1: stop after first match (performance + prevent ReDoS)
  if echo "$OUTPUT" | grep -qE -m 1 "$pattern"; then
    ERRORS_FOUND=1
    DETECTED_PATTERNS+=("$pattern")

    # Detect language
    lang=$(detect_language "$pattern")
    if [[ ! " ${DETECTED_LANGUAGES[@]} " =~ " ${lang} " ]]; then
      DETECTED_LANGUAGES+=("$lang")
    fi

    log "WARN" "Error pattern detected: $pattern (language: $lang)"
  fi
done

# ============================================================================
# TRIGGER AUTOMATION (if errors found)
# ============================================================================

if [ "$ERRORS_FOUND" -eq 1 ]; then
  echo "🔴 Error pattern(s) detected: ${DETECTED_PATTERNS[*]}"
  echo "📝 Languages: ${DETECTED_LANGUAGES[*]}"

  log "INFO" "Triggering automated bug detection workflow"
  log "INFO" "Languages detected: ${DETECTED_LANGUAGES[*]}"

  # Return prompt to invoke bug-detector
  # SECURITY: Use safe prompt - no user input interpolation to prevent injection
  echo "CLAUDE_HOOK_PROMPT: Error detected in command output (languages: ${DETECTED_LANGUAGES[*]}). Please run the bug-detector agent to analyze and create issues."

  exit 0
fi

# ============================================================================
# NO ERRORS DETECTED
# ============================================================================

log "INFO" "No errors detected"
exit 0
