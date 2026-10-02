#!/usr/bin/env bash
# lib-install.sh — shared helpers for bootstrap.sh and blueprint-sync.sh. Source it, do not run it.
#
# The one rule these helpers enforce: a file the user changed is never overwritten.
# Every file the blueprint installs is recorded with its checksum in a manifest
# (.blueprint-manifest). On the next run:
#   - file missing                      -> install it
#   - file identical to the blueprint   -> nothing to do
#   - file still matches the manifest   -> the user did not touch it -> update it
#   - anything else                     -> keep the user's file, write <file>.blueprint-new beside it
#
# Settings are merged with jq, never replaced (see merge-hooks.jq).

BP_DRY_RUN="${BP_DRY_RUN:-false}"
BP_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BP_ROOT="$(cd "$BP_LIB_DIR/.." && pwd -P)"

# Where a write may land. A project folder can be anything, e.g. a downloaded repo whose
# .claude/settings.json is a link into ~/.claude. So in project scope (BP_SCOPE=project, with
# BP_PROJECT = the project folder) nothing is written through a symlink: not the file, and no
# folder between it and the project folder. In global scope (~/.claude, the default) a link, e.g.
# from a dotfiles repo, is followed only when it lands inside $HOME and outside this blueprint folder.
BP_SCOPE="${BP_SCOPE:-global}"
BP_PROJECT="${BP_PROJECT:-}"
BP_HOME_REAL="$(cd "$HOME" 2>/dev/null && pwd -P)"

bp_physical() { # path -> where a write to it lands, every link followed; fails on a broken or looping link
  local p="$1" rest d n=0 t
  while [ -L "$p" ]; do
    n=$((n + 1)); [ "$n" -le 40 ] || return 1
    t="$(readlink "$p")"
    case "$t" in /*) p="$t" ;; *) p="$(dirname "$p")/$t" ;; esac
  done
  rest="$(basename "$p")"; d="$(dirname "$p")"
  while [ ! -d "$d" ]; do                 # folders that do not exist yet
    [ -L "$d" ] && return 1
    rest="$(basename "$d")/$rest"; d="$(dirname "$d")"
  done
  d="$(cd -P "$d" && pwd -P)" || return 1
  printf '%s/%s\n' "${d%/}" "$rest"
}

bp_write_ok() { # path -> 0 if a write to path may go ahead; otherwise says why and returns 1
  local p="$1" real
  if [ "$BP_SCOPE" = project ]; then
    case "$BP_PROJECT" in /?*) ;; *) echo "  REFUSED: no project folder set for $p" >&2; return 1 ;; esac
    case "$p" in "$BP_PROJECT"/*) ;; *) echo "  REFUSED: $p is outside the project $BP_PROJECT" >&2; return 1 ;; esac
    while [ "${#p}" -gt "${#BP_PROJECT}" ]; do   # the path and every folder above it, up to the project folder
      if [ -L "$p" ]; then
        echo "  REFUSED: $p is a symlink. Nothing in a project is written through a link; replace it with a real file or folder, then run again." >&2
        return 1
      fi
      p="$(dirname "$p")"
    done
    return 0
  fi
  real="$(bp_physical "$p")" || { echo "  REFUSED: $p is a broken or looping link." >&2; return 1; }
  case "$real/" in "$BP_ROOT"/*) echo "  REFUSED: $p leads into the blueprint folder ($real)." >&2; return 1 ;; esac
  case "$real" in "$BP_HOME_REAL"/*) return 0 ;; esac
  echo "  REFUSED: $p leads outside your home folder ($real)." >&2
  return 1
}

bp_sum() { cksum < "$1" | awk '{print $1 "-" $2}'; }

bp_manifest_get() { # manifest key
  [ -f "$1" ] || return 0
  awk -F '\t' -v k="$2" '$2 == k { v = $1 } END { if (v) print v }' "$1"
}

bp_manifest_set() { # manifest key file
  local manifest="$1" key="$2" file="$3" tmp
  $BP_DRY_RUN && return 0
  tmp="$manifest.tmp.$$"
  bp_write_ok "$manifest" && bp_write_ok "$tmp" || return 1
  touch "$manifest"
  awk -F '\t' -v k="$key" '$2 != k' "$manifest" > "$tmp"
  printf '%s\t%s\n' "$(bp_sum "$file")" "$key" >> "$tmp"
  mv "$tmp" "$manifest"
}

# Timestamped backup that never overwrites an earlier backup.
bp_backup() { # file
  local base="$1.bak-$(date +%Y%m%d-%H%M%S)" b n=0
  b="$base"
  while [ -e "$b" ] || [ -L "$b" ]; do n=$((n + 1)); b="$base-$n"; done
  cp -p "$1" "$b"
  echo "  backup: $b"
}

# Paths listed in <claude dir>/.blueprint-ignore (one per line, e.g. agents/reviewer.md or
# skills/debug) are never installed or updated, so a file you deleted stays deleted.
bp_ignored() { # manifest key
  local list line
  list="$(dirname "$1")/.blueprint-ignore"
  [ -f "$list" ] || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%/}"
    case "$line" in ''|'#'*) continue ;; esac
    case "$2" in "$line"|"$line"/*) return 0 ;; esac
  done < "$list"
  return 1
}

# A link we may replace: broken, or pointing into this blueprint folder (older installs
# linked hooks there). Any other link belongs to the user (e.g. a dotfiles repo): in global
# scope we write through it (see bp_write_ok), in project scope we refuse it.
bp_is_our_link() { # path
  local target_dir
  [ -L "$1" ] || return 1
  [ -e "$1" ] || return 0
  target_dir="$(cd "$(dirname "$1")" && cd "$(dirname "$(readlink "$1")")" 2>/dev/null && pwd -P)" || return 1
  case "$target_dir/" in "$BP_ROOT"/*) return 0 ;; esac
  return 1
}

bp_install_file() { # src dst manifest key
  local src="$1" dst="$2" manifest="$3" key="$4" recorded
  if bp_ignored "$manifest" "$key"; then return 0; fi
  bp_write_ok "$(dirname "$dst")" || return 1   # no link in the folders above it
  if $BP_DRY_RUN; then
    if bp_is_our_link "$dst"; then echo "  [dry-run] replace link $key with a real copy"
    elif ! bp_write_ok "$dst"; then :
    elif [ ! -e "$dst" ]; then echo "  [dry-run] install $key"
    elif cmp -s "$src" "$dst"; then :
    elif [ "$(bp_manifest_get "$manifest" "$key")" = "$(bp_sum "$dst")" ]; then echo "  [dry-run] update $key"
    else echo "  [dry-run] keep your $key, write $key.blueprint-new"
    fi
    return 0
  fi
  # A link into the blueprint folder breaks silently when the folder moves: replace it with a copy.
  if bp_is_our_link "$dst"; then rm -f "$dst"; fi
  bp_write_ok "$dst" || return 1
  mkdir -p "$(dirname "$dst")"
  if [ ! -e "$dst" ]; then
    cp "$src" "$dst"; bp_manifest_set "$manifest" "$key" "$dst"
    echo "  installed $key"
  elif cmp -s "$src" "$dst"; then
    bp_manifest_set "$manifest" "$key" "$dst"
  else
    recorded="$(bp_manifest_get "$manifest" "$key")"
    if [ -n "$recorded" ] && [ "$recorded" = "$(bp_sum "$dst")" ]; then
      cp "$src" "$dst"; bp_manifest_set "$manifest" "$key" "$dst"   # cp writes through a user's link
      echo "  updated $key"
    else
      bp_write_ok "$dst.blueprint-new" || return 1
      cp "$src" "$dst.blueprint-new"
      echo "  kept your $key (it differs from the blueprint); new version saved beside it as $(basename "$dst").blueprint-new"
    fi
  fi
}

bp_install_dir() { # srcdir dstdir manifest keyprefix — every file inside, one by one
  local srcdir="$1" dstdir="$2" manifest="$3" prefix="$4" f rel
  while IFS= read -r -d '' f; do
    rel="${f#"$srcdir"/}"
    bp_install_file "$f" "$dstdir/$rel" "$manifest" "$prefix/$rel"
  done < <(find "$srcdir" -type f -print0)
}

# Merge the blueprint's hooks into a settings.json. Every other key and every hook the
# user added stays. Blueprint hook entries from earlier runs are replaced, not duplicated.
# A missing, empty or whitespace-only file counts as {}. A symlinked settings.json is updated
# through the link in global scope only, and only when bp_write_ok allows it.
bp_has_content() { [ -f "$1" ] && grep -q '[^[:space:]]' "$1"; }

bp_merged_settings() { # settings_file template -> merged JSON on stdout
  if bp_has_content "$1"; then jq --argjson bp "$2" -f "$BP_LIB_DIR/merge-hooks.jq" "$1"
  else echo '{}' | jq --argjson bp "$2" -f "$BP_LIB_DIR/merge-hooks.jq"; fi
}

# The settings template minus every hook listed in .blueprint-ignore, so an ignored hook is
# not registered pointing at a file that was never installed.
bp_template_without_ignored() { # manifest template_json hooks_dir_of_blueprint
  local ignored=() hook name
  for hook in "$3"/*.sh; do
    name="$(basename "$hook")"
    bp_ignored "$1" "hooks/$name" && ignored+=("$name")
  done
  jq --argjson ign "$(printf '%s\n' "${ignored[@]+"${ignored[@]}"}" | jq -R . | jq -s 'map(select(length > 0))')" '
    .hooks |= (with_entries(.value |= map(
        .hooks |= map(select((.command // "") as $c | all($ign[]; . as $n | ($c | contains("/.claude/hooks/" + $n)) | not)))
        | select(.hooks | length > 0)))
      | with_entries(select(.value | length > 0)))' <<< "$2"
}

bp_merge_settings() { # settings_file template_json_string
  local file="$1" template="$2" tmp want_pre
  bp_write_ok "$file" || return 1
  if $BP_DRY_RUN; then
    if bp_has_content "$file" && bp_merged_settings "$file" "$template" 2>/dev/null | cmp -s - "$file"; then :
    else echo "  [dry-run] merge blueprint hooks into $file"; fi
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  tmp="$(dirname "$file")/.settings.json.tmp.$$"
  bp_write_ok "$tmp" || return 1
  if ! bp_merged_settings "$file" "$template" > "$tmp" 2>/dev/null; then
    rm -f "$tmp"
    echo "  ERROR: $file is not valid JSON. Left unchanged; fix it and run again." >&2
    return 1
  fi
  # When the template registers PreToolUse hooks, the result has to contain them.
  want_pre="$(jq '(.hooks.PreToolUse // []) | length > 0' <<< "$template")"
  if [ "$want_pre" = true ] && ! jq -e '(.hooks.PreToolUse | length) > 0' "$tmp" >/dev/null 2>&1; then
    rm -f "$tmp"
    echo "  ERROR: merging hooks into $file failed; the file was left unchanged and the hooks are NOT active." >&2
    return 1
  fi
  if bp_has_content "$file" && cmp -s "$tmp" "$file"; then
    rm -f "$tmp"
    echo "  settings.json already has the blueprint hooks"
    return 0
  fi
  [ -e "$file" ] && bp_backup "$file"
  if [ -L "$file" ] && [ -e "$file" ]; then cat "$tmp" > "$file"; rm -f "$tmp"   # keep the user's link
  else mv "$tmp" "$file"; fi
  if [ "$want_pre" = true ] && ! jq -e '(.hooks.PreToolUse | length) > 0' "$file" >/dev/null; then
    echo "  ERROR: $file has no hooks after the merge." >&2; return 1
  fi
  echo "  merged blueprint hooks into $file"
}
