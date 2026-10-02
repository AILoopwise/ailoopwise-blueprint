# Skill Writing Guide

Rules for creating Claude skills that work on Claude.ai, Claude Code, and the API. Based on Anthropic's official spec (2026) plus our quality additions.

---

## Folder Structure

```
skill-name/                    # kebab-case, must match `name` field
├── SKILL.md                   # Required — exact name, case-sensitive
├── scripts/                   # Optional — deterministic code
├── references/                # Optional — docs loaded on demand
└── assets/                    # Optional — templates, output files
```

**Forbidden inside skill folders:**
- README.md, CHANGELOG.md, INSTALLATION_GUIDE.md
- .claude-plugin/plugin.json
- Any file not needed by the AI agent to perform its job

**Pack structure** (when grouping skills by domain):
```
domain-name/
├── skill-one/SKILL.md         # Each skill independently installable
├── skill-one/reference/       # Its own copies of any shared checklist or rubric
└── skill-two/SKILL.md
```
Agents live in `blueprint/agents/`, hooks in `blueprint/hooks/`. A skill that needs a shared
reference file carries its own copy, so it still works when copied on its own.

---

## YAML Frontmatter

```yaml
---
name: skill-name        # kebab-case, max 64 chars, matches the folder name
description: "What it does, in one or two sentences."
when_to_use: "When to use it: trigger phrases, and when not to (use other-skill instead)."
---
```

`name` and `description` are the portable core (Claude.ai, API, Claude Code). Claude Code
(https://code.claude.com/docs/en/skills) also reads these optional fields; use one only when it clearly helps:

| Field | Use it for |
|---|---|
| `when_to_use` | Trigger phrases and exclusions, so `description` stays short. Claude Code shows description + when_to_use together, cut at 1,536 characters |
| `disable-model-invocation: true` | Skills with side effects (deploy, commit, start a loop): they only run when the user types `/name` |
| `user-invocable: false` | Background knowledge Claude may load, but that makes no sense as a `/command` |
| `allowed-tools` | Tools the skill may use without asking each time |
| `paths` | Only offer the skill when matching files are involved |
| `arguments` / `argument-hint` | Named arguments for `/name arg` |
| `model`, `effort` | Run the skill with a specific model or effort level |
| `context: fork`, `agent` | Run the skill in a subagent instead of the main conversation |
| `hooks` | Hooks that apply only while the skill runs |

### Name Rules
- kebab-case only: `code-review` not `codeReview` or `Code Review`
- No "claude" or "anthropic" prefix (reserved)
- Must match parent folder name exactly

### Description Rules (Most Important Field)
The description (plus `when_to_use`) is how Claude decides to load the skill. The body only loads after that.

**Structure:** what it does + when to use it + trigger phrases + when not to use it

**Good:**
```yaml
description: >
  4-layer code review covering architecture, code quality, tests, and performance.
  Use when reviewing PRs, auditing code, or checking code quality.
  Trigger on "review this PR", "code review", "check my code".
  Do not use for debugging (use debug) or writing tests (use test-gen).
```

**Bad:**
```yaml
description: Helps with code.              # Too vague, won't trigger
description: Implements review protocol.   # No user-facing triggers
```

---

## SKILL.md Body

**Target: under 500 lines.** Move verbose content to `references/`.

### Standard Structure

```markdown
---
[frontmatter]
---

# Skill Name

## Persona
[4-6 lines defining domain expert role. Not needed for coding skills.]

## Step 1: Context Gathering
[What to check, what to ask the user]

## Step 2: Core Process
[Numbered steps, methodology, frameworks]

## Evals
[3-6 hybrid evals: binary for structural, model-graded for semantic]

## Step 4: Output Format
[Exact deliverable structure]

## Examples
[Realistic input/output pairs with scores]

## Rules
[Hard constraints, common mistakes]
```

### Writing Rules
- Use imperative/infinitive form ("Run the linter", not "You should run the linter")
- Be specific and actionable, not vague
- Put critical instructions at the top
- Use numbered steps, bullet points, tables — not prose paragraphs
- Reference scripts by relative path: `scripts/validate.py`
- Reference docs by relative path: `references/checklist.md`

---

## Quality Evaluation

Give every skill 3-6 eval criteria using the hybrid system below.

### Binary Evals (for structural/deterministic checks)
Use for anything objectively testable: format, length, section presence, syntax validity.

```
EVAL [N]: [Short name] (binary)
Question: [Yes/no question about the output]
Pass: [What "yes" looks like]
Fail: [What triggers "no"]
```

### Model-Graded Evals (for semantic/quality checks)
Use for qualities that exist on a spectrum: thoroughness, relevance, clarity.
The grader writes its reasoning before the score (this prevents default middling scores).

```
EVAL [N]: [Short name] (model-graded)
Question: [What quality to assess]
Grading prompt: "Analyze [specific aspect]. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7
```

### Combined Score
`combined_score = (binary_pass_rate + model_score_avg_normalized) / 2`
Target: 85%+ combined score

### Rules
- 3-6 evals per skill (more = Goodhart's Law)
- Binary for anything two agents would score identically
- Model-graded for anything that's genuinely a spectrum
- Model graders reason before scoring (no score-only grading)
- Specific enough to be consistent, not so narrow the skill can game it
- Max 3 revision loops before delivering

See `autoresearch/references/eval-guide.md` for detailed examples.

---

## Progressive Disclosure

Three levels, each loaded only when needed:

| Level | What | Token Cost | When Loaded |
|-------|------|-----------|-------------|
| 1. Frontmatter | name + description | ~100 tokens | Always (every turn) |
| 2. SKILL.md body | Instructions | <5000 tokens | When skill triggers |
| 3. References | Detailed docs | Unlimited | When Claude navigates to them |

**Rule:** If SKILL.md approaches 500 lines, split content:
- Keep core workflow in SKILL.md
- Move checklists, rubrics, examples to `references/`
- Link clearly: "See `references/checklist.md` for the full audit list"

---

## Workflow vs Agent Decision Framework

Default to workflows (skills). Use agents only when task steps aren't known in advance.

| | Workflow (Skill) | Agent |
|---|---|---|
| Steps | Predetermined | Dynamic |
| Reliability | Higher | Lower |
| Testability | Easier (known path) | Harder (unpredictable path) |
| Use when | Steps known | Steps unclear |

### Workflow Patterns
- **Evaluator-Optimizer:** Producer generates output → evaluator scores it → loop until quality threshold met. (Example: autoresearch)
- **Parallelization:** Break task into independent subtasks → run in parallel → aggregate. (Example: code-review checking architecture/quality/tests/performance simultaneously)
- **Chaining:** Sequential steps where each focuses on one subtask. Use when single prompts with many constraints get violated. (Example: generate content → then check constraints in follow-up)
- **Routing:** Categorize input → route to specialized pipeline. (Example: new-project detecting domain → installing matching pack)

---

## Bundled Resources

### scripts/ — Deterministic Code
Use for tasks where language instructions are unreliable:
- Counting (word count, phrase matching, keyword density)
- Validation (format checking, schema validation)
- Calculation (contrast ratios, statistics)
- Running tools (lint, test, format)

Do not script judgment calls — the model handles those.

### references/ — On-Demand Documentation
Use for detailed content that not every invocation needs:
- Checklists (WCAG, SEO, security)
- Rubrics (content scoring criteria)
- API docs, schemas
- Domain knowledge

**Shared references:** each skill keeps its own copy (real files, not links), so a skill copied
on its own still has what it reads. When you change a shared checklist, update every copy.

### assets/ — Output Files
Files Claude uses in output without loading into context:
- Document templates
- Boilerplate code
- Brand assets

---

## Portability

Skills must work on all three surfaces:

| Surface | Skill discovery | Notes |
|---------|----------------|-------|
| Claude.ai | Upload .skill zip via Settings | No hooks, no agents |
| Claude Code | `~/.claude/skills/` or `.claude/skills/` | Full features |
| API | `/v1/skills` endpoint | Requires Code Execution beta |

**Rules:**
- Core instructions in SKILL.md must be surface-agnostic
- Hooks and agents are Claude Code add-ons; they live in `blueprint/hooks/` and `blueprint/agents/`
- Embed the domain persona in SKILL.md
- Never reference Code-specific features in the skill body

---

## Negative Triggers

In a multi-skill pack, say in each skill when not to use it, to prevent overlap:

```yaml
description: >
  ...
  Not for [overlapping task] (use [correct-skill] instead).
```

Common overlaps to disambiguate:
- code-review vs debug vs refactor
- content-gen vs humanize
- ui-review vs a11y-check vs responsive-audit
- outreach vs follow-up

---

## Prompt Engineering Rules

- First line of SKILL.md body is most critical (highest attention weight) — lead with action directive
- Move Persona AFTER the first instruction block (action first, identity second)
- Use XML tags for interpolated content: `<user_input>`, `<code_context>`, `<reference_data>`
- Write calm, specific instructions. Newer Claude models follow instructions closely, so
  shouted all-caps rules make them over-apply a rule. Explain the reason instead; keep a hard word only
  for real safety boundaries (secrets, destructive commands)
- Include worked examples with WHY explanation ("This example scores well because...")
- Temperature guidance: recommend low (0-0.3) for code/analysis skills, medium (0.5-0.7) for content/creative skills

### Pre-fill Patterns for Structured Output

Skills that generate structured data (JSON, code, tables, scored outputs) SHOULD include pre-fill guidance:
- Specify the opening format the model should continue from
- Example: For a skill that outputs JSON analysis, include: "Begin your response with \`\`\`json and structure as..."
- This eliminates preamble and ensures parseable output
- Works across all surfaces (Claude.ai, Claude Code, API)

### Budget Controls for Autonomous Skills

Give any autonomous skill:
- Budget cap (default 10 iterations)
- Progress logging after each iteration
- Diminishing-returns exit (e.g., 95%+ for 3 consecutive runs → stop)

### Error Handling in Scripts

Tool/script errors should include descriptive messages for self-correction:
- Validate inputs before processing
- Raise errors with meaningful messages (not just exit codes)
- Error messages are visible to Claude, allowing it to retry with corrected parameters

---

## Prompt Caching Awareness (API-portable skills)

Skills intended for API use SHOULD structure content for cache efficiency:
- Put stable instructions (persona, methodology, rules) at the top of SKILL.md
- Put variable content (user input, context) at the bottom
- This allows API consumers to cache the stable skill prefix and only vary the tail
- Note: This is an API optimization hint, not a requirement for Claude Code usage

---

## Extended Thinking Guidance

Skills MAY note when extended thinking is beneficial:
- Complex multi-step reasoning (security audits, architecture reviews)
- Tasks where accuracy matters more than speed
- NOT needed for: content generation, simple code changes, formatting tasks
- Format: Add a `> **Tip:** Enable extended thinking for complex [X] scenarios.` note in relevant steps

---

## Parallelization Guidance

Skills that check multiple independent dimensions (e.g., code-review: architecture + quality + tests + performance) SHOULD note which steps can run in parallel:
- Mark independent steps with `[parallelizable]`
- Agent implementations can then run these simultaneously via subagents
- Sequential-only steps should be marked `[sequential — depends on Step N]`

---

## Chaining Pattern for Constraint-Heavy Skills

When Claude consistently ignores constraints despite repetition, split into separate calls where each focuses on one subtask:
- Step 1: Generate the content
- Step 2: Check constraints (format, length, required sections)
- Step 3: Fix violations found in Step 2
- This pattern trades latency for constraint compliance

---

## Testing Checklist

Before shipping any skill:

### Structural
- [ ] SKILL.md exists (exact name, case-sensitive)
- [ ] Folder name is kebab-case
- [ ] `name` field matches folder name
- [ ] `description` + `when_to_use` under 1,536 characters, no XML tags
- [ ] SKILL.md under 500 lines
- [ ] No README.md in skill folder
- [ ] All referenced files exist
- [ ] All scripts are executable

### Triggering
- [ ] 3 queries that SHOULD trigger it — tested
- [ ] 2 queries that SHOULD NOT trigger it — tested
- [ ] Description includes negative triggers

### Functional
- [ ] 3-6 hybrid evals defined (binary + model-graded) with pass thresholds
- [ ] At least 1 input/output example included
- [ ] End-to-end test: skill triggers, runs, scores, delivers output

---

## Install Paths

```bash
# Personal (all projects)
~/.claude/skills/skill-name/SKILL.md

# Project (shared via git)
.claude/skills/skill-name/SKILL.md

# Pack install (one folder per skill)
cp -R blueprint/skills/coding/* ~/.claude/skills/
```
