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
# SessionStart hook. Its output is added to Claude's context at the start of a session.
# Claude Code already lists installed skills and agents, so this hook does not repeat them.

# The Edit/Write safety hooks read their input with jq. Without jq they block every edit and
# write (fail closed); the command guard has its own reader and keeps working. So this is the
# one warning worth printing every session.
if ! command -v jq >/dev/null 2>&1; then
  echo "WARNING: jq is not installed. Without jq, edits and writes are blocked until jq is installed; the command guard still works. Tell the user now: install jq (https://jqlang.org/download/), then restart Claude Code."
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

[ -f tasks/current.md ] && echo "tasks/current.md exists: read it to see where work stopped."
[ -f tasks/lessons.md ] && echo "tasks/lessons.md exists: read it for rules learned in this project."
if [ ! -f tasks/current.md ] && [ ! -d .claude/skills ]; then
  echo "This folder is not set up as a blueprint project yet. If the user wants to work here, suggest /new-project (setup) or /onboarding (explains the system)."
fi
exit 0
