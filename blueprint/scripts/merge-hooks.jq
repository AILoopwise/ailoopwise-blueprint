# merge-hooks.jq — used by lib-install.sh.
# Input: the user's settings.json. $bp: the blueprint settings (hooks only).
# 1. Keep every key of the user's settings.
# 2. Per hook event, drop only hook commands the blueprint itself installed earlier
#    (they call one of the blueprint scripts below), keep everything else.
# 3. Append the blueprint's current entries. Running this twice gives the same result.
def blueprint_owned:
  test("\\.claude/hooks/(block-dangerous-commands|protect-sensitive-files|detect-secrets-in-code|format-and-lint|owasp-check|audit-dependencies|quality-check|scan-skills|post-bash-security|session-start)\\.sh")
  or test("NEW/UNCONFIGURED PROJECT");

(. // {}) as $user
| ($user.hooks // {}) as $uh
| $user + {
    hooks: (
      reduce ((($uh | keys) + ($bp.hooks | keys)) | unique)[] as $event ({};
        .[$event] = (
          [ ($uh[$event] // [])[]
            | .hooks = [ (.hooks // [])[] | select(((.command // "") | blueprint_owned) | not) ]
            | select(.hooks | length > 0) ]
          + ($bp.hooks[$event] // [])
        ))
      | with_entries(select(.value | length > 0))
    )
  }
