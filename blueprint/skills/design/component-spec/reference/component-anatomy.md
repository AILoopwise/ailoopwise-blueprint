# Component Anatomy Template

Standard structure for every component specification. Use this template when generating component specs with the `component-spec` skill.

## Required Sections

### 1. Overview
```
**Name**: PascalCase component name
**Purpose**: One sentence — what user problem does this solve?
**Category**: Layout | Navigation | Input | Feedback | Data Display | Overlay
**Base Element**: The HTML element or library primitive this wraps
**Library**: shadcn/ui | Radix | Headless UI | Custom
```

### 2. Props Table
```
| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
```

**Required props for every component:**
- `className?: string` — Style overrides via Tailwind
- `children?: ReactNode` — If the component wraps content
- `ref?: Ref<HTMLElement>` — Forward ref for interactive elements
- `asChild?: boolean` — If using Radix/shadcn composition pattern

**Prop naming conventions:**
- Boolean props: `is` prefix for state (`isOpen`, `isLoading`), no prefix for behavior (`disabled`, `required`)
- Event handlers: `on` prefix (`onClick`, `onChange`, `onOpenChange`)
- Variants: String union types (`"default" | "destructive" | "outline"`)
- Sizes: `"sm" | "md" | "lg"` (use t-shirt sizes)

### 3. Variants (using cva or equivalent)
```ts
const componentVariants = cva("base-classes", {
  variants: {
    variant: {
      default: "...",
      // other variants
    },
    size: {
      sm: "...",
      md: "...",
      lg: "...",
    },
  },
  defaultVariants: {
    variant: "default",
    size: "md",
  },
})
```

### 4. States Table
```
| State | Trigger | Visual Change | Behavior Change |
|-------|---------|---------------|-----------------|
| Default | Initial render | Base styles | Normal interaction |
| Hover | Mouse enter | [specify] | — |
| Focus | Tab / click | Focus ring visible | — |
| Active | Mouse down / Enter | [specify] | — |
| Disabled | `disabled` prop | opacity-50, cursor-not-allowed | No interaction |
| Loading | `isLoading` prop | Spinner replaces content | No interaction |
| Error | `error` prop | Error border/message | Shows error |
| Selected | `isSelected` prop | Highlight / check | — |
```

Not every component needs every state. Include what applies.

### 5. Accessibility Requirements
```
**Role**: [ARIA role if not implicit from HTML element]
**Keyboard**:
  - Tab: [what happens]
  - Enter/Space: [what happens]
  - Escape: [what happens]
  - Arrow keys: [what happens, if applicable]
**Screen Reader**:
  - Label: [source — visible text, aria-label, or aria-labelledby]
  - State: [aria-expanded, aria-selected, aria-checked, etc.]
  - Announcements: [aria-live regions for dynamic content]
**Focus Management**:
  - [Where focus goes on open/close/mount/unmount]
  - [Whether focus is trapped (modals) or free]
```

### 6. Composition Patterns
Show 3-4 usage examples:

```tsx
// Basic usage
<Component>Content</Component>

// With variants
<Component variant="destructive" size="lg">Delete</Component>

// Composed with sub-components
<Component>
  <Component.Icon />
  <Component.Label />
  <Component.Description />
</Component>

// Controlled
const [open, setOpen] = useState(false)
<Component open={open} onOpenChange={setOpen} />
```

### 7. Edge Cases
Document known edge cases and how to handle them:
- **Overflow**: What happens when content exceeds bounds? (truncate, wrap, scroll)
- **Empty**: What does the component look like with no content?
- **Max content**: What happens with very long text or many items?
- **RTL**: Does the component support right-to-left layouts?
- **SSR**: Any hydration concerns?
- **Animation**: Does it respect `prefers-reduced-motion`?

### 8. Scoring
```
| Criterion | Score | Notes |
|-----------|-------|-------|
| Completeness | X/10 | All props, states, variants defined? |
| Developer Clarity | X/10 | Implementable without asking questions? |
| Accessibility | X/10 | ARIA, keyboard, screen reader explicit? |
| Consistency | X/10 | Matches existing project patterns? |
| **Average** | **X/10** | |
```

---

## File Structure Convention

When generating component files, follow this structure:
```
components/ui/
├── component-name.tsx        # Component implementation
├── component-name.stories.tsx # Storybook stories (if using Storybook)
└── component-name.test.tsx   # Tests (if requested)
```

For compound components:
```
components/ui/component-name/
├── index.tsx                  # Root + sub-component exports
├── component-name.tsx         # Main component
├── component-name-item.tsx    # Sub-component
├── component-name-context.tsx # Shared context (if needed)
└── types.ts                   # Shared types
```
