# Design System Specification

**Project:** Perductivity (Working Title)  
**Version:** 1.0.0  
**Status:** Draft

---

# 1. Design Vision

Perductivity should feel like a calm, modern workspace that helps users focus instead of overwhelming them.

The interface should be:

- Clean
- Minimal
- Fast
- Professional
- Friendly
- Consistent
- Accessible

Every screen should reduce cognitive load.

---

# 2. Design Principles

## Simplicity First

Remove unnecessary UI.

Every component must have a purpose.

---

## Consistency

Spacing, typography, colors, and interactions must remain consistent across the application.

---

## Focus on Content

The interface should highlight user data, not decorative elements.

---

## Fast Interaction

Common actions should require as few taps as possible.

---

## Accessibility

Design for everyone.

Support:

- Dark Mode
- Large Text
- Screen Readers
- Color Contrast
- Touch-friendly controls

---

# 3. Branding

## Personality

- Professional
- Modern
- Calm
- Motivating
- Trustworthy

---

## Keywords

Minimal

Productive

Organized

Focused

Clean

Modern

Reliable

---

# 4. Theme

Material 3

Support:

- Light Theme
- Dark Theme

Use dynamic colors only when supported.

---

# 5. Color Palette

## Primary

Blue

```text
#2563EB
```

Purpose

- Buttons
- Active Icons
- Links
- Highlights

---

## Secondary

Sky Blue

```text
#38BDF8
```

Purpose

- Accent
- Charts
- Secondary Buttons

---

## Success

Green

```text
#22C55E
```

---

## Warning

Amber

```text
#F59E0B
```

---

## Error

Red

```text
#EF4444
```

---

## Info

Cyan

```text
#06B6D4
```

---

## Background (Light)

```text
#F8FAFC
```

---

## Surface

```text
#FFFFFF
```

---

## Surface Variant

```text
#F1F5F9
```

---

## Border

```text
#CBD5E1
```

---

## Divider

```text
#E2E8F0
```

---

## Text Primary

```text
#0F172A
```

---

## Text Secondary

```text
#475569
```

---

## Text Disabled

```text
#94A3B8
```

---

# Dark Theme

Background

```text
#0F172A
```

Surface

```text
#1E293B
```

Surface Variant

```text
#334155
```

Primary Text

```text
#F8FAFC
```

Secondary Text

```text
#CBD5E1
```

Divider

```text
#475569
```

---

# 6. Typography

## Font Family

Primary

Inter

Fallback

Roboto

System Font

---

## Font Weights

Light

300

Regular

400

Medium

500

SemiBold

600

Bold

700

---

## Text Scale

Display Large

48

Display Medium

40

Display Small

32

Headline Large

28

Headline Medium

24

Headline Small

20

Title Large

18

Title Medium

16

Title Small

14

Body Large

16

Body Medium

14

Body Small

12

Label Large

14

Label Medium

12

Label Small

10

---

# 7. Spacing System

Use an 8-point grid.

Allowed spacing:

```text
4
8
12
16
20
24
32
40
48
64
80
96
```

Never use arbitrary spacing.

---

# 8. Border Radius

Small

8

Medium

12

Large

16

XL

24

Pill

999

---

# 9. Elevation

Use subtle shadows.

Levels

0

1

2

3

Avoid heavy shadows.

---

# 10. Iconography

Library

Material Symbols Rounded

Guidelines

- Filled for active
- Outlined for inactive

Standard size

24

Large

32

Small

20

---

# 11. Layout

Maximum content width

Desktop

1200px

Tablet

900px

Mobile

Responsive

---

Safe Areas must always be respected.

---

# 12. Navigation

Mobile

Bottom Navigation Bar

Tabs

- Home
- Tasks
- Calendar
- Statistics
- Settings

Desktop

Navigation Rail

Future

Collapsible Sidebar

---

# 13. Cards

Cards are the primary surface.

Padding

16

Radius

16

Elevation

1

Avoid borders unless necessary.

---

# 14. Buttons

Primary

Filled

Secondary

Outlined

Tertiary

Text Button

Danger

Filled Red

FAB

Circular

Primary Color

---

# 15. Inputs

Rounded

Radius

12

Support

- Helper Text
- Validation
- Prefix Icon
- Suffix Icon

---

# 16. Chips

Support

- Categories
- Tags
- Filters

Rounded

Radius

999

---

# 17. Lists

Cards separated by 12 spacing.

Swipe actions:

- Complete
- Delete
- Archive

---

# 18. Dialogs

Rounded

Radius

20

Must include

Title

Body

Primary Action

Cancel Action

---

# 19. Bottom Sheets

Use for

- Filters
- Sort
- Quick Create

Prefer modal sheets.

---

# 20. Animations

Animation Philosophy

Fast

Natural

Purposeful

Never distracting.

---

Duration

Fast

150ms

Normal

250ms

Slow

350ms

---

Curve

Ease Out

Default

---

Use animations for

- Page transitions
- Card expansion
- FAB
- Checkboxes
- Lists

Avoid unnecessary animations.

---

# 21. Loading States

Use

Skeleton Loading

Circular Progress

Linear Progress

Avoid blank screens.

---

# 22. Empty States

Every empty page must include

Illustration

Title

Description

Primary Action

---

# 23. Error States

Every error should include

Message

Retry Button

Helpful Description

Never expose raw exceptions.

---

# 24. Accessibility

Minimum touch target

48x48

Contrast

WCAG AA

Support

- Screen Readers
- Keyboard Navigation
- Dynamic Text Scaling

Never rely on color alone.

---

# 25. Responsive Design

Breakpoints

Mobile

<600

Tablet

600-1024

Desktop

> 1024

Layouts should adapt gracefully.

---

# 26. Design Tokens

## Radius

```yaml
radius:
  sm: 8
  md: 12
  lg: 16
  xl: 24
  pill: 999
```

---

## Spacing

```yaml
spacing:
  xs: 4
  sm: 8
  md: 16
  lg: 24
  xl: 32
  xxl: 48
```

---

## Animation

```yaml
animation:
  fast: 150ms
  normal: 250ms
  slow: 350ms
```

---

# 27. Component Guidelines

Every reusable component must:

- Support light and dark themes.
- Be responsive.
- Follow Material 3.
- Use design tokens.
- Be documented.
- Avoid hardcoded values.

---

# 28. Future Design Expansion

Reserved for:

- AI Assistant UI
- Dashboard Widgets
- Kanban Board
- Timeline View
- Collaboration
- Desktop Layout
- Tablet Optimizations
- Custom Themes

---

# 29. Design Rules

- Never hardcode colors.
- Never hardcode spacing.
- Never hardcode typography.
- Always use design tokens.
- Maintain visual consistency.
- Prioritize readability over decoration.
- Prefer whitespace over borders.
- Icons should always include semantic meaning.
- Components should be reusable.
- Every new UI component must integrate with the existing design system.

---

# 30. Definition of Good Design

A screen is considered complete when:

- It follows the design system.
- It is responsive.
- It is accessible.
- It supports light and dark mode.
- It uses design tokens.
- It has no visual inconsistencies.
- It minimizes user effort.
- It communicates hierarchy clearly.
- It remains performant on low-end devices.
