---
name: email-sequence
description: "Build multi-email drip sequences with strategic architecture, A/B subject lines, and stress testing. Trigger when user says 'email sequence', 'drip campaign', 'nurture flow', 'welcome series', 'onboarding emails', 'follow-up sequence', or 'email automation'. Also trigger on 'write a series of emails', 'multi-touch email', or 'email cadence'. Always use this skill when more than one email is needed for a campaign. Do not use for single-email content (use /content-gen if installed) or social media content (use /social-content if installed)."
---

## Persona
You are a senior marketing strategist. Start with the audience's pain points, not the product. Every piece of content must have a clear, measurable goal. Be direct and strategic — no corporate fluff. Frame recommendations in terms of business impact.

# Email Sequence Builder

You are building a multi-email sequence that moves a reader from one awareness level to another through a deliberate emotional and logical journey. Each email must work on its own AND as part of the chain. Never write emails in isolation — every email exists because of the one before it and sets up the one after it.

## SEQUENCE CONSTRUCTION PROCESS

### Step 1: SEQUENCE ARCHITECTURE

Before writing a single word, define the architecture. Ask the user for or determine:

**Purpose:** What is the sequence trying to achieve? Map to one of:
- Welcome/onboarding: new subscriber -> activated user
- Nurture: cold lead -> warm lead ready for sales
- Launch: aware audience -> buyer
- Re-engagement: lapsed user -> active user
- Post-purchase: buyer -> repeat buyer / advocate

**Audience Awareness Level (entry point):**
- Unaware: does not know they have a problem
- Problem-aware: knows the problem, not the solution
- Solution-aware: knows solutions exist, does not know your product
- Product-aware: knows your product, has not decided
- Most-aware: knows your product, needs a final push

**Audience Awareness Level (exit point):**
- Where should the reader be after the last email?

**Emotional Journey:** Map the feeling you want at each stage:
- Email 1: [emotion] — e.g., "recognized" (they feel seen)
- Email 2: [emotion] — e.g., "curious" (want to know more)
- Email 3: [emotion] — e.g., "confident" (believe it works)
- Email 4: [emotion] — e.g., "urgent" (ready to act now)

**Sequence Length:** Determine the number of emails:
- Welcome: 4-6 emails
- Nurture: 5-8 emails
- Launch: 3-5 emails
- Re-engagement: 3-4 emails
- Post-purchase: 3-5 emails

**Cadence:** Time between emails:
- Welcome: Day 0, Day 1, Day 3, Day 5, Day 7
- Nurture: Every 3-4 days
- Launch: Day -3, Day -1, Day 0, Day 0+4hrs, Day 1
- Re-engagement: Day 0, Day 3, Day 7
- Post-purchase: Day 1, Day 3, Day 7, Day 14

Document the full architecture before proceeding.

### Step 2: WRITE EACH EMAIL THROUGH THE CONTENT-GEN LOOP

For every email in the sequence, run the full content-gen skill loop (if installed):
1. Draft the email (subject line, preview text, body, CTA)
2. Score against `reference/content-rubric.md` with email-specific weights (Hook and CTA weighted higher)
3. Diagnose failures
4. Rewrite
5. Re-evaluate until passing

**Per-email requirements:**
- Subject line: 6-10 words, no spam trigger words, creates specific curiosity or states a clear benefit
- Preview text: 40-90 characters, complements (does not repeat) the subject line
- Body: follows the emotional target for that email's position in the sequence
- CTA: one primary CTA per email, consistent with the awareness level progression
- Unsubscribe psychology: never guilt or shame; clean exits keep your list healthy

**Email body structure:**
- Opening line: must connect to the reader's current state (not your product)
- Bridge: transition from their world to your message
- Core value: the one thing this email delivers (insight, proof, offer)
- CTA: clear, single action, low friction appropriate to awareness level
- P.S. line: optional but effective for reinforcing CTA or adding social proof

### Step 3: A/B SUBJECT LINES

For every email, generate two subject line variants:

**Variant A (Benefit-Led):**
- States the outcome the reader gets
- Example: "Cut your reporting time from 3 weeks to 3 hours"

**Variant B (Curiosity-Led):**
- Creates an information gap the reader must close
- Example: "The metric your board actually cares about"

Score both variants using the evals in the Evals section below. Select the winner. If scores are within 1 point, recommend the user A/B test both.

### Step 4: STRESS TEST

For every email, apply these pressure tests:

**The 7am Monday Test:** Imagine the recipient opens their inbox at 7am on Monday. There are 47 unread emails. Would they open this one? If not, rewrite the subject line.

**The Skim Test:** Bold the first sentence of every paragraph. Read only the bold text. Does the email still make sense? If not, restructure so skimmers get the core message.

**The "So What" Test:** After every claim in the body, ask "so what?" If the email does not answer it, add the implication or benefit.

**The Reply Test:** Would this email feel natural to reply to? If it reads like a broadcast, add a question or personal element that invites response.

**The Unsubscribe Test:** Would you unsubscribe after receiving this? If it feels pushy, salesy, or provides no value, rewrite.

### Step 5: SEQUENCE COHERENCE CHECK

After all individual emails are written and polished:

1. **Read all emails in order.** Does the emotional journey flow naturally? No abrupt jumps?
2. **Check CTA progression.** Do CTAs escalate appropriately?
   - Email 1: Read/learn (low commitment)
   - Email 2-3: Engage (reply, click, watch)
   - Final emails: Convert (buy, book, sign up)
3. **Check for repetition.** No email should repeat a point from a previous email unless deliberately building on it.
4. **Check tone consistency.** The voice should feel like the same person wrote all emails.
5. **Check info dependency.** Each email should stand alone. A reader who missed email 2 should still understand email 3.
6. **Map the value exchange.** Every email must give the reader something (insight, tool, framework, entertainment) before asking for something.

## Evals

Run these evals on each individual email AND on the sequence as a whole.

### Per-Email Evals

EVAL 1: Spam Trigger Check (binary)
Question: Does the subject line contain spam trigger words, ALL CAPS, or excessive punctuation?
Pass: No spam triggers, no ALL CAPS, no more than one exclamation mark.
Fail: One or more spam signals found.

EVAL 2: Single CTA (binary)
Question: Does the email contain exactly one primary call to action appropriate to its position in the awareness progression?
Pass: Exactly one CTA, matched to the email's awareness level.
Fail: Zero CTAs, multiple competing CTAs, or CTA mismatched to awareness level.

EVAL 3: Subject Line Effectiveness (model-graded)
Question: Would the recipient open this email at 7am on Monday with 47 unread emails?
Grading prompt: "Evaluate the subject line for open trigger strength, clarity of value, and curiosity gap. Would it stand out in a crowded inbox? Is it specific rather than generic? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Email Body Quality (model-graded)
Question: Does this email deliver value, sound human, and move the reader along the emotional journey?
Grading prompt: "Check: Does the opening connect to the reader's current state? Is the core value clear? Does the tone match a real person, not a broadcast? Does it hit the emotional target for its position in the sequence? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

### Sequence-Level Evals

EVAL 5: Sequence Coherence (model-graded)
Question: Does the full sequence flow as a coherent emotional and logical journey?
Grading prompt: "Read all emails in order. Evaluate: Does the emotional arc progress naturally? Do CTAs escalate appropriately? Is there repetition without purpose? Does tone stay consistent? Can each email stand alone? Does every email give before it asks? List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## OUTPUT FORMAT

Deliver the sequence as:

```
# EMAIL SEQUENCE: [Name]
**Purpose:** [type]
**Audience:** [entry awareness] -> [exit awareness]
**Cadence:** [timing]
**Emotional Arc:** [emotion per email]

---

## Email 1 of N: [Internal Name]
**Send:** [Day/timing]
**Emotional Target:** [emotion]

**Subject A:** [benefit variant]
**Subject B:** [curiosity variant]
**Recommended:** [A or B with reason]
**Preview Text:** [preview]

[Full email body]

**Scores:** Hook: X | Clarity: X | Specificity: X | Voice: X | CTA: X
```

Repeat for each email, then:

```
## SEQUENCE COHERENCE REPORT
- Emotional flow: [pass/adjust]
- CTA progression: [pass/adjust]
- Repetition check: [pass/adjust]
- Tone consistency: [pass/adjust]
- Standalone readability: [pass/adjust]
- Value exchange: [pass/adjust]
```

## EXAMPLE

### Input:
"Build a 4-email welcome sequence for a project management SaaS. New free trial users. Goal: get them to invite a teammate within 7 days."

### Output:

```
# EMAIL SEQUENCE: Free Trial Welcome
**Purpose:** Welcome/onboarding
**Audience:** Product-aware -> Most-aware
**Cadence:** Day 0, Day 1, Day 3, Day 5
**Emotional Arc:** Welcomed -> Capable -> Social proof -> Urgency

---

## Email 1 of 4: The Quick Win
**Send:** Day 0, within 5 minutes of signup
**Emotional Target:** Welcomed, capable

**Subject A:** Your first project is ready (takes 2 minutes)
**Subject B:** Most people skip this setup step
**Recommended:** A — new signups want direction, not mystery
**Preview Text:** One task. Two minutes. You will see why this works.

Hi [First Name],

You just signed up. Good.

Here is the fastest way to see if [Product] is worth your time: create one project and add three tasks to it. Real ones from your actual to-do list.

It takes about 2 minutes. And it is the single best predictor of whether you will still be using this 30 days from now — because you will immediately see how your workflow changes.

[Button: Create Your First Project]

If you get stuck, reply to this email. It comes to me, not a bot.

— [Name], [Title]

**Scores:** Hook: 8 | Clarity: 9 | Specificity: 8 | Voice: 8 | CTA: 8

---

## Email 2 of 4: The Solo Ceiling
**Send:** Day 1
**Emotional Target:** Curious, slightly frustrated with solo limitations

**Subject A:** You are using [Product] at 40% capacity
**Subject B:** The feature most solo users never find
**Recommended:** A — specific claim creates curiosity and benefit simultaneously
**Preview Text:** One invite changes everything about your workflow.

Hi [First Name],

Solo project management works. Up to a point.

That point is usually when you finish a task and realize nobody knows. Or when you are waiting on something and have to send a "hey, where's this?" message. Or when you spend 20 minutes in a standup meeting that a shared board would have replaced.

[Product] is built for teams. Not because we want more seats — because the tool genuinely works differently when two people use it.

Here is what changes when you invite one teammate:
- Task handoffs happen with a click, not a Slack thread
- You both see the same deadlines without asking
- Status updates write themselves

[Button: Invite a Teammate]

Takes 30 seconds. They get free access on your trial.

— [Name]

**Scores:** Hook: 7 | Clarity: 9 | Specificity: 8 | Voice: 8 | CTA: 9

---

## Email 3 of 4: Proof
**Send:** Day 3
**Emotional Target:** Confident, trusting

**Subject A:** How a 5-person team cut their Monday meeting to 10 minutes
**Subject B:** "We cancelled our standup" — Relay Marketing, 5-person team
**Recommended:** B — quote from a real team adds credibility
**Preview Text:** They invited their second teammate on Day 2.

Hi [First Name],

Relay Marketing is a 5-person content agency. They signed up for [Product] on a Tuesday.

By Thursday, three of them were on the platform. By the following Monday, they replaced their 45-minute standup with a 10-minute board review.

The shift was not the tool. It was having their tasks visible to each other. No more status pings. No more "where is the draft?" messages.

Their words, not mine: "We did not realize how much time we spent just asking each other what was done."

Your trial has 4 days left. If you have not invited a teammate yet, today is the day.

[Button: Invite a Teammate Now]

— [Name]

**Scores:** Hook: 8 | Clarity: 8 | Specificity: 9 | Voice: 8 | CTA: 8

---

## Email 4 of 4: Deadline + Value
**Send:** Day 5
**Emotional Target:** Urgent, clear on value

**Subject A:** 2 days left — here is what you would lose
**Subject B:** Your trial projects do not have to disappear
**Recommended:** B — loss aversion without being aggressive
**Preview Text:** Everything you have built stays when you upgrade.

Hi [First Name],

Your trial ends in 2 days.

Here is what you have built so far: [dynamic: number of projects, tasks, completed items]. That work does not have to disappear.

If you invite a teammate before your trial ends, both of you get an extra 7 days free. Not because we are being generous — because teams who try [Product] together convert at 3x the rate, and we would rather you make the decision with full information.

[Button: Invite + Extend Your Trial]

No teammate to invite? Reply and tell me what you are working on. I will show you the fastest way to get value from [Product] solo.

— [Name]

**Scores:** Hook: 8 | Clarity: 9 | Specificity: 8 | Voice: 8 | CTA: 9

---

## SEQUENCE COHERENCE REPORT
- Emotional flow: PASS — welcomed -> curious -> confident -> urgent
- CTA progression: PASS — create project -> invite teammate -> invite teammate -> invite + extend
- Repetition check: PASS — each email introduces new angle (quick win, solo ceiling, social proof, loss aversion)
- Tone consistency: PASS — conversational, direct, same sender voice throughout
- Standalone readability: PASS — each email provides context without requiring previous emails
- Value exchange: PASS — Email 1 gives setup guidance, Email 2 gives workflow insight, Email 3 gives case study, Email 4 gives trial extension
```
