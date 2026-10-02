---
name: refactor
description: "Trigger on 'refactor', 'clean up', 'improve this code', 'simplify', 'make this more readable', 'reduce complexity', 'extract', 'restructure', 'tech debt'. Demands elegance for non-trivial changes. Applies named refactoring patterns with mandatory before/after comparison and test verification. Skips trivial changes. Do not use for debugging (use /debug if installed), code reviews (use /code-review if installed), or adding new features."
---

# Refactor Skill

## Purpose

Improve code structure, readability, and maintainability WITHOUT changing external behavior. Every refactoring must preserve all existing tests. Don't refactor and change behavior in the same step. If behavior changes are needed, do them in a SEPARATE commit after the refactoring is verified green.

## Scope Gate: Trivial vs. Non-Trivial

BEFORE starting any refactoring work, evaluate whether it is worth the effort.

### Skip refactoring if:
- The change is fewer than 5 lines of code
- The code is in a file that is scheduled for deletion
- The code has no tests and adding tests is out of scope (flag this instead)
- The "improvement" is purely stylistic and the project has an autoformatter

### Proceed with refactoring if:
- A function exceeds 30 lines
- Cyclomatic complexity is above 10
- The same logic appears in 3+ places
- A function takes more than 4 parameters
- Nested conditionals go 3+ levels deep
- Type safety is compromised (`any`, unchecked casts, loose types)
- Names are misleading or ambiguous
- A module has mixed responsibilities

When skipping, say explicitly: "This change is too small to benefit from structured refactoring. Applying the fix directly."

## Context Gathering

1. **Read the code to be refactored.** Understand its purpose, inputs, outputs, and side effects completely before touching it.

2. **Identify all callers.** Search for every usage of the function, class, or module being refactored using the Grep tool (pattern: `functionName`, path: `src/`). Don't refactor a public API without understanding all call sites.

3. **Run the existing test suite** to establish a green baseline:
   ```bash
   npm test 2>&1 | tail -20
   pytest 2>&1 | tail -20
   go test ./... 2>&1 | tail -20
   cargo test 2>&1 | tail -20
   ```
   If tests are NOT green before refactoring, STOP. Fix failing tests first. Don't refactor on a red test suite.

4. **Check for linter configuration** to ensure the refactored code conforms. Use the Glob tool to find lint config files (e.g., pattern `.eslintrc*`, `ruff.toml`, `.golangci.yml`, `.rubocop.yml`).

## Core Process: Refactoring Categories

Name the refactoring pattern you are applying. This creates shared vocabulary and makes the change reviewable. Use the categories below.

### Category 1: Extract Method

**When:** A block of code inside a function does one coherent thing and the function is too long.

**Process:**
1. Identify the block and its inputs (variables read) and outputs (variables written).
2. Create a new function with a descriptive name that captures the WHAT, not the HOW.
3. Replace the block with a call to the new function.
4. Ensure the original function's behavior is identical.

**Before:**
```typescript
function processOrder(order: Order) {
  // validate
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (!order.customerId) {
    throw new Error('Order must have a customer');
  }
  if (order.items.some(item => item.quantity <= 0)) {
    throw new Error('All items must have positive quantity');
  }

  // calculate total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  if (order.discount) {
    total *= (1 - order.discount);
  }

  return { ...order, total, status: 'processed' };
}
```

**After:**
```typescript
function validateOrder(order: Order): void {
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (!order.customerId) {
    throw new Error('Order must have a customer');
  }
  if (order.items.some(item => item.quantity <= 0)) {
    throw new Error('All items must have positive quantity');
  }
}

function calculateOrderTotal(items: OrderItem[], discount?: number): number {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  return discount ? subtotal * (1 - discount) : subtotal;
}

function processOrder(order: Order) {
  validateOrder(order);
  const total = calculateOrderTotal(order.items, order.discount);
  return { ...order, total, status: 'processed' };
}
```

### Category 2: Rename

**When:** A name is misleading, ambiguous, or does not match the current behavior.

**Process:**
1. Identify ALL usages across the codebase (code, tests, docs, config).
2. Choose a name that is specific, accurate, and follows project conventions.
3. Apply the rename everywhere atomically.
4. Run tests to confirm nothing broke.

**Rules:**
- Functions: use verb phrases (`getUserById`, not `user` or `data`)
- Booleans: use `is`/`has`/`should` prefix (`isValid`, not `valid`)
- Collections: use plural nouns (`users`, not `userList`)
- Don't use abbreviations unless they are universal (`id`, `url`, `http`)

### Category 3: Simplify Conditional

**When:** Nested if/else chains, complex boolean expressions, or switch statements with fallthrough.

**Techniques:**
- **Guard clauses:** Replace nested ifs with early returns.
- **Lookup tables:** Replace switch/case with object maps.
- **Boolean extraction:** Extract complex conditions into named boolean variables.
- **Polymorphism:** Replace type-checking conditionals with polymorphic dispatch.

**Before:**
```typescript
function getDiscount(user: User): number {
  if (user.type === 'premium') {
    if (user.years > 5) {
      return 0.20;
    } else {
      return 0.10;
    }
  } else if (user.type === 'business') {
    if (user.employees > 100) {
      return 0.25;
    } else {
      return 0.15;
    }
  } else {
    return 0;
  }
}
```

**After:**
```typescript
const DISCOUNT_TABLE: Record<string, (user: User) => number> = {
  premium: (user) => user.years > 5 ? 0.20 : 0.10,
  business: (user) => user.employees > 100 ? 0.25 : 0.15,
};

function getDiscount(user: User): number {
  const calculator = DISCOUNT_TABLE[user.type];
  return calculator ? calculator(user) : 0;
}
```

### Category 4: Remove Duplication

**When:** The same logic (not just similar-looking code) exists in 2+ places.

**Process:**
1. Confirm the duplication is TRUE duplication (same intent, not coincidental similarity).
2. Extract the shared logic into a single function or module.
3. Replace all duplicate sites with calls to the shared function.
4. Verify each call site still works correctly with the shared version.

**Warning:** Do not merge code that looks similar but serves different business purposes. Two functions that happen to have similar implementations today may diverge tomorrow.

### Category 5: Improve Types

**When:** Types are too loose (`any`, `object`, `unknown` without narrowing, excessive type assertions).

**Process:**
1. Identify the actual shape of the data at runtime.
2. Define precise types or interfaces.
3. Replace loose types with precise ones.
4. Fix any type errors that surface (these are bugs you just found).

**Before:**
```typescript
function handleEvent(event: any) {
  if (event.type === 'click') {
    processClick(event.x, event.y);
  } else if (event.type === 'keypress') {
    processKey(event.key);
  }
}
```

**After:**
```typescript
interface ClickEvent { type: 'click'; x: number; y: number; }
interface KeypressEvent { type: 'keypress'; key: string; }
type AppEvent = ClickEvent | KeypressEvent;

function handleEvent(event: AppEvent) {
  switch (event.type) {
    case 'click':
      processClick(event.x, event.y);
      break;
    case 'keypress':
      processKey(event.key);
      break;
  }
}
```

## Validation: Before/After Test Loop

This is MANDATORY for every refactoring. No exceptions.

```
1. Run tests BEFORE refactoring -> record result (must be green)
   npm test 2>&1 | tail -5

2. Apply refactoring

3. Run tests AFTER refactoring -> compare result (must still be green)
   npm test 2>&1 | tail -5

4. Run linter AFTER refactoring -> confirm no new warnings
   npm run lint 2>&1 | tail -10

5. If tests fail -> REVERT the refactoring and investigate why
   git checkout -- <file>
```

Don't merge a refactoring that breaks tests. If tests break, the refactoring changed behavior, which means it is NOT a refactoring -- it is a rewrite. Treat it differently.

## Output Format

Structure refactoring output as follows:

### Refactoring Summary

```
**Pattern:** <named category from above>
**Scope:** <file(s) and function(s) affected>
**Rationale:** <why this refactoring improves the code>
**Risk:** Low / Medium / High (based on number of call sites and test coverage)
```

### Before/After Comparison

Show the COMPLETE before and after code for the refactored section. Do not truncate.

### Test Verification

```
**Tests before:** X passed, 0 failed
**Tests after:** X passed, 0 failed
**Lint after:** 0 errors, 0 warnings
**Behavior change:** None (verified by tests)
```

## Example

### Input

User says: "Clean up this function, it's hard to read"

```python
def process(d):
    r = []
    for i in d:
        if i['type'] == 'a':
            if i['val'] > 0:
                r.append(i['val'] * 2)
            else:
                r.append(0)
        elif i['type'] == 'b':
            if i['val'] > 0:
                r.append(i['val'] * 3)
            else:
                r.append(0)
    return r
```

### Output

**Refactoring Summary**

| Field | Value |
|-------|-------|
| Pattern | Rename + Simplify Conditional + Improve Types |
| Scope | `process` function |
| Rationale | Names are cryptic, conditional logic is nested and duplicated, no type hints |
| Risk | Low (single function, assuming tests exist) |

**Before/After**

```python
from dataclasses import dataclass
from typing import Literal

@dataclass
class Item:
    type: Literal['a', 'b']
    val: float

MULTIPLIERS = {'a': 2, 'b': 3}

def compute_weighted_values(items: list[Item]) -> list[float]:
    return [
        item.val * MULTIPLIERS[item.type] if item.val > 0 else 0
        for item in items
    ]
```

**Verification:**
```bash
pytest tests/test_process.py -v
# Before: 4 passed
# After:  4 passed (updated import name)
```

## Evals

EVAL 1: Behavior Preservation (binary)
Question: Did all existing tests pass before AND after the refactoring with zero failures?
Pass: Test suite was run before and after refactoring, both runs are green, and results are shown in the output.
Fail: Tests were not run before or after, or any test failed after the refactoring.

EVAL 2: Pattern Naming (binary)
Question: Is the refactoring pattern explicitly named using a recognized category (Extract Method, Rename, Simplify Conditional, Remove Duplication, Improve Types)?
Pass: Output states the specific pattern name and the rationale for choosing it.
Fail: Refactoring was applied without naming the pattern, or a vague label like "cleanup" was used.

EVAL 3: Code Quality Improvement (model-graded)
Question: Does the refactored code meaningfully improve readability, maintainability, or type safety compared to the original?
Grading prompt: "Compare the before and after code. Is the improvement clear and significant? Does it reduce complexity, improve naming, tighten types, or eliminate duplication? Or is the change cosmetic with marginal benefit? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Before/After Comparison (binary)
Question: Is a complete before/after code comparison provided in the output?
Pass: Both the original and refactored code are shown in full (not truncated) with a clear diff or side-by-side.
Fail: Before/after comparison is missing, incomplete, or only shows the after state.

EVAL 5: Scope Appropriateness (model-graded)
Question: Is the refactoring appropriately scoped -- not too large (rewrite) and not too small (trivial)?
Grading prompt: "Analyze the scope of this refactoring. Is it a single, focused change or did it sprawl across unrelated concerns? Did it avoid mixing behavior changes with structural changes? Is it too trivial to warrant structured refactoring? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't refactor and change behavior simultaneously.
- Don't refactor without a green test suite as your starting point.
- Name the refactoring pattern you are applying.
- Show before/after comparison for the changed code.
- Run tests before AND after.
- SKIP structured refactoring for changes under 5 lines -- just apply the fix.
- If the code has no tests, flag this as a risk and recommend adding tests BEFORE refactoring. Do not refuse to refactor, but warn the user that safety is reduced.
- PREFER small, incremental refactorings over large rewrites. Each step should be independently verifiable.
