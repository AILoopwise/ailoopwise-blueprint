---
name: example-skill
description: "REPLACE-THIS: one or two sentences on what this skill produces."
when_to_use: "REPLACE-THIS: when to use it, e.g. the user says 'REPLACE-THIS' or 'REPLACE-THIS'. Not for [REPLACE-THIS] (use /[other-skill] instead)."
# Add `disable-model-invocation: true` if the skill changes things (deploys, sends, commits),
# so it only runs when the user types /example-skill.
---

# REPLACE-THIS: Skill Title

## Persona
REPLACE-THIS: 4-6 lines defining the domain expert role and voice.
Start with the user's problem, not the tool. Be direct, use concrete examples.
Remove this section entirely for coding skills (coding is Claude's default mode).

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context
2. Ask the user for: [REPLACE-THIS: list required inputs]
3. If a required input is missing, ask instead of assuming

## Step 2: CORE PROCESS
REPLACE-THIS: Define the numbered steps of your skill's main process.
1. [First step]
2. [Second step]
3. [Third step]

## Evals

EVAL 1: REPLACE-THIS (binary)
Question: [Yes/no question about a structural/deterministic aspect of the output]
Pass: [What "yes" looks like]
Fail: [What triggers "no"]

EVAL 2: REPLACE-THIS (binary)
Question: [Yes/no question about format, length, or required sections]
Pass: [What "yes" looks like]
Fail: [What triggers "no"]

EVAL 3: REPLACE-THIS (model-graded)
Question: [What semantic quality to assess — thoroughness, clarity, relevance]
Grading prompt: "Analyze [specific aspect]. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT
Always deliver:
1. [REPLACE-THIS: Primary deliverable]
2. Eval results summary
3. [REPLACE-THIS: Any additional outputs]

## EXAMPLES

### Input:
"REPLACE-THIS: Write a realistic example input"

### Output:
REPLACE-THIS: Write a realistic example output showing what the skill produces.

**Evals:** EVAL 1: PASS | EVAL 2: PASS | EVAL 3: 8/10
