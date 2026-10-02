#!/usr/bin/env bash

# ── Run once, not twice. If this is the global copy (~/.claude/hooks) and the current project
# registers its own copy of this same hook, stop here: the project copy runs instead.
# Project copies always run. Needs no jq.
bp_self="$(basename "${BASH_SOURCE[0]}")"
case "${BASH_SOURCE[0]}" in
  "$HOME"/.claude/hooks/*)
    if [ -n "${CLAUDE_PROJECT_DIR:-}" ] \
      && [ "$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && pwd -P)" != "$(cd "$HOME" 2>/dev/null && pwd -P)" ] \
      && [ -f "$CLAUDE_PROJECT_DIR/.claude/hooks/$bp_self" ] \
      && grep -F ".claude/hooks/$bp_self" "$CLAUDE_PROJECT_DIR/.claude/settings.json" 2>/dev/null | grep -qvE '(\$HOME|~|/home/[^/"]+|/Users/[^/"]+)/\.claude/hooks/'; then
      exit 0
    fi ;;
esac
set -euo pipefail

# OWASP vulnerability pattern detection — PostToolUse on Edit|Write
# WARNS (non-blocking) about common vulnerability patterns in written code.
# Layer: BLUEPRINT (project-level)

input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0

# Only scan code files
echo "$file_path" | grep -qE '\.(js|jsx|ts|tsx|mjs|cjs|py|rb|php|go|java)$' || exit 0

# Skip test/fixture files (high false-positive rate)
if echo "$file_path" | grep -qEi '(test|spec|fixture|mock|fake|stub|__test__|__spec__|\.test\.|\.spec\.)'; then
    exit 0
fi

# Skip if file doesn't exist on disk
[ -f "$file_path" ] || exit 0

# Read from disk (PostToolUse — file is already written, so we scan the full result)
file_content=$(cat "$file_path")
warnings=()

# --- SQL Injection ---
if echo "$file_content" | grep -qE '(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER)[[:space:]].*\+[[:space:]]'; then
    warnings+=("SQL INJECTION: String concatenation in SQL query — use parameterized queries")
fi
if echo "$file_content" | grep -qE '(SELECT|INSERT|UPDATE|DELETE)[[:space:]].*\$\{'; then
    warnings+=("SQL INJECTION: Template literal in SQL query — use parameterized queries")
fi
if echo "$file_content" | grep -qE "f[\"'](SELECT|INSERT|UPDATE|DELETE)[[:space:]].*\{"; then
    warnings+=("SQL INJECTION: Python f-string in SQL query — use parameterized queries")
fi

# --- XSS ---
if echo "$file_content" | grep -qE '\.innerHTML[[:space:]]*='; then
    warnings+=("XSS: innerHTML assignment — use textContent or sanitize input")
fi
if echo "$file_content" | grep -qE 'dangerouslySetInnerHTML'; then
    warnings+=("XSS: dangerouslySetInnerHTML — ensure content is sanitized (e.g., DOMPurify)")
fi
if echo "$file_content" | grep -qE 'document\.write[[:space:]]*\('; then
    warnings+=("XSS: document.write() — avoid in modern applications")
fi
if echo "$file_content" | grep -qE 'outerHTML[[:space:]]*='; then
    warnings+=("XSS: outerHTML assignment — use safe DOM manipulation")
fi

# --- Command Injection ---
if echo "$file_content" | grep -qE '(^|[[:space:]])eval[[:space:]]*\('; then
    warnings+=("COMMAND INJECTION: eval() — avoid evaluating dynamic strings")
fi
if echo "$file_content" | grep -qE 'os\.(system|popen)[[:space:]]*\('; then
    warnings+=("COMMAND INJECTION: os.system()/os.popen() — use subprocess with shell=False")
fi
if echo "$file_content" | grep -qE 'subprocess\.[a-z]+\(.*shell[[:space:]]*=[[:space:]]*True'; then
    warnings+=("COMMAND INJECTION: subprocess with shell=True — use shell=False with args list")
fi
if echo "$file_content" | grep -qE 'child_process.*exec[[:space:]]*\('; then
    warnings+=("COMMAND INJECTION: child_process.exec() — prefer execFile() with argument arrays")
fi

# --- Path Traversal ---
if echo "$file_content" | grep -qE '(readFile|writeFile|createReadStream|open\(|fopen|file_get_contents).*\.\./'; then
    warnings+=("PATH TRAVERSAL: ../ in file operation — validate and sanitize file paths")
fi

# --- Output warnings ---
if [ ${#warnings[@]} -gt 0 ]; then
    echo "=== OWASP Security Warnings: $file_path ===" >&2
    for warning in "${warnings[@]}"; do
        echo "  [!] $warning" >&2
    done
fi

exit 0
