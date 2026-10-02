---
name: security-audit
description: "Trigger on 'security audit', 'security review', 'check for vulnerabilities', 'is this secure', 'security scan', 'pentest', 'hardening', 'OWASP', 'CVE', 'vulnerability'. Performs a checklist-based security audit across 8 categories: injection, auth, secrets, dependencies, CORS, rate limiting, input validation, error handling. Pass/fail per category. Do NOT use for general code reviews (use /code-review if installed) or debugging (use /debug if installed)."
---

# Security Audit Skill

Perform a systematic security audit using an 8-category checklist. Every category receives a PASS or FAIL grade with specific findings. Don't give blanket assurances like "looks secure." Cite specific code locations for every finding. This is a code-level audit, not a penetration test.

## Context Gathering

1. **Application type** — Identify framework (Express, Django, Rails, Gin) and frontend (React, Vue, Angular)
2. **Attack surface** — Map all entry points: API routes, form handlers, file uploads, WebSocket endpoints
3. **Auth code** — Locate authentication middleware, JWT config, session handling, role/permission checks
4. **Dependency health** — Run `npm audit`, `pip-audit`, `govulncheck`, or `cargo audit`

## Core Process: 8-Category Security Checklist

Audit EVERY category. Don't skip one — mark as N/A with justification if truly not applicable.

### Category 1: Injection (SQL, XSS, Command)

**SQL Injection** — Search for raw SQL with string interpolation or concatenation.
- FAIL: User input in raw queries without parameterized statements
- PASS: All queries use bound parameters (`$1`, `?`, `:param`) or ORM query builders

**XSS** — Search for `dangerouslySetInnerHTML`, `innerHTML`, `v-html`, `mark_safe`, unescaped templates.
- FAIL: User content rendered as raw HTML without sanitization
- PASS: All user content escaped by default or sanitized (DOMPurify, bleach)

**Command Injection** — Search for `exec(`, `spawn(`, `system(`, `subprocess.`, `child_process`.
- FAIL: User input passed to shell execution without sanitization
- PASS: Shell commands use array-form arguments, input validated against allowlist

### Category 2: Authentication / Authorization

**Authentication** — Check password hashing, JWT config, session cookie flags.
- FAIL: Plaintext/weak hashing (MD5, SHA1), hardcoded JWT secret, no JWT expiry, missing cookie security flags, no brute-force protection
- PASS: bcrypt/argon2/scrypt, env-loaded secrets, reasonable expiry, all cookie flags set

**Authorization** — Check endpoint protection and resource ownership verification.
- FAIL: Admin endpoints lack role checks, no IDOR protection, unprotected API endpoints
- PASS: All non-public endpoints require auth, resource ownership verified, RBAC consistently applied

### Category 3: Secrets Management

Search for hardcoded secrets, committed `.env` files, secrets in git history.
- FAIL: API keys/passwords hardcoded, `.env` committed, `.gitignore` missing `.env` entries, secrets in logs
- PASS: All secrets from env vars or secrets manager, `.env` gitignored, clean git history

### Category 4: Dependency Vulnerabilities

Run the appropriate audit tool for the language.
- FAIL: Any CRITICAL/HIGH CVE with available fix, 2+ major versions outdated, missing lock file
- PASS: No known critical/high vulns, lock file present and committed

### Category 5: CORS Configuration

Search for CORS setup and `Access-Control-Allow-Origin`.
- FAIL: Wildcard `*` with credentials, origin reflected without validation, overly permissive methods
- PASS: Origins explicitly allowlisted, credentials only with specific origins, env-specific config

### Category 6: Rate Limiting

Search for rate limiting middleware.
- FAIL: No rate limits on auth endpoints (login, register, password reset), no limits on expensive operations, client-side only
- PASS: Auth endpoints aggressively limited, API endpoints reasonably limited, server-side enforcement

### Category 7: Input Validation

Check for validation libraries (Zod, Joi, Pydantic) and manual validation.
- FAIL: Raw user input without validation, no file upload limits, no numeric bounds, no body size limit
- PASS: Schema validation on all API inputs, file uploads restricted, body size limited

### Category 8: Error Handling (Information Leakage)

Search for stack traces, detailed errors, debug mode in production config.
- FAIL: Stack traces sent to clients, internal details in API responses, debug mode in production
- PASS: Generic client errors, detailed logging server-side only, debug disabled in production

## Output Format

### Audit Summary

```
| Category                | Status | Findings |
|-------------------------|--------|----------|
| 1. Injection            | PASS/FAIL | N critical, N warnings |
| 2. Auth/AuthZ           | PASS/FAIL | N critical, N warnings |
| 3. Secrets Management   | PASS/FAIL | N critical, N warnings |
| 4. Dependencies         | PASS/FAIL | N critical, N warnings |
| 5. CORS                 | PASS/FAIL | N critical, N warnings |
| 6. Rate Limiting        | PASS/FAIL | N critical, N warnings |
| 7. Input Validation     | PASS/FAIL | N critical, N warnings |
| 8. Error Handling       | PASS/FAIL | N critical, N warnings |

**Overall:** X/8 passed
**Critical findings:** N
**Recommendation:** PASS / NEEDS REMEDIATION / BLOCK DEPLOYMENT
```

### Detailed Findings

For each FAIL, list every finding with:
- **Location:** `path/to/file.ts:42`
- **Evidence:** Code snippet or command output showing the vulnerability
- **Risk:** What an attacker could do
- **Fix:** Specific remediation steps with code

## Example

### Input
"Run a security audit on this Express app"

### Output (abbreviated)

| Category | Status | Findings |
|----------|--------|----------|
| 1. Injection | FAIL | 1 critical (SQL) |
| 2. Auth/AuthZ | FAIL | 1 critical (IDOR), 1 warning (JWT expiry) |
| 3. Secrets | PASS | 0 |
| 4. Dependencies | FAIL | 2 high CVEs |
| 5. CORS | PASS | 0 |
| 6. Rate Limiting | FAIL | 1 critical (no limit on /login) |
| 7. Input Validation | WARNING | 1 warning (no body size limit) |
| 8. Error Handling | FAIL | 1 critical (stack traces exposed) |

**Overall:** 2/8 passed. **BLOCK DEPLOYMENT.**

#### [Injection] [CRITICAL] SQL injection in user search
**Location:** `src/routes/users.ts:27`
**Evidence:** `db.query(\`SELECT * FROM users WHERE name LIKE '%${req.query.q}%'\`)`
**Risk:** Full database extraction, data modification, or system command execution
**Fix:** Use parameterized query: `db.query('SELECT * FROM users WHERE name LIKE $1', [\`%${req.query.q}%\`])`

## Evals

EVAL 1: Category Coverage (binary)
Question: Were all 8 security categories audited (or explicitly marked N/A with justification)?
Pass: Output includes a status for all 8 categories: Injection, Auth/AuthZ, Secrets, Dependencies, CORS, Rate Limiting, Input Validation, Error Handling.
Fail: Any category is missing from the audit without N/A justification.

EVAL 2: Evidence Quality (binary)
Question: Does every FAIL finding cite a specific file path, line number, and code snippet as evidence?
Pass: Every critical or high finding includes `path/to/file:line`, the vulnerable code, and the risk explanation.
Fail: Any FAIL finding is vague or lacks specific file/line references.

EVAL 3: Finding Depth (model-graded)
Question: Are the security findings accurate, significant, and not false positives?
Grading prompt: "Analyze the security findings. Are they real vulnerabilities or false positives? Are severity levels (CRITICAL, WARNING) appropriate? Are important issues missed? Does the audit go beyond surface-level checks to find subtle vulnerabilities? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Remediation Quality (model-graded)
Question: Does every CRITICAL finding include a concrete, correct fix with code?
Grading prompt: "Analyze the remediation advice for critical findings. Is each fix specific with a code snippet? Would the fix actually resolve the vulnerability without introducing new issues? Are alternative approaches mentioned where appropriate? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 5: Dependency Scan Executed (binary)
Question: Was an automated dependency vulnerability scanner run (npm audit, pip-audit, govulncheck, cargo audit)?
Pass: Output shows the scanner command was executed and results were reported.
Fail: No dependency scanner was run, or results were not shown.

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't skip a category. Mark as N/A with justification if truly not applicable.
- Don't give a PASS without running the corresponding checks.
- Cite specific file paths and line numbers for every finding.
- Provide a concrete fix for every CRITICAL finding.
- Run `npm audit` or equivalent dependency scanner when available.
- Don't say "the code looks secure" without completing all 8 categories.
- Recommend blocking deployment if any CRITICAL injection, auth, or secrets finding exists.
- TREAT this audit as a minimum baseline. Recommend external penetration testing for production systems.
