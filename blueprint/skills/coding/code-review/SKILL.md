---
name: code-review
description: "Trigger on 'review', 'code review', 'review this PR', 'check my code', 'critique this'. Performs a rigorous 4-layer code review covering architecture, code quality, tests, and performance. Produces scored, actionable feedback with multiple fix options per issue. Use this whenever a user asks for feedback on code changes, pull requests, or diffs. Do not use for debugging (use /debug if installed), writing tests (use /test-gen if installed), or refactoring (use /refactor if installed)."
---

# Code Review Skill

## Purpose

Perform a structured, 4-layer code review that produces actionable findings with concrete fix options. Don't give vague feedback like "looks good" or "could be better." Every observation must include a specific location, a clear description, and at least two resolution options with a recommended choice.

## Context Gathering

Before reviewing ANY code, always collect these inputs:

1. **Identify the scope.** Determine what files or diff to review. If the user provides a PR number, run:
   ```bash
   gh pr diff <PR_NUMBER>
   gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName
   ```
   If the user provides files directly, read them. If the user says "review my changes," run:
   ```bash
   git diff HEAD
   git diff --cached
   ```

2. **Understand the project context.** Check for:
   - Language and framework (inspect `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.)
   - Linting configuration (`.eslintrc`, `ruff.toml`, `.golangci.yml`, etc.)
   - Test framework (look for `jest.config`, `pytest.ini`, `vitest.config`, etc.)
   - CI configuration (`.github/workflows/`, `Jenkinsfile`, etc.)

3. **Check existing lint and test status.** Run the project's lint and test commands to establish a baseline:
   ```bash
   # Detect and run linter
   npm run lint 2>/dev/null || npx eslint . 2>/dev/null || ruff check . 2>/dev/null || golangci-lint run 2>/dev/null
   # Detect and run tests
   npm test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || cargo test 2>/dev/null
   ```

4. **Gather recent git history** for context on the change:
   ```bash
   git log --oneline -10
   ```

## Core Process: 4-Layer Review Protocol

Review in this exact order. Don't skip a layer.

### Layer 1: Architecture

Examine structural decisions and design patterns.

- Does the change follow existing project patterns or introduce inconsistency?
- Are responsibilities properly separated (single responsibility principle)?
- Are dependencies flowing in the correct direction (no circular deps)?
- Is the public API surface minimal and well-defined?
- Are new abstractions justified, or do they add unnecessary complexity?
- Does the change respect module boundaries?

For each architectural issue found, classify severity as: **CRITICAL**, **WARNING**, or **SUGGESTION**.

### Layer 2: Code Quality

Examine readability, maintainability, and correctness.

- Naming: Are variable, function, and class names clear and consistent with project conventions?
- Complexity: Are functions under 30 lines? Is cyclomatic complexity reasonable?
- Error handling: Are all error paths handled? Are errors propagated or swallowed?
- Type safety: Are types precise (no unnecessary `any`, `object`, or `interface{}`)?
- Dead code: Is there commented-out code, unused imports, or unreachable branches?
- Magic values: Are magic numbers and strings extracted to named constants?
- DRY violations: Is logic duplicated that should be extracted?

Run the project linter and report any new violations introduced by the change:
```bash
# Example for a JS/TS project
npx eslint --no-eslintrc -c .eslintrc.js <changed_files>
```

### Layer 3: Tests

Examine test coverage and quality for the changed code.

- Does every new public function or method have at least one test?
- Are edge cases covered (null, empty, boundary values, error conditions)?
- Are tests isolated (no shared mutable state, no order dependence)?
- Do test names describe the behavior being verified?
- Are assertions specific (not just "does not throw")?
- Is there integration test coverage for new API endpoints or workflows?

Run tests to verify they pass:
```bash
# Run only tests related to changed files if possible
npm test -- --findRelatedTests <changed_files> 2>/dev/null || pytest <changed_test_files> 2>/dev/null
```

If test coverage tooling exists, check coverage on changed lines:
```bash
npx jest --coverage --collectCoverageFrom='<changed_file_glob>' 2>/dev/null
```

### Layer 4: Performance

Examine runtime and resource efficiency.

- Are there N+1 query patterns in database access?
- Are there unnecessary allocations inside loops?
- Is there blocking I/O on a hot path?
- Are large datasets processed without streaming or pagination?
- Are expensive computations cached when results are reused?
- Are there missing database indexes for new queries?
- Could any synchronous operation become a bottleneck under load?

## Output Format

Structure the review output as follows:

### Summary

One paragraph: what the change does, overall assessment, and the single most important finding.

### Findings

For EACH issue, use this exact format:

```
#### [LAYER] [SEVERITY] Finding title

**Location:** `path/to/file.ts:42-58`

**Description:** Clear explanation of what is wrong and why it matters.

**Options:**
1. **Option A (Recommended):** Description of the fix with code snippet.
2. **Option B:** Alternative approach with trade-offs noted.
3. **Option C:** Minimal fix if time-constrained.
```

Group findings by layer. Within each layer, order by severity (CRITICAL first).

### Validation Commands

List the exact commands the author should run after addressing findings:
```bash
# Lint
npm run lint
# Tests
npm test
# Type check
npx tsc --noEmit
# Build
npm run build
```

## Evals

EVAL 1: Architecture Quality (model-graded)
Question: Does the review accurately assess structural decisions, design patterns, dependency flow, and module boundaries?
Grading prompt: "Analyze the architecture assessment in this review. Does it identify real structural issues? Are the severity classifications justified? Does it miss obvious architectural problems? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 2: Code Quality Assessment (model-graded)
Question: Does the review identify meaningful readability, maintainability, and correctness issues with specific locations and actionable fix options?
Grading prompt: "Analyze the code quality findings. Are issues real and significant (not nitpicks)? Does each finding have a specific file:line location? Are fix options concrete with code snippets? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 3: Test Coverage Check (binary)
Question: Does the review verify whether tests exist and cover the changed code?
Pass: Review includes Layer 3 (Tests) with specific assessment of test existence, coverage gaps, and test quality for the changed code.
Fail: Review skips test assessment or gives only a generic statement like "tests look fine" without specifics.

EVAL 4: Performance Issue Detection (binary)
Question: Does the review check for obvious performance problems?
Pass: Review includes Layer 4 (Performance) and either identifies specific performance concerns with locations or explicitly confirms no issues found with evidence.
Fail: Review omits performance analysis or waves it off without examining the code.

EVAL 5: Actionable Fix Options (binary)
Question: Does every finding include at least 2 concrete resolution options?
Pass: Every finding in the review has 2+ options with code snippets and a recommended choice.
Fail: Any finding lacks multiple options or provides vague suggestions without code.

Target: 85%+ combined score. Max 3 revision loops.

## Example

### Input

User says: "Review this function I wrote"

```typescript
// src/utils/fetchUser.ts
export async function fetchUser(id: any) {
  const res = await fetch(`/api/users/${id}`);
  const data = await res.json();
  return data;
}
```

### Output

#### Summary

This function fetches a user by ID from an API endpoint. It lacks type safety, error handling, and input validation. Three critical issues must be addressed before merging.

#### Findings

#### [Code Quality] [CRITICAL] No error handling for failed HTTP responses

**Location:** `src/utils/fetchUser.ts:3-4`

**Description:** If the API returns a 404 or 500 status, `res.json()` may throw or return an error body that is silently treated as valid data. Callers will receive garbage data with no indication of failure.

**Options:**
1. **(Recommended) Check `res.ok` and throw a typed error:**
   ```typescript
   if (!res.ok) {
     throw new ApiError(`Failed to fetch user ${id}`, res.status);
   }
   ```
2. **Return a Result type** that wraps success/failure:
   ```typescript
   return res.ok ? { ok: true, data } : { ok: false, status: res.status };
   ```
3. **Minimal: add a status check and return null on failure:**
   ```typescript
   if (!res.ok) return null;
   ```

#### [Code Quality] [CRITICAL] Parameter typed as `any`

**Location:** `src/utils/fetchUser.ts:2`

**Description:** The `id` parameter is typed as `any`, which disables all type checking at the call site. A caller could pass an object, undefined, or a function without any compiler warning.

**Options:**
1. **(Recommended) Type as `string`** since URL path segments are strings:
   ```typescript
   export async function fetchUser(id: string): Promise<User> {
   ```
2. **Type as `string | number`** if numeric IDs are used and coerce in the URL:
   ```typescript
   export async function fetchUser(id: string | number): Promise<User> {
   ```

#### [Tests] [WARNING] No test coverage

**Location:** `src/utils/fetchUser.ts` (entire file)

**Description:** This function has zero tests. At minimum, test the happy path and the error path.

**Options:**
1. **(Recommended) Add tests using msw or a fetch mock:**
   ```typescript
   describe('fetchUser', () => {
     it('returns user data on success', async () => { /* ... */ });
     it('throws ApiError on 404', async () => { /* ... */ });
     it('throws ApiError on 500', async () => { /* ... */ });
   });
   ```

#### [Performance] [SUGGESTION] No request timeout

**Location:** `src/utils/fetchUser.ts:3`

**Description:** The fetch call has no timeout. If the server hangs, the caller hangs indefinitely.

**Options:**
1. **(Recommended) Use AbortSignal.timeout:**
   ```typescript
   const res = await fetch(`/api/users/${id}`, { signal: AbortSignal.timeout(5000) });
   ```

#### Validation Commands

```bash
npx tsc --noEmit
npx eslint src/utils/fetchUser.ts
npx jest --findRelatedTests src/utils/fetchUser.ts
```

#### Score

| Dimension      | Score | Rationale                                         |
|----------------|-------|----------------------------------------------------|
| Correctness    | 3/10  | No error handling means incorrect behavior on failure |
| Completeness   | 4/10  | Missing types, tests, and validation               |
| Depth          | 8/10  | Review covered all 4 layers thoroughly              |
| Actionability  | 9/10  | Every finding has concrete fix options with code    |
| **Average**    | 6/10  | **NEEDS REVISION**                                  |

## Rules

- Don't approve code with zero tests for new public functions.
- Don't skip a review layer, even if it seems irrelevant.
- Provide at least 2 options for each finding.
- Run lint and test commands when the project supports them.
- Run evals at the end of the review.
- If the diff is empty or there are no changes to review, say so immediately and stop.
- If the user asks to "just check one thing," STILL run the full 4-layer protocol but note which layer was the user's focus.
