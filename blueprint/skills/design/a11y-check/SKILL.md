---
name: a11y-check
description: "Deep accessibility audit against WCAG 2.2 AA with specific remediation steps. Trigger when asked to check accessibility, audit a11y, review for screen readers, check ARIA, verify keyboard navigation, or test color contrast. Also activates on 'accessibility', 'a11y', 'WCAG', 'screen reader', 'keyboard nav', 'color contrast', or 'assistive technology'. Always use this skill for comprehensive accessibility evaluation beyond the quick check in ui-review. Do not use for general UI reviews (use /ui-review if installed), responsive audits (use /responsive-audit if installed), or design system work (use /design-system if installed)."
---

## Persona
You are a senior UI/UX designer and design systems architect. Start with the user's mental model, not the implementation. Consistency beats novelty. Accessibility is a baseline, not a feature. Lead with the specific issue and its user impact.

# Accessibility Audit (WCAG 2.2 AA)

Comprehensive accessibility audit against WCAG 2.2 Level AA success criteria. Produces a categorized findings report with specific remediation code and testing instructions.

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context
2. Ask the user for:
   - The page or component to audit (file path)
   - Target WCAG level (default: AA)
   - Any known accessibility issues or user complaints
   - Assistive technologies used by their audience (if known)
3. Read the component code, focusing on HTML semantics, ARIA attributes, and event handlers
4. Reference `reference/wcag-checklist.md` for the complete criteria list

## Step 2: AUDIT PROCESS

Audit against the four WCAG principles (POUR):

### 2.1 Perceivable
**Can all users perceive the content?**

| Check | What to Verify | How to Test |
|-------|---------------|-------------|
| Text contrast | Body text >= 4.5:1, large text >= 3:1 against background | Extract color values, calculate ratios |
| UI component contrast | Borders, icons, focus indicators >= 3:1 against adjacent | Check computed Tailwind colors |
| Images | All `<img>` have `alt`. Decorative: `alt=""`. Informative: descriptive alt. | Grep for `<img` without `alt` |
| Color alone | Information not conveyed by color alone (add icons, text, patterns) | Check error states, status indicators |
| Text resize | Content readable at 200% zoom without horizontal scroll | Check for fixed widths, overflow |
| Motion | Animations respect `prefers-reduced-motion` | Search for transitions/animations |
| Audio/Video | Captions and transcripts provided | Check media elements |

### 2.2 Operable
**Can all users operate the interface?**

| Check | What to Verify | How to Test |
|-------|---------------|-------------|
| Keyboard access | All interactive elements reachable via Tab | Trace `tabIndex`, check for `onClick` without `onKeyDown` |
| Focus visible | Focus indicator visible on all interactive elements | Check for `outline-none` without `ring` replacement |
| Focus order | Tab order matches visual order | Check DOM order vs. CSS `order` or absolute positioning |
| Focus trap | Modals trap focus; focus returns on close | Check dialog/modal components |
| No keyboard trap | User can always Tab away (except intentional modals) | Check for focus traps without escape |
| Skip links | "Skip to content" link before repetitive navigation | Check first focusable element |
| Touch target | Interactive elements >= 44x44px (WCAG 2.5.8) | Check computed sizes |
| Timing | No time limits, or adjustable/extendable | Check auto-dismiss, session timeouts |

### 2.3 Understandable
**Can all users understand the content and interface?**

| Check | What to Verify | How to Test |
|-------|---------------|-------------|
| Language | `<html lang="...">` set correctly | Check document root |
| Labels | All form inputs have associated `<label>` or `aria-label` | Grep for inputs without labels |
| Error identification | Errors are described in text (not just color/icon) | Check form validation |
| Error suggestion | Error messages suggest how to fix | Review error message content |
| Consistent navigation | Navigation is consistent across pages | Compare nav components |
| Consistent identification | Same actions use same labels/icons | Check button text consistency |

### 2.4 Robust
**Is the code compatible with assistive technologies?**

| Check | What to Verify | How to Test |
|-------|---------------|-------------|
| Valid HTML | No duplicate IDs, proper nesting, closed tags | Check for common issues |
| ARIA roles | Correct roles on custom widgets (e.g., `role="dialog"`, `role="tab"`) | Audit ARIA usage |
| ARIA states | Dynamic states reflected (`aria-expanded`, `aria-selected`, `aria-checked`) | Check interactive components |
| ARIA labels | `aria-label` or `aria-labelledby` on elements without visible text | Check icon buttons, links |
| Live regions | Dynamic content updates announced (`aria-live`, `role="status"`) | Check toasts, alerts, loaders |
| Name/Role/Value | All custom controls expose name, role, and value to AT | Check custom widgets |

## Evals

EVAL 1: Perceivable (binary)
Question: Does text contrast meet >= 4.5:1 (3:1 for large text/UI), do all images have appropriate alt text, is no information conveyed by color alone, and does content work at 200% zoom?
Pass: All perceivable checks pass.
Fail: Any check fails.

EVAL 2: Keyboard & Focus (binary)
Question: Are all interactive elements reachable via Tab, is a visible focus indicator present on every focusable element, does focus order match visual order, and do modals trap and return focus correctly?
Pass: All keyboard/focus checks pass.
Fail: Any check fails.

EVAL 3: ARIA & Semantics (binary)
Question: Is HTML valid (no duplicate IDs, proper nesting), are ARIA roles correct on custom widgets, are dynamic states reflected (aria-expanded, aria-selected), and do all custom controls expose name/role/value?
Pass: All semantic checks pass.
Fail: Any check fails.

EVAL 4: Labels & Error Handling (binary)
Question: Do all form inputs have associated labels (visible or aria-label), are errors described in text (not just color/icon), do error messages suggest remediation, and is `<html lang>` set?
Pass: All checks pass.
Fail: Any check fails.

EVAL 5: Overall WCAG Conformance (model-graded)
Question: Taking all four POUR principles together, how thoroughly does this page/component conform to WCAG 2.2 AA?
Grading prompt: "Analyze overall WCAG 2.2 AA conformance across Perceivable, Operable, Understandable, and Robust. List remaining gaps, their severity, and user impact. Then score 1-10."
Pass threshold: >= 7

WCAG conformance note: A single Critical failure means the page does NOT conform to WCAG AA, regardless of eval scores.

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT

```
## Accessibility Audit: [Page/Component Name]
**Target Level**: WCAG 2.2 AA

### Conformance Summary
[CONFORMS / DOES NOT CONFORM] — [X critical, Y major, Z minor findings]

### Findings by Priority

#### Critical (WCAG violation — must fix)
| # | WCAG SC | Issue | Location | Remediation |
|---|---------|-------|----------|-------------|
| 1 | [e.g., 1.4.3] | [Issue] | [file:line] | [Code fix] |

#### Major (Significant barrier)
| # | WCAG SC | Issue | Location | Remediation |
|---|---------|-------|----------|-------------|

#### Minor (Best practice)
| # | Issue | Location | Remediation |
|---|-------|----------|-------------|

### Scoring (POUR)
| Criterion | Score | Notes |
|-----------|-------|-------|
| Perceivable | X/10 | |
| Operable | X/10 | |
| Understandable | X/10 | |
| Robust | X/10 | |
| **Average** | **X/10** | |

### Testing Checklist
- [ ] Keyboard-only navigation test
- [ ] Screen reader test (VoiceOver / NVDA)
- [ ] 200% zoom test
- [ ] High contrast mode test
- [ ] prefers-reduced-motion test
```

## EXAMPLES

### Input:
"Run an accessibility audit on our dashboard component at `src/components/Dashboard.tsx`"

### Output:
## Accessibility Audit: Dashboard
**Target Level**: WCAG 2.2 AA

### Conformance Summary
DOES NOT CONFORM — 3 critical, 4 major, 2 minor findings

### Critical Findings
| # | WCAG SC | Issue | Location | Remediation |
|---|---------|-------|----------|-------------|
| 1 | 1.1.1 | Chart images have no alt text — data is invisible to screen readers | Dashboard.tsx:45 | Add `aria-label` describing chart data or provide data table alternative |
| 2 | 2.1.1 | Metric cards use `onClick` with no keyboard handler — unreachable via Tab | Dashboard.tsx:72 | Change `<div onClick>` to `<button>` or add `role="button" tabIndex={0} onKeyDown` |
| 3 | 4.1.2 | Notification badge has no accessible name — screen reader says "3" with no context | Dashboard.tsx:28 | Add `aria-label="3 unread notifications"` |

**Scores:** Perceivable: 4 | Operable: 5 | Understandable: 7 | Robust: 5
