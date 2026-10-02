# Design Heuristics

## Nielsen's 10 Usability Heuristics

### 1. Visibility of System Status
The system should always keep users informed about what is going on through timely and appropriate feedback.

**Check for:**
- Loading indicators on async operations (skeleton screens, spinners, progress bars)
- Success/error feedback after actions (toasts, inline messages)
- Progress indicators for multi-step flows (step counter, progress bar)
- Active state on current navigation item
- Real-time validation on form inputs

**Common violations:**
- Silent failures (action fails with no feedback)
- Ambiguous loading (page goes blank during load)
- No confirmation after destructive actions

### 2. Match Between System and Real World
The system should speak the users' language with words, phrases, and concepts familiar to the user.

**Check for:**
- Labels use user vocabulary, not developer jargon
- Icons match common mental models (trash can = delete, gear = settings)
- Data formats match user expectations (dates, currency, units)
- Metaphors are consistent (if "folders" are used, they should behave like folders)

**Common violations:**
- Technical error messages ("Error 500", "null reference")
- Developer-facing labels ("Submit payload", "Sync state")
- Inconsistent terminology (same concept called different things on different screens)

### 3. User Control and Freedom
Users need a clearly marked "emergency exit" to leave unwanted states without extended dialogue.

**Check for:**
- Undo for destructive actions (especially delete)
- Cancel buttons on forms and modals
- Back navigation always available
- Ability to dismiss modals and overlays (Escape key, backdrop click)
- Draft saving for long forms

**Common violations:**
- No undo on delete
- Modal with no close button
- Multi-step form with no way to go back
- Auto-saving without undo

### 4. Consistency and Standards
Users should not have to wonder whether different words, situations, or actions mean the same thing.

**Check for:**
- Same action uses same button style across all screens
- Terminology is consistent (don't mix "Save" and "Submit" for the same action)
- Layout patterns are reused (forms, lists, detail views)
- Icon usage is consistent (same icon = same meaning everywhere)
- Interactive elements look interactive; static elements look static

**Common violations:**
- Multiple button styles for the same action type
- Different navigation patterns on different pages
- Inconsistent spacing between similar sections

### 5. Error Prevention
Good design prevents problems from occurring in the first place.

**Check for:**
- Confirmation dialogs before destructive actions
- Inline validation before submission
- Disabled submit until form is valid
- Constraints that prevent invalid input (date pickers vs. free text for dates)
- Default values for common choices
- Clear formatting hints for expected input

**Common violations:**
- Delete with no confirmation
- Free text input for structured data (dates, phone numbers)
- No validation until after submission

### 6. Recognition Rather Than Recall
Minimize the user's memory load by making elements, actions, and options visible.

**Check for:**
- Recently used items are accessible
- Labels visible (not hidden behind icons only)
- Tooltips on icon-only buttons
- Search with autocomplete and suggestions
- Context preserved when navigating back

**Common violations:**
- Icon-only toolbar with no tooltips
- Settings that require remembering where they are
- Form that clears on back-navigation

### 7. Flexibility and Efficiency of Use
Accelerators — unseen by the novice user — may speed up interaction for the expert user.

**Check for:**
- Keyboard shortcuts for frequent actions
- Search/filter on long lists
- Bulk actions for power users
- Customizable dashboard or views
- Recent/favorites for quick access

**Common violations:**
- No keyboard shortcuts
- Long lists with no search or filter
- Repetitive actions with no bulk option

### 8. Aesthetic and Minimalist Design
Every extra unit of information competes with relevant units and diminishes their relative visibility.

**Check for:**
- Each screen has a clear primary action
- Secondary information is de-emphasized (smaller, muted, collapsible)
- No redundant information on the same screen
- White space is used to group related content
- Progressive disclosure for advanced options

**Common violations:**
- Cluttered dashboards with equal visual weight on everything
- All information shown at once (no progressive disclosure)
- Multiple competing CTAs

### 9. Help Users Recognize, Diagnose, and Recover From Errors
Error messages should be expressed in plain language, precisely indicate the problem, and suggest a solution.

**Check for:**
- Error messages are in plain language (not error codes)
- Error messages indicate what went wrong specifically
- Error messages suggest how to fix it
- Error messages appear next to the problem (not just at page top)
- Form errors highlight the specific field

**Common violations:**
- "Something went wrong" with no detail
- Error message at top of page, not near the field
- Technical error messages shown to users

### 10. Help and Documentation
Even though it's better if the system can be used without documentation, it may be necessary to provide help.

**Check for:**
- Contextual help (tooltips, inline hints) near complex features
- Searchable help/docs
- Onboarding for first-time users
- Empty states that guide the user on what to do

**Common violations:**
- No onboarding for complex features
- Empty state is just blank
- Help is only available in a separate docs site

---

## Mobile-Specific Heuristics

### M1. Touch Target Size
- Minimum 44x44px for primary actions
- Minimum 24x24px for secondary (WCAG 2.5.8)
- At least 8px between adjacent targets

### M2. Thumb Zone
- Primary actions within thumb reach (bottom third of screen)
- Navigation tabs at bottom, not top
- Destructive actions require intentional reach (top or behind confirmation)

### M3. One-Handed Use
- Key actions reachable with one thumb
- No required two-handed gestures for essential tasks
- Pull-to-refresh, swipe-to-dismiss for natural one-hand patterns

### M4. Orientation
- Support both portrait and landscape unless genuinely single-orientation
- Content adapts, not just stretches

### M5. Offline and Connectivity
- Graceful degradation when offline
- Clear indicator of connectivity status
- Queue actions for retry when connection returns

### M6. Input Adaptation
- Appropriate keyboard type for input (email, number, phone, URL)
- Auto-capitalize and auto-correct where appropriate
- Paste support on all text inputs
- Biometric authentication where supported
