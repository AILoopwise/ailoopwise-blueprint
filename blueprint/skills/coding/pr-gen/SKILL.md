---
name: pr-gen
description: "Trigger on 'create PR', 'generate PR', 'PR description', 'pull request', 'open PR', 'draft PR', 'submit PR', 'write PR description', 'prepare PR'. Generates a structured pull request description from git diff and commit history. Includes what changed, why, how to test, breaking changes, and a review checklist. Do not use for code reviews (use /code-review if installed) or deployment (use /deploy if installed)."
disable-model-invocation: true
---

# PR Generation Skill

## Purpose

Generate a complete, well-structured pull request from the current branch's changes. The PR description must give reviewers everything they need: what changed, why it changed, how to verify it, and what to watch out for. Don't generate a vague PR like "misc fixes" or "update code."

## Context Gathering

Run these commands to understand the full scope of changes before writing anything.

### Step 1: Identify the current branch and base

```bash
# Current branch name
git branch --show-current

# Find the base branch (usually main or master)
git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | tr -d ' '

# If the above fails, check common defaults
git branch -a | grep -E "main|master" | head -1
```

Store the base branch name. All diffs and logs are computed against this base.

### Step 2: Gather the diff

```bash
# Full diff of all changes on this branch vs base
git diff <base_branch>...HEAD

# Stat summary (files changed, insertions, deletions)
git diff <base_branch>...HEAD --stat

# List only changed file names
git diff <base_branch>...HEAD --name-only
```

### Step 3: Gather commit history

```bash
# All commits on this branch since diverging from base
git log <base_branch>...HEAD --oneline

# Detailed commit messages for context on the "why"
git log <base_branch>...HEAD --format="%h %s%n%n%b" --no-merges
```

### Step 4: Check CI and test status

```bash
# Run tests locally to confirm green
npm test 2>&1 | tail -10
pytest 2>&1 | tail -10
go test ./... 2>&1 | tail -10

# Run linter
npm run lint 2>&1 | tail -10

# Check for type errors
npx tsc --noEmit 2>&1 | tail -10

# Build check
npm run build 2>&1 | tail -10
```

### Step 5: Check for common PR problems

```bash
# Secrets accidentally staged
git diff <base_branch>...HEAD | grep -iE "(password|secret|api_key|token|private_key)" | head -5

# Large files
git diff <base_branch>...HEAD --stat | awk '{print $3}' | sort -rn | head -5

# Merge conflicts markers left in code
git diff <base_branch>...HEAD | grep -E "^[<>=]{7}" | head -5

# Console.log / debug statements left in
git diff <base_branch>...HEAD | grep -E "(console\.log|debugger|binding\.pry|import pdb)" | head -5
```

If ANY of these checks find issues, WARN the user before creating the PR.

## Core Process: PR Description Generation

### Analyze the changes

Categorize every changed file into one of these buckets:
- **Feature:** New functionality added
- **Fix:** Bug fix
- **Refactor:** Code restructure without behavior change
- **Test:** Test additions or modifications
- **Config:** Configuration, CI, build changes
- **Docs:** Documentation updates
- **Chore:** Dependencies, tooling, housekeeping

### Determine the PR type

Based on the dominant category:
- If mostly Feature files: title starts with `feat:`
- If mostly Fix files: title starts with `fix:`
- If mostly Refactor files: title starts with `refactor:`
- If mixed: use the most impactful category

### Extract the "why" from commits

Read ALL commit messages. Look for:
- Issue/ticket references (`#123`, `JIRA-456`)
- Motivation statements ("because...", "to fix...", "to enable...")
- Context that explains the decision, not just the action

If commit messages lack context, ask the user: "What problem does this PR solve?"

### Identify breaking changes

A change is breaking if:
- A public API signature changed (parameters added/removed/retyped)
- A database migration is required
- Environment variables were added or changed
- A dependency version was bumped with breaking changes
- A config file format changed
- An endpoint URL or method changed

Scan the diff for these patterns:
```bash
# API signature changes
git diff <base_branch>...HEAD | grep -E "^[-+].*export (function|class|interface|type)" | head -20

# Migration files
git diff <base_branch>...HEAD --name-only | grep -iE "migration"

# Env var changes
git diff <base_branch>...HEAD | grep -iE "process\.env\.|os\.environ|env\." | head -10

# Package.json dependency changes
git diff <base_branch>...HEAD -- package.json | grep -E "^[+-].*\":" | head -20
```

## Output Format

### PR Title

Under 70 characters. Format: `<type>: <concise description>`

Examples:
- `feat: add user avatar upload with image compression`
- `fix: prevent duplicate webhook deliveries on retry`
- `refactor: extract payment processing into dedicated service`

### PR Body

Use this exact structure:

```markdown
## Summary

<2-4 sentences explaining WHAT changed and WHY. Link to issue if applicable.>

Closes #<issue_number> (if applicable)

## Changes

<Bulleted list of specific changes, grouped by file or component>

- **component/module:** What changed and why
- **component/module:** What changed and why

## How to Test

<Step-by-step instructions a reviewer can follow to verify the change>

1. `<command to set up>`
2. `<command to run or action to take>`
3. `<expected result to verify>`

### Automated Tests
```bash
<exact command to run relevant tests>
```

## Breaking Changes

<If none: "None">
<If any: describe each breaking change, who is affected, and the migration path>

- **Change:** <what changed>
- **Impact:** <who/what is affected>
- **Migration:** <what consumers need to do>

## Checklist

- [ ] Tests pass locally (`<test command>`)
- [ ] Lint passes (`<lint command>`)
- [ ] Types check (`<type check command>`)
- [ ] No secrets in diff
- [ ] No debug statements left in code
- [ ] Documentation updated (if applicable)
- [ ] Breaking changes documented (if applicable)
- [ ] Reviewer assigned
```

## PR Creation

After generating the description, create the PR using the GitHub CLI:

```bash
gh pr create \
  --title "<title>" \
  --body "<body>" \
  --base <base_branch> \
  --head <current_branch>
```

If the branch has not been pushed yet:
```bash
git push -u origin <current_branch>
```

If the user wants a draft PR:
```bash
gh pr create --draft \
  --title "<title>" \
  --body "<body>"
```

## Example

### Input

User says: "Create a PR for my changes"

Git log shows:
```
a1b2c3d Add rate limiting middleware to API endpoints
d4e5f6g Add rate limit tests for /api/users endpoint
h7i8j9k Update README with rate limit documentation
```

Git diff stat shows:
```
 src/middleware/rateLimit.ts     | 45 +++++++++++++++++++++++++++++++++
 src/routes/users.ts            |  3 +++
 src/routes/orders.ts           |  3 +++
 tests/middleware/rateLimit.test.ts | 62 +++++++++++++++++++++++++++++++++++
 README.md                      |  8 +++++
 5 files changed, 121 insertions(+)
```

### Output

**Title:** `feat: add rate limiting middleware to API endpoints`

**Body:**

```markdown
## Summary

Add rate limiting to all API endpoints to prevent abuse and ensure fair usage.
The middleware uses a sliding window algorithm with configurable limits per
endpoint. Default limit is 100 requests per minute per IP.

## Changes

- **src/middleware/rateLimit.ts:** New rate limiting middleware using sliding
  window counter stored in memory (Redis adapter can be added later)
- **src/routes/users.ts:** Apply rate limiter to all /api/users routes
- **src/routes/orders.ts:** Apply rate limiter to all /api/orders routes
- **tests/middleware/rateLimit.test.ts:** Tests covering normal usage,
  limit exceeded (429 response), window reset, and concurrent requests
- **README.md:** Document rate limit headers and behavior

## How to Test

1. Start the dev server: `npm run dev`
2. Hit any API endpoint 101 times in rapid succession:
   ```bash
   for i in $(seq 1 101); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/api/users; done
   ```
3. Verify: first 100 requests return `200`, request 101 returns `429`
4. Verify response headers include `X-RateLimit-Remaining` and `X-RateLimit-Reset`

### Automated Tests
```bash
npm test -- --testPathPattern="rateLimit"
```

## Breaking Changes

None. Rate limiting is additive. Existing clients will not be affected unless
they exceed 100 requests/minute, which indicates abusive behavior.

## Checklist

- [ ] Tests pass locally (`npm test`)
- [ ] Lint passes (`npm run lint`)
- [ ] Types check (`npx tsc --noEmit`)
- [ ] No secrets in diff
- [ ] No debug statements left in code
- [ ] Documentation updated (README.md)
- [ ] Breaking changes documented (N/A)
- [ ] Reviewer assigned
```

Then execute:
```bash
git push -u origin feat/rate-limiting
gh pr create --title "feat: add rate limiting middleware to API endpoints" --body "$(cat <<'EOF'
<body content from above>
EOF
)"
```

## Evals

EVAL 1: Title Quality (binary)
Question: Is the PR title under 70 characters, prefixed with a conventional type (feat/fix/refactor/etc.), and descriptive of the change?
Pass: Title follows `<type>: <concise description>` format, is under 70 chars, and accurately describes the change.
Fail: Title is vague ("updates", "fixes"), missing type prefix, over 70 chars, or inaccurate.

EVAL 2: Description Completeness (model-graded)
Question: Does the PR body include all required sections (Summary, Changes, How to Test, Breaking Changes, Checklist) with substantive content?
Grading prompt: "Analyze the PR description. Does the Summary explain what and why? Does the Changes section list specific file-level changes? Is How to Test actionable with step-by-step instructions? Are Breaking Changes documented or explicitly marked None? Is the Checklist present? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 3: Pre-Creation Safety Checks (binary)
Question: Were secrets, debug statements, and conflict markers scanned for before PR creation?
Pass: Output shows grep/scan commands were run for secrets, console.log/debugger statements, and merge conflict markers, with results reported.
Fail: Safety scans were skipped or not shown in the output.

EVAL 4: Tests Verified (binary)
Question: Were tests, lint, and type checks run before creating the PR?
Pass: Output shows test suite, linter, and type checker were all run with results reported.
Fail: Any of the three checks were skipped.

EVAL 5: How-to-Test Quality (model-graded)
Question: Could a reviewer follow the testing instructions to independently verify the change?
Grading prompt: "Analyze the How to Test section. Are the steps specific and reproducible? Do they include exact commands? Do they describe expected results for verification? Would a reviewer unfamiliar with the code be able to follow them? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't create a PR with a vague title like "updates" or "fixes."
- Don't create a PR without running tests first. If tests fail, report the failure.
- Include the "How to Test" section with specific, reproducible steps.
- Check for secrets, debug statements, and conflict markers before creating.
- Include the checklist at the bottom.
- If the diff is empty (no changes), say so immediately and do not create a PR.
- If there are uncommitted changes, warn the user and ask whether to commit them first.
- NEVER force-push or modify commit history without explicit user permission.
- If breaking changes exist, they must be prominently documented with migration steps.
- Return the PR URL to the user after creation so they can review it.
