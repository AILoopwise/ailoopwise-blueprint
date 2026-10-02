---
name: prepare-autonomous
description: "Turns a PRD into a task queue and a tiered quality protocol (tasks/quality-protocol.md) so a semi- or full-auto loop can work through it. Creates a feature branch and commits the task files."
when_to_use: "The user types /prepare-autonomous, or /semi-auto or /full-auto finds the project unprepared. Run interactively, before any loop."
disable-model-invocation: true
---

# /prepare-autonomous

Prepares a project for autonomous execution. Run interactively.

## Step 1: Detect Domain

| Signal | Domain |
|--------|--------|
| express/fastify/nest/django/flask in deps | backend |
| react/vue/next/svelte in deps | frontend |
| Both | fullstack |
| Marketing skills in .claude/skills/ or ~/.claude/skills/ | marketing |
| Sales skills in .claude/skills/ or ~/.claude/skills/ | sales |
| Design skills in .claude/skills/ or ~/.claude/skills/ | design |
| Dockerfile, terraform, k8s configs | infrastructure |

Confirm with user: "Detected [domains]. Correct?"

## Step 2: Detect Project Commands

Use the Read tool to read `package.json` (or `Makefile`, `pyproject.toml`) and look for script definitions.
Use the Read tool to read `CLAUDE.md` and look for test, lint, and build commands.

Record: TEST_CMD, LINT_CMD, BUILD_CMD. Note if any are missing.

## Step 3: Read the PRD

Check: docs/prd.md → docs/PRD.md → ask user. Read fully.

## Step 4: Generate tasks/quality-protocol.md

This is the file the loop relies on most. Structure it in three tiers so the autonomous
loop knows what to run when. Use the project's actual commands.

Include only the sections that match the detected domains.

```markdown
# Quality Protocol
*Domain(s): [detected] | Test: [TEST_CMD] | Lint: [LINT_CMD] | Build: [BUILD_CMD]*

---

## Tier 1 — Per Commit (every subtask, every iteration)
*Budget: 2-3 minutes. Run this before every git commit.*

1. Tests pass: `[TEST_CMD]`
2. Lint passes: `[LINT_CMD]`
3. Build succeeds: `[BUILD_CMD]`
4. Quick scan of your diff:
   - No hardcoded secrets, API keys, passwords, tokens
   - No console.log/print left in (unless intentional logging)
   - No commented-out code blocks
   - No TODO/FIXME without corresponding blockers.md entry
   - Changes scoped to current task only
5. Pattern check: does new code follow conventions in existing files?

If tests fail → Recursive Fix Loop:
  a. Read FULL error output
  b. Identify ROOT CAUSE (not symptom)
  c. Minimal targeted fix
  d. Re-run tests
  e. Different approach if same fix fails twice
  f. After 3 total attempts → blockers.md, move on

---

## Tier 2 — Per Task (when a full task is marked DONE)
*Budget: 5-10 minutes. Run ONCE when all subtasks for a task complete.*

### Universal (all domains)
- [ ] All acceptance criteria from PRD section verified
- [ ] Implementation is simplest working form — refactor if:
  - Any function > 50 lines → extract
  - Repeated pattern > 2 occurrences → shared utility
  - Nesting > 3 levels → flatten with early returns
  - Refactor only code from this task, not unrelated files
- [ ] Add to tasks/lessons.md if you learned something reusable

### [INCLUDE IF: backend or fullstack]
Security scan (only categories relevant to what you built):
| Category | Check | Result |
|----------|-------|--------|
| Injection | Parameterized queries? Input sanitized? | PASS/FAIL/N/A |
| Auth/AuthZ | Endpoint protected? Role check correct? | PASS/FAIL/N/A |
| Secrets | Env vars used? .env in .gitignore? | PASS/FAIL/N/A |
| Input Validation | Schema validation? Type checking? Limits? | PASS/FAIL/N/A |
| Error Handling | No stack traces leaked? Generic client errors? | PASS/FAIL/N/A |
| Dependencies | New deps? Run audit command if available | PASS/FAIL/N/A |

Mark N/A for categories not touched. Fix any FAIL before moving on.

Code quality:
- Error handling on all async operations
- Database transactions for multi-step writes
- No N+1 queries (batch if looping with DB calls)

### [INCLUDE IF: frontend or fullstack]
Accessibility spot-check (on components you built/modified):
- [ ] Images have alt text
- [ ] Form inputs have labels
- [ ] Interactive elements keyboard-accessible (Tab, Enter)
- [ ] Semantic HTML (correct heading hierarchy)

Responsive spot-check:
- [ ] No obvious breakage at mobile (375px) and desktop (1280px)
- [ ] Touch targets reasonable size on mobile

Code quality:
- Components under 200 lines — split if longer
- Business logic extracted from UI components
- Consistent styling approach

### [INCLUDE IF: marketing]
Content eval loop (run on the COMPLETE deliverable, not drafts):
1. Binary evals: banned phrases absent? Word count in range? CTA present and specific?
2. Model-graded evals: Clarity, Voice, Audience Fit (1-10 with reasoning before scoring)
3. Combined score = (binary_pass_rate + model_avg_normalized) / 2. Target: 85%+.
4. If below target → diagnose, rewrite, re-score. Max 2 rewrites.

Humanization scan — eliminate:
"leverage", "in today's [X] landscape", "game-changer", "dive into",
"it's important to note", "streamline", "robust", "seamless", "holistic",
"synergy", "empower", "unlock", "revolutionize", "cutting-edge"

### [INCLUDE IF: sales]
Outreach/proposal quality (run on complete deliverable):
- [ ] Personalization: specific reference to prospect's situation
- [ ] Value prop clear within first 2 sentences
- [ ] CTA: one specific ask
- [ ] "So what?" test: every claim has evidence
Score same dimensions as marketing. Pass threshold: avg >= 7.

### [INCLUDE IF: design]
UI review (on completed component/page):
- [ ] Visual hierarchy clear
- [ ] Spacing consistent with project's system
- [ ] Color within palette
- [ ] States documented: default, hover, disabled, error, loading

### [INCLUDE IF: infrastructure]
- [ ] No secrets in config files
- [ ] Base images pinned to versions (not :latest)
- [ ] Health checks defined

---

## Tier 3 — Per PRD (morning review, run interactively)
*Run by the human AFTER the autonomous loop completes, BEFORE merging.*

This is NOT run by the loop. This is your morning checklist:
```bash
# Review all changes
git diff main..autonomous/[branch]

# Check blockers Claude flagged
cat tasks/blockers.md

# Run comprehensive audit interactively
claude
# "Audit all changes on this branch vs main:
#  1. Architecture: do changes fit the existing design?
#  2. Security: full 8-category audit on all new code
#  3. Test coverage: any gaps in what was built?
#  4. Code quality: anything that needs refactoring?
#  5. [frontend] Full a11y audit, responsive at all breakpoints
#  6. [marketing] Full content scoring with 3-loop recursive quality
#  Report findings with file:line references."
```
```

## Step 5: Decompose PRD Into Tasks

Each task must be:
- Completable in one session (15-45 min)
- Testable (verifiable with Tier 1 checks)
- Dependency-ordered
- Domain-tagged: `[backend]`, `[frontend]`, etc.
- Specific enough for a cold-start Claude Code instance

BAD: "Build authentication"
GOOD: "[backend] Create POST /auth/register in src/routes/auth.ts.
Accept {email, password, name}. Hash with bcrypt. Store in users table.
Return JWT. Write tests for success + duplicate email + weak password."

## Step 6: Generate todo.md Task Queue

```markdown
## Task Queue (ordered — autonomous mode works top-down)
1. [PRD §X.X] [backend] Task description — Status: NOT_STARTED
2. [PRD §X.X] [frontend] Task description — Status: NOT_STARTED
```

## Step 7: Populate current.md

Fill ALL fields: Active Task, Status (NOT_STARTED), PRD Section,
Domain, Completed Subtasks checklist, Exact Next Action paragraph,
Files to Reference (include tasks/quality-protocol.md).

## Step 8: Create Support Files

- tasks/blockers.md — if missing, create it from `blockers-template.md` in this skill's folder
- .gitignore — add tasks/logs/ and tasks/autonomous-log.txt

## Step 9: Create Feature Branch

```bash
git checkout -b autonomous/[name]
git add tasks/
git commit -m "Prepare autonomous: [N] tasks, [domains] quality protocol"
```

## Step 10: Validate

- [ ] PRD readable
- [ ] quality-protocol.md generated with correct domain sections
- [ ] TEST_CMD runs without error
- [ ] LINT_CMD runs without error
- [ ] todo.md has numbered queue with domain tags
- [ ] current.md has all required fields
- [ ] blockers.md exists
- [ ] Feature branch created
- [ ] Secret-scanning pre-commit hook installed in this repo (`.git/hooks/pre-commit` exists, or `git config core.hooksPath` in this repo returns a path)

## Step 11: Ask Which Mode

After validation passes, ask the user:

```
✅ Ready — [N] tasks, [domains], quality protocol active

How do you want to work?

  1. Interactive — stay here, work together normally (default)
  2. Semi-auto — loop for 1-2 hours, you're nearby
  3. Full-auto — overnight run, review in the morning

Type 1, 2, or 3 (or just hit enter for interactive):
```

Based on their answer:

**1 (Interactive):** Load the first task from current.md and start working on it
right here in this session. Business as usual.

**2 (Semi-auto):** Display:
```
Exit Claude Code, then paste in your terminal:

  bash ~/ailoopwise-blueprint/blueprint/scripts/semi-auto-loop.sh . 10

Stop anytime: Ctrl+C
```

**3 (Full-auto):** Tell the user to type `/full-auto`. It checks for Docker and shows the right launch command.
