#!/bin/bash
# full-auto-loop.sh — Overnight, tiered quality, morning summary
#
# REQUIRES Docker/sandbox by default. Will not run on bare metal.
#
# Inside Docker:
#   bash scripts/full-auto-loop.sh /path/to/project [iterations]
#
# To allow bare-metal (NOT recommended), create a config file:
#   echo "I_ACCEPT_BARE_METAL_RISK=true" > ~/.claude-auto-config
#   bash scripts/full-auto-loop.sh . 30
#   (on macOS, prefix with `caffeinate -s` so the Mac does not sleep during the run)
set -e

PROJECT_PATH="${1:-.}"
MAX_ITERATIONS="${2:-30}"
COOLDOWN=15
TIMEOUT_PER_ITERATION=2400
TOTAL_TIMEOUT=28800
LOG_DIR="$PROJECT_PATH/tasks/logs"
LOG_FILE="$LOG_DIR/overnight-$(date '+%Y-%m-%d').log"
SUMMARY_FILE="$LOG_DIR/overnight-$(date '+%Y-%m-%d')-summary.md"

ALLOWED_TOOLS="Read,Write,Bash(npm test),Bash(npm run lint),Bash(npm run build),Bash(npx tsc --noEmit),Bash(git add -A),Bash(git commit*),Bash(git status),Bash(git log*),Bash(git diff*),Bash(cat *),Bash(ls *),Bash(mkdir *),Bash(npx prettier*),Bash(npx eslint*)"

# ── Sandbox enforcement ──
# Only the marker files a container runtime puts inside the container (Docker: /.dockerenv,
# Podman: /run/.containerenv). /proc/self/mountinfo and /proc/1/cgroup also mention docker on
# a HOST that runs containers (or WSL with Docker Desktop), which would skip this check there.
IN_DOCKER=false
[ -f "/.dockerenv" ] && IN_DOCKER=true
[ -f "/run/.containerenv" ] && IN_DOCKER=true

BARE_METAL_ALLOWED=false
[ -f "$HOME/.claude-auto-config" ] && grep -q "I_ACCEPT_BARE_METAL_RISK=true" "$HOME/.claude-auto-config" 2>/dev/null && BARE_METAL_ALLOWED=true

if [ "$IN_DOCKER" = false ] && [ "$BARE_METAL_ALLOWED" = false ]; then
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  FULL AUTO BLOCKED — requires Docker/sandbox               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Full-auto runs 30+ unattended iterations overnight."
    echo "Docker contains any unexpected behavior to the container."
    echo ""
    echo "Option 1 — Run in Docker (recommended):"
    echo "  docker run --rm -v \"\$(pwd)\":/project -w /project \\"
    echo "    -v ~/ailoopwise-blueprint/blueprint/scripts:/blueprint-scripts:ro \\"
    echo "    claude-auto bash /blueprint-scripts/full-auto-loop.sh . 30"
    echo ""
    echo "Option 2 — Use semi-auto (no Docker needed, you're nearby):"
    echo "  bash ~/ailoopwise-blueprint/blueprint/scripts/semi-auto-loop.sh . 10"
    echo ""
    echo "Option 3 — Allow bare-metal (one-time config, you accept risk):"
    echo "  echo \"I_ACCEPT_BARE_METAL_RISK=true\" > ~/.claude-auto-config"
    echo "  Then re-run this command."
    echo ""
    echo "Protections still active even on bare metal:"
    echo "  --allowedTools restricts Claude to specific commands"
    echo "  Feature branch keeps main untouched"
    echo "  Pre-commit hook blocks secrets"
    exit 1
fi

if [ "$IN_DOCKER" = true ]; then
    echo "✓ Running inside Docker sandbox"
else
    echo "⚠ Bare-metal mode (~/.claude-auto-config). Protections: --allowedTools, feature branch, pre-commit hook."
fi

# macOS doesn't have GNU timeout — detect available alternative
if command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
elif command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout"
else
    TIMEOUT_CMD=""
fi

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

PROJECT_PATH=$(cd "$PROJECT_PATH" && pwd)
mkdir -p "$LOG_DIR"
cd "$PROJECT_PATH"

# Pre-flight
[ ! -f "tasks/current.md" ] && echo "ERROR: Run /prepare-autonomous first." && exit 1
[ ! -f "tasks/quality-protocol.md" ] && echo "ERROR: Run /prepare-autonomous first." && exit 1

BRANCH=$(git branch --show-current)
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] && echo "ERROR: Use feature branch." && exit 1

START_TIME=$(date +%s)
CONSECUTIVE_FAILURES=0
COMPLETED=0

echo "=== Overnight Build ===" | tee "$LOG_FILE"
echo "Branch: $BRANCH | Max: $MAX_ITERATIONS | Timeout: ${TOTAL_TIMEOUT}s total" | tee -a "$LOG_FILE"

for i in $(seq 1 $MAX_ITERATIONS); do
    ELAPSED=$(( $(date +%s) - START_TIME ))
    [ $ELAPSED -ge $TOTAL_TIMEOUT ] && echo "Total timeout." | tee -a "$LOG_FILE" && break

    echo "" | tee -a "$LOG_FILE"
    echo "── Iteration $i/$MAX_ITERATIONS [$(date '+%H:%M:%S')] ──" | tee -a "$LOG_FILE"

    grep -q "NOT_STARTED\|IN_PROGRESS" tasks/todo.md 2>/dev/null || { echo "All tasks DONE!" | tee -a "$LOG_FILE"; break; }

    run_with_timeout $TIMEOUT_PER_ITERATION claude -p "
You are in autonomous mode. Read these files first:
1. tasks/current.md — your task and exact next action
2. tasks/quality-protocol.md — read Tier 1 (per-commit) and Tier 2 (per-task) sections
3. tasks/todo.md — task queue
4. tasks/lessons.md — rules
5. CLAUDE.md — project conventions

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
- Do NOT ask questions — decide, document in blockers.md
- Do NOT modify files outside current task scope
- NEVER hardcode secrets/keys/tokens — env vars only
- NEVER commit .env or credentials
" --allowedTools "$ALLOWED_TOOLS" 2>&1 | tee -a "$LOG_FILE"

    EXIT_CODE=${PIPESTATUS[0]}  # claude's exit code; plain $? would be tee's (always 0)
    if [ $EXIT_CODE -ne 0 ]; then
        CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        [ $CONSECUTIVE_FAILURES -ge 3 ] && echo "3 consecutive failures. Stopping." | tee -a "$LOG_FILE" && break
    else
        CONSECUTIVE_FAILURES=0
        COMPLETED=$((COMPLETED + 1))
    fi

    [ $i -lt $MAX_ITERATIONS ] && sleep $COOLDOWN
done

# Morning summary
TOTAL_TIME=$(( $(date +%s) - START_TIME ))
TOTAL_COMMITS=$(git log --oneline "$BRANCH" --not main 2>/dev/null | wc -l | tr -d ' ')
BLOCKED_COUNT=$(grep -c "^### " tasks/blockers.md 2>/dev/null || echo 0)

cat > "$SUMMARY_FILE" << EOF
# Overnight Summary — $(date '+%Y-%m-%d')

- **Runtime:** $(($TOTAL_TIME / 3600))h $((($TOTAL_TIME % 3600) / 60))m
- **Iterations:** $i/$MAX_ITERATIONS ($COMPLETED successful)
- **Commits:** $TOTAL_COMMITS
- **Blockers:** $BLOCKED_COUNT

## Morning Review
\`\`\`bash
git log --oneline $BRANCH --not main     # what was built
git diff main..$BRANCH                    # full diff
cat tasks/blockers.md                     # decisions needing review
cat tasks/current.md                      # where it stopped
\`\`\`

## Tier 3 Audit (run interactively before merging)
\`\`\`
claude
# "Audit all changes on branch $BRANCH vs main.
#  Security, architecture, test coverage, code quality.
#  Report findings with file:line references."
\`\`\`

## Recent Commits
$(git log --oneline -20 "$BRANCH" --not main 2>/dev/null || echo "(none)")

## Blockers
$(grep -A 4 "^### " tasks/blockers.md 2>/dev/null || echo "(none)")
EOF

echo "" | tee -a "$LOG_FILE"
echo "=== Overnight Complete ===" | tee -a "$LOG_FILE"
cat "$SUMMARY_FILE"
