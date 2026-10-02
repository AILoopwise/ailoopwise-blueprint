#!/usr/bin/env bash
export LC_ALL=C   # byte semantics: fast substring/regex on any input, same answer in every locale
# Fail CLOSED on any exit not chosen below (e.g. fork failure -> bash exits 254): only an
# exit preceded by BDC_OK=1 may allow. SIGPIPE is ignored so a closed stderr cannot kill
# the hook mid-message (ignored signals stay ignored in the checker subshell too).
trap '' PIPE
trap '[ "${BDC_OK:-}" = 1 ] || exit 2' EXIT

# No "run once" guard in a security hook: the global copy always runs, even when the project
# registers its own copy, so a project file can never switch this check off.

# PreToolUse guard for Bash: blocks commands that destroy data or history. Exit 2 = block.
#
# How it reads a command:
#   · the command is split into words the way the shell would (quotes and backslashes
#     removed, "my dir" stays one word) and into segments at ; && || | & ( ) and newline.
#     Every rule runs on EVERY segment, keyed on that segment's command word, so
#     `cat x; git reset --hard` is caught and text inside a quoted commit message is data.
#     $( … ) and `…` — also inside double quotes — are checked as commands of their own;
#   · the command word skips VAR=x, shell keywords (if then do while { ! …), wrappers
#     (sudo env command nice time nohup exec xargs timeout stdbuf ionice watch, with their
#     option-arguments) and a path prefix (/bin/rm is rm); `bash -c "…"`, `sh -c '…'`,
#     `env -S "…"` and `eval "…"` have their inner string checked as a command, and so do
#     heredocs fed to a shell (at most 64 inner strings; more fails CLOSED);
#   · secrets: blocked when a .env file is READ (cat/grep/head … .env*, printenv, bare env),
#     not when a variable name is printed and not when a file is written with > / >>;
#   · database/volume resets (prisma migrate reset, supabase db reset, compose down -v,
#     docker volume rm/prune, rails db:drop/reset, manage.py flush, dropdb) and destructive
#     SQL (DROP TABLE/DATABASE, TRUNCATE TABLE …) are blocked;
#   · rm: any recursive flag (-r -R --recursive, any order) makes the target rules apply.
#     A target is resolved lexically (. .. // and a trailing * or .* collapsed) and blocked
#     when it is a root or top-level dir, a home ( ~ ~user $HOME /home/u /Users/u /root
#     /c/Users/u C:/Users/u /mnt/c/Users/u ) or a home container, the project ( . * ), a
#     parent ( .. ../.. ), or a .git dir. Below a home or ../ it is allowed only when it
#     contains a disposable segment (DISPOSABLE_RE: node_modules, dist, .venv, …);
#   · find: -delete / -exec rm need a real -name/-path filter (not '*', no -o); over a
#     home/root the filter must name a disposable dir;
#   · pure bash, LC_ALL=C, linear in the command size (60 KB ≈ 0.8 s). Bash 3.2
#     compatible, same answers under --posix. jq is used when present; without it a small
#     JSON reader takes over and FAILS CLOSED if it cannot be sure (no "command" key at
#     all = nothing to run = allow, as with jq).
#   · FAIL CLOSED, generically: the checker runs in a subshell and ANY exit other than
#     0/2 (crash, segfault, bash error) blocks. Also blocked: more than MAX_CMD_BYTES, a
#     physical line over MAX_LINE, nesting deeper than MAXDEPTH, more than TBUDGET seconds
#     of checking, a heredoc delimiter with embedded quotes or > 256 chars, a heredoc
#     pending inside a multi-line quote, an escaped command word ($'\162m'), and a shell
#     that reads commands from a pipe. When parsing is unsure, the answer is "blocked".
#   · no `set -e`: a crash would exit 1, which Claude Code treats as "allow".
#
# Known limits (accepted, not chased): computed targets (rm -rf $(echo ~), xargs rm -rf
# fed from stdin, eval of a variable, brace expansion {/,}, aliases, functions defined
# earlier in the session), context (`cd .. && rm -rf app`), git aliases defined with -c,
# quoted heredoc bodies of non-shell commands are not read (unquoted ones: only their
# $( ) / ` `), `git checkout <name>` cannot tell a file without extension from a branch,
# arithmetic $(( )) is told from a substitution by a heuristic, slower machines (Git Bash
# on Windows) reach TBUDGET on smaller inputs and then block, and other destructive tools
# (dd, shred, truncate, mv, chmod -R) are out of scope.
#
# Tests live beside this file and are the thing to extend first:
#     bash block-dangerous-commands.matrix.sh <path-to-this-hook>
# Add the new case, show it failing, then change this file until it passes.
#
# NOTE: installs copy this file into ~/.claude/hooks/ or <project>/.claude/hooks/.
# If you patch it here, run blueprint-sync.sh so the installed copies get the fix.

deny() { echo "BLOCKED: $1" >&2 2>/dev/null; exit 2; }   # a failed write must not change the answer

BS='\'; DQ='"'; SQ="'"; NL=$'\n'; SEP=$'\x1f'

# ── JSON fallback: extract .tool_input.command without jq. Returns 1 when unsure.
json_command() {
  # Linear: walks 512-byte windows of the input; all slicing happens inside the window.
  local s=$1 re='"command"[[:space:]]*:[[:space:]]*"' pre p W k t e out='' done=0
  [[ $s =~ $re ]] || return 1
  pre=${s%%"${BASH_REMATCH[0]}"*}
  p=$(( ${#pre} + ${#BASH_REMATCH[0]} ))
  while [ $done = 0 ]; do
    [ $SECONDS -lt $TBUDGET ] || deny "command too complex for the safety check (over ${TBUDGET}s) -- split it or write a script file."
    W=${s:p:512}; k=0
    [ -z "$W" ] && return 1                            # unterminated string
    while [ $k -lt ${#W} ]; do
      t=${W:k}; t=${t%%[\"\\]*}
      out+=$t; k=$((k+${#t}))
      [ $k -ge ${#W} ] && break                        # window used up: refill
      [ "${W:k:1}" = "$DQ" ] && { k=$((k+1)); done=1; break; }   # end of the value
      e=${W:k+1:1}
      [ -z "$e" ] && break                             # escape split by the window: refill
      case $e in
        n) out+=$NL ;; t) out+=$'\t' ;; r) out+=$'\r' ;; b|f) ;;
        "$DQ"|"$BS"|/) out+=$e ;;
        *) return 1 ;;                                 # \uXXXX or an unknown escape: unsure
      esac
      k=$((k+2))
    done
    [ $k = 0 ] && return 1                             # lone trailing backslash at the end
    p=$((p+k))
  done
  [[ ${s:p} =~ $re ]] && return 1                     # a second "command" key: ambiguous
  JSON_CMD=$out
}

# ── Everything below runs inside main(), which runs in a subshell: a crash (segfault on
# absurd nesting, a bash bug, an unexpected exit code) must BLOCK, never allow. The parent
# only maps the child's exit code: 0 = allow, 2 = block, anything else = block.
main() {
TBUDGET=3        # seconds; past it the command is "too complex" and blocks (SECONDS is integer)
MAX_LINE=16384   # one physical line longer than this blocks
MAXDEPTH=64      # nested $( ) / ` ` / subshell scans

# $(< /dev/stdin) reads in blocks; `read -d ''` reads a pipe one byte per syscall (~100 ms
# on a large command). Fall back to read where /dev/stdin cannot be opened.
input=$(< /dev/stdin) 2>/dev/null || IFS= read -r -d '' input
MAX_INPUT_BYTES=131072
[ ${#input} -gt $MAX_INPUT_BYTES ] && deny "hook input too large for the safety check (${#input} bytes > $MAX_INPUT_BYTES) -- split the command or write a script file."
cmd=''
if command -v jq >/dev/null 2>&1 && cmd=$(printf '%s' "$input" | jq -r '.tool_input.command | if type == "string" then . elif . == null then empty else error("not a string") end' 2>/dev/null); then
  :
elif case $input in *'"command"'*) false ;; *) true ;; esac; then
  cmd=''                                              # no command key at all: nothing to run
elif json_command "$input"; then
  cmd=$JSON_CMD
else
  deny "cannot read the command safely without jq -- install jq (see README). Failing closed."
fi
[ -z "$cmd" ] && exit 0


# ── Size cap. The scanner is linear, but a hook that runs past Claude Code's timeout may be
# treated as "allow", so anything this large fails CLOSED with a clear way out.
MAX_CMD_BYTES=100000
if [ ${#cmd} -gt $MAX_CMD_BYTES ]; then
  deny "command too long for the safety check (${#cmd} bytes > $MAX_CMD_BYTES) -- split it or write a script file and run that."
fi

# ── Tokenizer. Reads the command line by line (LN, LI) at a position (P) in the current line
# (L), never copying the rest of the input, so time stays linear in its size.
# Words go to TOK; $SEP marks a segment boundary (; & | ( ) newline). A $( … ) or `…`
# is scanned as its own command — its tokens go to SUBTOK and are checked as separate
# segments — and the word it sits in continues, so `git commit -m "$(cat <<'EOF' … EOF
# )" && git push --force` keeps the push visible. Heredoc bodies are skipped at the end
# of their line, except when that line runs a shell: then the body is queued (Q).
# Glob "stop sets": ${W%%$STOP} is the run of ordinary characters at the start of W. Globs,
# not [[ =~ ]], on the hot path: bash recompiles a regex on every =~.
PLAIN_STOP=$'[ \t\r;&|()`$"\'\\\\<]*'
DQ_STOP=$'["\\\\$`]*'
RE_ANSIRUN="^([^'\\\\]|\\\\.)+"
RE_ARITH_CMD='(;|&&|[|][|]|(^|[ (])[A-Za-z_][A-Za-z0-9_.-]* +[A-Za-z_./~-])'
HD_STOP=$'[ \t\r;&|<>()]*'
Q=()

next_line() { # move to the next line, consuming pending heredoc bodies first. 1 = no more input
  local k line tl body sh j
  LI=$((LI+1))
  k=0
  while [ $k -lt ${#HD[@]} ]; do
    sh=0; j=${HDAT[$k]}
    while [ $j -lt ${#TOK[@]} ]; do                 # a shell or eval anywhere on that line
      case ${TOK[$j]##*/} in bash|sh|zsh|dash|ksh|eval) sh=1 ;; esac
      j=$((j+1))
    done
    body=''
    while [ $LI -lt ${#LN[@]} ]; do
      line=${LN[$LI]}; LI=$((LI+1))
      tl=$line; while [ "${tl:0:1}" = $'\t' ]; do tl=${tl:1}; done
      [ "${tl%$'\r'}" = "${HD[$k]}" ] && break
      [ $sh = 1 ] && body+=$line$NL
      if [ $sh = 0 ] && [ "${HDQ[$k]}" = 0 ]; then     # unquoted body: $( ) and ` ` still run
        case $line in *'$('*) Q+=("\$(${line#*\$(}") ;; esac
        case $line in *'`'*) Q+=("\`${line#*\`}") ;; esac
      fi
    done
    [ $sh = 1 ] && Q+=("$body")
    k=$((k+1))
  done
  HD=(); HDAT=(); HDQ=()
  if [ $LI -ge ${#LN[@]} ]; then L=''; P=0; return 1; fi
  L=${LN[$LI]}; P=0; LTS=${#TOK[@]}
  return 0
}

next_line_q() { # next_line from INSIDE an open quote / continuation: a pending heredoc is ambiguous
  [ ${#HD[@]} -gt 0 ] && deny "heredoc combined with a multi-line quote is ambiguous for the safety check -- split the command."
  next_line
}

subst() { # $1 = sub|bt; P is just past the opener. Scans the inner command, moves its
          # tokens to SUBTOK, and leaves a placeholder for the word in SUBST_TEXT.
  local mark=${#TOK[@]} k txt=''
  DEPTH=$((DEPTH+1))
  [ $DEPTH -gt $MAXDEPTH ] && deny "nesting deeper than $MAXDEPTH levels is too complex for the safety check -- split the command."
  TOK+=("$SEP")
  scan "$1" "$mark"
  DEPTH=$((DEPTH-1))
  k=$mark
  while [ $k -lt ${#TOK[@]} ]; do
    SUBTOK+=("${TOK[$k]}")
    [ "${TOK[$k]}" != "$SEP" ] && txt+="${txt:+ }${TOK[$k]}"
    k=$((k+1))
  done
  SUBTOK+=("$SEP")
  k=${#TOK[@]}
  while [ $k -gt $mark ]; do k=$((k-1)); unset "TOK[$k]"; done
  SUBST_TEXT="\$($txt)"
}

scan() { # $1 = top | sub (ends at its ")") | bt (ends at its "`"); $2 = first TOK index of the frame
  local kind=$1 fs=${2:-0} w='' have=0 depth=0 c W m t k ncase
  while :; do
    [ $SECONDS -lt $TBUDGET ] || deny "command too complex for the safety check (over ${TBUDGET}s) -- split it or write a script file."
    if [ $P -ge ${#L} ]; then                                   # end of line
      [ $have = 1 ] && TOK+=("$w"); w=''; have=0; TOK+=("$SEP")
      next_line || return 0
      continue
    fi
    c=${L:P:1}
    case $c in
      ' '|$'\t'|$'\r') [ $have = 1 ] && TOK+=("$w"); w=''; have=0; P=$((P+1)) ;;
      ';'|'&'|'|') [ $have = 1 ] && TOK+=("$w"); w=''; have=0; TOK+=("$SEP"); P=$((P+1)) ;;
      '(') [ $have = 1 ] && TOK+=("$w"); w=''; have=0; TOK+=("$SEP"); depth=$((depth+1)); P=$((P+1)) ;;
      ')') [ $have = 1 ] && TOK+=("$w"); w=''; have=0; TOK+=("$SEP"); P=$((P+1))
           if [ $depth -gt 0 ]; then depth=$((depth-1))
           elif [ "$kind" = sub ]; then
             # inside $( ), a `case` arm's "pat)" must not close the substitution
             ncase=0; k=$fs
             while [ $k -lt ${#TOK[@]} ]; do
               if [ "${TOK[$k]}" = "$SEP" ]; then
                 case ${TOK[$((k+1))]} in 'case') ncase=$((ncase+1)) ;; esac
               else
                 case ${TOK[$k]} in 'esac') ncase=$((ncase-1)) ;; esac
               fi
               k=$((k+1))
             done
             [ $ncase -le 0 ] && return 0
           fi ;;
      '`') P=$((P+1))
           if [ "$kind" = bt ]; then [ $have = 1 ] && TOK+=("$w"); TOK+=("$SEP"); return 0; fi
           subst bt; w+=$SUBST_TEXT; have=1 ;;
      "$SQ") P=$((P+1)); have=1
           while :; do
             if [ $P -ge ${#L} ]; then w+=$NL; next_line_q || break; continue; fi
             W=${L:P:512}
             case $W in
               *"$SQ"*) t=${W%%"$SQ"*}; w+=$t; P=$((P+${#t}+1)); break ;;
               *) w+=$W; P=$((P+${#W})) ;;
             esac
           done ;;
      "$DQ") P=$((P+1)); have=1
           while :; do
             if [ $P -ge ${#L} ]; then w+=$NL; next_line_q || break; continue; fi
             W=${L:P:512}; m=${W%%$DQ_STOP}
             if [ -n "$m" ]; then w+=$m; P=$((P+${#m})); continue; fi
             case ${L:P:1} in
               "$DQ") P=$((P+1)); break ;;
               "$BS") t=${L:P+1:1}
                      if [ -z "$t" ]; then P=$((P+1)); next_line_q || break   # continuation
                      else
                        case $t in "$DQ"|"$BS"|'$'|'`') w+=$t ;; *) w+=$BS$t ;; esac
                        P=$((P+2))
                      fi ;;
               '`') P=$((P+1)); subst bt; w+=$SUBST_TEXT ;;
               '$') if [ "${L:P+1:1}" = '(' ] && [ "${L:P+2:1}" != '(' ]; then
                      P=$((P+2)); subst sub; w+=$SUBST_TEXT
                    else w+='$'; P=$((P+1)); fi ;;
             esac
           done ;;
      "$BS")
           if [ $((P+1)) -ge ${#L} ]; then next_line_q; continue; fi   # line continuation (or end: flushed above)
           t=${L:P+1:1}; P=$((P+2)); have=1
           case $w in [A-Za-z]:*) w+=/$t ;; *) w+=$t ;; esac ;;          # C:\Users\x is a path
      '$')
           case ${L:P+1:1} in
             '(')
               if [ "${L:P+2:1}" = '(' ]; then                         # $(( arithmetic ))
                 W=${L:P:4096}
                 case $W in *'))'*)
                   t=${W%%'))'*}
                   # `$((cd a && rm …) )` is a substitution holding a subshell: scan it as one
                   if ! [[ ${t:3} =~ $RE_ARITH_CMD ]]; then
                     case ${t:3} in *'$('*|*'`'*) Q+=("${t:3}") ;; esac   # $(( $(cmd) + 1 ))
                     w+=$t'))'; P=$((P+${#t}+2)); have=1; continue
                   fi ;;
                 esac
               fi
               P=$((P+2)); subst sub; w+=$SUBST_TEXT; have=1 ;;
             "$SQ") P=$((P+2)); have=1                                  # $'ANSI-C', \' does not end it
               while :; do
                 W=${L:P:512}
                 if [[ $W =~ $RE_ANSIRUN ]]; then m=${BASH_REMATCH[0]}; w+=$m; P=$((P+${#m})); continue; fi
                 if [ $P -ge ${#L} ]; then w+=$NL; next_line_q || break; continue; fi
                 c=${L:P:1}; P=$((P+1))
                 [ "$c" = "$SQ" ] && break
                 [ $P -ge ${#L} ] && { next_line_q || break; }             # lone trailing backslash
               done ;;
             *) w+='$'; have=1; P=$((P+1)) ;;
           esac ;;
      '<')
           if [ "${L:P:3}" = '<<<' ]; then [ $have = 1 ] && TOK+=("$w"); w=''; have=0; TOK+=('<<<'); P=$((P+3))
           elif [ "${L:P:2}" = '<<' ]; then
             [ $have = 1 ] && TOK+=("$w"); w=''; have=0; P=$((P+2))
             [ "${L:P:1}" = '-' ] && P=$((P+1))
             while [ "${L:P:1}" = ' ' ]; do P=$((P+1)); done
             W=${L:P:300}; t=${W%%$HD_STOP}; m=0
             [ ${#t} -gt 256 ] && deny "heredoc delimiter longer than 256 characters -- not checked, blocked."
             P=$((P+${#t}))
             case $t in
               "$SQ"*"$SQ"|"$DQ"*"$DQ") t=${t:1:${#t}-2}; m=1 ;;
               "$BS"*) t=${t:1}; m=1 ;;
             esac
             case $t in ''|*"$SQ"*|*"$DQ"*|*"$BS"*)
               deny "heredoc delimiter with embedded quotes/backslashes is ambiguous for the safety check -- use <<'EOF'." ;;
             esac
             HD+=("$t"); HDQ+=("$m"); HDAT+=("$LTS"); TOK+=('<<')
           else w+='<'; have=1; P=$((P+1)); fi ;;
      '#') if [ $have = 0 ]; then P=${#L}; else w+='#'; P=$((P+1)); fi ;;
      *)
           W=${L:P:256}
           m=${W%%$PLAIN_STOP}
           if [ -n "$m" ]; then w+=$m; P=$((P+${#m})); else w+=$c; P=$((P+1)); fi
           have=1 ;;
    esac
  done
}

tokenize() { # $1 = command string -> TOK, SUBTOK
  TOK=(); SUBTOK=(); HD=(); HDAT=(); HDQ=()
  set -f; IFS=$NL; LN=($1); IFS=$' \t\n'; set +f
  for L in "${LN[@]}"; do
    [ ${#L} -gt $MAX_LINE ] && deny "a single line of ${#L} bytes is too long for the safety check (> $MAX_LINE) -- split it or write a script file."
  done
  LI=0; L=${LN[0]}; P=0; LTS=0; DEPTH=0
  [ ${#LN[@]} -gt 0 ] && scan top
}

# ── rm targets.
DISPOSABLE_RE='/(node_modules|dist|build|out|tmp|coverage|target|\.next|\.nuxt|\.output|\.turbo|\.cache|Caches|\.npm|_cacache|\.pnpm-store|\.yarn/cache|\.venv|venv|__pycache__|\.pytest_cache|\.mypy_cache|\.ruff_cache|\.svelte-kit|\.parcel-cache|\.expo|\.angular|\.vercel|\.terraform|\.gradle|\.m2/repository|vendor|\.vscode/extensions|Pods|DerivedData)/'
HOME_RE='^/(root|(home|Users|[A-Za-z]/Users|mnt/[A-Za-z]/Users)/[^/]+)(/|$)'
HOMEBASE_RE='^/(home|Users|[A-Za-z]/Users|mnt/[A-Za-z]/Users|mnt|mnt/[A-Za-z]|[A-Za-z])$'

# Returns 0 when deleting $1 recursively is dangerous; TGT_KIND = home|root|project|outside|git.
rm_target_dangerous() {
  local t=$1 anchor rest norm='' p IFS
  local -a parts
  TGT_KIND=''
  case $t in
    '$PWD'|'${PWD}'|'$(pwd)'|'`pwd`') t=. ;;
    '$PWD/'*|'${PWD}/'*|'$(pwd)/'*) t=./${t#*/} ;;
  esac
  if [[ $t =~ ^[A-Za-z]: ]]; then t=${t//"$BS"//}; t=/${t:0:1}${t:2}; fi
  case $t in
    '~'|'~/'*) anchor=H; rest=${t:1} ;;
    '~'*) anchor=H; case $t in */*) rest=/${t#*/} ;; *) rest='' ;; esac ;;
    '$HOME'|'$HOME/'*) anchor=H; rest=${t:5} ;;
    '${HOME}'*|'${HOME:'*) anchor=H; rest=${t#*\}} ;;
    /*) anchor=/; rest=$t ;;
    *) anchor=.; rest=/$t ;;
  esac
  IFS=/; set -f; parts=($rest); set +f; IFS=' '
  for p in "${parts[@]}"; do
    case $p in
      ''|.) ;;
      ..) case $norm in
            ''|*/..) if [ $anchor = . ]; then norm+=/..
                     elif [ $anchor = H ]; then TGT_KIND=home; return 0; fi ;;
            *) norm=${norm%/*} ;;
          esac ;;
      *) norm+=/$p ;;
    esac
  done
  case $norm in */\*|*/.\*) norm=${norm%/*} ;; esac
  case $norm in */.git) TGT_KIND=git; return 0 ;; esac
  case $anchor in
    H) TGT_KIND=home
       [ -z "$norm" ] && return 0
       [[ $norm/ =~ $DISPOSABLE_RE ]] && return 1
       return 0 ;;
    /) TGT_KIND=root
       [ -z "$norm" ] && return 0
       [[ $norm =~ $HOMEBASE_RE ]] && return 0
       if [[ $norm =~ $HOME_RE ]]; then
         TGT_KIND=home
         [[ $norm/ =~ $DISPOSABLE_RE ]] && return 1
         return 0
       fi
       case $norm in /tmp|/*/*) return 1 ;; esac
       return 0 ;;
  esac
  case $norm in
    '') TGT_KIND=project; return 0 ;;
    /..*) TGT_KIND=outside
          [[ $norm =~ ^(/\.\.)+$ ]] && return 0
          [[ $norm/ =~ $DISPOSABLE_RE ]] && return 1
          return 0 ;;
  esac
  return 1
}

check_rm() {
  local j=$A0 a rec=0 opts=1 bad=''
  while [ $j -lt $n ]; do
    a=${SEG[$j]}; j=$((j+1))
    if [ $opts = 1 ]; then
      case $a in
        --) opts=0; continue ;;
        --recursive) rec=1; continue ;;
        --*) continue ;;
        -?*) case $a in *[rR]*) rec=1 ;; esac; continue ;;
      esac
    fi
    if [ -z "$bad" ] && rm_target_dangerous "$a"; then bad=$a; fi
  done
  if [ $rec = 1 ] && [ -n "$bad" ]; then
    deny "recursive delete of a root/home/project/parent/.git path ($bad). Name a subfolder instead."
  fi
  return 0
}

check_git() {
  local j=$A0 a sub st=0 wt=0 dry=0 force=0 skip=0
  while [ $j -lt $n ]; do
    case ${SEG[$j]} in
      -C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--config-env) j=$((j+2)) ;;
      -*) j=$((j+1)) ;;
      *) break ;;
    esac
  done
  [ $j -ge $n ] && return 0
  sub=${SEG[$j]}; j=$((j+1))
  case $sub in
    reset)
      while [ $j -lt $n ]; do
        [ "${SEG[$j]}" = --hard ] && deny "git reset --hard discards uncommitted work. Use git stash."
        j=$((j+1))
      done ;;
    push)
      while [ $j -lt $n ]; do
        a=${SEG[$j]}; j=$((j+1))
        case $a in
          --force|--mirror|--delete) deny "force push / remote ref deletion ($a). Use --force-with-lease." ;;
          --*) ;;
          -*f*|-*d*) deny "force push / remote ref deletion ($a). Use --force-with-lease." ;;
          +*|:*) deny "force push / remote ref deletion via refspec ($a). Use --force-with-lease." ;;
        esac
      done ;;
    clean)
      while [ $j -lt $n ]; do
        a=${SEG[$j]}; j=$((j+1))
        case $a in
          --dry-run) dry=1 ;;
          --force) force=1 ;;
          --*) ;;
          -*) case $a in *n*) dry=1 ;; esac; case $a in *f*) force=1 ;; esac ;;
        esac
      done
      if [ $force = 1 ] && [ $dry = 0 ]; then
        deny "git clean -f deletes untracked files for good. Run git clean -n first."
      fi ;;
    checkout)
      while [ $j -lt $n ]; do
        a=${SEG[$j]}; j=$((j+1))
        if [ $skip = 1 ]; then skip=0; continue; fi
        case $a in
          -b|-B|--orphan) skip=1 ;;
          -f|--force) deny "git checkout -f discards uncommitted changes. Use git stash." ;;
          --) [ $j -lt $n ] && deny "git checkout of a PATH discards uncommitted changes -- it restores HEAD, not your last state. Copy the file aside and copy it back, or use git stash." ;;
          -*) ;;
          .|./*|*/) deny "git checkout of a directory discards every uncommitted change in it. Use git stash." ;;
          *.ts|*.tsx|*.mts|*.cts|*.js|*.jsx|*.mjs|*.cjs|*.json|*.md|*.sh|*.bash|*.py|*.rb|*.go|*.rs|*.sql|*.yml|*.yaml|*.css|*.scss|*.html|*.toml|*.lock)
            deny "git checkout of a FILE discards its uncommitted changes -- it restores HEAD, not your last state. Copy the file aside and copy it back, or use git stash." ;;
        esac
      done ;;
    switch)
      while [ $j -lt $n ]; do
        case ${SEG[$j]} in --discard-changes|-f|--force) deny "git switch ${SEG[$j]} discards uncommitted changes. Use git stash." ;; esac
        j=$((j+1))
      done ;;
    restore)
      # --staged (-S) without --worktree (-W) only unstages; the working tree is untouched.
      while [ $j -lt $n ]; do
        a=${SEG[$j]}; j=$((j+1))
        case $a in
          --staged) st=1 ;;
          --worktree) wt=1 ;;
          --*) ;;
          -*) case $a in *S*) st=1 ;; esac; case $a in *W*) wt=1 ;; esac ;;
        esac
      done
      if [ $st = 0 ] || [ $wt = 1 ]; then
        deny "git restore discards uncommitted changes. Copy the file aside and copy it back, or use git stash."
      fi ;;
    reflog)
      # git branch -D and git stash drop stay allowed BECAUSE the reflog can bring them back;
      # destroying the reflog is what has to be blocked.
      case ${SEG[$j]} in expire|delete) deny "git reflog ${SEG[$j]} destroys the recovery path for lost commits." ;; esac ;;
    gc)
      while [ $j -lt $n ]; do
        case ${SEG[$j]} in --prune=now|--prune=all) deny "git gc ${SEG[$j]} deletes unreachable commits immediately." ;; esac
        j=$((j+1))
      done ;;
    stash)
      # `git stash drop` removes ONE entry and is recoverable by hash for a while: allowed.
      [ "${SEG[$j]}" = clear ] && deny "git stash clear deletes every stash. Drop entries one by one." ;;
    worktree)
      if [ "${SEG[$j]}" = remove ]; then
        while [ $j -lt $n ]; do
          case ${SEG[$j]} in -f|--force) deny "git worktree remove --force discards that worktree's changes." ;; esac
          j=$((j+1))
        done
      fi ;;
  esac
  return 0
}

check_find() {
  local j=$A0 a r prev='' action=0 filter=0 orf=0 disp=0
  local -a roots
  while [ $j -lt $n ]; do
    a=${SEG[$j]}
    case $a in -*|'!'|'('|')') break ;; esac
    roots+=("$a"); j=$((j+1))
  done
  while [ $j -lt $n ]; do
    a=${SEG[$j]}; j=$((j+1))
    case $prev in
      -name|-iname|-path|-ipath|-wholename|-iwholename|-regex|-iregex)
        case $a in '*'|'.*'|'*/*'|'./*'|'.*/.*') ;; *) filter=1 ;; esac
        [[ /$a/ =~ $DISPOSABLE_RE ]] && disp=1 ;;
      -exec|-execdir|-ok|-okdir) [ "${a##*/}" = rm ] && action=1 ;;
    esac
    case $a in -delete) action=1 ;; -o|-or) orf=1 ;; esac
    prev=$a
  done
  [ $action = 0 ] && return 0
  if [ $filter = 0 ] || [ $orf = 1 ]; then
    deny "find-based mass deletion: -delete / -exec rm needs a -name/-path filter (and no -o)."
  fi
  for r in "${roots[@]}"; do
    if rm_target_dangerous "$r" && [ "$TGT_KIND" != project ] && [ $disp = 0 ]; then
      deny "find-based deletion under a home/root ($r): the filter must name a build/cache dir."
    fi
  done
  return 0
}

SQL_RE='(DROP +(TABLE|DATABASE|SCHEMA)|TRUNCATE +TABLE|DELETE +FROM +[a-z_.]+ *;?$|DELETE +FROM .* WHERE +1)'

DB_RE='[ /](prisma migrate reset|supabase db reset|docker volume (rm|prune)|(rails|rake) db:(drop|reset)|manage\.py flush)( |$)|(^|[ /])dropdb( |$)| docker[ -]compose( [^ ]+)* down( [^ ]+)* (-v|--volumes)( |$)| docker system prune( [^ ]+)* --volumes( |$)'

# Option-arguments of command wrappers: these options consume the next word.
wrapper_argopts() {
  case $1 in
    sudo|doas) WARGS=' -u -g -p -C -h -r -t -U -D ' ;;
    env)       WARGS=' -u -C -S --unset --chdir ' ;;
    exec)      WARGS=' -a ' ;;
    nice)      WARGS=' -n --adjustment ' ;;
    ionice)    WARGS=' -c -n -p ' ;;
    timeout)   WARGS=' -s -k --signal --kill-after ' ;;
    stdbuf)    WARGS=' -i -o -e ' ;;
    xargs)     WARGS=' -I -n -L -P -d -E -s -a ' ;;
    watch)     WARGS=' -n -d --interval ' ;;
    time)      WARGS=' -f -o ' ;;
    *)         WARGS=' ' ;;
  esac
}

check_segment() {
  local n=${#SEG[@]} i=0 w wrap='' j a joined cflag=0 prev=''
  while [ $i -lt $n ]; do
    w=${SEG[$i]}
    case $w in
      [A-Za-z_]*=*) case ${w%%=*} in *[!A-Za-z0-9_]*) ;; *) i=$((i+1)); continue ;; esac ;;   # VAR=x
    esac
    case $w in
      # shell keywords in front of a command: `if x; then rm …; fi`, `do rm …; done`, `! rm …`
      if|then|else|elif|fi|do|done|while|until|'{'|'}'|'!'|'[['|coproc|esac) i=$((i+1)); continue ;;
      for|select|case) return 0 ;;                                  # a `for x in …` head
      function) i=$((i+2)); continue ;;
    esac
    case ${w##*/} in
      sudo|doas|env|command|builtin|nice|time|nohup|exec|xargs|stdbuf|timeout|ionice|watch)
        wrap=${w##*/}; wrapper_argopts "$wrap"; i=$((i+1))
        while [ $i -lt $n ]; do
          a=${SEG[$i]}
          case $a in
            --) i=$((i+1)); break ;;
            --split-string=*) [ "$wrap" = env ] && { Q+=("${a#*=} ${SEG[*]:$((i+1))}"); return 0; }; i=$((i+1)) ;;
            --split-string) [ "$wrap" = env ] && { Q+=("${SEG[*]:$((i+1))}"); return 0; }; i=$((i+1)) ;;
            -[!-]*S*) if [ "$wrap" = env ]; then                    # env -S / -iS "split string"
                   a=${a#*S}
                   if [ -z "$a" ]; then Q+=("${SEG[*]:$((i+1))}"); else Q+=("$a ${SEG[*]:$((i+1))}"); fi
                   return 0
                 fi
                 i=$((i+1)) ;;
            -*) case $WARGS in *" ${a%%=*} "*) [ "${a#*=}" = "$a" ] && i=$((i+2)) || i=$((i+1)) ;; *) i=$((i+1)) ;; esac ;;
            *) break ;;
          esac
        done
        [ "$wrap" = timeout ] && i=$((i+1)) ;;                      # the DURATION
      *) break ;;
    esac
  done
  if [ $i -ge $n ]; then
    [ "$wrap" = env ] && deny "Command may expose secrets"
    return 0
  fi
  CMD=${SEG[$i]##*/}; A0=$((i+1))
  case $CMD in *"$BS"*) deny "escaped command word (${SEG[$i]}) cannot be checked -- write it plainly." ;; esac
  case $CMD in
    rm) check_rm ;;
    git) check_git ;;
    find) check_find ;;
    bash|sh|zsh|dash|ksh)
      # the first non-option word after -c is the command string; -o/-O take an argument
      j=$A0
      while [ $j -lt $n ]; do
        a=${SEG[$j]}
        case $a in
          --) j=$((j+1)); break ;;
          -o|-O|+o|+O|--rcfile|--init-file) j=$((j+1)) ;;
          --*) ;;
          -*c*) cflag=1 ;;
          -*|+*) ;;
          *) break ;;
        esac
        j=$((j+1))
      done
      if [ $cflag = 1 ]; then [ $j -lt $n ] && Q+=("${SEG[$j]}")
      elif [ $j -ge $n ]; then
        deny "a shell reading commands from a pipe/stdin cannot be checked -- run the commands directly."
      elif [ "${SEG[$j]}" = '<<<' ]; then Q+=("${SEG[$((j+1))]}")
      fi ;;
    eval) Q+=("${SEG[*]:$A0}") ;;
    trap) case ${SEG[$A0]} in -*|'') ;; *) Q+=("${SEG[$A0]}") ;; esac ;;
    printenv) deny "Command may expose secrets" ;;
    set) [ $A0 -ge $n ] && deny "Command may expose secrets" ;;
    cat|less|more|head|tail|bat|strings|grep|rg|awk|sed|xxd|od|base64|nl)
      # READING a secrets file prints it. The word after > / >> is a file being WRITTEN, and
      # `sed -i` (edit in place) / `grep -q` (silent test) print nothing: all allowed.
      for a in "${SEG[@]:$A0}"; do
        case $CMD/$a in sed/-i*|sed/--in-place*|grep/-*q*|grep/--quiet|grep/--silent|rg/-*q*|rg/--quiet) return 0 ;; esac
      done
      for a in "${SEG[@]:$A0}"; do
        case $prev in '>'|'>>'|'1>'|'2>'|'&>') prev=$a; continue ;; esac
        prev=$a
        a=${a#<}; a=${a%%>*}                                     # <.env  .env>&2  .env>/dev/stderr
        case ${a##*/} in
          *.example|*.sample|*.template) ;;
          .env*) deny "Command may expose secrets (reads ${a##*/})" ;;
        esac
      done ;;
    npm|yarn|pnpm)
      for a in "${SEG[@]:$A0}"; do
        [ "$a" = publish ] && deny "Publishing requires manual confirmation"
      done ;;
  esac
  # Text tools and git/gh only carry these words as data (patterns, messages).
  case $CMD in
    grep|rg|ag|awk|cat|less|more|head|tail|wc|diff|comm|sort|uniq|jq|fgrep|egrep|strings|sed|git|gh) ;;
    *)
      joined="${SEG[*]:$((A0-1))}"
      # Database resets: they wipe local data the same way rm -rf does.
      case $CMD in echo|printf) ;; *)
        case $joined in *prisma*|*supabase*|*docker*|*rails*|*rake*|*manage.py*|*dropdb*)
          [[ " $joined" =~ $DB_RE ]] && deny "database/volume reset (${BASH_REMATCH[0]# }) wipes data. Run it yourself if you mean it." ;;
        esac ;;
      esac
      # Destructive SQL, wherever it is passed (psql -c, mysql -e, echo … | psql, a heredoc).
      case $joined in *[Dd][Rr][Oo][Pp]*|*[Tt][Rr][Uu][Nn][Cc]*|*[Dd][Ee][Ll][Ee][Tt][Ee]*)
        shopt -s nocasematch
        if [[ $joined =~ $SQL_RE ]]; then shopt -u nocasematch; deny "destructive SQL statement"; fi
        shopt -u nocasematch ;;
      esac ;;
  esac
  return 0
}

check_tokens() { # walk an array of tokens (passed as words) and check every segment
  SEG=()
  for t in "$@" "$SEP"; do
    if [ "$t" = "$SEP" ]; then
      [ $SECONDS -lt $TBUDGET ] || deny "command too complex for the safety check (over ${TBUDGET}s) -- split it or write a script file."
      [ ${#SEG[@]} -gt 0 ] && check_segment
      SEG=()
    else
      SEG+=("$t")
    fi
  done
}

# ── Main: check every segment of the command, every $( )/backtick inside it, then any inner
# command strings it queued (bash -c, eval, heredocs to a shell). Fails CLOSED at the cap.
Q=("$cmd"); qi=0; QMAX=64
while [ $qi -lt ${#Q[@]} ] && [ $qi -lt $QMAX ]; do
  tokenize "${Q[$qi]}"; qi=$((qi+1))
  check_tokens "${TOK[@]}"
  check_tokens "${SUBTOK[@]}"
done
[ $qi -lt ${#Q[@]} ] && deny "too many nested shell commands to check ($QMAX) -- split the command."

exit 0
}

( main ); rc=$?
[ $rc = 0 ] && { BDC_OK=1; exit 0; }
[ $rc = 2 ] && exit 2
echo "BLOCKED: safety check failed (exit $rc) -- blocked. Split the command or use a script file." >&2 2>/dev/null
exit 2
