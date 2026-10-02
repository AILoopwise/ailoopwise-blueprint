#!/usr/bin/env bash
# No "run once" guard in a security hook: the global copy always runs, even when the project
# registers its own copy, so a project file can never switch this check off.
set -euo pipefail

# Secret detection hook — PreToolUse on Edit|Write
# BLOCKS writes containing hardcoded API keys, tokens, private keys, or DB passwords.
# Layer: GLOBAL (blocking) — secrets must never be committed regardless of project.

# Without jq this hook cannot read the content. Fail CLOSED: exit 2 blocks the edit/write
# (any other exit code, e.g. 127 "command not found", would let it through).
command -v jq >/dev/null 2>&1 || { echo "safety hooks need jq — install it (see README)" >&2; exit 2; }

input=$(cat)

# Native jq.exe (Git Bash on Windows) ends every output line in CRLF: drop \r from both.
# Windows paths use \: turn it into / in the path only (in content a backslash is data).
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' | tr -d '\r' | tr '\\' '/')
content=$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty' | tr -d '\r')

[ -z "$content" ] && exit 0

# Skip template/example/sample files
if echo "$file_path" | grep -qEi '\.(example|sample|template)(\.|$)'; then
    exit 0
fi
# Skip docs
if echo "$file_path" | grep -qEi '\.(md|mdx|rst|txt|adoc)$'; then
    exit 0
fi
# Skip test fixtures/mocks
if echo "$file_path" | grep -qEi '(fixture|mock|fake|stub|__test__|__spec__)'; then
    exit 0
fi

# --- Secret Patterns (macOS grep -E compatible) ---

# AWS Access Key IDs (always start with AKIA, 20 chars total)
if echo "$content" | grep -qE 'AKIA[0-9A-Z]{16}'; then
    echo "BLOCKED: AWS Access Key ID detected in $file_path" >&2
    exit 2
fi

# GitHub tokens (ghp_, gho_, ghu_, ghs_, ghr_ + 36 chars)
if echo "$content" | grep -qE 'gh[pousr]_[A-Za-z0-9]{36}'; then
    echo "BLOCKED: GitHub token detected in $file_path" >&2
    exit 2
fi

# OpenAI / Anthropic / generic sk- keys (20+ chars)
if echo "$content" | grep -qE 'sk-[A-Za-z0-9_-]{20,}'; then
    echo "BLOCKED: API secret key (sk-...) detected in $file_path" >&2
    exit 2
fi

# Stripe live/restricted keys
if echo "$content" | grep -qE '(sk_live_|rk_live_)[A-Za-z0-9]{20,}'; then
    echo "BLOCKED: Stripe live key detected in $file_path" >&2
    exit 2
fi

# Private keys (PEM format)
if echo "$content" | grep -qE 'BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'; then
    echo "BLOCKED: Private key detected in $file_path" >&2
    exit 2
fi

# Database connection strings with embedded passwords
if echo "$content" | grep -qE '(postgres|postgresql|mysql|mongodb|redis|amqp|mssql)://[^:[:space:]]+:[^@[:space:]]+@'; then
    echo "BLOCKED: Database connection string with embedded password in $file_path" >&2
    exit 2
fi

# Slack tokens
if echo "$content" | grep -qE 'xox[bpsa]-[A-Za-z0-9-]{10,}'; then
    echo "BLOCKED: Slack token detected in $file_path" >&2
    exit 2
fi

# Generic credential assignments: a sensitive variable name set to a long literal
if echo "$content" | grep -qEi '(api_key|api_secret|auth_token|access_token|secret_key|private_key|password)[[:space:]]*[=:][[:space:]]*["'"'"'][A-Za-z0-9/+=_-]{20,}["'"'"']'; then
    echo "BLOCKED: Hardcoded secret assignment detected in $file_path" >&2
    exit 2
fi

exit 0
