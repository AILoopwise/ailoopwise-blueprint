#!/usr/bin/env bash
# bootstrap.sh — install the blueprint for every project on this computer (into ~/.claude/).
# Usage: bash ~/ailoopwise-blueprint/blueprint/scripts/bootstrap.sh
#
# Safe to run more than once:
#   - a file you changed is never overwritten (the new version is saved beside it as *.blueprint-new)
#   - ~/.claude/settings.json is merged, not replaced: your settings and your own hooks stay,
#     the blueprint's hooks are added once; a timestamped backup is made before any change
#
# Needs: Claude Code, jq (https://jqlang.org/download/)

set -euo pipefail

BLUEPRINT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL="$HOME/.claude"
MANIFEST="$GLOBAL/.blueprint-manifest"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required (the safety hooks use it). Install it, then run this again:"
  echo "  macOS:          brew install jq"
  echo "  Linux / WSL:    sudo apt-get install -y jq"
  echo "  Other systems:  https://jqlang.org/download/"
  exit 1
fi

# shellcheck source=lib-install.sh
. "$BLUEPRINT/scripts/lib-install.sh"

echo "=== Claude Code blueprint: global install into $GLOBAL ==="
mkdir -p "$GLOBAL/hooks" "$GLOBAL/agents" "$GLOBAL/skills"

echo "1. Global CLAUDE.md"
bp_install_file "$BLUEPRINT/global-claude.md" "$GLOBAL/CLAUDE.md" "$MANIFEST" "CLAUDE.md"

echo "2. Hook scripts"
for hook in "$BLUEPRINT/hooks/"*.sh; do
  name="$(basename "$hook")"
  case "$name" in *.matrix.sh) continue ;; esac   # test file, not a hook
  if bp_ignored "$MANIFEST" "hooks/$name"; then echo "  skipped hooks/$name (listed in .blueprint-ignore)"; continue; fi
  bp_install_file "$hook" "$GLOBAL/hooks/$name" "$MANIFEST" "hooks/$name"
  chmod +x "$GLOBAL/hooks/$name"
done

echo "3. Agents"
for agent in "$BLUEPRINT/agents/"*.md; do
  bp_install_file "$agent" "$GLOBAL/agents/$(basename "$agent")" "$MANIFEST" "agents/$(basename "$agent")"
done

echo "4. Skills available in every project"
GLOBAL_SKILLS=(new-project new-domain onboarding autoresearch claude-api prepare-autonomous semi-auto full-auto coding/security-audit)
for skill in "${GLOBAL_SKILLS[@]}"; do
  name="$(basename "$skill")"
  bp_install_dir "$BLUEPRINT/skills/$skill" "$GLOBAL/skills/$name" "$MANIFEST" "skills/$name"
done
for old in full-auto semi-auto prepare-autonomous; do
  if [ -f "$GLOBAL/commands/$old.md" ]; then
    echo "  note: $GLOBAL/commands/$old.md is from an older blueprint; the /$old skill replaces it. Delete the old file when convenient."
  fi
done

echo "5. Hooks in settings.json"
# Project hooks point at "$CLAUDE_PROJECT_DIR"/.claude/hooks; the global copies live in "$HOME"/.claude/hooks.
# Both stay shell variables in quotes, so a home folder with a space in its name works.
TEMPLATE="$(jq '(.. | objects | select(has("command")) | .command) |= gsub("\"\\$CLAUDE_PROJECT_DIR\"/\\.claude/hooks/"; "\"$HOME\"/.claude/hooks/")' "$BLUEPRINT/hooks/settings.json")"
TEMPLATE="$(bp_template_without_ignored "$MANIFEST" "$TEMPLATE" "$BLUEPRINT/hooks")"
bp_merge_settings "$GLOBAL/settings.json" "$TEMPLATE"

echo ""
echo "=== Done ==="
echo "Next:"
echo "  1. Restart Claude Code so it loads the new settings."
echo "  2. Open ~/.claude/CLAUDE.md and fill in the [placeholders]."
echo "  3. In a project folder, run /new-project."
