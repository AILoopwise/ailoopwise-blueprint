# Apple Human Interface Guidelines Checklist

Platform-specific checklist for Apple HIG compliance. Use during `hig-review` skill audits.

---

## Universal (All Apple Platforms)

### Typography
- [ ] Using system font (SF Pro on iOS/macOS, SF Compact on watchOS, NY for serif)
- [ ] Following the Dynamic Type text styles (LargeTitle, Title, Headline, Body, Callout, Subheadline, Footnote, Caption)
- [ ] Supporting Dynamic Type scaling (text responds to user's preferred text size)
- [ ] Not using more than 3-4 font weights per screen
- [ ] Minimum body text size: 17pt (iOS), 13pt (macOS)
- [ ] Sufficient line spacing for readability

### Color
- [ ] Using semantic/system colors (`label`, `secondaryLabel`, `systemBackground`, etc.)
- [ ] Works in both Light and Dark Mode
- [ ] Works in High Contrast mode (Increase Contrast accessibility setting)
- [ ] Accent color is consistent and used for interactive elements
- [ ] Not relying on color alone to convey information
- [ ] Tint colors distinguish interactive from non-interactive elements

### SF Symbols
- [ ] Using SF Symbols instead of custom icons for standard concepts
- [ ] Symbols use appropriate rendering mode:
  - Monochrome: Single color, simplest
  - Hierarchical: Single color with depth/layering
  - Palette: Multiple custom colors
  - Multicolor: Fixed, predefined colors
- [ ] Symbols are sized relative to adjacent text (use `font` configuration)
- [ ] Custom symbols match SF Symbols weight and optical metrics
- [ ] All symbols have accessibility labels when used without visible text

### Accessibility
- [ ] All controls are accessible via VoiceOver
- [ ] VoiceOver labels are concise and descriptive
- [ ] Supports Bold Text accessibility setting
- [ ] Supports Reduce Motion (no essential info in animations)
- [ ] Supports Reduce Transparency
- [ ] Supports Switch Control and Voice Control
- [ ] Buttons and controls have minimum 44x44pt touch target

### Layout
- [ ] Content respects Safe Areas (no content under notch, Dynamic Island, home indicator)
- [ ] Uses standard system margins (16pt iPhone, 20pt iPad)
- [ ] Follows 4pt/8pt spacing grid
- [ ] Supports both portrait and landscape (unless app is inherently single-orientation)
- [ ] Leading-aligned text (not center-aligned body text)

---

## iOS Specific

### Navigation
- [ ] **Tab Bar** used for top-level destinations (3-5 items max)
- [ ] Tab bar items have both icon (SF Symbol) and text label
- [ ] Tab bar is always visible (not hidden on scroll unless explicitly needed)
- [ ] **Navigation Bar** used for hierarchical navigation with back button
- [ ] Back button includes previous screen's title or "Back"
- [ ] Large title used on top-level screens, inline title on pushed screens
- [ ] **No hamburger menu** — use tab bar, sidebar (iPad), or navigation stack

### Sheets and Modals
- [ ] Sheets used for focused, self-contained tasks
- [ ] Sheets have a clear dismiss mechanism (swipe down, X button, or "Done")
- [ ] Fullscreen modals reserved for immersive content (photo editing, document creation)
- [ ] Alert dialogs have max 2 buttons (preferred) or 3 (rare)
- [ ] Destructive actions in alerts are red and on the left (iOS convention)

### Lists and Tables
- [ ] Using system list styles (`.insetGrouped` for settings, `.plain` for content)
- [ ] Swipe actions for contextual operations (delete, archive, flag)
- [ ] Pull-to-refresh on scrollable content where data can be stale
- [ ] Section headers for grouped content
- [ ] Disclosure indicators (chevron) for drill-down rows

### Search
- [ ] Search bar follows system placement (below navigation bar or inline)
- [ ] Search shows recent searches and suggestions
- [ ] Results update as user types (when feasible)
- [ ] Cancel button dismisses search cleanly

### System Integration
- [ ] Share Sheet used for sharing (not custom share UI)
- [ ] Haptic feedback on significant interactions:
  - Impact: Physical feel (button press, toggle)
  - Selection: Light tick (picker, segment change)
  - Notification: Success, warning, error
- [ ] Context menus (long press) on actionable items with preview
- [ ] Respects system settings (text size, reduce motion, dark mode)

---

## macOS Specific

### Window and Layout
- [ ] Supports standard window management (resize, minimize, fullscreen, close)
- [ ] Remembers window size and position across launches
- [ ] Sidebar navigation for content categories (optional: collapsible)
- [ ] Toolbar for contextual actions (customizable if complex app)
- [ ] Inspector panel for detail/properties (if applicable)

### Menu Bar
- [ ] App has a complete menu bar with standard menus (File, Edit, View, Window, Help)
- [ ] Keyboard shortcuts listed in menu items
- [ ] Standard shortcuts respected (Cmd+Q quit, Cmd+W close, Cmd+, preferences)
- [ ] Context menus (right-click) on relevant elements

### Controls
- [ ] Using AppKit/SwiftUI standard controls (not custom when system exists)
- [ ] Buttons follow macOS hierarchy (filled, bordered, borderless)
- [ ] Popovers used for secondary information (not modal dialogs)
- [ ] Sheets attached to windows for window-specific tasks
- [ ] Sidebars use source list style with selection highlighting

### Typography
- [ ] System font (SF Pro) at standard macOS sizes (13pt body minimum)
- [ ] Not using iOS-style large titles (macOS uses smaller, denser layout)

---

## iPadOS Specific

### Multitasking
- [ ] Supports Split View and Slide Over
- [ ] Content adapts between Regular and Compact size classes
- [ ] Stage Manager compatible (resizable windows)

### Layout
- [ ] Sidebar + Detail pattern for wide layouts
- [ ] Sidebar collapses on compact width (falls back to navigation stack)
- [ ] Content uses available width (no fixed-width centered content with empty margins)
- [ ] Pointer (trackpad/mouse) support with hover states

### Input
- [ ] Keyboard shortcuts for common actions (with Cmd key, matching macOS conventions)
- [ ] Hardware keyboard navigation support
- [ ] Pencil support where drawing/annotation is relevant
- [ ] Drag and drop between apps and within app

---

## watchOS Specific

### Layout
- [ ] Content designed for quick glances (10-15 seconds)
- [ ] Vertical scrolling only (no horizontal)
- [ ] Large, tappable controls (full-width buttons)
- [ ] Using Digital Crown for scrolling and value input

### Complications
- [ ] Provide at least one complication for the watch face
- [ ] Complications show timely, glanceable data
- [ ] Tapping complication launches relevant screen

---

## visionOS Specific

### Spatial Design
- [ ] Windows float in space at comfortable viewing distance
- [ ] Content uses glass material (vibrancy) for backgrounds
- [ ] No sharp edges or heavy shadows (feel lightweight and spatial)
- [ ] Text and controls are large enough for eye/hand tracking

### Input
- [ ] Look and tap (eye tracking + pinch) as primary input
- [ ] Hover states visible when user looks at interactive elements
- [ ] No drag-heavy interactions (spatial drag is imprecise)

### Immersion
- [ ] Start in Shared Space (window alongside other apps)
- [ ] Only request Full Space when immersion is essential
- [ ] Provide comfortable transitions between immersion levels

---

## Quick-Check Priority (iOS apps)
When time is limited, check these first:
1. Tab bar for navigation (no hamburger)
2. System controls instead of custom (toggles, lists, alerts)
3. SF Symbols instead of custom icons
4. Dynamic Type support
5. Light and Dark mode
6. Safe area respect
7. Haptic feedback on key actions
8. Swipe actions on list items
