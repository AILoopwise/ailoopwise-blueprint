---
name: deploy
description: "Trigger on 'deploy', 'ship it', 'release', 'push to production', 'go live', 'publish', 'cut a release', 'deploy to staging', 'deploy to prod'. Executes a 3-phase deployment protocol: pre-deploy checklist, deployment execution, and post-deploy verification. Stops if any pre-flight check fails. Do not use for code reviews (use /code-review if installed) or PR generation (use /pr-gen if installed)."
disable-model-invocation: true
---

# Deploy Skill

Execute a safe, verified deployment through a strict 3-phase protocol: pre-deploy checks, deployment execution, and post-deploy verification. Don't deploy code that fails any pre-flight check. Don't consider a deployment complete without post-deploy verification. Every deployment must be reversible.

## Context Gathering

Before deploying, determine:

1. **Deployment target** — Check for Dockerfile, fly.toml, vercel.json, netlify.toml, serverless.yml, CI/CD configs, or deploy scripts in package.json
2. **Environment** — Staging or production? Check current branch and env-specific configs. Production = MAXIMUM caution, zero exceptions.
3. **Current version** — From package.json, git tags, or CHANGELOG. Compare with last deployed version.

## Phase 1: Pre-Deploy Checklist

EVERY item must pass. A single failure BLOCKS deployment.

### Check 1: All tests pass
Run the full test suite. **FAIL:** Any test failure. Zero tolerance. Fix before deploying.

### Check 2: Linter passes
Run linter (eslint, ruff, clippy). **FAIL:** Any lint error. Warnings are acceptable but noted.

### Check 3: Type checking passes
Run type checker (tsc --noEmit, mypy). **FAIL:** Any type error — they often indicate real bugs.

### Check 4: Build succeeds
Run production build. **FAIL:** Build failure = undeployable artifact.

### Check 5: No secrets in code
```bash
git diff HEAD --cached -- . | grep -iE "(password|secret|api_key|private_key|token)\s*[:=]\s*[\"'][^\"']{8,}" | head -10
git ls-files | grep -E "\.env$|\.env\.(local|production|staging)$"
git ls-files | xargs grep -l "BEGIN.*PRIVATE KEY" 2>/dev/null
```
**FAIL:** Any secret found. Remove it, rotate it (it is now compromised), use env vars or secrets manager.

### Check 6: Version bumped
Compare current version with latest tag. **FAIL:** Same version as last deploy. Bump per semver (patch/minor/major).

### Check 7: Changelog updated
**FAIL:** No changelog entry for new version. Add one before deploying.

### Check 8: Database migrations ready (if applicable)
Check for pending migrations. **FAIL:** Untested migrations. Run in staging first.

### Pre-Deploy Summary

```
| Check        | Status    | Details                  |
|--------------|-----------|--------------------------|
| Tests        | PASS/FAIL | X passed, Y failed       |
| Lint         | PASS/FAIL | N errors, N warnings     |
| Type check   | PASS/FAIL | N errors                 |
| Build        | PASS/FAIL | Build time, artifact size|
| Secrets      | PASS/FAIL | N findings               |
| Version      | PASS/FAIL | vX.Y.Z -> vA.B.C        |
| Changelog    | PASS/FAIL | Updated / Not updated    |
| Migrations   | PASS/FAIL/N/A | N pending            |

**Pre-deploy result:** ALL PASS / BLOCKED (list failures)
```

If ANY check is FAIL, STOP. Do not proceed to Phase 2.

## Phase 2: Deployment Execution

Only proceed if ALL pre-deploy checks pass.

### Step 1: Tag the release
```bash
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"
```

### Step 2: Deploy
Use the project's deployment method (detected in context gathering):
- **PaaS:** `vercel --prod`, `fly deploy`, `railway up`, `netlify deploy --prod`
- **Docker/K8s:** Build image, push to registry, update deployment
- **Serverless:** `npx serverless deploy --stage production`
- **Custom:** `npm run deploy` or project-defined script

### Step 3: Record the deployment
```bash
echo "Deployed v$VERSION at $(date -u +%Y-%m-%dT%H:%M:%SZ) by $(git config user.name)" >> DEPLOY_LOG.md
```

## Phase 3: Post-Deploy Verification

Don't consider deployment complete until all checks pass. If any fails, IMMEDIATELY roll back.

### Check 1: Health check
Hit the health endpoint. **Expected:** HTTP 200. **On failure:** Roll back immediately.

### Check 2: Smoke tests
Test 2-3 critical-path operations against the deployed environment (status endpoint, auth, core business operation). **On failure:** Roll back.

### Check 3: Error rate
Check application logs for error spikes in the first 5 minutes. **On failure:** Investigate, consider rollback.

### Check 4: Version verification
Confirm deployed version matches intended version via version endpoint or build metadata.

### Post-Deploy Summary
```
| Check          | Status    | Details                    |
|----------------|-----------|----------------------------|
| Health check   | PASS/FAIL | HTTP 200, response time Xms|
| Smoke tests    | PASS/FAIL | N/N passed                 |
| Error rate     | PASS/FAIL | X errors/min (baseline: Y) |
| Version check  | PASS/FAIL | Deployed: vX.Y.Z           |

**Post-deploy result:** ALL PASS / ROLLBACK REQUIRED
```

## Rollback Procedure

If ANY post-deploy check fails:
```bash
# Option 1: Platform rollback
fly releases rollback 2>/dev/null
kubectl rollout undo deployment/app 2>/dev/null

# Option 2: Redeploy previous version
git checkout v$PREVIOUS_VERSION && npm run deploy

# Option 3: Revert the git tag
git tag -d "v$VERSION" && git push origin ":refs/tags/v$VERSION"
```

After rollback: verify previous version is running, investigate the failure, fix, and redeploy through the full process.

## Example

### Input
"Deploy to production"

### Output

**Phase 1 Results:**

| Check | Status | Details |
|-------|--------|---------|
| Tests | PASS | 147 passed, 0 failed |
| Lint | PASS | 0 errors |
| Type check | PASS | 0 errors |
| Build | PASS | 12.3s, 245KB |
| Secrets | PASS | Clean |
| Version | PASS | 2.3.1 -> 2.4.0 |
| Changelog | PASS | Updated |
| Migrations | N/A | No DB changes |

**Phase 2:** Tagged v2.4.0, deployed via `fly deploy`.

**Phase 3 Results:**

| Check | Status | Details |
|-------|--------|---------|
| Health | PASS | HTTP 200, 45ms |
| Smoke tests | PASS | 3/3 passed |
| Error rate | PASS | 0 errors / 5 min |
| Version | PASS | v2.4.0 confirmed |

**Deployment complete. v2.4.0 is live.**

## Evals

EVAL 1: Pre-Deploy Checks Complete (binary)
Question: Were all 8 pre-deploy checks executed (tests, lint, type check, build, secrets, version, changelog, migrations)?
Pass: Output shows all 8 checks were run with PASS/FAIL status and details for each.
Fail: Any check was skipped without N/A justification.

EVAL 2: Post-Deploy Verification (binary)
Question: Were post-deploy health check, smoke tests, error rate monitoring, and version verification all performed?
Pass: All 4 post-deploy checks were run with results shown. On any failure, rollback was initiated.
Fail: Post-deploy verification was skipped or incomplete.

EVAL 3: Rollback Readiness (binary)
Question: Was a git tag created before deployment and a rollback plan documented?
Pass: A versioned git tag was pushed before deployment, and the rollback procedure was identified for the deployment platform.
Fail: No tag was created, or no rollback plan was stated.

EVAL 4: Deployment Safety (model-graded)
Question: Was the deployment executed with appropriate caution for the target environment?
Grading prompt: "Analyze the deployment process. Was staging deployed before production (if staging exists)? Were pre-deploy failures treated as blockers (not bypassed)? Was the deployment recorded with version, timestamp, and deployer? Was production treated with maximum caution? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 5: Zero-Downtime Verification (model-graded)
Question: Was the deployment process designed to minimize or eliminate downtime?
Grading prompt: "Analyze the deployment approach. Does the platform support rolling deploys or blue-green? Were health checks configured with appropriate thresholds? Was the transition smooth or was there a gap? Were error rates monitored during the transition window? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Rules

- Don't deploy if any pre-deploy check fails. Zero exceptions.
- Don't skip post-deploy verification. A deployment is not done until verified.
- Create a git tag before deploying so rollback is possible.
- Have a rollback plan before starting deployment.
- If deploying to production, always deploy to staging first if staging exists.
- Don't deploy on Fridays or before holidays unless critical and pre-approved.
- If the user says "just deploy, skip the checks," REFUSE. Pre-deploy checks are non-negotiable.
- Record what was deployed, when, and by whom.
- If rollback is needed, execute it IMMEDIATELY. Do not debug in production with broken code running.
