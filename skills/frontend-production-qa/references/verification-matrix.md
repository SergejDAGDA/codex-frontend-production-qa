# Verification Matrix

## Class A — full matrix

Use for layout, responsive, typography wrapping, sizing, visibility, navigation, shared UI and release preparation.

| Surface | Viewport |
|---|---:|
| Small mobile | 320x568 |
| Mobile | 375x812 |
| Mobile | 390x844 |
| Tablet portrait | 768x1024 |
| Tablet landscape | 1024x768 |
| Small desktop | 1280x800 |
| Desktop | 1440x900 |
| Large desktop | 1920x1080 |

## Class B — reduced matrix

Use only when the visual change has no plausible geometry/wrapping/sizing/visibility/responsive impact.

- 390x844
- 768x1024
- 1440x900

If uncertain, use Class A.

## Breakpoint boundary rule

If breakpoint `B` changes or is suspected, additionally test:

- `B - 1`
- `B`
- `B + 1`

## Inspect at applicable viewports

Check for:

- horizontal/vertical overflow;
- clipping and overlap;
- duplicate separators;
- broken wrapping;
- misaligned columns;
- wrong stacking/order;
- fixed/sticky collisions;
- header/navigation/footer failures;
- content hidden behind overlays;
- unexpected nested scrolling;
- broken or distorted media;
- off-screen controls;
- modal/drawer/menu/tooltip overflow;
- unexpected layout shifts.

For long pages inspect top, representative middle content, below-the-fold behavior, and terminal/footer sections.

## Shared components

If a shared component changes, test representative routes that use it in different contexts.

Global header, footer, navigation, typography, containers and design tokens require cross-page checks.
