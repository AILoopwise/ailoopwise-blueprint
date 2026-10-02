# WCAG 2.2 AA Checklist

Actionable checklist for WCAG 2.2 Level AA conformance. Each item includes the success criterion number, a plain-language check, and a common fix.

## 1. Perceivable

### 1.1 Text Alternatives
- [ ] **1.1.1** Every `<img>` has `alt` text. Decorative images use `alt=""`. Complex images have extended descriptions.
  - Fix: Add `alt="description"` or `alt=""` to every image element.

### 1.2 Time-Based Media
- [ ] **1.2.1** Audio-only and video-only content has text alternatives (transcripts).
- [ ] **1.2.2** Videos have synchronized captions.
- [ ] **1.2.5** Videos have audio descriptions for visual-only content.

### 1.3 Adaptable
- [ ] **1.3.1** Content structure is conveyed through semantic HTML (headings, lists, tables, landmarks), not just visual styling.
  - Fix: Use `<h1>`-`<h6>`, `<nav>`, `<main>`, `<aside>`, `<section>`, `<ul>/<ol>`.
- [ ] **1.3.2** Reading order in the DOM matches visual order. CSS `order` or absolute positioning does not break logical sequence.
- [ ] **1.3.3** Instructions do not rely solely on sensory characteristics ("click the blue button", "the item on the left").
- [ ] **1.3.4** Content does not restrict display orientation (portrait/landscape) unless essential.
- [ ] **1.3.5** Form inputs identify their purpose with `autocomplete` attributes where applicable.

### 1.4 Distinguishable
- [ ] **1.4.1** Color is not the only way to convey information (add text, icons, or patterns).
  - Fix: Error states need text labels, not just red borders.
- [ ] **1.4.3** Text contrast ratio >= 4.5:1 (normal text) or >= 3:1 (large text: 18pt+ or 14pt bold+).
- [ ] **1.4.4** Text can be resized to 200% without losing content or functionality.
- [ ] **1.4.5** Text is used instead of images of text (except logos).
- [ ] **1.4.10** Content reflows at 320px width (no horizontal scrolling at 400% zoom).
- [ ] **1.4.11** UI components and graphics have >= 3:1 contrast against adjacent colors.
  - Fix: Borders, icons, and focus rings must meet this threshold.
- [ ] **1.4.12** Text spacing can be overridden (line-height 1.5x, paragraph spacing 2x, letter spacing 0.12em, word spacing 0.16em) without breaking layout.
- [ ] **1.4.13** Hover/focus-triggered content (tooltips, popovers) is dismissible, hoverable, and persistent.

## 2. Operable

### 2.1 Keyboard Accessible
- [ ] **2.1.1** All functionality is operable via keyboard (Tab, Enter, Space, Escape, Arrow keys).
  - Fix: If using `onClick` on a `<div>`, switch to `<button>` or add `role="button" tabIndex={0} onKeyDown`.
- [ ] **2.1.2** No keyboard traps — users can always Tab away (modals may trap focus intentionally but must have an escape mechanism).
- [ ] **2.1.4** Single-character shortcuts (if any) can be remapped or disabled.

### 2.2 Enough Time
- [ ] **2.2.1** Time limits are adjustable, extendable, or removable (except real-time events).
- [ ] **2.2.2** Auto-moving/scrolling content can be paused, stopped, or hidden.

### 2.3 Seizures and Physical Reactions
- [ ] **2.3.1** No content flashes more than 3 times per second.

### 2.4 Navigable
- [ ] **2.4.1** Skip navigation link ("Skip to content") is the first focusable element.
- [ ] **2.4.2** Pages have descriptive `<title>` elements.
- [ ] **2.4.3** Focus order follows a logical sequence matching visual layout.
- [ ] **2.4.4** Link text is descriptive (no "click here" or "read more" without context).
- [ ] **2.4.5** Multiple ways to find pages (navigation, search, sitemap).
- [ ] **2.4.6** Headings and labels are descriptive.
- [ ] **2.4.7** Focus indicator is always visible on keyboard-focused elements.
  - Fix: Never use `outline: none` without a replacement focus style (e.g., `ring-2 ring-offset-2`).
- [ ] **2.4.11** Focus is not obscured by other content (sticky headers, footers, modals).

### 2.5 Input Modalities
- [ ] **2.5.1** Multi-point gestures (pinch, multi-finger swipe) have single-pointer alternatives.
- [ ] **2.5.2** Pointer actions can be cancelled (use `mouseup`/`keyup`, not `mousedown`/`keydown` for activation).
- [ ] **2.5.3** Visible labels match accessible names (what you see is what screen readers say).
- [ ] **2.5.4** Motion-activated functions (shake, tilt) have UI alternatives and can be disabled.
- [ ] **2.5.7** Dragging actions have non-dragging alternatives.
- [ ] **2.5.8** Touch targets are at least 24x24px (44x44px recommended).

## 3. Understandable

### 3.1 Readable
- [ ] **3.1.1** Page language is declared: `<html lang="en">`.
- [ ] **3.1.2** Language changes within the page are marked: `<span lang="fr">`.

### 3.2 Predictable
- [ ] **3.2.1** Focus does not trigger unexpected context changes (no auto-submit on focus).
- [ ] **3.2.2** Input does not trigger unexpected context changes (no auto-navigate on select).
- [ ] **3.2.3** Navigation is consistent across pages.
- [ ] **3.2.4** Components with the same function are identified consistently.

### 3.3 Input Assistance
- [ ] **3.3.1** Input errors are identified and described in text.
  - Fix: Show error messages adjacent to the field, not just at the top of the form.
- [ ] **3.3.2** Labels and instructions are provided for user input.
  - Fix: Every `<input>` needs a `<label>` (visible or `sr-only`). Placeholder alone is insufficient.
- [ ] **3.3.3** Error messages suggest corrections when possible.
- [ ] **3.3.4** Legal, financial, and data-deletion actions are reversible, confirmed, or reviewed before submission.
- [ ] **3.3.7** Redundant entry: information previously provided is auto-populated or selectable.
- [ ] **3.3.8** Accessible authentication: no cognitive function test (memory, puzzle) required to log in. Support password managers and passkeys.

## 4. Robust

### 4.1 Compatible
- [ ] **4.1.2** All UI components expose name, role, and value to assistive technology.
  - Fix: Custom widgets need appropriate ARIA roles, states, and properties.
- [ ] **4.1.3** Status messages use `role="status"` or `aria-live="polite"` so screen readers announce them without receiving focus.

---

## Quick-Check Priority Order
When time is limited, check these first (most common failures):
1. Color contrast (1.4.3, 1.4.11)
2. Keyboard access (2.1.1)
3. Focus visibility (2.4.7)
4. Form labels (3.3.2)
5. Image alt text (1.1.1)
6. Heading structure (1.3.1)
7. Link text (2.4.4)
8. Touch targets (2.5.8)
