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
# Opted-in projects only. This hook runs the project's own tools (npm run lint, tests, type
# checks), which can be any code the folder ships. It acts only when the project folder is a line
# in ~/.claude/blueprint-projects, your own list on this machine (/new-project and
# blueprint-sync.sh --project add to it). A file inside a repo cannot opt it in.
bp_root="$(cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null && pwd -P)" || exit 0
grep -qxF -- "$bp_root" "$HOME/.claude/blueprint-projects" 2>/dev/null || exit 0
cd "$bp_root" || exit 0
set -euo pipefail

# Quality check hook — runs when Claude stops. Multi-language support.
#
# Blocking rule: a type error or a failed test sets HARD_FAIL. At the end the hook exits 2 ONCE,
# which stops Claude from finishing and shows it the reason, so it fixes the code first.
# Claude Code passes stop_hook_active=true when a hook already blocked this stop; then we exit 0,
# so a failure Claude cannot fix can never loop forever (see the hooks reference).
HARD_FAIL=""
STOP_HOOK_ACTIVE=false
if [ ! -t 0 ]; then
    hook_input=$(cat 2>/dev/null || true)
    if command -v jq &>/dev/null && [ -n "$hook_input" ]; then
        STOP_HOOK_ACTIVE=$(echo "$hook_input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)
    fi
fi

# --- Detect which files changed (staged + unstaged) ---
changed_files=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    changed_files=$(git diff --name-only 2>/dev/null; git diff --cached --name-only 2>/dev/null)
fi

# --- Generic checks on staged changes ---
if git diff --cached 2>/dev/null | grep -qE '^\+.*console\.(log|debug)'; then
    echo "Warning: console.log/debug in staged changes" >&2
fi

if git diff --cached 2>/dev/null | grep -qE '^\+.*(TODO|FIXME|HACK|XXX)'; then
    echo "Note: TODO/FIXME found in staged changes" >&2
fi

if git diff --cached 2>/dev/null | grep -qE '^\+.*(localhost|127\.0\.0\.1):[0-9]+'; then
    echo "Warning: Hardcoded localhost URL in staged changes" >&2
fi

# --- JavaScript / TypeScript ---
if [ -f "package.json" ]; then
    code_changed=false
    if echo "$changed_files" | grep -qE '\.(ts|tsx|js|jsx)$'; then
        code_changed=true
    fi

    # TypeScript type-check
    if [ -f "tsconfig.json" ] && command -v npx &>/dev/null; then
        tsc_output=$(npx --no tsc --noEmit 2>&1 || true)  # --no: never download from npm
        if [ -n "$tsc_output" ]; then
            error_count=$(echo "$tsc_output" | grep -cE '^.+\([0-9]+,[0-9]+\): error TS' || true)
            if [ "$error_count" -gt 0 ]; then
                echo "TypeScript: $error_count type error(s) found:" >&2
                HARD_FAIL="$HARD_FAIL typescript"
                echo "$tsc_output" | grep -E '^.+\([0-9]+,[0-9]+\): error TS' | head -5 >&2
                if [ "$error_count" -gt 5 ]; then
                    echo "  ... and $((error_count - 5)) more. Run 'npx tsc --noEmit' for all." >&2
                fi
            fi
        fi
    fi

    # Lint (if available)
    if grep -q '"lint"' package.json 2>/dev/null; then
        lint_output=$(npm run lint 2>&1 || true)
        if echo "$lint_output" | grep -qEi '(error|warning)'; then
            echo "Lint issues found:" >&2
            echo "$lint_output" | grep -Ei '(error|warning)' | head -10 >&2
        fi
    fi

    # Format check (if available)
    if grep -q '"format:check"' package.json 2>/dev/null; then
        fmt_output=$(npm run format:check 2>&1 || true)
        if echo "$fmt_output" | grep -qEi '(error|fail|differ)'; then
            echo "Format check failed — run formatter." >&2
        fi
    fi

    # Tests (only when code files changed)
    if [ "$code_changed" = true ]; then
        if grep -q '"test"' package.json 2>/dev/null; then
            echo "Running tests (code files changed)..." >&2
            test_rc=0
            test_output=$(npm test 2>&1) || test_rc=$?
            # exit code first: npm prints nothing recognisable when a script simply exits 1
            if [ "$test_rc" -ne 0 ] || echo "$test_output" | grep -qEi '(FAIL|failed|error|ERR!)'; then
                echo "TESTS FAILED — fix before finishing:" >&2
                HARD_FAIL="$HARD_FAIL tests"
                echo "$test_output" | tail -20 >&2
            else
                echo "Tests passed." >&2
            fi
        else
            echo "Warning: No test script in package.json. Add tests." >&2
        fi
    fi
fi

# --- Python ---
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    py_changed=false
    if echo "$changed_files" | grep -qE '\.py$'; then
        py_changed=true
    fi

    # Type check (mypy)
    if command -v mypy &>/dev/null && [ "$py_changed" = true ]; then
        mypy_output=$(mypy . --ignore-missing-imports 2>&1 || true)
        error_count=$(echo "$mypy_output" | grep -cE ': error:' || true)
        if [ "$error_count" -gt 0 ]; then
            echo "mypy: $error_count type error(s) found:" >&2
            echo "$mypy_output" | grep -E ': error:' | head -5 >&2
        fi
    fi

    # Lint (ruff or flake8)
    if command -v ruff &>/dev/null && [ "$py_changed" = true ]; then
        ruff_output=$(ruff check . 2>&1 || true)
        if [ -n "$ruff_output" ]; then
            echo "ruff lint issues:" >&2
            echo "$ruff_output" | head -10 >&2
        fi
    elif command -v flake8 &>/dev/null && [ "$py_changed" = true ]; then
        flake8_output=$(flake8 . 2>&1 || true)
        if [ -n "$flake8_output" ]; then
            echo "flake8 issues:" >&2
            echo "$flake8_output" | head -10 >&2
        fi
    fi

    # Format check (black)
    if command -v black &>/dev/null && [ "$py_changed" = true ]; then
        black_output=$(black --check . 2>&1 || true)
        if echo "$black_output" | grep -qE 'would reformat'; then
            echo "Format: black would reformat files. Run 'black .' to fix." >&2
        fi
    fi

    # Tests (pytest)
    if command -v pytest &>/dev/null && [ "$py_changed" = true ]; then
        echo "Running pytest (Python files changed)..." >&2
        pytest_output=$(pytest --tb=short -q 2>&1 || true)
        if echo "$pytest_output" | grep -qEi '(FAILED|ERROR)'; then
            echo "PYTEST FAILED:" >&2
            HARD_FAIL="$HARD_FAIL pytest"
            echo "$pytest_output" | tail -15 >&2
        else
            echo "Tests passed." >&2
        fi
    fi
fi

# --- Go ---
if [ -f "go.mod" ]; then
    go_changed=false
    if echo "$changed_files" | grep -qE '\.go$'; then
        go_changed=true
    fi

    if [ "$go_changed" = true ]; then
        # go vet
        vet_output=$(go vet ./... 2>&1 || true)
        if [ -n "$vet_output" ]; then
            echo "go vet issues:" >&2
            echo "$vet_output" | head -10 >&2
        fi

        # golangci-lint (if available)
        if command -v golangci-lint &>/dev/null; then
            lint_output=$(golangci-lint run 2>&1 || true)
            if [ -n "$lint_output" ]; then
                echo "golangci-lint issues:" >&2
                echo "$lint_output" | head -10 >&2
            fi
        fi

        # go test
        echo "Running go test (Go files changed)..." >&2
        test_output=$(go test ./... 2>&1 || true)
        if echo "$test_output" | grep -qE '(FAIL)'; then
            echo "GO TESTS FAILED:" >&2
            HARD_FAIL="$HARD_FAIL go-test"
            echo "$test_output" | tail -15 >&2
        else
            echo "Tests passed." >&2
        fi
    fi
fi

# --- Rust ---
if [ -f "Cargo.toml" ]; then
    rs_changed=false
    if echo "$changed_files" | grep -qE '\.rs$'; then
        rs_changed=true
    fi

    if [ "$rs_changed" = true ]; then
        # cargo check
        check_output=$(cargo check 2>&1 || true)
        if echo "$check_output" | grep -qE '^error'; then
            echo "cargo check errors:" >&2
            echo "$check_output" | grep -E '^error' | head -5 >&2
        fi

        # cargo clippy (if available)
        if cargo clippy --version &>/dev/null 2>&1; then
            clippy_output=$(cargo clippy 2>&1 || true)
            if echo "$clippy_output" | grep -qE 'warning:'; then
                echo "clippy warnings:" >&2
                echo "$clippy_output" | grep -E 'warning:' | head -10 >&2
            fi
        fi

        # cargo test
        echo "Running cargo test (Rust files changed)..." >&2
        test_output=$(cargo test 2>&1 || true)
        if echo "$test_output" | grep -qE '(FAILED|failures)'; then
            echo "CARGO TESTS FAILED:" >&2
            HARD_FAIL="$HARD_FAIL cargo-test"
            echo "$test_output" | tail -15 >&2
        else
            echo "Tests passed." >&2
        fi
    fi
fi

if [ -n "$HARD_FAIL" ] && [ "$STOP_HOOK_ACTIVE" != "true" ]; then
    echo "STOP BLOCKED by quality-check.sh — failing:$HARD_FAIL. Fix the code, re-run the checks, then finish. This blocks once per turn; if the failure is pre-existing and not yours, say so explicitly." >&2
    exit 2
fi
exit 0
