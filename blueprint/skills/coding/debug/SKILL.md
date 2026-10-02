---
name: debug
description: "Trigger on 'debug', 'fix this bug', 'why is this failing', 'not working', 'error', 'broken', 'crash', 'exception', 'unexpected behavior', 'investigate'. Performs root-cause diagnosis by separating symptoms from causes, then fixes the root cause with a mandatory test-verify loop. Don't patch symptoms. Do not use for code reviews (use /code-review if installed), refactoring (use /refactor if installed), or writing tests (use /test-gen if installed)."
---

# Debug Skill

## Purpose

Diagnose and fix bugs by identifying the ROOT CAUSE, not the symptom. Don't apply a surface-level patch that silences an error without understanding why it occurred. Every debug session must end with a verified fix: a failing test that now passes.

## Context Gathering (Phase 1: Evidence Collection)

Before writing a single line of fix code, always collect ALL available evidence. Rushing to a fix without evidence leads to symptom-patching.

### Step 1: Capture the error

Get the EXACT error message, stack trace, or incorrect behavior description.

```bash
# If the user reports a test failure, reproduce it
npm test 2>&1 | tail -50
pytest -x --tb=long 2>&1 | tail -80
go test ./... 2>&1 | tail -50
cargo test 2>&1 | tail -80
```

If the user provides an error message, read it carefully. Extract:
- **Error type** (TypeError, NullPointerException, panic, segfault, etc.)
- **Error message** (the human-readable string)
- **Stack trace** (file names and line numbers)
- **Trigger condition** (what action caused it: API call, button click, startup, etc.)

### Step 2: Reproduce the failure

Reproduce the bug before attempting to fix it. If you cannot reproduce it, you cannot verify the fix.

```bash
# Run the specific failing test
npm test -- --testPathPattern="<test_file>" --testNamePattern="<test_name>"
pytest <test_file>::<test_class>::<test_name> -x
go test -run <TestName> ./path/to/package
```

If there is no existing test that demonstrates the failure, WRITE ONE immediately. This test becomes the verification gate.

### Step 3: Examine recent changes

Check what changed recently that could have introduced the bug:

```bash
# Last 10 commits
git log --oneline -10

# Diff of recent changes
git diff HEAD~3 -- <suspected_files>

# Blame the failing line
git blame <file> -L <start>,<end>
```

### Step 4: Read surrounding code

Read the file(s) referenced in the stack trace. Read at least 50 lines of context around the error site. Also read:
- The function's callers (search for function name usage)
- Related type definitions
- Configuration files that might affect behavior

### Step 5: Check logs and state

If the application has logs, inspect them:

```bash
# Application logs
tail -100 /var/log/app.log 2>/dev/null
# Docker logs
docker logs <container> --tail 100 2>/dev/null
# System journal
journalctl -u <service> --since "10 minutes ago" 2>/dev/null
```

## Root-vs-Symptom Classification (Phase 2: Diagnosis)

After collecting evidence, always explicitly classify what you found. This is the most critical step. Present your analysis in this format:

### Symptom vs. Root Cause Analysis

```
SYMPTOM: What the user sees or what the test reports.
  Example: "TypeError: Cannot read property 'name' of undefined at UserCard.tsx:15"

CHAIN OF CAUSATION:
  1. [Proximate] UserCard receives `undefined` as the `user` prop
  2. [Intermediate] The parent component passes `users[0]` but `users` is an empty array
  3. [ROOT CAUSE] The API call in useEffect has a race condition: the component renders
     before the fetch completes, and there is no loading state or default value

ROOT CAUSE: <one clear sentence>
```

### Classification rules

- **A symptom** is the observable error or incorrect output.
- **An intermediate cause** is a condition that enables the symptom but is itself caused by something deeper.
- **The root cause** is the FIRST point in the chain where the code's logic deviates from the correct behavior. Fixing it eliminates the entire chain.

Don't stop at the symptom. Ask "but WHY does that happen?" until you reach a point where the answer is "because the code does X when it should do Y."

### Common root-cause patterns

| Symptom | Likely Root Cause |
|---------|-------------------|
| `undefined is not a function` | Wrong import, incorrect API version, misspelled method |
| `null reference` / `Cannot read property of null` | Missing null check, async data not yet loaded, wrong query |
| Off-by-one error | Loop boundary wrong, inclusive vs exclusive range confusion |
| Race condition | Missing await, shared mutable state, no synchronization |
| `Module not found` | Wrong path, missing dependency, misconfigured aliases |
| Test passes locally, fails in CI | Environment difference, timezone, locale, file ordering |
| Stale data | Missing cache invalidation, stale closure, wrong dependency array |
| Silent failure | Swallowed exception, missing error handler, catch-all without rethrow |

## Fix Implementation (Phase 3: Root Cause Fix)

### Step 1: Write or confirm the failing test

BEFORE writing any fix code, ensure you have a test that FAILS and demonstrates the bug.

```bash
# Run the specific test and confirm it fails
npm test -- --testPathPattern="<test_file>" 2>&1 | grep -E "(FAIL|PASS|Error)"
```

If the test does not exist, write one. The test must:
- Target the root cause, not the symptom
- Be minimal (test one thing)
- Have a descriptive name that explains the bug

### Step 2: Implement the minimal fix

Fix the ROOT CAUSE identified in Phase 2. The fix must be:
- **Minimal:** Change only what is necessary. Do not refactor unrelated code during a bug fix.
- **Targeted:** Fix the root cause, not a symptom.
- **Safe:** Do not introduce new side effects. If the fix changes a public API, consider backward compatibility.

### Step 3: Verify the fix (MANDATORY)

Run the failing test again. It must now pass.

```bash
# Run the specific test
npm test -- --testPathPattern="<test_file>" --testNamePattern="<test_name>"
pytest <test_file>::<test_name> -x
go test -run <TestName> ./path/to/package
```

Then run the FULL test suite to ensure no regressions:

```bash
npm test
pytest
go test ./...
cargo test
```

### The Mandatory Loop

```
REPEAT:
  1. Run failing test -> confirm FAIL
  2. Apply fix
  3. Run failing test -> check PASS
  4. Run full suite -> check no regressions
  IF full suite has new failures:
    -> The fix introduced a regression. Go back to step 2.
  ELSE:
    -> Done. Report results.
```

Don't declare a bug fixed without completing this loop. Don't skip step 4 (regression check).

## Output Format

Structure debug output as follows:

### Bug Report

```
**Error:** <exact error message>
**Location:** <file:line>
**Trigger:** <what action causes the bug>
**Reproduced:** Yes/No (if No, explain why and what was attempted)
```

### Diagnosis

```
**Symptom:** <what the user sees>
**Root Cause:** <what is actually wrong and why>
**Chain:** symptom <- intermediate cause <- root cause
```

### Fix

```
**File:** <path>
**Change:** <description of what was changed and why>
**Diff:** <show the before/after or the actual diff>
```

### Verification

```
**Failing test before fix:** <test name> -> FAIL
**Failing test after fix:** <test name> -> PASS
**Full suite after fix:** X passed, 0 failed
**Regression check:** CLEAN
```

## Example

### Input

User says: "My API endpoint returns 500 when I try to create a user with an email that already exists."

### Debug Session

**Phase 1: Evidence Collection**

Read the error logs:
```
Error: Unique constraint violation on field "email"
    at PrismaClient._executeRequest (node_modules/@prisma/client/runtime/library.js:123)
    at UserService.createUser (src/services/user.service.ts:34)
    at UserController.create (src/controllers/user.controller.ts:18)
```

Read the relevant code at `src/services/user.service.ts:34`:
```typescript
async createUser(data: CreateUserDto) {
  const user = await this.prisma.user.create({ data });
  return user;
}
```

Read the controller at `src/controllers/user.controller.ts:18`:
```typescript
async create(req: Request, res: Response) {
  const user = await this.userService.createUser(req.body);
  res.status(201).json(user);
}
```

No try/catch anywhere. No duplicate check before insert.

**Phase 2: Diagnosis**

```
SYMPTOM: 500 Internal Server Error when creating user with duplicate email
CHAIN:
  1. [Proximate] Prisma throws P2002 (unique constraint violation)
  2. [Intermediate] No try/catch in service or controller to handle the error
  3. [ROOT CAUSE] The createUser flow does not check for existing users or handle
     the unique constraint error, so Prisma's exception propagates as an unhandled 500.
ROOT CAUSE: Missing error handling for duplicate email in the user creation flow.
```

**Phase 3: Fix**

Write the failing test first:
```typescript
it('should return 409 when email already exists', async () => {
  await createTestUser({ email: 'dup@test.com' });
  const res = await request(app).post('/users').send({ email: 'dup@test.com', name: 'Test' });
  expect(res.status).toBe(409);
  expect(res.body.message).toContain('already exists');
});
```

Confirm it fails (returns 500 instead of 409). Then fix:

```typescript
// src/services/user.service.ts
async createUser(data: CreateUserDto) {
  const existing = await this.prisma.user.findUnique({ where: { email: data.email } });
  if (existing) {
    throw new ConflictError(`User with email ${data.email} already exists`);
  }
  return this.prisma.user.create({ data });
}
```

```typescript
// src/controllers/user.controller.ts
async create(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await this.userService.createUser(req.body);
    res.status(201).json(user);
  } catch (err) {
    if (err instanceof ConflictError) {
      res.status(409).json({ message: err.message });
    } else {
      next(err);
    }
  }
}
```

Run test: PASS. Run full suite: all green. No regressions.

## Evals

EVAL 1: Root Cause Identification (model-graded)
Question: Does the diagnosis correctly distinguish the root cause from symptoms and intermediate causes?
Grading prompt: "Analyze the symptom-vs-root-cause chain. Is the root cause the true first point of deviation, not a symptom or intermediate cause? Would fixing it eliminate the entire chain? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 2: Reproduction (binary)
Question: Was the bug reproduced before attempting a fix?
Pass: A specific test or command was run that demonstrated the failure before any fix code was written.
Fail: Fix was applied without first reproducing the bug, or reproduction was skipped without justification.

EVAL 3: Fix Minimality (model-graded)
Question: Is the fix minimal and targeted at the root cause rather than patching a symptom?
Grading prompt: "Analyze the fix. Does it change only what is necessary? Does it target the root cause identified in the diagnosis? Does it avoid unrelated refactoring or scope creep? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Test Verification (binary)
Question: Was the fix verified with a test that failed before and passes after?
Pass: A specific test was shown failing before the fix and passing after, plus the full test suite was run with no regressions.
Fail: No before/after test verification, or full suite regression check was skipped.

EVAL 5: Chain of Causation Documented (binary)
Question: Is the symptom-to-root-cause chain explicitly documented in the output?
Pass: Output includes a clear SYMPTOM, CHAIN OF CAUSATION, and ROOT CAUSE section with numbered steps.
Fail: Diagnosis jumps straight to a fix without documenting the causal chain.

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't apply a fix without reproducing the bug first.
- Don't patch a symptom. Trace to root cause.
- Write or confirm a failing test before fixing.
- Run the full test suite after the fix to check for regressions.
- Don't declare "fixed" without showing a passing test.
- If reproduction is impossible (environment-specific, intermittent), document exactly what was tried and why reproduction failed. Propose a fix with lower confidence and flag it for manual verification.
- If the bug is in a dependency (not the user's code), document the dependency bug, suggest a workaround in user code, and recommend filing an upstream issue.
- Present the symptom-vs-root-cause chain explicitly. This forces disciplined thinking.
