#!/usr/bin/env bash
# No "run once" guard in a security hook: the global copy always runs, even when the project
# registers its own copy, so a project file can never switch this check off.
set -euo pipefail

# Without jq this hook cannot read the path. Fail CLOSED: exit 2 blocks the edit/write
# (any other exit code, e.g. 127 "command not found", would let it through).
command -v jq >/dev/null 2>&1 || { echo "safety hooks need jq — install it (see README)" >&2; exit 2; }

# Read tool input from stdin
input=$(cat)
# One path format on every system: native jq.exe (Git Bash on Windows) ends its output in
# CRLF, so drop \r; Windows paths use \, so turn it into / before the patterns below.
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' | tr -d '\r' | tr '\\' '/')

# Skip if no file path
[ -z "$file_path" ] && exit 0

# Allowlist: these .env-named files are templates meant to be committed.
# Must come BEFORE the block loop so the generic \.env patterns don't catch them.
if echo "$file_path" | grep -qE '\.env\.(example|sample|template|schema|dist|defaults?)$'; then
    exit 0
fi

# Protected file patterns
# Note: we list .env variants explicitly rather than using a broad "\.env\." pattern,
# because the broad pattern would also block .env.example / .env.sample (template files
# meant to be committed). The allowlist above handles those; this list handles the rest.
protected_patterns=(
    "\.env$"
    "\.env\.local$"
    "\.env\.development$"
    "\.env\.production$"
    "\.env\.test$"
    "\.env\.staging$"
    "package-lock\.json$"
    "pnpm-lock\.yaml$"
    "yarn\.lock$"
    "\.git/"
    "node_modules/"
    "\.next/"
    "\.ssh/"
    "\.aws/"
    "credentials"
    "\.pem$"
    "\.key$"
)

for pattern in "${protected_patterns[@]}"; do
    if echo "$file_path" | grep -qE "$pattern"; then
        echo "BLOCKED: Protected file pattern: $file_path" >&2
        exit 2
    fi
done

exit 0
