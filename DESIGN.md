# Design System: The Clinical Sentinel (Safe Scan)

## 1. Overview & Creative North Star
The Creative North Star for Safe Scan is **"The Clinical Sentinel."** This aesthetic moves beyond standard mobile utility into the realm of high-end, near-future medical instrumentation. It is precise, authoritative, and vital.

While most apps rely on generic cards and heavy borders, this system utilizes **Organic Brutalism**—a combination of rigid, scientific data density and soft, atmospheric depth. It features intentional asymmetry, overlapping "Floating Island" elements, and a high-contrast typographic scale that mirrors a tactical HUD.

## 2. Colors & Surface Architecture
The palette is rooted in deep, charcoal voids to ensure maximum legibility of critical bio-data.

### The Palette
- **Primary (Bio-Green):** `#8eff71`. Used for "Safe" status, success states, and primary actions. It mimics a glowing phosphor display.
- **Secondary (Safety Orange):** `#ff7354`. Used for "Hazard" warnings and urgent diagnostic data.
- **Neutral Base:** `#0e0e0e` (`surface`). A deep, ink-like charcoal foundation.

### Surface Hierarchy (The "No-Line" Rule)
Boundaries are defined solely through background color shifts, not 1px borders.
- **Base Layer:** `surface` (#0e0e0e).
- **Secondary Tier:** `surface-container-low` (#131313) for large content areas.
- **Tertiary Tier:** `surface-container-high` (#20201f) for interactive elements and nested data modules.

### Layering & Depth
- **Glassmorphism:** Used for floating elements (e.g., Warning states use `error_container` at 40-60% opacity with 20px backdrop-blur).
- **Ambient Shadows:** Blur: 40px-60px, Opacity: 4-8%, using tinted versions of `on_surface`.

## 3. Typography
- **Display & Headlines (Space Grotesk):** Technical precision, "Editorial Anchors." Used for critical biometric readings.
- **Body & Labels (Inter):** Functional text with a tall x-height for readability in high-stress scenarios.
- **Scale:** Extreme contrast (e.g., `display-lg` vs `label-sm`) to create a data-rich, professional laboratory feel.

## 4. UI Components

### Floating Island Navigation
- **Style:** `surface-container-highest` at 80% opacity with a `12px` backdrop blur.
- **Shape:** Full roundedness.
- **Interaction:** Haptic-style feedback with a `primary` glow indicator for the active state.

### Diagnostic Cards
- **Safe State:** `surface-container-low` background with a `primary` (Bio-Green) left-accent glow.
- **Hazard State:** Red Glassmorphism (`error_container`) with high backdrop-blur and `secondary` (Safety Orange) text.
- **Rule:** No divider lines; vertical white space (`spacing-6`) separates data points.

### Haptic Buttons
- **Primary:** Background `primary` (#8eff71), Text `on_primary` (#0d6100), Roundedness `md`.
- **Secondary:** Ghost style with a 15% opacity "Ghost Border" (`outline-variant`).
- **Interaction:** "Sink" effect (scale 0.98) with a subtle outer glow on press.

### Input Fields
- **Style:** `surface-variant` background (#262626).
- **Indicator:** A `primary` vertical "scanning line" on the left when focused (no bottom border).

## 5. Design Principles (Do's and Don'ts)
- **DO** use intentional asymmetry to aid the "Scanning" metaphor.
- **DO** embrace breath with large functional group spacing (`spacing-10` to `spacing-12`).
- **DON'T** use 1px dividers; use tonal shifts instead.
- **DON'T** use standard grey shadows; use tinted ambient blurs.
