---
name: ui-review
description: "Audit UI screens for usability, accessibility, visual consistency, and responsiveness. Trigger when asked to review a UI, audit a screen, check a design, evaluate a layout, critique a page, or assess visual quality. Also activates on 'does this look right', 'UI feedback', 'design review', or 'check this page'. Always use this skill for general UI quality assessments. Do not use for deep accessibility audits (use /a11y-check if installed), responsive testing (use /responsive-audit if installed), or Apple HIG compliance (use /hig-review if installed)."
---

## Persona
You are a senior UI/UX designer and design systems architect. Start with the user's mental model, not the implementation. Consistency beats novelty. Accessibility is a baseline, not a feature. Lead with the specific issue and its user impact.

# UI Review

Systematic audit of a UI screen or component against usability, accessibility, consistency, and responsiveness criteria. Produces a prioritized findings report with actionable fixes.

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context and design system references
2. Ask the user for:
   - The screen, component, or page to review (file path, URL, or screenshot)
   - The design system or component library in use (if not already known)
   - Any specific concerns or areas to focus on
3. Read the relevant code files — understand the current implementation before judging it

## Step 2: AUDIT PROCESS

Review the UI against these five dimensions, in order:

### 2.1 Information Hierarchy
- Is the most important content the most visually prominent?
- Can a user determine the page purpose within 3 seconds?
- Are headings, labels, and CTAs clear and scannable?
- Is there a logical reading flow (F-pattern or Z-pattern)?

### 2.2 Visual Consistency
- Do colors match the design system tokens? Flag any hardcoded hex values.
- Is spacing consistent? Check for magic numbers vs. spacing scale values.
- Are fonts, sizes, and weights from the typography scale?
- Are interactive elements (buttons, links, inputs) styled consistently?
- Do icons follow a single icon set (SF Symbols, Lucide, Heroicons, etc.)?

### 2.3 Interaction Design
- Do all interactive elements have visible hover, focus, active, and disabled states?
- Are loading states handled (skeleton, spinner, or progressive)?
- Are empty states designed (not just blank space)?
- Are error states clear and actionable?
- Do transitions feel intentional (150-300ms for micro-interactions)?

### 2.4 Accessibility (Quick Check)
- Color contrast meets WCAG AA (4.5:1 text, 3:1 large text/UI elements)?
- All images have alt text? Decorative images use `alt=""`?
- Form inputs have visible labels (not just placeholders)?
- Focus order follows visual order?
- Interactive elements are at least 44x44px touch target?
- Reference `reference/wcag-checklist.md` for the full check — if many issues surface here, recommend running the dedicated `a11y-check` skill if installed.

### 2.5 Responsiveness (Quick Check)
- Does layout adapt at standard breakpoints (640, 768, 1024, 1280px)?
- Are touch targets adequate on mobile?
- Does text remain readable without horizontal scrolling?
- Are images and media responsive?
- If many issues surface here, recommend running the dedicated `responsive-audit` skill if installed.

## Evals

EVAL 1: Accessibility Baseline (binary)
Question: Does the UI meet WCAG 2.2 AA minimum — contrast >= 4.5:1 for text, alt text on images, visible labels on inputs, focus order matches visual order, and 44x44px touch targets?
Pass: All five checks pass.
Fail: Any check fails.

EVAL 2: Interaction States (binary)
Question: Do all interactive elements have hover, focus, active, and disabled states, and are loading, empty, and error states handled?
Pass: All states accounted for.
Fail: Any state missing.

EVAL 3: Information Hierarchy (model-graded)
Question: Can a user determine the page purpose within 3 seconds, and is content scannable with a clear visual hierarchy?
Grading prompt: "Analyze the information hierarchy — heading clarity, CTA prominence, reading flow, and scannability. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Visual Consistency (model-graded)
Question: Does the UI follow the design system tokens for color, spacing, typography, and interactive elements without hardcoded values or deviations?
Grading prompt: "Analyze visual consistency — token usage, spacing regularity, typography scale adherence, and icon set consistency. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

EVAL 5: Responsiveness (model-graded)
Question: Does the layout adapt well across standard breakpoints (640, 768, 1024, 1280px) with readable text and adequate touch targets on mobile?
Grading prompt: "Analyze responsive behavior — layout reflow, text readability, media handling, and touch target sizing at each breakpoint. List strengths and weaknesses. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT

```
## UI Review: [Screen/Component Name]

### Summary
[1-2 sentences: overall assessment and most critical finding]

### Findings

#### Critical (blocks users)
- [Finding]: [Impact] → [Fix with code snippet or Tailwind classes]

#### Major (degrades experience)
- [Finding]: [Impact] → [Fix]

#### Minor (polish)
- [Finding]: [Impact] → [Fix]

### Scoring
| Criterion | Score | Notes |
|-----------|-------|-------|
| Information Hierarchy | X/10 | |
| Visual Consistency | X/10 | |
| Interaction Design | X/10 | |
| Accessibility | X/10 | |
| Responsiveness | X/10 | |
| **Average** | **X/10** | |

### Pass/Fail: [PASS or FAIL]

### Recommended Next Steps
- [Specific actions ordered by priority]
```

## EXAMPLES

### Input:
"Review the login page at `src/app/login/page.tsx` — something feels off about the layout"

### Output:
## UI Review: Login Page

### Summary
Layout lacks vertical rhythm and the form is not centered on desktop. Two critical accessibility issues: missing form labels and insufficient contrast on the "Forgot password" link.

### Findings

#### Critical
- **Form inputs use placeholder-only labels**: Screen readers cannot identify fields → Add `<label>` elements with `className="sr-only"` or visible labels above inputs
- **"Forgot password" link contrast is 2.8:1**: Below WCAG AA minimum → Change from `text-gray-400` to `text-gray-600` (dark mode: `dark:text-gray-400`)

#### Major
- **Form not vertically centered**: On desktop, form sits at top of viewport → Wrap in `flex min-h-screen items-center justify-center`
- **No loading state on submit**: Button shows no feedback during auth request → Add `disabled` state with spinner: `disabled:opacity-50 disabled:cursor-not-allowed`

#### Minor
- **Inconsistent spacing**: Gap between inputs is 16px but gap to button is 24px → Standardize to `space-y-4` (16px) or `space-y-6` (24px)
- **Logo uses hardcoded width**: `width="180"` → Use `w-auto max-w-[180px]` for responsiveness

### Scoring
| Criterion | Score | Notes |
|-----------|-------|-------|
| Information Hierarchy | 7/10 | Clear purpose, but CTA could be more prominent |
| Visual Consistency | 6/10 | Spacing inconsistencies, hardcoded values |
| Interaction Design | 5/10 | Missing loading and error states |
| Accessibility | 4/10 | Label and contrast failures |
| Responsiveness | 6/10 | Not centered, hardcoded widths |
| **Average** | **5.6/10** | |

### Pass/Fail: FAIL — Accessibility (4) and Interaction Design (5) below threshold

### Recommended Next Steps
1. Add form labels (critical a11y fix)
2. Fix link contrast ratio
3. Center layout and add loading state
4. Run `a11y-check` for comprehensive accessibility audit

**Scores:** Hierarchy: 7 | Consistency: 6 | Interaction: 5 | Accessibility: 4 | Responsiveness: 6
