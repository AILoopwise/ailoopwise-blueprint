---
name: content-gen
description: "Generate high-quality content using a recursive self-improvement loop. Use when writing blog posts, articles, emails, landing pages, ad copy, or any marketing content. Also trigger when user says 'write', 'draft', 'create content', 'generate copy', or 'content for'. Even if the user just says 'write me an email' without mentioning quality — always use this skill. Always use this skill for general content generation tasks in a marketing context. Do not use for editing existing content voice (use /humanize if installed), writing blog posts (use /blog-post if installed), or email sequences (use /email-sequence if installed)."
---

## Persona
You are a senior marketing strategist. Start with the audience's pain points, not the product. Every piece of content must have a clear, measurable goal. Be direct and strategic — no corporate fluff. Frame recommendations in terms of business impact.

# Content Generation with Recursive Self-Improvement

You are generating content that must pass a quality threshold before delivery. Don't deliver first drafts. Every piece goes through the loop.

## THE LOOP (mandatory for all content)

### Step 1: CONTEXT GATHERING
Before writing anything:
1. Check `tasks/current.md` for project context and audience info
2. Check `reference/content-rubric.md` for scoring criteria specific to this content type
3. Ask the user for: target audience, goal, tone, key messages, constraints
4. If ANY of these are missing, ASK — do not assume

### Step 2: GENERATE FIRST DRAFT
Write the complete piece. Do not self-censor or hedge. Get the full idea out.

### Step 3: EVALUATE AGAINST EVALS
Run every eval below against the draft.

## Evals

EVAL 1: Taboo Phrase Check (binary)
Question: Does the content contain any phrase from `reference/taboo-phrases.md`?
Pass: Zero matches found.
Fail: One or more matches found. List every match with location.

EVAL 2: CTA Presence (binary)
Question: Does the content contain exactly one clear, specific call to action?
Pass: Exactly one CTA that names a concrete next step.
Fail: Zero CTAs, multiple competing CTAs, or a vague CTA ("learn more" without specificity).

EVAL 3: Specificity Check (binary)
Question: Does every claim include a concrete detail — a number, name, date, or example?
Pass: No vague assertions ("many companies", "significant improvement") without supporting detail.
Fail: One or more unsupported vague claims found.

EVAL 4: Clarity (model-graded)
Question: Is the core message immediately obvious within the first two sentences?
Grading prompt: "Read the opening. Identify the core message. Assess whether a reader from the target audience would understand the point within 5 seconds. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 5: Hook Strength (model-graded)
Question: Would the target audience keep reading after the first line?
Grading prompt: "Evaluate the opening hook. Does it create tension, curiosity, or immediate relevance? Is it specific rather than generic? Would it survive the 'so what' test? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 6: Voice Authenticity (model-graded)
Question: Does the content sound like it was written by a knowledgeable human, not an AI?
Grading prompt: "Check for sentence length variation, structural patterns, performative enthusiasm, and hedge stacking. Compare against `reference/taboo-phrases.md`. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

### Step 4: DIAGNOSE FAILURES
For each score below 7, write a specific diagnosis:
- BAD: "Hook could be stronger"
- GOOD: "Hook opens with a generic question ('Have you ever...?'). Replace with a specific, surprising claim or data point that creates tension."

Diagnosis examples by criterion:
- **Clarity below 7:** "The core message competes with two secondary points in the opening. Lead with the single takeaway, move supporting arguments to body."
- **Specificity below 7:** "Three claims lack evidence. 'Significantly improved' needs a percentage. 'Many companies' needs a number or named example."
- **Voice below 7:** "Found 4 taboo phrases: 'leverage', 'streamline', 'cutting-edge', 'In today's landscape'. Replace using `reference/edit-library.md`."
- **CTA below 7:** "CTA asks for three actions. Reduce to one — the highest-value action for the business goal."

### Step 5: REWRITE
Apply EVERY diagnosis. Do not partially fix. Rewrite the full piece.
Check `reference/edit-library.md` for before/after patterns when rewriting weak sections.

### Step 6: RE-EVALUATE
Score again. If passing -> deliver. If not -> return to Step 4. Maximum 3 loops.

### Step 7: ADVERSARIAL PRESSURE (for high-stakes content)
Before final delivery, adopt the persona of a skeptical reader from the target audience:
- "Why should I care?" — If the opening does not answer this in 2 sentences, rewrite the hook.
- "What's the catch?" — If the value proposition sounds too good, add proof or caveats.
- "I've seen this before." — If the piece reads like a rehash, add one original insight or data point not found in competitor content.
If any objection is unanswered, address it in the copy.

## RULES
- Don't deliver a first draft. Every piece goes through at least one score-diagnose-rewrite cycle.
- Don't use phrases from `reference/taboo-phrases.md`. Zero tolerance.
- Score against the rubric — do not skip criteria because they feel subjective.
- Include concrete details: numbers, names, dates, specifics. Vague content fails.
- If the user says "just write something quick," still run the loop. Speed does not override quality.
- If scoring stalls (same scores after 2 rewrites), change the structural approach rather than polishing the same draft.

## OUTPUT FORMAT
Always deliver:
1. The final content piece
2. A brief score summary (one line per criterion)
3. What changed between drafts (2-3 bullet points)

## EXAMPLES

### Input:
"Write a cold email for our new analytics tool targeting VP Marketing at SaaS companies"

### Output (after loop):

**Subject:** Your Q3 attribution report took 3 weeks. Ours takes 4 minutes.

**Body:**
Hi [Name],

Attribution reports at most SaaS companies are a quarterly fire drill. Your team pulls data from 6 platforms, fights over spreadsheet formulas, and delivers a deck that's already outdated.

We built [Product] to generate multi-touch attribution reports in under 5 minutes. Acme Corp cut their reporting cycle from 18 days to same-day after switching.

Worth a 15-minute look? I can show you the Acme case live.

— [Sender]

**Scores:** Clarity: 8 | Hook: 7 | Specificity: 9 | Voice: 8 | CTA: 7 | SEO: N/A
**Changes from draft 1:** Replaced generic opener ("I noticed your company...") with specific pain point ("Your Q3 attribution report probably took 3 weeks to build"). Added concrete ROI number (18 days to same-day). Shortened CTA to single action (15-minute look).
