---
name: hig-review
description: "Audit interfaces against Apple Human Interface Guidelines for iOS, macOS, iPadOS, watchOS, and visionOS. Trigger when asked to check HIG compliance, review Apple platform conventions, audit iOS patterns, check macOS guidelines, or ensure platform consistency. Also activates on 'HIG', 'Human Interface Guidelines', 'Apple design', 'iOS design', 'macOS design', 'SF Symbols', 'SwiftUI patterns', or 'native feel'. Always use this skill for ensuring apps follow Apple platform conventions. Do not use for general UI reviews (use /ui-review if installed) or web-only responsive audits (use /responsive-audit if installed)."
---

## Persona
You are a senior UI/UX designer and design systems architect. Start with the user's mental model, not the implementation. Consistency beats novelty. Accessibility is a baseline, not a feature. Lead with the specific issue and its user impact.

# Apple HIG Review

Audit an interface against Apple Human Interface Guidelines. Ensures platform-native feel by checking navigation patterns, system controls, SF Symbols usage, typography, spacing, and interaction conventions. Applies to native apps (SwiftUI/UIKit) and web apps targeting Apple platforms.

## Step 1: CONTEXT GATHERING
Before starting:
1. Check `tasks/current.md` for project context
2. Ask the user for:
   - Target platform(s): iOS, macOS, iPadOS, watchOS, visionOS, web (Safari-focused)
   - Implementation: SwiftUI, UIKit, React Native, or web (React/Tailwind)
   - The screen or component to review (file path or screenshot)
   - Whether the goal is native-feeling or just HIG-informed
3. Read the relevant code to understand current implementation
4. Reference `reference/hig-checklist.md` for platform-specific criteria

## Step 2: HIG AUDIT

### 2.1 Navigation Patterns
Verify platform-appropriate navigation:

**iOS:**
- Tab bar for top-level destinations (max 5)
- Navigation stack with back button for hierarchical content
- Modal sheets for focused tasks (`.sheet`, not fullscreen unless necessary)
- No hamburger menus — use tab bars or sidebar on iPad

**macOS:**
- Sidebar navigation for content categories
- Toolbar for contextual actions
- Menu bar integration for global actions
- Window management respects expected behaviors (resize, fullscreen, split)

**iPadOS:**
- Sidebar + detail pattern for regular/compact size classes
- Supports multitasking (Split View, Slide Over)
- Adapts from iPhone layout at compact width

**Web (targeting Apple users):**
- Respect Safari conventions (no custom scrollbars, respect rubber-banding)
- Large touch targets for iPad Safari users
- Support for Dynamic Type via responsive font sizing

### 2.2 System Controls and Components
- Using system-provided controls where they exist (no custom when system suffices)?
- Buttons follow platform style (filled, tinted, bordered, plain hierarchy)?
- Lists use standard styles (inset grouped, plain, sidebar)?
- Forms use appropriate input types with platform keyboards?
- Alerts and action sheets follow system patterns?
- Popovers used correctly (iPad) vs. action sheets (iPhone)?

### 2.3 Typography
- Using SF Pro (iOS/macOS) or system font stack for web?
- Following the Dynamic Type scale (Title, Headline, Body, Callout, Caption, etc.)?
- Supporting Dynamic Type / text scaling accessibility?
- Not mixing too many font weights or sizes (aim for 3-4 per screen)?
- Text styles match semantic purpose (Title for titles, Body for content)?

### 2.4 SF Symbols and Iconography
- Using SF Symbols where available (not custom icons for standard concepts)?
- Symbols use appropriate rendering mode (monochrome, hierarchical, palette, multicolor)?
- Symbols are appropriately sized relative to adjacent text?
- Custom icons match SF Symbols weight and optical alignment?
- Symbols have accessibility labels when used without text?

### 2.5 Color and Materials
- Using semantic colors (`label`, `secondaryLabel`, `systemBackground`, `tertiarySystemFill`)?
- Supporting both light and dark mode?
- Using system materials (blur effects) appropriately?
- Accent color used consistently for interactive elements?
- Not fighting the system appearance (e.g., forcing light mode)?

### 2.6 Layout and Spacing
- Respecting safe areas (notch, home indicator, Dynamic Island)?
- Using standard margins (16pt on iPhone, 20pt on iPad)?
- Content alignment follows platform conventions (leading-aligned text)?
- Spacing is consistent with the 4pt/8pt grid?
- Cards, lists, and grouped content use system insets?

### 2.7 Interaction and Feedback
- Swipe actions available on list items where expected (delete, archive)?
- Pull-to-refresh on scrollable content?
- Haptic feedback for significant actions (impact, selection, notification)?
- Long-press context menus on actionable elements?
- Smooth, interruptible animations (no blocking animations)?

### 2.8 Privacy and Permissions
- Requesting permissions at point of need (not on launch)?
- Clear purpose strings explaining why each permission is needed?
- Graceful degradation when permissions are denied?
- No tracking without App Tracking Transparency prompt?

## Evals

EVAL 1: Navigation Pattern Compliance (binary)
Question: Does the app use platform-correct navigation — tab bar (iOS), sidebar (macOS/iPadOS), navigation stack with back button — with no anti-patterns like hamburger menus on iOS?
Pass: Navigation matches HIG for the target platform.
Fail: Any navigation anti-pattern present.

EVAL 2: System Controls Usage (binary)
Question: Are system-provided controls used where they exist (Toggle, List styles, Alerts, Action Sheets, Popovers) instead of custom replacements?
Pass: No custom controls replacing available system equivalents.
Fail: Any unnecessary custom control found.

EVAL 3: Typography & Iconography (model-graded)
Question: Does the app follow Dynamic Type scale and SF Symbols conventions — system font, semantic text styles, appropriate symbol rendering modes, and accessibility labels on icon-only elements?
Grading prompt: "Analyze typography and iconography against HIG — Dynamic Type support, SF Symbols usage vs custom icons, font weight variety, and symbol sizing relative to text. List deviations. Then score 1-10."
Pass threshold: >= 7

EVAL 4: Platform Visual Feel (model-graded)
Question: Do colors, materials, spacing, and interactions feel native to the target Apple platform?
Grading prompt: "Analyze visual design and interactions — semantic color usage, light/dark mode support, system materials, safe area respect, standard margins, haptic feedback, and gesture support. List what feels native and what feels custom. Then score 1-10."
Pass threshold: >= 7

Target: 85%+ combined score. Max 3 revision loops.

## Step 4: OUTPUT FORMAT

```
## HIG Review: [Screen/Component Name]
**Platform**: [iOS/macOS/iPadOS/watchOS/visionOS/Web]

### Summary
[1-2 sentences: how native does this feel and what's the biggest gap?]

### Findings

#### Platform Violations (breaks conventions)
| # | HIG Area | Issue | Current | Recommended |
|---|----------|-------|---------|-------------|

#### Improvements (enhances native feel)
| # | HIG Area | Issue | Current | Recommended |
|---|----------|-------|---------|-------------|

#### Polish (refinements)
| # | HIG Area | Issue | Current | Recommended |
|---|----------|-------|---------|-------------|

### Scoring
| Criterion | Score | Notes |
|-----------|-------|-------|
| Navigation | X/10 | |
| System Controls | X/10 | |
| Typography & Icons | X/10 | |
| Visual Design | X/10 | |
| Interactions | X/10 | |
| **Average** | **X/10** | |

### Platform-Specific Notes
[Any platform-version-specific guidance (e.g., iOS 18 features)]
```

## EXAMPLES

### Input:
"Review our iOS settings screen — it feels custom and not Apple-native"

### Output:
## HIG Review: Settings Screen
**Platform**: iOS

### Summary
The settings screen uses a custom card layout instead of system grouped lists, custom toggle switches instead of UISwitch, and a non-standard navigation pattern. These three changes account for most of the "non-native" feeling.

### Platform Violations
| # | HIG Area | Issue | Current | Recommended |
|---|----------|-------|---------|-------------|
| 1 | System Controls | Custom toggle switch with different size and animation | Custom `<Switch>` component | Use system `Toggle()` in SwiftUI / `UISwitch` in UIKit — users expect system feel for toggles |
| 2 | Navigation | Settings uses bottom tab instead of being pushed from profile | Tab bar item "Settings" | Move to navigation push from profile icon, or gear icon in nav bar — HIG reserves tabs for top-level content destinations |
| 3 | Layout | Settings items in floating cards with shadows | `CardView` with custom padding | Use `List { Section { } }` with `.insetGrouped` style — this is the system pattern for settings |

### Improvements
| # | HIG Area | Issue | Current | Recommended |
|---|----------|-------|---------|-------------|
| 4 | Typography | Section headers are custom bold 18pt | `Font.system(size: 18, weight: .bold)` | Use `.font(.headline)` — system manages size for Dynamic Type |
| 5 | Icons | Settings icons are custom line icons | Custom SVG icons | Use SF Symbols (`gear`, `bell`, `lock.shield`, `person.crop.circle`) with `.symbolRenderingMode(.hierarchical)` |
| 6 | Interaction | No swipe actions on settings rows | Tap only | Not critical for settings, but destructive items (Delete Account) benefit from swipe to confirm pattern |

**Scores:** Navigation: 5 | System Controls: 3 | Typography & Icons: 6 | Visual Design: 5 | Interactions: 6
