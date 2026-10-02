#!/usr/bin/env bash
# Both-directions matrix for the Edit/Write safety hooks: protect-sensitive-files.sh and
# detect-secrets-in-code.sh.
# Run:  bash edit-write-hooks.matrix.sh [hooks-dir] [extra bash args, e.g. --posix]
# Every case runs twice: with jq as installed, and with a jq whose output lines end in CRLF,
# the way native jq.exe behaves under Git Bash on Windows. Both runs must give the expected
# answer. Only exit 2 counts as "block" (Claude Code lets any other exit code through), so a
# crash or exit 127 is reported as a mismatch, never as a block.
# Without jq on PATH both hooks must fail CLOSED. (The matrix itself needs jq to build JSON.)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${1:-$HERE}"; [ $# -gt 0 ] && shift
EXTRA=("$@")
REALJQ="$(command -v jq)" || { echo "this matrix needs jq on PATH" >&2; exit 1; }
T="$(mktemp -d "${TMPDIR:-/tmp}/bp-editwrite.XXXXXX")"
trap 'rm -r "$T"' EXIT

# A jq that ends every output line in CRLF (awk, not sed: BSD sed has no \r in replacements).
mkdir -p "$T/crlf"
printf '#!/bin/sh\n"%s" "$@" | awk '"'"'{ printf "%%s\\r\\n", $0 }'"'"'\n' "$REALJQ" > "$T/crlf/jq"
chmod +x "$T/crlf/jq"
# A PATH without jq: one tiny wrapper script per command the hooks use (not ln -s: Git Bash
# copies instead of linking, and a copied binary cannot find its DLLs).
mkdir -p "$T/nojq" "$T/empty"
for b in cat grep tr; do
  printf '#!/bin/sh\nexec "%s" "$@"\n' "$(command -v "$b")" > "$T/nojq/$b"; chmod +x "$T/nojq/$b"
done

pass=0; fail=0
rc_word() { case "$1" in 0) echo allow ;; 2) echo block ;; *) echo "rc=$1" ;; esac; }
run_hook() { # hook json PATH -> allow | block | rc=N
  local rc=0
  printf '%s' "$2" | PATH="$3" "$BASH" "${EXTRA[@]}" "$DIR/$1.sh" >/dev/null 2>&1 || rc=$?
  rc_word "$rc"
}
case_() { # case_ <expect> <hook> <json>  -- with jq, and with CRLF jq; both must agree
  local got1 got2
  got1=$(run_hook "$2" "$3" "$PATH")
  got2=$(run_hook "$2" "$3" "$T/crlf:$PATH")
  if [ "$got1" = "$1" ] && [ "$got2" = "$1" ]; then pass=$((pass+1))
  else fail=$((fail+1)); printf '  MISMATCH %s expected=%-5s jq=%-5s crlf-jq=%-5s : %s\n' "$2" "$1" "$got1" "$got2" "$3"; fi
}
path_json()  { "$REALJQ" -nc --arg p "$1" '{tool_name:"Write",tool_input:{file_path:$p,content:"x"}}'; }
write_json() { "$REALJQ" -nc --arg p "$1" --arg c "$2" '{tool_name:"Write",tool_input:{file_path:$p,content:$c}}'; }
edit_json()  { "$REALJQ" -nc --arg p "$1" --arg c "$2" '{tool_name:"Edit",tool_input:{file_path:$p,old_string:"a",new_string:$c}}'; }
P=protect-sensitive-files; D=detect-secrets-in-code
KEY="AKIA""IOSFODNN7EXAMPLQ"         # split so secret scanners do not flag this test file
PW="abcdefghijk""lmnopqrstuv"         # same reason
WIN='C:\Users\alex'                  # the example user's home, Windows spelling

echo "-- $P: protected paths, POSIX and Windows spellings --"
for p in '/home/alex/proj/.env' "$WIN\proj\.env" 'proj\.env.local' 'C:\proj\.env.production' \
         'proj/.git/config' 'proj\.git\config' "$WIN\proj\.git\hooks\pre-commit" \
         "$WIN\.ssh\id_rsa" "$WIN\.aws\credentials" 'C:\proj\node_modules\x\index.js' \
         'C:\proj\.next\cache\x.json' 'C:\proj\package-lock.json' 'proj\yarn.lock' 'C:\certs\server.pem' 'certs\tls.key'; do
  case_ block "$P" "$(path_json "$p")"
done
echo "-- $P: ordinary files and committed templates stay writable --"
for p in 'src/app.ts' "$WIN\proj\src\app.ts" 'proj\.github\workflows\ci.yml' \
         "$WIN\proj\.env.example" 'proj\.env.sample' 'docs\gitignore-notes.md'; do
  case_ allow "$P" "$(path_json "$p")"
done

echo "-- $D: secrets block in code, POSIX and Windows paths, Write and Edit --"
case_ block "$D" "$(write_json 'src/a.js' "const k = \"$KEY\";")"
case_ block "$D" "$(write_json 'C:\proj\src\a.js' "const k = \"$KEY\";")"
case_ block "$D" "$(edit_json 'proj\src\a.js' "const k = \"$KEY\";")"
case_ block "$D" "$(write_json 'C:\proj\config.py' "$(printf 'x = 1\r\npassword = "%s"\r\n' "$PW")")"
echo "-- $D: docs, templates and fixtures are skipped; clean code passes --"
case_ allow "$D" "$(write_json 'C:\proj\docs\notes.md' "key: $KEY")"
case_ allow "$D" "$(write_json 'C:\proj\.env.example' "AWS_KEY=$KEY")"
case_ allow "$D" "$(write_json 'proj\test\fixtures\aws.json' "{\"k\":\"$KEY\"}")"
case_ allow "$D" "$(write_json 'C:\proj\src\a.js' 'const x = 1;')"

echo "-- no jq on PATH: both hooks fail CLOSED (exit 2) with a one-line reason --"
for h in "$P" "$D"; do
  for path in "$T/nojq" "$T/empty"; do
    got=$(run_hook "$h" "$(write_json 'src/app.ts' 'const x = 1;')" "$path")
    if [ "$got" = block ]; then pass=$((pass+1))
    else fail=$((fail+1)); echo "  MISMATCH $h without jq (PATH=$path): expected=block got=$got"; fi
  done
  msg=$(printf '%s' '{}' | PATH="$T/nojq" "$BASH" "${EXTRA[@]}" "$DIR/$h.sh" 2>&1 >/dev/null)
  case "$msg" in
    *"safety hooks need jq"*) pass=$((pass+1)) ;;
    *) fail=$((fail+1)); echo "  MISMATCH $h without jq: message was: $msg" ;;
  esac
done

echo "-- pass=$pass fail=$fail --"
[ "$fail" -eq 0 ]
