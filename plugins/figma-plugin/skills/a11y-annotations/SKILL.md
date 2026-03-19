---
name: a11y-annotations
description: >
  Add a structured accessibility annotation layer to a Figma design — focus order, landmark
  regions, heading hierarchy, ARIA roles, alt text, and reading order. Use after the design
  is built (Phase 6 of /design) to produce a handoff-ready annotation overlay that developers
  can implement correctly. Also contains the pre-check rules used in Phase 2c to validate
  contrast ratios, touch target sizes, and heading hierarchy before building starts.
---

# A11y Annotations

Add a complete accessibility annotation layer to a built Figma design. Annotations live on a
dedicated **"♿ Accessibility"** page — they never modify the original design frames.

## When to Use

- After the design is built: add the annotation overlay for developer handoff
- During Phase 2c pre-check: validate contrast, touch targets, and heading hierarchy before building
- When reviewing an existing design for accessibility compliance

## When NOT to Use

- Before the design is built — annotations describe what exists, not what will be built
- Instead of building accessible components — annotations document intent; the design must still use correct Fluent 2 components with proper labels

---

## Phase 2c Pre-Check Rules

Run these checks during design planning, before any agent spawns.

### 1. Contrast Ratio Validation

For every text + background color pair in the design plan:

```javascript
function luminance(r, g, b) {
  return [r, g, b].reduce((sum, c, i) => {
    c = c / 255;
    c = c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    return sum + c * [0.2126, 0.7152, 0.0722][i];
  }, 0);
}

function contrastRatio(hex1, hex2) {
  const parse = h => [1,3,5].map(i => parseInt(h.slice(i,i+2),16));
  const l1 = luminance(...parse(hex1));
  const l2 = luminance(...parse(hex2));
  const [light, dark] = [Math.max(l1,l2), Math.min(l1,l2)];
  return ((light + 0.05) / (dark + 0.05)).toFixed(2);
}
```

Required ratios (from `constitution.md` WCAG level):

| Text size | WCAG AA | WCAG AAA |
|---|---|---|
| Normal text (< 18px regular, < 14px bold) | 4.5:1 | 7:1 |
| Large text (≥ 18px regular, ≥ 14px bold) | 3:1 | 4.5:1 |
| UI components & icons | 3:1 | 3:1 |

**Flag as BLOCKING** if any planned pair fails the required level.

Common pairs to check in every design plan:
- Body text on page background
- Heading text on section backgrounds
- Button label on button fill (primary, secondary, danger)
- Placeholder text on input background
- Badge text on badge fill
- Link color on page background
- Disabled text on disabled background (only needs 3:1 for AA)

### 2. Touch Target Size (Mobile designs only)

Every interactive element on mobile must be ≥ 44 × 44px (WCAG 2.5.5).

Check the design plan for:
- Icon-only buttons — must have a hit area frame of ≥ 44×44px even if the icon is 24px
- Navigation items — minimum 44px height
- Checkbox / Radio / Switch — minimum 44×44px tap area
- Table row actions — minimum 44px height per row
- Close / dismiss buttons — minimum 44×44px

**Flag as WARNING** if any planned interactive element is smaller. Suggest wrapping in a transparent 44×44px hit-area frame.

### 3. Heading Hierarchy

For every page in the design plan, check:
- Exactly **one H1** per page (the main page title)
- No skipped levels (H1 → H3 without H2 is invalid)
- Section headings follow a logical nesting (H2 for sections, H3 for sub-sections, H4 for cards)

**Flag as BLOCKING** if H1 is missing on any page.
**Flag as WARNING** if levels are skipped.

### 4. Image Alt Text

Every image in the design plan must have a planned alt text string.

- **Decorative images** (backgrounds, textures) → `alt=""` (empty, explicitly decorative)
- **Informative images** (hero photos, product images) → descriptive alt text required
- **Functional images** (image that is a button/link) → alt text describes the action, not the image

**Flag as BLOCKING** if any informative or functional image has no alt text planned.

---

## Annotation Layer — What to Annotate

### Annotation Types

| Type | Color | What it marks |
|---|---|---|
| Focus order | `#0066CC` (blue) | Tab sequence for keyboard navigation |
| Landmark | varies (see below) | Page regions (main, nav, header, footer, aside, form) |
| Heading | `#7C3AED` (purple) | H1–H6 level on text nodes |
| ARIA role | `#D97706` (amber) | Custom interactive elements needing explicit roles |
| Alt text | `#0891B2` (cyan) | Alt text string for images |
| Reading order | `#059669` (green) | Arrows where visual order ≠ logical order |
| State | `#DB2777` (pink) | Focus ring, hover, disabled state specs |

### Landmark Colors (semi-transparent fills)

| Landmark | Color | Opacity |
|---|---|---|
| `<header>` | `#7C3AED` purple | 10% |
| `<nav>` | `#16A34A` green | 10% |
| `<main>` | `#2563EB` blue | 10% |
| `<aside>` | `#D97706` amber | 10% |
| `<footer>` | `#6B7280` gray | 10% |
| `<form>` | `#DB2777` pink | 10% |
| `role="search"` | `#0891B2` cyan | 10% |
| `role="dialog"` | `#EF4444` red | 10% |

---

## Figma Implementation

### Step 1: Create the Annotations Page

```javascript
// Create dedicated accessibility page
const a11yPage = figma.createPage();
a11yPage.name = '♿ Accessibility';
figma.currentPage = a11yPage;
```

### Step 2: Mirror the Design Page

For each design page being annotated, create a frame on the accessibility page at the same dimensions. Paste or reference the design content, then overlay annotations on top.

```javascript
// For each design page, create a container on the a11y page
const designPage = figma.root.children.find(p => p.name === 'Dashboard');
const masterFrame = designPage.children[0]; // the main page frame

// Create annotation canvas at same size
const canvas = __figb.frame(`Annotations — ${masterFrame.name}`, {
  w: masterFrame.width,
  h: masterFrame.height,
  fill: __figb.rgba(0, 0, 0, 0),
});
```

### Step 3: Focus Order Badges

Number every interactive element in the logical tab order. Start at 1, go left-to-right, top-to-bottom unless focus order differs from reading order.

```javascript
function focusBadge(number, x, y, parent) {
  const badge = __figb.frame(`Focus-${number}`, {
    direction: 'HORIZONTAL', mainAlign: 'CENTER', crossAlign: 'CENTER',
    w: 24, h: 24, radius: 12,
    fill: __figb.hex('#0066CC'),
    absolute: true, x: x - 12, y: y - 12,
    parent,
  });
  await __figb.txt(String(number), {
    size: 11, style: 'Bold', fill: __figb.hex('#FFFFFF'), parent: badge,
  });
}

// Usage — place at top-left corner of each interactive element
await focusBadge(1, skipNavBtn.x, skipNavBtn.y, canvas);
await focusBadge(2, logoLink.x, logoLink.y, canvas);
await focusBadge(3, navItem1.x, navItem1.y, canvas);
// ... continue for all interactive elements
```

**Focus order rules:**
- Skip links (e.g. "Skip to main content") are always focus #1
- Dialogs trap focus — restart numbering inside the dialog
- Disabled elements have no focus order number
- Custom dropdowns and date pickers: number the trigger, then number each option as a sub-sequence (3, 3.1, 3.2, 3.3...)

### Step 4: Landmark Region Overlays

Draw semi-transparent filled rectangles over each landmark region. Label each with its role.

```javascript
function landmark(role, color, x, y, w, h, parent) {
  const overlay = __figb.rect({
    name: `Landmark: ${role}`,
    w, h,
    fill: __figb.rgba(...hexToRgb(color), 0.1),
    strokes: [{ type: 'SOLID', color: __figb.hex(color) }],
    strokeWeight: 2,
    absolute: true, x, y,
    parent,
  });

  // Label badge in top-left corner
  const label = __figb.frame(`Label: ${role}`, {
    direction: 'HORIZONTAL', px: 6, py: 3, radius: 4,
    fill: __figb.hex(color),
    absolute: true, x: x + 4, y: y + 4,
    parent,
  });
  await __figb.txt(`<${role}>`, {
    size: 11, style: 'Bold', fill: __figb.hex('#FFFFFF'), parent: label,
  });
}

// Usage
await landmark('header',  '#7C3AED', headerFrame.x, headerFrame.y, headerFrame.width, headerFrame.height, canvas);
await landmark('nav',     '#16A34A', navFrame.x, navFrame.y, navFrame.width, navFrame.height, canvas);
await landmark('main',    '#2563EB', mainFrame.x, mainFrame.y, mainFrame.width, mainFrame.height, canvas);
await landmark('footer',  '#6B7280', footerFrame.x, footerFrame.y, footerFrame.width, footerFrame.height, canvas);
```

### Step 5: Heading Level Labels

Place a purple badge on every text node that acts as a heading, showing its level.

```javascript
function headingLabel(level, x, y, parent) {
  const badge = __figb.frame(`Heading-H${level}`, {
    direction: 'HORIZONTAL', px: 6, py: 2, radius: 4,
    fill: __figb.hex('#7C3AED'),
    absolute: true, x, y: y - 20,
    parent,
  });
  await __figb.txt(`H${level}`, {
    size: 11, style: 'Bold', fill: __figb.hex('#FFFFFF'), parent: badge,
  });
}

// Usage — one per heading text node
await headingLabel(1, pageTitle.x, pageTitle.y, canvas);       // page title
await headingLabel(2, sectionTitle.x, sectionTitle.y, canvas); // section heading
await headingLabel(3, cardTitle.x, cardTitle.y, canvas);       // card title
```

### Step 6: ARIA Role Labels

For any custom interactive element that needs an explicit ARIA role (not covered by a native HTML element or Fluent 2 component):

```javascript
function ariaLabel(role, description, x, y, parent) {
  const badge = __figb.frame(`ARIA: ${role}`, {
    direction: 'HORIZONTAL', gap: 4, px: 6, py: 3, radius: 4,
    fill: __figb.hex('#D97706'),
    absolute: true, x, y: y - 24,
    parent,
  });
  await __figb.txt(`role="${role}"`, {
    size: 11, style: 'Bold', fill: __figb.hex('#FFFFFF'), parent: badge,
  });
  if (description) {
    await __figb.txt(description, {
      size: 11, fill: __figb.hex('#FFFFFF'), parent: badge,
    });
  }
}

// Examples
await ariaLabel('tablist', '', tabBar.x, tabBar.y, canvas);
await ariaLabel('tab', 'aria-selected="true"', activeTab.x, activeTab.y, canvas);
await ariaLabel('dialog', 'aria-modal="true"', modal.x, modal.y, canvas);
await ariaLabel('status', 'live region', statusBanner.x, statusBanner.y, canvas);
```

### Step 7: Alt Text Annotations

For every image frame, add a cyan label showing the planned alt text (or marking it as decorative).

```javascript
function altTextLabel(text, x, y, w, parent) {
  const isDecorative = text === '' || text === 'decorative';
  const badge = __figb.frame(`Alt: ${text.slice(0, 20)}`, {
    direction: 'VERTICAL', px: 8, py: 4, radius: 4,
    fill: __figb.hex('#0891B2'),
    absolute: true, x, y: y + 4,
    parent,
  });
  await __figb.txt(isDecorative ? 'alt="" (decorative)' : `alt="${text}"`, {
    size: 11, style: isDecorative ? 'Italic' : 'Regular',
    fill: __figb.hex('#FFFFFF'),
    w: Math.min(w - 16, 280),
    parent: badge,
  });
}

// Usage
await altTextLabel('Dashboard showing monthly revenue chart', heroImage.x, heroImage.y, heroImage.width, canvas);
await altTextLabel('decorative', bgTexture.x, bgTexture.y, bgTexture.width, canvas);
```

### Step 8: Reading Order Arrows (where visual ≠ logical)

Only needed where CSS reordering, absolute positioning, or grid placement means visual order differs from DOM/reading order. Draw arrows between elements in logical order.

```javascript
function readingArrow(fromNode, toNode, parent) {
  // Draw a connector line between two elements
  const x1 = fromNode.x + fromNode.width / 2;
  const y1 = fromNode.y + fromNode.height / 2;
  const x2 = toNode.x + toNode.width / 2;
  const y2 = toNode.y + toNode.height / 2;

  const arrow = figma.createVector();
  arrow.name = 'Reading Order Arrow';
  arrow.vectorNetwork = {
    vertices: [{ x: x1, y: y1 }, { x: x2, y: y2 }],
    segments: [{ startVertex: 0, endVertex: 1, tangentStart: { x: 0, y: 0 }, tangentEnd: { x: 0, y: 0 } }],
    regions: [],
  };
  arrow.strokes = [{ type: 'SOLID', color: __figb.hex('#059669') }];
  arrow.strokeWeight = 2;
  arrow.strokeCap = 'ARROW_EQUILATERAL';
  parent.appendChild(arrow);
}
```

### Step 9: Interactive State Specs

For each interactive component, add a pink annotation listing the states that must be implemented:

```javascript
function stateSpec(states, x, y, parent) {
  const badge = __figb.frame('States', {
    direction: 'VERTICAL', px: 8, py: 6, gap: 2, radius: 4,
    fill: __figb.hex('#DB2777'),
    absolute: true, x: x + 4, y,
    parent,
  });
  await __figb.txt('States:', { size: 10, style: 'Bold', fill: __figb.hex('#FFF'), parent: badge });
  for (const state of states) {
    await __figb.txt(`• ${state}`, { size: 10, fill: __figb.hex('#FFF'), parent: badge });
  }
}

// Usage
await stateSpec(['default', 'hover', 'focus-visible', 'active', 'disabled'], btn.x + btn.width, btn.y, canvas);
await stateSpec(['empty', 'filled', 'focused', 'error', 'disabled'], input.x + input.width, input.y, canvas);
```

---

## Agent Prompt Template

When the orchestrator spawns the a11y annotation agent in Phase 6, use this template:

```
You are an accessibility annotation agent. Add a complete a11y annotation layer
to the Figma design at [Figma URL].

Use the a11y-annotations skill.

Design summary:
[paste the design plan — pages, sections, components]

Accessibility requirements (from constitution.md):
- WCAG level: [AA / AAA]
- Platform: [desktop / mobile / both]
- Special requirements: [screen reader, keyboard-only, etc.]

Component inventory (from the Fluent 2 Component Mapping):
[paste the full component mapping table]

Alt text plan (from spec.md):
[paste all image alt text strings]

Instructions:
1. Create a "♿ Accessibility" page in the Figma file
2. For each design page, create an annotation canvas at the same dimensions
3. Add ALL annotation types: focus order, landmarks, headings, ARIA roles, alt text, states
4. Focus order must be complete and correct — number every interactive element
5. Every image must have an alt text label (empty string if decorative)
6. Do not modify any existing design frames — annotations only go on the a11y page
```

---

## Annotation Completeness Checklist

Before marking the annotation layer done, verify:

- [ ] Focus order: every interactive element numbered, no gaps in sequence
- [ ] Skip link annotated as focus #1 (even if not yet in the design — flag it as missing)
- [ ] All landmark regions labeled
- [ ] Every text node acting as a heading has an H1–H6 label
- [ ] Exactly one H1 per page
- [ ] Every image has an alt text annotation
- [ ] All icon-only buttons have their tooltip/aria-label shown
- [ ] All form inputs have their label association noted
- [ ] Interactive state specs added for all Buttons, Inputs, and custom components
- [ ] Reading order arrows added anywhere visual order diverges from logical order

---

## Common Mistakes to Flag

| Mistake | How to annotate |
|---|---|
| Two H1s on one page | Red warning badge on the second H1: "ERROR: duplicate H1" |
| Icon button with no tooltip in spec | Red warning badge: "MISSING: aria-label" |
| Focus order skips an interactive element | Red warning badge on the skipped element: "MISSING from focus order" |
| Image with no alt text planned | Red warning badge: "MISSING: alt text" |
| Form input with no associated label | Red warning badge: "MISSING: label association" |
| Interactive element < 44×44px on mobile | Red warning badge: "Touch target too small (Xpx × Ypx)" |
