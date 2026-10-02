#!/usr/bin/env bash
# Tests the "run once, not twice" guard, and that the security hooks do NOT have it.
# Run:  bash defer-to-project.matrix.sh
#
# Security hooks (block-dangerous-commands, protect-sensitive-files, detect-secrets-in-code):
#   the global copy ALWAYS runs. A project that registers its own copy, or ships a dummy one
#   that just exits 0, must never switch the global check off.
# Every other hook: the global copy steps aside when the project registers its own copy, so the
#   same check never runs twice. session-start.sh stands in for them because its result is easy
#   to read: output = the hook ran, no output = it stepped aside.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECURITY="block-dangerous-commands protect-sensitive-files detect-secrets-in-code"
DEFERRING="quality-check format-and-lint audit-dependencies owasp-check session-start"
HOOK=session-start.sh
T="$(mktemp -d "${TMPDIR:-/tmp}/bp-defer.XXXXXX")"
trap 'rm -r "$T"' EXIT
H="$T/home dir"; PROJ="$T/project"; BARE="$T/bare-project"
mkdir -p "$H/.claude/hooks" "$PROJ/.claude/hooks" "$BARE/.claude"
cp "$HERE/"*.sh "$H/.claude/hooks/"; cp "$HERE/$HOOK" "$PROJ/.claude/hooks/"
printf '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash \\"$CLAUDE_PROJECT_DIR\\"/.claude/hooks/%s"}]}]}}\n' "$HOOK" > "$PROJ/.claude/settings.json"
echo '{"hooks":{}}' > "$BARE/.claude/settings.json"
# A PATH without jq: one tiny wrapper script per command, which runs the real binary. Not ln -s:
# Git Bash copies instead of linking, and a copied bash.exe cannot find msys-2.0.dll.
NOJQ="$T/nojq"; mkdir -p "$NOJQ"
for b in bash basename grep cat tr dirname; do
  printf '#!/bin/sh\nexec "%s" "$@"\n' "$(command -v "$b")" > "$NOJQ/$b"; chmod +x "$NOJQ/$b"
done

pass=0; fail=0
check() { # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "  MISMATCH $1: expected $2 got $3"; fi
}
run() { # home project_dir(or -) hook_path [PATH] -> "ran" or "skipped"
  local p="${4:-$PATH}" out
  if [ "$2" = - ]; then out="$(cd "$T" && printf '{}' | env -u CLAUDE_PROJECT_DIR HOME="$1" PATH="$p" bash "$3" 2>/dev/null)"
  else out="$(cd "$T" && printf '{}' | HOME="$1" CLAUDE_PROJECT_DIR="$2" PATH="$p" bash "$3" 2>/dev/null)"; fi
  [ -n "$out" ] && echo ran || echo skipped
}

# ── Which hooks carry the guard ──
for h in $DEFERRING; do
  grep -qF '# ── Run once, not twice.' "$HERE/$h.sh" && r=guard || r=none
  check "$h.sh carries the run-once guard" guard "$r"
done
for h in $SECURITY; do
  grep -q 'bp_self' "$HERE/$h.sh" && r=guard || r=none
  check "$h.sh has no run-once guard" none "$r"
done

# ── Security hooks: the global copy runs whatever the project registers ──
KEY="AKIA""IOSFODNN7EXAMPLQ"   # split so secret scanners do not flag this test file
SEC="$T/sec-project"; mkdir -p "$SEC/.claude/hooks"
sec_rc() { # hook input [PATH]
  printf '%s' "$2" | HOME="$H" CLAUDE_PROJECT_DIR="$SEC" PATH="${3:-$PATH}" bash "$H/.claude/hooks/$1.sh" >/dev/null 2>&1; echo $?
}
sec_input() { # hook -> an input that hook must block
  case "$1" in
    block-dangerous-commands) printf '{"tool_input":{"command":"rm -rf ."}}' ;;
    protect-sensitive-files)  printf '{"tool_input":{"file_path":"%s/.env"}}' "$SEC" ;;
    detect-secrets-in-code)   printf '{"tool_input":{"file_path":"%s/a.js","content":"const k = \\"%s\\";"}}' "$SEC" "$KEY" ;;
  esac
}
for h in $SECURITY; do
  in="$(sec_input "$h")"
  cp "$HERE/$h.sh" "$SEC/.claude/hooks/"
  printf '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"bash \\"$CLAUDE_PROJECT_DIR\\"/.claude/hooks/%s.sh"}]}]}}\n' "$h" > "$SEC/.claude/settings.json"
  check "global $h runs when the project registers its own copy" 2 "$(sec_rc "$h" "$in")"
  echo 'exit 0' > "$SEC/.claude/hooks/$h.sh"
  check "global $h runs when the project copy is a dummy (exit 0)" 2 "$(sec_rc "$h" "$in")"
  printf '{"env":{"NOTE":"see .claude/hooks/%s.sh"}}\n' "$h" > "$SEC/.claude/settings.json"
  check "global $h runs when settings.json only mentions the path" 2 "$(sec_rc "$h" "$in")"
done
echo 'exit 0' > "$SEC/.claude/hooks/block-dangerous-commands.sh"
printf '{"hooks":{"PreToolUse":[{"hooks":[{"type":"command","command":"bash .claude/hooks/block-dangerous-commands.sh"}]}]}}\n' > "$SEC/.claude/settings.json"
check "global block-dangerous-commands runs with a dummy project copy, also without jq" 2 \
  "$(sec_rc block-dangerous-commands "$(sec_input block-dangerous-commands)" "$NOJQ")"

# ── Deferring hooks (session-start as the example): the global copy steps aside ──
G="$H/.claude/hooks/$HOOK"
check "global copy steps aside when the project registers its own copy" skipped "$(run "$H" "$PROJ" "$G")"
check "global copy steps aside, also without jq"                       skipped "$(run "$H" "$PROJ" "$G" "$NOJQ")"
check "global copy runs when the project does not register the hook"   ran "$(run "$H" "$BARE" "$G")"
check "global copy runs when CLAUDE_PROJECT_DIR is unset"              ran "$(run "$H" - "$G")"
check "global copy runs when the project is the home folder"           ran "$(run "$H" "$H" "$G")"
rm "$PROJ/.claude/hooks/$HOOK"
check "global copy runs when the project's hook file is missing"       ran "$(run "$H" "$PROJ" "$G")"
cp "$HERE/$HOOK" "$PROJ/.claude/hooks/"
check "project copy always runs"                                       ran "$(run "$H" "$PROJ" "$PROJ/.claude/hooks/$HOOK")"
check "project copy runs with CLAUDE_PROJECT_DIR unset"                ran "$(run "$H" - "$PROJ/.claude/hooks/$HOOK")"

# Older projects register hooks in the relative form; that is a project copy too.
printf '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash .claude/hooks/%s"}]}]}}\n' "$HOOK" > "$PROJ/.claude/settings.json"
check "global copy steps aside for the relative form"                   skipped "$(run "$H" "$PROJ" "$G")"
# A project entry that points at the GLOBAL hooks is not a project copy.
for form in '~/.claude/hooks' '$HOME/.claude/hooks' '/home/someone/.claude/hooks' '/Users/someone/.claude/hooks'; do
  printf '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash %s/%s"}]}]}}\n' "$form" "$HOOK" > "$PROJ/.claude/settings.json"
  check "global copy runs when the project points at $form"          ran "$(run "$H" "$PROJ" "$G")"
done
# A project copy that is a dead symlink (e.g. into another machine's folder) does not count.
printf '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash .claude/hooks/%s"}]}]}}\n' "$HOOK" > "$PROJ/.claude/settings.json"
rm "$PROJ/.claude/hooks/$HOOK"; ln -s "/Users/nobody/gone/$HOOK" "$PROJ/.claude/hooks/$HOOK"
check "global copy runs when the project's copy is a dead link"        ran "$(run "$H" "$PROJ" "$G")"

echo "-- pass=$pass fail=$fail --"
[ "$fail" -eq 0 ]
