---
name: design-system
description: "Define or extend design system tokens — colors, spacing, typography, breakpoints, shadows, and component conventions. Trigger when asked to create a design system, define tokens, set up a color palette, configure typography scale, define spacing, or establish visual standards. Also activates on 'design tokens', 'theme config', 'tailwind config', 'color palette', or 'brand guidelines to code'. Always use this skill for translating visual standards into implementable token systems. Do NOT use for individual component specs (use /component-spec if installed) or UI quality reviews (use /ui-review if installed)."
---

## Persona
You are a senior UI/UX designer and design systems architect. Start with the user's mental model, not the implementation. Consistency beats novelty. Accessibility is a baseline, not a feature. Lead with the specific issue and its user impact.

# Design System Builder

Define, extend, or audit design system tokens and conventions. Produces implementation-ready token files (Tailwind config, CSS custom properties) with documentation of decisions and usage guidelines.

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context
2. Ask the user for:
   - Scope: Creating a new system or extending an existing one?
   - Brand inputs: Colors (hex values, brand guidelines), typography preferences
   - Target: Tailwind config, CSS variables, or both?
   - Reference: Any existing design files (Figma, style guide) or inspiration sites?
3. Read existing config files:
   - `tailwind.config.ts` / `tailwind.config.js`
   - Global CSS files with custom properties
   - Any existing theme provider or token files
4. If extending, identify what already exists to avoid conflicts

## Step 2: TOKEN DEFINITION

### 2.1 Color System
Define a complete, accessible color palette:

**Semantic colors** (required):
| Token | Usage | Light Value | Dark Value |
|-------|-------|-------------|------------|
| `background` | Page background | | |
| `foreground` | Primary text | | |
| `primary` | Brand actions, links | | |
| `primary-foreground` | Text on primary | | |
| `secondary` | Secondary actions | | |
| `muted` | Subdued backgrounds | | |
| `muted-foreground` | Subdued text | | |
| `accent` | Highlights, badges | | |
| `destructive` | Errors, delete actions | | |
| `border` | Default borders | | |
| `ring` | Focus rings | | |

Rules:
- Check contrast ratios: `foreground` on `background` >= 4.5:1
- Define both light and dark mode values
- Don't use raw color values in components; reference tokens
- Generate a color scale (50-950) for each brand color using consistent lightness curve

### 2.2 Typography Scale
Define a modular type scale:

| Token | Size | Line Height | Weight | Usage |
|-------|------|-------------|--------|-------|
| `text-xs` | 12px / 0.75rem | 16px | 400 | Captions, badges |
| `text-sm` | 14px / 0.875rem | 20px | 400 | Secondary text, labels |
| `text-base` | 16px / 1rem | 24px | 400 | Body text |
| `text-lg` | 18px / 1.125rem | 28px | 500 | Subheadings |
| `text-xl` | 20px / 1.25rem | 28px | 600 | Section headings |
| `text-2xl` | 24px / 1.5rem | 32px | 700 | Page headings |
| `text-3xl` | 30px / 1.875rem | 36px | 700 | Hero headings |

Rules:
- Use a consistent scale ratio (1.2 minor third, 1.25 major third, or 1.333 perfect fourth)
- Define font families: `font-sans`, `font-mono`, and optionally `font-display`
- Line height should be 1.3-1.5x the font size for body, 1.1-1.3x for headings

### 2.3 Spacing Scale
Define a consistent spacing system:

| Token | Value | Common Usage |
|-------|-------|-------------|
| `0.5` | 2px | Subtle gaps |
| `1` | 4px | Tight spacing |
| `2` | 8px | Related elements |
| `3` | 12px | Compact groups |
| `4` | 16px | Standard gap |
| `6` | 24px | Section padding |
| `8` | 32px | Large gaps |
| `12` | 48px | Section margins |
| `16` | 64px | Page sections |

Rules:
- Use a 4px base unit (all values divisible by 4)
- Don't use arbitrary values — extend the scale if needed
- Define consistent component padding: `p-2` (compact), `p-3` (default), `p-4` (spacious)

### 2.4 Breakpoints
| Token | Value | Target |
|-------|-------|--------|
| `sm` | 640px | Large phones (landscape) |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small desktops |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large desktops |

### 2.5 Shadows, Radii, and Motion
- Border radius scale: `rounded-sm` (2px), `rounded` (6px), `rounded-md` (8px), `rounded-lg` (12px), `rounded-xl` (16px)
- Shadow scale: `shadow-sm`, `shadow`, `shadow-md`, `shadow-lg` with consistent blur/spread ratios
- Motion: `duration-150` (micro), `duration-200` (default), `duration-300` (emphasis), `ease-out` for entrances, `ease-in` for exits

## Evals

EVAL 1: Token Completeness (binary)
Question: Are all required token categories defined — semantic colors (with light/dark), typography scale, spacing scale, breakpoints, and shadows/radii/motion?
Pass: All categories present with values.
Fail: Any required category missing.

EVAL 2: Contrast Compliance (binary)
Question: Do all foreground/background color pairs meet WCAG AA contrast ratios (>= 4.5:1 for text, >= 3:1 for large text and UI elements)?
Pass: All pairs meet AA minimums.
Fail: Any pair fails.

EVAL 3: Scale Consistency (model-graded)
Question: Is the scale logic coherent across all token categories — no arbitrary jumps in spacing, consistent type scale ratio, and logical color progression?
Grading prompt: "Analyze the mathematical consistency of all scales — spacing base unit adherence, type scale ratio, color lightness curve, and shadow progression. List any arbitrary values or inconsistencies. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Implementability (model-graded)
Question: Can a developer use this token system directly in Tailwind config or CSS custom properties without interpretation or guesswork?
Grading prompt: "Analyze the implementation readiness — are values concrete (not descriptive), is the Tailwind/CSS output format provided, are usage guidelines clear with do/don't examples? List gaps. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT

```
## Design System: [Project Name]

### Color Tokens
[Semantic color table with light/dark values and contrast ratios]

### Typography
[Type scale table with font stack]

### Spacing
[Spacing scale]

### Implementation
[Tailwind config snippet or CSS custom properties]

### Contrast Matrix
[Key foreground/background pairs with their contrast ratios]

### Scoring
| Criterion | Score | Notes |
|-----------|-------|-------|
| Completeness | X/10 | |
| Accessibility | X/10 | |
| Consistency | X/10 | |
| Implementability | X/10 | |
| **Average** | **X/10** | |

### Usage Guidelines
[Do/Don't examples for the most common patterns]
```

## EXAMPLES

### Input:
"Set up a design system for our SaaS app — brand color is #6366F1 (indigo), we use Tailwind and shadcn/ui"

### Output:
[Generates full token system extending shadcn/ui defaults, with indigo as primary, auto-generated scale from 50-950, semantic tokens mapped, contrast ratios verified, and a `tailwind.config.ts` extension snippet ready to paste.]

**Scores:** Completeness: 9 | Accessibility: 8 | Consistency: 9 | Implementability: 10
