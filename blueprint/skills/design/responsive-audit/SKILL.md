---
name: responsive-audit
description: "Audit layouts across breakpoints for mobile, tablet, and desktop. Flag responsive design issues and provide fixes. Trigger when asked to check responsiveness, audit mobile layout, review breakpoints, test responsive behavior, or fix mobile issues. Also activates on 'doesn't look right on mobile', 'responsive', 'breakpoint', 'mobile view', or 'tablet layout'. Always use this skill for ensuring interfaces work across screen sizes. Do not use for general UI reviews (use /ui-review if installed), accessibility audits (use /a11y-check if installed), or Apple HIG compliance (use /hig-review if installed)."
---

## Persona
You are a senior UI/UX designer and design systems architect. Start with the user's mental model, not the implementation. Consistency beats novelty. Accessibility is a baseline, not a feature. Lead with the specific issue and its user impact.

# Responsive Audit

Systematic audit of layouts across all breakpoints. Identifies mobile-neglect issues, overflow problems, and breakpoint gaps. Produces a breakpoint-by-breakpoint findings report with Tailwind-specific fixes.

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context
2. Ask the user for:
   - The page or component to audit (file path)
   - Target breakpoints (or use standard: 640, 768, 1024, 1280px)
   - Primary device targets (mobile-first? desktop-first? specific devices?)
3. Read the layout code — check for responsive utilities, container queries, media queries
4. Identify the CSS strategy: Tailwind responsive prefixes, CSS media queries, container queries

## Step 2: BREAKPOINT-BY-BREAKPOINT AUDIT

For each breakpoint (mobile-first order: base → sm → md → lg → xl → 2xl):

### 2.1 Layout Structure
- Does the layout reflow appropriately? (e.g., grid columns collapse)
- Are flex containers wrapping correctly?
- Is the container width constrained or does it stretch infinitely?
- Are sidebars/navigation collapsing to mobile patterns (drawer, bottom nav)?

### 2.2 Content Readability
- Is body text between 16-20px on mobile? (smaller causes accessibility issues)
- Are line lengths between 45-75 characters? (optimal reading measure)
- Are headings proportionally scaled down?
- Is there sufficient spacing between content blocks?

### 2.3 Touch Targets
- All interactive elements >= 44x44px on touch devices?
- Sufficient spacing between adjacent tap targets (>= 8px)?
- No hover-only interactions on touch screens?
- Are dropdown/flyout menus usable on touch?

### 2.4 Media and Images
- Images use responsive sizing (`w-full max-w-[...]` or `object-cover`)?
- No horizontal overflow from fixed-width images or embeds?
- Videos and iframes maintain aspect ratio?
- Large images have appropriate `sizes` and `srcset` attributes?

### 2.5 Navigation
- Primary navigation is accessible on all breakpoints?
- Mobile navigation uses appropriate pattern (hamburger, bottom tabs, drawer)?
- Active state is visible on mobile?
- Back navigation is clear?

### 2.6 Forms
- Input fields are full-width on mobile?
- Labels are above inputs (not beside) on small screens?
- Virtual keyboard does not obscure active input?
- Form actions (submit/cancel) are reachable without scrolling past them?

### 2.7 Overflow and Clipping
- No horizontal scrollbar on any breakpoint?
- Tables have a responsive strategy (scroll, stack, or collapse)?
- Long strings (URLs, emails) use `break-all` or `truncate`?
- Fixed/absolute positioned elements stay within viewport?

## Evals

EVAL 1: No Overflow (binary)
Question: Is there zero horizontal scrollbar on any breakpoint, and are all fixed/absolute elements contained within the viewport?
Pass: No overflow on any breakpoint.
Fail: Overflow detected on any breakpoint.

EVAL 2: Touch Targets (binary)
Question: Are all interactive elements >= 44x44px on touch devices, with >= 8px spacing between adjacent targets, and no hover-only interactions?
Pass: All touch target requirements met.
Fail: Any target undersized or hover-only interaction present.

EVAL 3: Mobile Layout (model-graded)
Question: Does the layout work well on a 375px viewport — stacked grids, readable text (16-20px), full-width inputs, and adequate spacing?
Grading prompt: "Analyze the mobile (375px) layout — grid reflow, text readability, line lengths, content spacing, and navigation pattern. List issues and strengths. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Tablet & Desktop (model-graded)
Question: Does the tablet layout add value beyond stretched mobile, and does desktop use available space effectively?
Grading prompt: "Analyze tablet (768px) and desktop (1024px+) layouts — is tablet more than just wider mobile, does desktop use the space well, are there wasted gutters or overstretched content? List issues. Then score 1-10."
Pass threshold: >= 7

EVAL 5: Breakpoint Transitions (model-graded)
Question: Are transitions between breakpoints smooth without jarring jumps in layout, font size, or spacing?
Grading prompt: "Analyze the transitions at each breakpoint boundary — do elements reflow gracefully, are there sudden layout shifts, and is the visual rhythm maintained? List any jarring transitions. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT

```
## Responsive Audit: [Page/Component Name]

### Summary
[Overall responsive health and most critical issue]

### Breakpoint Report

#### Base (< 640px / Mobile)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|

#### sm (640px)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|

#### md (768px / Tablet)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|

#### lg (1024px / Desktop)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|

#### xl+ (1280px+)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|

### Scoring
| Criterion | Score | Notes |
|-----------|-------|-------|
| Mobile | X/10 | |
| Tablet | X/10 | |
| Desktop | X/10 | |
| Transitions | X/10 | |
| Touch UX | X/10 | |
| **Average** | **X/10** | |

### Critical Fixes (do first)
1. [Fix with Tailwind classes]
2. [Fix with Tailwind classes]
```

## EXAMPLES

### Input:
"Check if the pricing page is responsive — users on mobile are complaining"

### Output:
## Responsive Audit: Pricing Page

### Summary
Pricing cards use `grid-cols-3` with no responsive override — they render at ~125px wide on mobile, making content unreadable. Three critical issues, all fixable with responsive utility classes.

### Breakpoint Report

#### Base (Mobile)
| Issue | Severity | Current | Fix |
|-------|----------|---------|-----|
| Pricing grid doesn't stack | Critical | `grid-cols-3` | `grid-cols-1 md:grid-cols-3` |
| CTA button too narrow to tap | Critical | `px-2 py-1 text-xs` | `w-full py-3 text-base md:w-auto md:px-4 md:py-2 md:text-sm` |
| Feature comparison table overflows | Major | `<table>` with no wrapper | Wrap in `overflow-x-auto` and add `min-w-[600px]` to table |
| Plan names truncated | Major | `truncate` on heading | Remove `truncate`, allow wrapping on mobile |

**Scores:** Mobile: 3 | Tablet: 6 | Desktop: 8 | Transitions: 4 | Touch: 5
