# Design System Rules - KC-App

## Brand Foundation

- **Brand**: Kapada Creation
- **Tagline**: We Care What You Wear.
- **Primary Color**: `#1D3F32` (Deep Forest Emerald)

## Customer App Experience

- The Customer App UI must feel:
  - **Premium**
  - **Editorial**
  - **Fashion-focused**
  - **Calm**
  - **Smooth & Inspiring**
  - **Easy to browse**

## Design System Guidelines

- All colors must be sourced from the centralized theme system (`Theme.of(context).colorScheme`).
- Do not hard-code raw hex or RGB colors inside widget files.
- Use semantic color names: `primary`, `onPrimary`, `surface`, `surfaceElevated`, `textPrimary`, `textSecondary`, `error`, `divider`, `unavailable`.
- Typography must derive from `Theme.of(context).textTheme`.
- Spacing, border-radius, and shadows must use defined constants.
- Customer App layout is visual and editorial (large design cards, generous padding, clean image-focused grids).
- Current theme files in `lib/src/app/theme/` serve as temporary Material 3 foundations until the dedicated design-system task.
