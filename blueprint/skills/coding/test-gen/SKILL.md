---
name: test-gen
description: "Trigger on 'write tests', 'generate tests', 'add tests', 'test this', 'cover this', 'missing tests', 'increase coverage', 'edge cases', 'unit test', 'test coverage'. Generates edge-case-focused tests by analyzing code for boundary conditions, null inputs, error paths, race conditions, and type coercion traps. Covers more than the happy path. Do not use for code reviews (use /code-review if installed) or debugging (use /debug if installed)."
---

# Test Generation Skill

## Purpose

Generate thorough, edge-case-focused tests by systematically analyzing the code under test. Don't produce tests that only cover the happy path. Every test suite generated must include boundary conditions, error paths, and at least one adversarial input. All generated tests must be executed and verified to pass.

## Context Gathering

### Step 1: Identify the code under test

Read the function, class, or module the user wants tested. Understand:
- **Inputs:** All parameters, their types, and valid ranges
- **Outputs:** Return type, possible return values, side effects
- **Dependencies:** External calls (database, API, filesystem, clock)
- **Error paths:** Exceptions thrown, error codes returned, validation failures

Use the Glob tool to find existing tests for context on test style and framework (patterns: `**/*.test.*`, `**/*.spec.*`, `**/test_*`).

### Step 2: Detect the test framework

Identify what test framework and assertion library the project uses:

Use the Grep tool to detect the test framework:
- JavaScript/TypeScript: search for `jest|vitest|mocha|ava|tap` in `package.json`
- Python: search for `pytest|unittest|nose` in `pyproject.toml`, `setup.cfg`, or `requirements*.txt`
- Go: use the Glob tool with pattern `**/*_test.go` to confirm built-in testing package usage
- Rust: use the Grep tool to search for `[dev-dependencies]` in `Cargo.toml`

Match the existing test style. If the project uses `describe`/`it` blocks, use those. If it uses `test()`, use that. Don't introduce a different test style than what exists.

### Step 3: Find existing tests

Read existing tests for the same module or related modules to understand:
- Naming conventions (`should return...`, `when X, then Y`, `test_function_name_condition`)
- Setup/teardown patterns (beforeEach, fixtures, factory functions)
- Mocking approach (jest.mock, unittest.mock, testify.mock, gomock)
- Assertion style (expect/toBe, assert, require)

## Core Process: Edge Case Analysis

BEFORE writing any test, perform a systematic analysis of the code to identify test cases. Use this checklist for EVERY function.

### Analysis Checklist

#### 1. Boundary Conditions
- What happens at the minimum valid input? (0, 1, empty string, single element)
- What happens at the maximum valid input? (MAX_INT, very long string, huge array)
- What happens at the boundary between valid and invalid? (exactly at limit)
- Off-by-one: what about `n-1`, `n`, `n+1` where `n` is a boundary?

#### 2. Null / Empty / Missing Inputs
- What if a required parameter is `null` or `undefined`?
- What if a string parameter is empty `""`?
- What if an array parameter is empty `[]`?
- What if an object parameter is missing expected keys?
- What if optional parameters are omitted?

#### 3. Error Paths
- What exceptions can the function throw? Test each one.
- What happens when a dependency fails? (network error, database timeout, file not found)
- What happens with invalid input types? (string where number expected, if dynamically typed)
- What happens when preconditions are violated?

#### 4. Race Conditions (for async code)
- What if two calls happen concurrently?
- What if a dependency resolves out of order?
- What if a timeout occurs mid-operation?
- What if the caller cancels or aborts?

#### 5. Type Coercion Traps (for dynamically typed languages)
- What happens with `0` vs `false` vs `null` vs `undefined` vs `""`?
- What happens with `"0"` vs `0`?
- What happens with `NaN`?
- What if an array is passed where an object is expected?

#### 6. State-Dependent Behavior
- What if the function is called twice in a row?
- What if internal state is in an unexpected condition?
- What if the function is called before initialization completes?

### Test Case Matrix

After analysis, build a test case matrix:

```
| # | Category       | Input                  | Expected Output         | Why |
|---|----------------|------------------------|-------------------------|-----|
| 1 | Happy path     | valid typical input    | normal output           | baseline |
| 2 | Boundary low   | minimum valid input    | correct edge output     | off-by-one |
| 3 | Boundary high  | maximum valid input    | correct edge output     | overflow |
| 4 | Empty input    | empty string/array     | defined behavior        | null safety |
| 5 | Null input     | null/undefined param   | error or default        | robustness |
| 6 | Error path     | triggers known error   | correct error thrown    | error handling |
| 7 | Adversarial    | malicious/weird input  | safe behavior           | security |
```

Generate at least 5 test cases. For complex functions, generate 10+.

## Test Writing Rules

1. **One assertion per test** (or one logical assertion group). A test named "handles empty input" should test exactly that.

2. **Descriptive names.** The test name must describe the scenario AND the expected outcome:
   - GOOD: `it('returns empty array when input array is empty')`
   - BAD: `it('test empty')`
   - GOOD: `def test_raises_value_error_when_amount_is_negative()`
   - BAD: `def test_negative()`

3. **Arrange-Act-Assert** structure. Separate setup, execution, and verification:
   ```typescript
   it('returns 0 when cart has no items', () => {
     // Arrange
     const cart = createCart({ items: [] });

     // Act
     const total = calculateTotal(cart);

     // Assert
     expect(total).toBe(0);
   });
   ```

4. **No test interdependence.** Each test must work in isolation. Don't rely on execution order.

5. **Mock external dependencies.** Database calls, HTTP requests, filesystem access, timers -- all must be mocked. Don't let tests make real network calls.

6. **Use factory functions** for test data, not raw object literals copied everywhere:
   ```typescript
   function createUser(overrides: Partial<User> = {}): User {
     return { id: '1', name: 'Test User', email: 'test@test.com', ...overrides };
   }
   ```

## Validation: Run Generated Tests

Run the generated tests after writing them. This is non-negotiable.

```bash
# JavaScript/TypeScript
npx jest <test_file> --verbose
npx vitest run <test_file>

# Python
pytest <test_file> -v

# Go
go test -v -run <TestFunctionPrefix> ./path/to/package

# Rust
cargo test <test_name> -- --nocapture
```

If ANY generated test fails:
1. Determine if the test is wrong or the code has a bug.
2. If the test is wrong, fix the test and re-run.
3. If the code has a bug, report it to the user and keep the failing test as a bug-documenting test (mark it with `skip` or `todo` and explain why).

Don't silently delete a failing test. Either fix it or document why it fails.

## Output Format

### Test Plan

Present the analysis matrix BEFORE writing code:

```
## Test Plan for `functionName`

### Analysis
- **Inputs:** param1 (string), param2 (number, optional)
- **Output:** Result object or throws ValidationError
- **Dependencies:** DatabaseClient (must mock)

### Cases
1. [Happy] Valid input returns expected result
2. [Boundary] param2 = 0 returns zero-value result
3. [Boundary] param2 = Number.MAX_SAFE_INTEGER handles large numbers
4. [Empty] param1 = "" throws ValidationError
5. [Null] param1 = null throws TypeError
6. [Error] database connection fails, throws ServiceError
7. [Adversarial] param1 contains SQL injection attempt, safely handled
```

### Generated Tests

The complete test file, ready to copy or save.

### Verification

```
**Test run result:** X passed, 0 failed, 0 skipped
**Command used:** <exact command>
```

## Example

### Input

User says: "Write tests for this function"

```typescript
// src/utils/slugify.ts
export function slugify(input: string): string {
  return input
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}
```

### Output

**Test Plan for `slugify`**

| # | Category | Input | Expected | Why |
|---|----------|-------|----------|-----|
| 1 | Happy | `"Hello World"` | `"hello-world"` | Basic space-to-hyphen |
| 2 | Happy | `"Already-Slugged"` | `"already-slugged"` | Idempotent-ish |
| 3 | Boundary | `""` (empty) | `""` | Empty input |
| 4 | Boundary | `"a"` (single char) | `"a"` | Minimal input |
| 5 | Boundary | `"---"` (only hyphens) | `""` | All stripped |
| 6 | Special | `"  leading trailing  "` | `"leading-trailing"` | Whitespace handling |
| 7 | Special | `"hello___world"` | `"hello-world"` | Underscores |
| 8 | Special | `"Hello! @World#"` | `"hello-world"` | Special characters |
| 9 | Unicode | `"cafe\u0301"` | Varies | Accented characters |
| 10 | Adversarial | `"<script>alert('xss')</script>"` | `"scriptalertxssscript"` | HTML stripped |
| 11 | Multi-space | `"multiple   spaces"` | `"multiple-spaces"` | Collapsed |
| 12 | Mixed | `"--My  Post_Title!--"` | `"my-post-title"` | Combined edge cases |

**Generated Tests**

```typescript
// src/utils/__tests__/slugify.test.ts
import { slugify } from '../slugify';

describe('slugify', () => {
  describe('happy path', () => {
    it('converts spaces to hyphens and lowercases', () => {
      expect(slugify('Hello World')).toBe('hello-world');
    });

    it('lowercases already hyphenated input', () => {
      expect(slugify('Already-Slugged')).toBe('already-slugged');
    });

    it('handles multi-word titles', () => {
      expect(slugify('My Blog Post Title')).toBe('my-blog-post-title');
    });
  });

  describe('boundary conditions', () => {
    it('returns empty string for empty input', () => {
      expect(slugify('')).toBe('');
    });

    it('handles single character input', () => {
      expect(slugify('a')).toBe('a');
    });

    it('returns empty string when input is only hyphens', () => {
      expect(slugify('---')).toBe('');
    });

    it('returns empty string when input is only special characters', () => {
      expect(slugify('!@#$%^&*()')).toBe('');
    });
  });

  describe('whitespace handling', () => {
    it('trims leading and trailing whitespace', () => {
      expect(slugify('  leading trailing  ')).toBe('leading-trailing');
    });

    it('collapses multiple spaces into single hyphen', () => {
      expect(slugify('multiple   spaces')).toBe('multiple-spaces');
    });

    it('handles tabs and newlines as spaces', () => {
      expect(slugify("hello\tworld\nnew")).toBe('hello-world-new');
    });
  });

  describe('special characters', () => {
    it('removes special characters', () => {
      expect(slugify('Hello! @World#')).toBe('hello-world');
    });

    it('converts underscores to hyphens', () => {
      expect(slugify('hello___world')).toBe('hello-world');
    });

    it('strips leading and trailing hyphens after processing', () => {
      expect(slugify('--My  Post_Title!--')).toBe('my-post-title');
    });
  });

  describe('adversarial input', () => {
    it('strips HTML tags', () => {
      expect(slugify("<script>alert('xss')</script>")).toBe('scriptalertxssscript');
    });

    it('handles very long input without crashing', () => {
      const longInput = 'word '.repeat(1000);
      const result = slugify(longInput);
      expect(result).toBeTruthy();
      expect(result).not.toContain('  ');
    });
  });
});
```

**Verification:**
```bash
npx jest src/utils/__tests__/slugify.test.ts --verbose
# 12 passed, 0 failed
```

## Evals

EVAL 1: Edge Case Coverage (binary)
Question: Does the generated test suite include at least one boundary condition, one null/empty input, and one error path test?
Pass: Test suite has identifiable tests for boundary, null/empty, and error scenarios -- not just happy paths.
Fail: Test suite only covers happy paths, or is missing any of the three required categories.

EVAL 2: Test Quality (model-graded)
Question: Are the generated tests well-structured, isolated, and following project conventions?
Grading prompt: "Analyze the test suite. Do tests follow Arrange-Act-Assert? Are names descriptive (scenario + expected outcome)? Is each test independent with no shared mutable state? Do they match the project's existing test style and framework? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 3: Tests Execute Successfully (binary)
Question: Were all generated tests run and did they pass?
Pass: Output shows the exact test command used and a result of all tests passing (or failing tests are documented as intentional bug-exposing tests with skip/todo annotations).
Fail: Tests were not run, or failures exist without explanation.

EVAL 4: Analysis Before Code (binary)
Question: Was a test case matrix/plan presented before writing test code?
Pass: A test plan table or analysis listing all planned cases with categories, inputs, and expected outputs was shown before any test code.
Fail: Tests were written without presenting an analysis plan first.

EVAL 5: Adversarial Input Coverage (model-graded)
Question: Does the test suite include genuinely adversarial or unusual inputs that could expose real bugs?
Grading prompt: "Analyze the adversarial and edge-case tests. Are they testing inputs that a real user or attacker might provide? Do they go beyond obvious cases to test type coercion traps, race conditions, or malicious inputs relevant to the function? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't generate only happy-path tests. Every test suite must include at least one boundary, one null/empty, and one error path test.
- Analyze the code BEFORE writing tests. Do not guess at behavior.
- Run generated tests and verify they pass.
- Match the project's existing test style, framework, and conventions.
- Don't write tests that depend on execution order.
- Don't write tests that make real network or database calls.
- Use descriptive test names that state the scenario and expected outcome.
- If the code under test has no clear error handling, write tests that EXPOSE this gap and report it.
- PREFER many small tests over few large tests. Each test should verify one behavior.
- Present the test plan matrix before writing test code so the user can review the approach.
