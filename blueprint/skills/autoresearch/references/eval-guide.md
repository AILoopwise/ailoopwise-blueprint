# Eval Guide

How to write eval criteria that actually improve your skills instead of giving you false confidence.

---

## the golden rule

Use the right eval type for what you're measuring:
- **Binary** for anything objectively testable (format, length, section presence, syntax)
- **Model-graded** for qualities on a genuine spectrum (thoroughness, relevance, clarity)

Why two types: Pure binary can't capture "how thorough is this analysis?" Pure scales are unreliable for structural checks. Hybrid gives you deterministic confidence on structure + nuanced signal on quality.

---

## good evals vs bad evals

### Text/copy skills (newsletters, tweets, emails, landing pages)

**Bad evals:**
- "Is the writing good?" (too vague — what's "good"?)
- "Rate the engagement potential 1-10" (scale = unreliable)
- "Does it sound like a human?" (subjective, inconsistent scoring)

**Good evals:**
- "Does the output contain zero phrases from this banned list: [game-changer, here's the kicker, the best part, level up]?" (binary, specific)
- "Does the opening sentence reference a specific time, place, or sensory detail?" (binary, checkable)
- "Is the output between 150-400 words?" (binary, measurable)
- "Does it end with a specific CTA that tells the reader exactly what to do next?" (binary, structural)

### Visual/design skills (diagrams, images, slides)

**Bad evals:**
- "Does it look professional?" (subjective)
- "Rate the visual quality 1-5" (scale)
- "Is the layout good?" (vague)

**Good evals:**
- "Is all text in the image legible with no truncated or overlapping words?" (binary, specific)
- "Does the color palette use only soft/pastel tones with no neon, bright red, or high-saturation colors?" (binary, checkable)
- "Is the layout linear — flowing either left-to-right or top-to-bottom with no scattered elements?" (binary, structural)
- "Is the image free of numbered steps, ordinals, or sequential numbering?" (binary, specific)

### Code/technical skills (code generation, configs, scripts)

**Bad evals:**
- "Is the code clean?" (subjective)
- "Does it follow best practices?" (vague, which best practices?)

**Good evals:**
- "Does the code run without errors?" (binary, testable — actually execute it)
- "Does the output contain zero TODO or placeholder comments?" (binary, greppable)
- "Are all function and variable names descriptive (no single-letter names except loop counters)?" (binary, checkable)
- "Does the code include error handling for all external calls (API, file I/O, network)?" (binary, structural)

### Document skills (proposals, reports, decks)

**Bad evals:**
- "Is it comprehensive?" (compared to what?)
- "Does it address the client's needs?" (too open-ended)

**Good evals:**
- "Does the document contain all required sections: [list them]?" (binary, structural)
- "Is every claim backed by a specific number, date, or source?" (binary, checkable)
- "Is the document under [X] pages/words?" (binary, measurable)
- "Does the executive summary fit in one paragraph of 3 sentences or fewer?" (binary, countable)

---

## common mistakes

### 1. Too many evals
More than 6 evals and the skill starts gaming them — it optimizes for passing the test instead of producing good output. Like a student who memorizes answers without understanding the material.

**Fix:** Pick the 3-6 checks that matter most. If everything passes those, the output is probably good.

### 2. Too narrow/rigid
"Must contain exactly 3 bullet points" or "Must use the word 'because' at least twice" — these create skills that technically pass but produce weird, stilted output.

**Fix:** Evals should check for qualities you care about, not arbitrary structural constraints.

### 3. Overlapping evals
If eval 1 is "Is the text grammatically correct?" and eval 4 is "Are there any spelling errors?" — these overlap. A grammar fail often includes spelling. You're double-counting.

**Fix:** Each eval should test something distinct.

### 4. Unmeasurable by an agent
"Would a human find this engaging?" — an agent can't reliably answer this. It'll say "yes" almost every time.

**Fix:** Translate subjective qualities into observable signals. "Engaging" might mean: "Does the first sentence contain a specific claim, story, or question (not a generic statement)?"

---

## when to use binary vs model-graded

| Signal | Use Binary | Use Model-Graded |
|--------|-----------|-----------------|
| Format correct? | yes | no |
| Word count in range? | yes | no |
| Required sections present? | yes | no |
| Code runs without errors? | yes | no |
| Analysis is thorough? | no | yes |
| Writing is clear and engaging? | no | yes |
| Recommendations are actionable? | no | yes |
| Code is well-structured? | no | yes |

**Rule of thumb:** If two agents would score the same output identically → binary. If reasonable agents might disagree by 1-2 points → model-graded.

---

## model-graded evals

For qualities that exist on a genuine spectrum. The key rule: **reasoning before scoring**.

Without reasoning, models default to middling scores (6-7 on everything). Forcing the grader to list strengths and weaknesses first produces more accurate, differentiated scores.

### Good model-graded evals

```
EVAL 3: Analysis depth (model-graded)
Question: How thorough is the analysis?
Grading prompt: "Read the analysis. List specific strengths (insights, evidence, connections made). List specific weaknesses (gaps, unsupported claims, missing perspectives). Then score 1-10 where 1=surface-level and 10=expert-level depth."
Pass threshold: >= 7
```

```
EVAL 4: Recommendation quality (model-graded)
Question: Are the recommendations actionable and well-justified?
Grading prompt: "For each recommendation: is it specific (not generic)? Is it justified with evidence from the analysis? Could someone act on it without further clarification? List strengths and weaknesses. Score 1-10."
Pass threshold: >= 7
```

### Bad model-graded evals

- "Score the quality 1-10" (no reasoning prompt — will get 7 every time)
- "Is this good?" (binary question disguised as model-graded — use binary)
- "Rate creativity 1-10" (too subjective even with reasoning — unmeasurable)

---

## combined score formula

When a skill has both binary and model-graded evals:

```
binary_pass_rate = (binary evals passed) / (total binary evals)
model_score_avg = average of all model-graded scores / 10  (normalize to 0-1)
combined_score = (binary_pass_rate + model_score_avg) / 2
```

Target: **85%+ combined score**

Example: 3 binary evals (2 pass) + 2 model-graded evals (avg 8.0)
→ binary_pass_rate = 0.67, model_score_avg = 0.80
→ combined = (0.67 + 0.80) / 2 = 0.735 = 73.5% → needs improvement

---

## writing your evals: the 3-question test

Before finalizing an eval, ask:

1. **Could two different agents score the same output and agree?** If not, the eval is too subjective. Rewrite it.
2. **Could a skill game this eval without actually improving?** If yes, the eval is too narrow. Broaden it.
3. **Does this eval test something the user actually cares about?** If not, drop it. Every eval that doesn't matter dilutes the signal from evals that do.

---

## templates

### Binary eval template
```
EVAL [N]: [Short name] (binary)
Question: [Yes/no question]
Pass: [What "yes" looks like — one sentence, specific]
Fail: [What triggers "no" — one sentence, specific]
```

### Model-graded eval template
```
EVAL [N]: [Short name] (model-graded)
Question: [What quality to assess]
Grading prompt: "Analyze [specific aspect]. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7
```

### Examples

```
EVAL 1: Text legibility (binary)
Question: Is all text in the output fully legible with no truncated, overlapping, or cut-off words?
Pass: Every word is complete and readable without squinting or guessing
Fail: Any word is partially hidden, overlapping another element, or cut off at the edge

EVAL 2: Analysis depth (model-graded)
Question: How thorough is the analysis of the subject matter?
Grading prompt: "Read the analysis. List specific insights and evidence cited. List gaps or unsupported claims. Score 1-10 where 1=surface-level and 10=expert-level."
Pass threshold: >= 7
```