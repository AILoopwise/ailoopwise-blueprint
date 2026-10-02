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
# Opted-in projects only. This hook runs the project's own eslint and eslint config, which can
# be any code the folder ships. It acts only when the project folder is a line in
# ~/.claude/blueprint-projects, your own list on this machine (/new-project and
# blueprint-sync.sh --project add to it). A file inside a repo cannot opt it in.
bp_root="$(cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null && pwd -P)" || exit 0
grep -qxF -- "$bp_root" "$HOME/.claude/blueprint-projects" 2>/dev/null || exit 0
cd "$bp_root" || exit 0
set -euo pipefail

# Read tool input from stdin
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Skip if no file path or not JS/TS
[ -z "$file_path" ] && exit 0
echo "$file_path" | grep -qE '\.(js|jsx|ts|tsx|mjs|cjs)$' || exit 0

# Skip if file doesn't exist (was deleted)
[ -f "$file_path" ] || exit 0

# Lint with ESLint (if available)
# Auto-fix with ESLint, but don't let it delete unused imports/vars: when one edit adds an
# `import` and a later edit adds its usage, this hook fires in between, and the removal rules
# would strip the still-unused import. Only those rules are switched off here; the project's own
# lint run still catches genuinely dead imports. If a project lacks these plugins, eslint rejects
# the --rule and the plain fix runs instead. --no: never download eslint from npm.
if [ -f "package.json" ] && command -v npx &>/dev/null; then
    npx --no eslint --fix \
        --rule '{"unused-imports/no-unused-imports":"off","unused-imports/no-unused-vars":"off","@typescript-eslint/no-unused-vars":"off","no-unused-vars":"off"}' \
        "$file_path" 2>/dev/null \
    || npx --no eslint --fix "$file_path" 2>/dev/null \
    || true
fi

exit 0
