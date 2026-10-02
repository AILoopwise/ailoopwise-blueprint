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

# Dependency vulnerability audit — PostToolUse on Bash
# WARNS (non-blocking) after package install commands by running audit.
# Layer: BLUEPRINT (project-level)

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

[ -z "$command" ] && exit 0

# Only trigger on package install commands
echo "$command" | grep -qE '(npm (install|i)( |$)|yarn (add|install)( |$)|pnpm (install|add)( |$)|bun (install|add)( |$))' || exit 0

echo "=== Dependency security audit ===" >&2

if echo "$command" | grep -qE '^npm '; then
    if command -v npm &>/dev/null; then
        npm audit --omit=dev 2>&1 | head -20 >&2 || true
    fi
elif echo "$command" | grep -qE '^pnpm '; then
    if command -v pnpm &>/dev/null; then
        pnpm audit --prod 2>&1 | head -20 >&2 || true
    fi
elif echo "$command" | grep -qE '^yarn '; then
    if command -v yarn &>/dev/null; then
        # Detect Yarn version: Berry (2+) uses different audit syntax
        yarn_version=$(yarn --version 2>/dev/null | cut -d. -f1)
        if [ "$yarn_version" -ge 2 ] 2>/dev/null; then
            yarn npm audit --all 2>&1 | head -20 >&2 || true
        else
            yarn audit --groups dependencies 2>&1 | head -20 >&2 || true
        fi
    fi
elif echo "$command" | grep -qE '^bun '; then
    # bun has no native audit — fall back to npm if available
    if command -v npm &>/dev/null; then
        npm audit --omit=dev 2>&1 | head -20 >&2 || true
    fi
fi

echo "=== End dependency audit ===" >&2

exit 0
