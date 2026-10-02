#!/bin/bash
# semi-auto-loop.sh — Tiered quality enforcement, restricted permissions
# Usage: bash scripts/semi-auto-loop.sh /path/to/project [iterations]
set -e

PROJECT_PATH="${1:-.}"
MAX_ITERATIONS="${2:-10}"
COOLDOWN=10
TIMEOUT_PER_ITERATION=1800
LOG_FILE="$PROJECT_PATH/tasks/autonomous-log.txt"

ALLOWED_TOOLS="Read,Write,Edit,Glob,Grep,Bash(git add*),Bash(git commit*),Bash(git status*),Bash(git log*),Bash(git diff*),Bash(cat *),Bash(ls *),Bash(mkdir *)"

# macOS doesn't have GNU timeout — detect available alternative
if command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
elif command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout"
else
    TIMEOUT_CMD=""
fi

cd "$PROJECT_PATH"

# Detect project type and extend allowed tools
if [ -f "package.json" ]; then
    ALLOWED_TOOLS="$ALLOWED_TOOLS,Bash(npm test*),Bash(npm run*),Bash(npx tsc*),Bash(npx prettier*),Bash(npx eslint*)"
fi
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    ALLOWED_TOOLS="$ALLOWED_TOOLS,Bash(pytest*),Bash(ruff*),Bash(python*),Bash(pip*)"
fi

# Pre-flight
[ ! -f "tasks/current.md" ] && echo "ERROR: tasks/current.md missing. Run /prepare-autonomous." && exit 1
[ ! -f "tasks/quality-protocol.md" ] && echo "ERROR: tasks/quality-protocol.md missing. Run /prepare-autonomous." && exit 1

BRANCH=$(git branch --show-current)
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] && echo "ERROR: On $BRANCH. Use feature branch." && exit 1

echo "=== Semi-Auto Loop ==="
echo "Branch: $BRANCH | Max: $MAX_ITERATIONS | Timeout: ${TIMEOUT_PER_ITERATION}s/iteration"
echo "Starting in 5s... (Ctrl+C to cancel)"
sleep 5

run_with_timeout() {
    if [ -n "$TIMEOUT_CMD" ]; then
        $TIMEOUT_CMD "$1" "${@:2}"
    else
        # Bash-native timeout: run in background, kill after deadline
        "${@:2}" &
        local pid=$!
        ( sleep "$1" && kill $pid 2>/dev/null ) &
        local watchdog=$!
        wait $pid 2>/dev/null
        local rc=$?
        kill $watchdog 2>/dev/null
        wait $watchdog 2>/dev/null
        return $rc
    fi
}

for i in $(seq 1 $MAX_ITERATIONS); do
    TS=$(date '+%Y-%m-%d %H:%M:%S')
    echo ""
    echo "── Iteration $i/$MAX_ITERATIONS [$TS] ──"
    echo "[$TS] Iteration $i" >> "$LOG_FILE"

    grep -q "NOT_STARTED\|IN_PROGRESS" tasks/todo.md 2>/dev/null || { echo "All tasks DONE."; break; }

    run_with_timeout $TIMEOUT_PER_ITERATION claude -p "
You are in autonomous mode. Read these files first:
1. tasks/current.md — your task and exact next action
2. tasks/quality-protocol.md — read Tier 1 (per-commit) and Tier 2 (per-task) sections
3. tasks/todo.md — task queue
4. tasks/lessons.md — rules

Execute the Exact Next Action from current.md.

PER SUBTASK:
1. Build it
2. Run Tier 1 checks (tests, lint, quick diff scan — see quality-protocol.md)
3. If tests fail: root cause → fix → re-test (3 attempts max, then blockers.md)
4. Commit only after Tier 1 passes
5. Check off subtask in current.md

WHEN TASK FULLY DONE (all subtasks complete):
1. Run Tier 2 checks from quality-protocol.md for this task's domain
2. Fix any Tier 2 failures
3. Refactor if needed: simplest working form, only your own code
4. Final commit for this task
5. Update todo.md (DONE), load next NOT_STARTED task into current.md
6. Add to lessons.md if you learned something reusable

RULES:
- Build what current.md says. No scope changes.
- Blocked after 3 attempts → blockers.md, BLOCKED, next task
- Always end: update current.md with Exact Next Action, commit
- Context heavy → commit progress, update current.md, stop
- NEVER hardcode secrets/keys/tokens — env vars only
- NEVER commit .env or credentials
" --allowedTools "$ALLOWED_TOOLS" 2>&1 | tee -a "$LOG_FILE"

    [ "${PIPESTATUS[0]}" -eq 124 ] && echo "⚠ Timed out."  # claude's exit code, not tee's
    [ $i -lt $MAX_ITERATIONS ] && sleep $COOLDOWN
done

echo ""
echo "=== Done ==="
COMMITS=$(git log --oneline "$BRANCH" --not main 2>/dev/null | wc -l | tr -d ' ')
echo "Commits: $COMMITS | Review: git diff main..$BRANCH | Blockers: cat tasks/blockers.md"
