#!/usr/bin/env bash
# blueprint-sync.sh — bring earlier installs up to date after you update this blueprint folder.
# Usage: bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh [--dry-run]
#        bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --project <folder>
#          (only that project, and adds it to your opt-in list ~/.claude/blueprint-projects;
#           /new-project runs this)
#        bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --unregister <folder>
#          (remove a project from the opt-in list; nothing else changes)
#        --depth N   how many folder levels below $HOME to search for projects (default 3)
#
# What it updates:
#   - the global install in ~/.claude/ (only if bootstrap.sh installed it)
#   - every project with a .claude/.blueprint marker (written by /new-project and --project), up to --depth folders below $HOME:
#     hook scripts, agents, and the blueprint skills that project already has
#   - the hooks in each settings.json, merged: your settings and your own hooks stay
#
# What it never does:
#   - overwrite a file you changed (the new version is saved beside it as *.blueprint-new)
#   - install anything listed in <.claude folder>/.blueprint-ignore (a file you deleted comes back otherwise)
#   - touch a project CLAUDE.md, .mcp.json or tasks/
#   - link into this folder: everything is copied, so moving this folder breaks nothing
#   - write through a symlink inside a project (a downloaded repo can link .claude/settings.json
#     into ~/.claude): such a project is skipped, or that one file is refused
#   - add a project to ~/.claude/blueprint-projects unless you name it with --project
#     (a .claude/.blueprint file inside a folder only means "update me", it grants nothing)

set -uo pipefail

BLUEPRINT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BP_DRY_RUN=false
ONLY_PROJECT=""
UNREGISTER=""
DEPTH=3
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) BP_DRY_RUN=true ;;
    --project) ONLY_PROJECT="$(cd "${2:?--project needs a folder}" && pwd -P)" || exit 1; shift ;;
    --unregister) UNREGISTER="${2:?--unregister needs a folder}"; shift ;;
    --depth) DEPTH="${2:?--depth needs a number}"; shift
             case "$DEPTH" in ''|*[!0-9]*) echo "--depth needs a number"; exit 1 ;; esac ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required. Install it (https://jqlang.org/download/) and run this again."
  exit 1
fi

# shellcheck source=lib-install.sh
. "$BLUEPRINT/scripts/lib-install.sh"

HOOK_SCRIPTS=()
for hook in "$BLUEPRINT/hooks/"*.sh; do
  case "$(basename "$hook")" in *.matrix.sh) continue ;; esac
  HOOK_SCRIPTS+=("$hook")
done

# The opt-in list: projects whose own tools (npm run lint, tests, eslint) quality-check.sh and
# format-and-lint.sh may run. One resolved folder per line. It lives in ~/.claude, not in the
# project, so a downloaded repo cannot opt itself in.
OPTIN="$HOME/.claude/blueprint-projects"
optin_register() { # resolved project folder
  local BP_SCOPE=global
  case "$1" in /*) ;; *) echo "  ERROR: not an absolute folder: $1" >&2; return 1 ;; esac
  case "$1" in *$'\n'*) echo "  ERROR: a folder name with a line break cannot be registered." >&2; return 1 ;; esac
  if [ -f "$OPTIN" ] && grep -qxF -- "$1" "$OPTIN"; then echo "  already in $OPTIN"; return 0; fi
  if $BP_DRY_RUN; then echo "  [dry-run] add to $OPTIN"; return 0; fi
  bp_write_ok "$OPTIN" || return 1
  mkdir -p "$(dirname "$OPTIN")" && ( umask 077; : >> "$OPTIN" ) || return 1
  if [ -n "$(tail -c 1 "$OPTIN")" ]; then echo >> "$OPTIN"; fi   # the last line had no line break
  printf '%s\n' "$1" >> "$OPTIN"
  echo "  added to $OPTIN: its quality checks may now run this project's own tools"
}
optin_unregister() { # folder
  local BP_SCOPE=global tmp="$OPTIN.tmp.$$"
  if ! { [ -f "$OPTIN" ] && grep -qxF -- "$1" "$OPTIN"; }; then echo "Not in $OPTIN: $1"; return 0; fi
  bp_write_ok "$OPTIN" && bp_write_ok "$tmp" || return 1
  ( umask 077; grep -vxF -- "$1" "$OPTIN" > "$tmp" )
  [ $? -le 1 ] || { rm -f "$tmp"; echo "ERROR: could not read $OPTIN; nothing changed." >&2; return 1; }
  cat "$tmp" > "$OPTIN"; rm -f "$tmp"
  echo "Removed from $OPTIN: $1"
}
if [ -n "$UNREGISTER" ]; then
  optin_unregister "$(cd "$UNREGISTER" 2>/dev/null && pwd -P || printf '%s' "$UNREGISTER")"
  exit $?
fi

# Skill name -> folder in this blueprint (packs are nested: skills/coding/debug).
skill_source() { # name
  local f
  while IFS= read -r -d '' f; do
    if [ "$(basename "$(dirname "$f")")" = "$1" ]; then dirname "$f"; return 0; fi
  done < <(find "$BLUEPRINT/skills" -name SKILL.md -not -path "*/template/*" -print0)
  return 1
}

sync_hooks() { # claude_dir manifest
  local dir="$1" manifest="$2" hook name link
  bp_write_ok "$dir/hooks" || return 0
  for hook in "${HOOK_SCRIPTS[@]}"; do
    name="$(basename "$hook")"
    bp_ignored "$manifest" "hooks/$name" && continue   # listed in .blueprint-ignore
    bp_install_file "$hook" "$dir/hooks/$name" "$manifest" "hooks/$name" || continue
    $BP_DRY_RUN || chmod +x "$dir/hooks/$name"
  done
  # A link left by an older install whose target no longer exists (e.g. scan-skills.sh).
  for link in "$dir/hooks/"*.sh; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
      if $BP_DRY_RUN; then echo "  [dry-run] remove broken link hooks/$(basename "$link")"
      else rm -f "$link"; echo "  removed broken link hooks/$(basename "$link")"; fi
    fi
  done
}

sync_agents() { # claude_dir manifest
  local agent
  bp_write_ok "$1/agents" || return 0
  for agent in "$BLUEPRINT/agents/"*.md; do
    bp_install_file "$agent" "$1/agents/$(basename "$agent")" "$2" "agents/$(basename "$agent")"
  done
}

sync_installed_skills() { # claude_dir manifest — only skills that are already there
  local dir="$1" manifest="$2" installed name src
  bp_write_ok "$dir/skills" || return 0
  for installed in "$dir/skills/"*/; do
    [ -d "$installed" ] || continue
    bp_write_ok "${installed%/}" || continue
    name="$(basename "$installed")"
    src="$(skill_source "$name")" || continue   # not a blueprint skill: leave it alone
    bp_install_dir "$src" "$dir/skills/$name" "$manifest" "skills/$name"
  done
}

# ── Global ~/.claude ─────────────────────────────────────────────────
GLOBAL="$HOME/.claude"
GLOBAL_MANIFEST="$GLOBAL/.blueprint-manifest"
GLOBAL_REAL="$(cd "$GLOBAL" 2>/dev/null && pwd -P)"
if [ -n "$ONLY_PROJECT" ]; then
  :
elif [ -f "$GLOBAL_MANIFEST" ]; then
  echo "=== Global: $GLOBAL ==="
  bp_install_file "$BLUEPRINT/global-claude.md" "$GLOBAL/CLAUDE.md" "$GLOBAL_MANIFEST" "CLAUDE.md"
  sync_hooks "$GLOBAL" "$GLOBAL_MANIFEST"
  sync_agents "$GLOBAL" "$GLOBAL_MANIFEST"
  sync_installed_skills "$GLOBAL" "$GLOBAL_MANIFEST"
  TEMPLATE="$(jq '(.. | objects | select(has("command")) | .command) |= gsub("\"\\$CLAUDE_PROJECT_DIR\"/\\.claude/hooks/"; "\"$HOME\"/.claude/hooks/")' "$BLUEPRINT/hooks/settings.json")"
  bp_merge_settings "$GLOBAL/settings.json" "$(bp_template_without_ignored "$GLOBAL_MANIFEST" "$TEMPLATE" "$BLUEPRINT/hooks")"
else
  echo "=== Global: not installed by bootstrap.sh, skipped ==="
fi
[ -z "$ONLY_PROJECT" ] && echo ""

# ── Projects ─────────────────────────────────────────────────────────
PROJECT_TEMPLATE="$(cat "$BLUEPRINT/hooks/settings.json")"
SYNCED=0
while IFS= read -r -d '' CLAUDE_DIR; do
  [ -f "$CLAUDE_DIR/.blueprint" ] || [ -n "$ONLY_PROJECT" ] || continue
  case "$CLAUDE_DIR" in "$BLUEPRINT"/*|"$BP_ROOT"/*|"$GLOBAL"|"$GLOBAL_REAL") continue ;; esac
  echo "=== Project: ${CLAUDE_DIR%/.claude} ==="
  MANIFEST="$CLAUDE_DIR/.blueprint-manifest"
  BP_SCOPE=project; BP_PROJECT="${CLAUDE_DIR%/.claude}"
  # A project whose .claude folder, marker, manifest or settings.json is a link is left alone.
  if ! { bp_write_ok "$CLAUDE_DIR/.blueprint" && bp_write_ok "$MANIFEST" && bp_write_ok "$CLAUDE_DIR/settings.json"; }; then
    echo "  skipped: nothing in this project was changed."; echo ""; continue
  fi
  if [ ! -f "$CLAUDE_DIR/.blueprint" ]; then   # --project: mark it, so later syncs update it
    if $BP_DRY_RUN; then echo "  [dry-run] mark as a blueprint project (.claude/.blueprint)"
    else mkdir -p "$CLAUDE_DIR" && : > "$CLAUDE_DIR/.blueprint" && echo "  marked as a blueprint project (.claude/.blueprint)"; fi
  fi
  # Only an explicit --project opts a folder in; finding a .claude/.blueprint file never does.
  [ -n "$ONLY_PROJECT" ] && optin_register "$BP_PROJECT"
  # Hooks only where the project has its own copies. A project that relies on the
  # global hooks gets none, so the same check never runs twice.
  if [ -d "$CLAUDE_DIR/hooks" ]; then
    sync_hooks "$CLAUDE_DIR" "$MANIFEST"
    bp_merge_settings "$CLAUDE_DIR/settings.json" "$(bp_template_without_ignored "$MANIFEST" "$PROJECT_TEMPLATE" "$BLUEPRINT/hooks")"
  fi
  [ -d "$CLAUDE_DIR/agents" ] && sync_agents "$CLAUDE_DIR" "$MANIFEST"
  [ -d "$CLAUDE_DIR/skills" ] && sync_installed_skills "$CLAUDE_DIR" "$MANIFEST"
  SYNCED=$((SYNCED + 1))
  echo ""
done < <(
  if [ -n "$ONLY_PROJECT" ]; then printf '%s\0' "$ONLY_PROJECT/.claude"
  else find "$HOME" -maxdepth "$((DEPTH + 1))" -name .claude -type d -not -path "$GLOBAL" -print0 2>/dev/null
  fi)

echo "Synced $SYNCED project(s)."
[ -z "$ONLY_PROJECT" ] && echo "(Searched $DEPTH folder levels below $HOME; use --depth N to search deeper.)"
$BP_DRY_RUN && echo "(Dry run: nothing was changed. Run again without --dry-run to apply.)"
exit 0
