---
name: icon-library
description: >
  Fetch pre-made SVG icons from @fluentui/svg-icons (Fluent UI) for use in Figma or code projects.
  Use when the user asks to "add an icon", "use a search icon", "insert icons in Figma", "find an
  icon for settings", or needs clean SVG icons. NEVER draw icons manually — always fetch from
  @fluentui/svg-icons. Supports browsing, searching, and inserting icons into Figma via
  figma.createNodeFromSvg().
---

# Icon Library — Fluent UI Icons

Fetch production-quality SVG icons from `@fluentui/svg-icons` (the raw-SVG companion to `@fluentui/react-icons`). Icons are part of the Fluent 2 design system and visually consistent with all Fluent 2 components.

## When to Use

- User asks to add icons to a Figma design
- User needs SVG icons for a UI component, button, navigation, etc.
- User says "add a search icon", "use a settings gear", "insert an arrow icon"
- You need icons as part of a larger Figma automation task
- User wants consistent iconography across a Fluent 2 design

## When NOT to Use

- User wants custom illustrations or logos (use image generation instead)
- User already has specific SVG code they want to use

## CRITICAL RULE

**NEVER attempt to draw icons by hand using basic shapes (rectangles, circles, paths).** The result will always look awful. Instead, ALWAYS fetch a pre-made SVG from `@fluentui/svg-icons`.

## Fluent UI Icons

- **Package**: `@fluentui/svg-icons`
- **Count**: 2000+ icons in regular and filled variants
- **Style**: Fluent 2 — consistent stroke weight, rounded corners, pixel-aligned
- **Sizes available**: 10, 12, 16, 20, 24, 28, 32, 48 — **default to 24**
- **Variants**: `regular` (outline) and `filled`
- **License**: MIT
- **URL pattern**: `https://unpkg.com/@fluentui/svg-icons@latest/icons/{name}_{size}_{variant}.svg`
- **Icon browser**: https://storybooks.fluentui.dev/react/?path=/docs/icons-overview--docs

### Naming Convention

File names use **snake_case** with size and variant suffix. The React component name maps directly:

| React component (`@fluentui/react-icons`) | File name |
|---|---|
| `HomeRegular` | `home_24_regular.svg` |
| `HomeFilled` | `home_24_filled.svg` |
| `Home20Regular` | `home_20_regular.svg` |
| `SearchRegular` | `search_24_regular.svg` |
| `DismissRegular` | `dismiss_24_regular.svg` |
| `AddRegular` | `add_24_regular.svg` |
| `ChevronDownRegular` | `chevron_down_24_regular.svg` |
| `ArrowRightRegular` | `arrow_right_24_regular.svg` |
| `PersonRegular` | `person_24_regular.svg` |
| `SettingsRegular` | `settings_24_regular.svg` |

**Rule:** PascalCase → snake_case, insert `_24_` (or desired size) before `regular`/`filled`.

### Fetch Examples

```bash
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/home_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/search_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/dismiss_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/add_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/settings_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/person_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/chevron_down_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/arrow_right_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/star_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/heart_24_regular.svg
```

Or with WebFetch:
```
WebFetch → https://unpkg.com/@fluentui/svg-icons@latest/icons/search_24_regular.svg
→ prompt: "Return the complete SVG markup exactly as-is, no modifications"
```

### Common Icon Names (snake_case, size 24, regular variant)

**Navigation & Layout:**
`home`, `navigation`, `grid`, `list`, `sidebar`, `panel_left`, `panel_right`, `layout_column`, `apps`

**Actions:**
`add`, `add_circle`, `dismiss`, `dismiss_circle`, `edit`, `delete`, `save`, `copy`, `cut`, `clipboard_paste`, `share`, `send`, `download`, `upload`, `arrow_upload`, `arrow_download`, `open`, `link`, `link_edit`

**Arrows & Chevrons:**
`arrow_right`, `arrow_left`, `arrow_up`, `arrow_down`, `chevron_right`, `chevron_left`, `chevron_up`, `chevron_down`, `arrow_circle_right`, `arrow_expand`, `arrow_collapse`

**People & Identity:**
`person`, `person_circle`, `people`, `person_add`, `person_delete`, `contact_card`, `guest`

**Communication:**
`mail`, `mail_unread`, `chat`, `chat_multiple`, `comment`, `mention`, `mention_arrow`, `bell`, `alert`

**Files & Data:**
`document`, `document_add`, `document_copy`, `folder`, `folder_open`, `attach`, `database`, `server`, `cloud`, `cloud_arrow_up`, `cloud_arrow_down`

**Status & Feedback:**
`checkmark`, `checkmark_circle`, `error_circle`, `warning`, `info`, `question_circle`, `dismiss_circle`, `star`, `star_emphasis`, `heart`, `thumbs_up`, `thumbs_down`

**Search & Filter:**
`search`, `filter`, `filter_add`, `funnel`, `zoom_in`, `zoom_out`

**Settings & Tools:**
`settings`, `wrench`, `options`, `toggle_left`, `toggle_right`, `plug_connected`, `key`

**Media:**
`image`, `camera`, `video`, `video_clip`, `play_circle`, `pause_circle`, `speaker_2`, `music_note_2`

**Time & Calendar:**
`calendar`, `calendar_add`, `clock`, `timer`, `history`

**Commerce & Finance:**
`cart`, `tag`, `payment`, `wallet`, `gift`, `money`

**Other:**
`globe`, `map`, `location`, `pin`, `phone`, `phone_call`, `wifi`, `lock_closed`, `lock_open`, `eye`, `eye_off`, `color_fill`, `paint_brush`, `emoji`, `dark_theme`, `weather_sunny`, `tag_multiple`

## How to Fetch an Icon

### Step 1: Map intent to icon name

| User intent | Icon name |
|---|---|
| "search" | `search` |
| "settings" or "gear" | `settings` |
| "close" or "dismiss" | `dismiss` |
| "delete" | `delete` |
| "add" or "create" | `add` |
| "hamburger menu" | `navigation` |
| "notification" | `bell` |
| "profile" | `person_circle` |
| "back" | `arrow_left` or `chevron_left` |
| "check" or "done" | `checkmark_circle` |
| "warning" or "error" | `warning` or `error_circle` |
| "info" | `info` |
| "filter" | `filter` |
| "attach" | `attach` |
| "share" | `share` |

### Step 2: Fetch the SVG

```bash
# Regular (outline) — default
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/search_24_regular.svg

# Filled — for emphasis or active states
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/search_24_filled.svg

# Smaller size (e.g. for dense UIs)
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/search_20_regular.svg
```

### Step 3: Insert into Figma

```javascript
const svgString = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">...</svg>`;

const icon = figma.createNodeFromSvg(svgString);
icon.name = "Icon/Search";
icon.resize(24, 24);
figma.currentPage.appendChild(icon);
```

Or with the `__figb` helper:
```javascript
__figb.icon(svgString, { name: 'Icon/Search', size: 24, parent: container });
```

## Batch Fetching (for Figma designs)

Fetch all icons needed before building. Return a map:

```bash
# Fetch in parallel
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/home_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/search_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/bell_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/person_24_regular.svg
curl https://unpkg.com/@fluentui/svg-icons@latest/icons/settings_24_regular.svg
```

Then pass as a map to Figma build scripts:
```javascript
const icons = {
  home: `<svg>...</svg>`,
  search: `<svg>...</svg>`,
  bell: `<svg>...</svg>`,
  person: `<svg>...</svg>`,
  settings: `<svg>...</svg>`,
};

for (const [name, svg] of Object.entries(icons)) {
  __figb.icon(svg, { name: `Icon/${name}`, size: 24, parent: iconFrame });
}
```

## Customizing Icons in Figma

After inserting an SVG, recolor using the `__figb` helper:

```javascript
const iconNode = __figb.icon(svgString, { name: 'Icon/Search', size: 24, parent: container });
__figb.recolor(iconNode, __figb.hex('#0F6CBD')); // Fluent 2 brand blue
```

Or manually:
```javascript
function recolorNode(node, color) {
  if ('strokes' in node && node.strokes.length > 0) {
    node.strokes = [{ type: 'SOLID', color }];
  }
  if ('fills' in node && node.fills.length > 0) {
    node.fills = [{ type: 'SOLID', color }];
  }
  if ('children' in node) {
    node.children.forEach(child => recolorNode(child, color));
  }
}

recolorNode(icon, { r: 0.06, g: 0.42, b: 0.74 }); // #0F6CBD
```

## Searching for the Right Icon

If unsure of the exact icon name, browse the icon storybook:
```
WebFetch → https://storybooks.fluentui.dev/react/?path=/docs/icons-overview--docs
→ prompt: "Find icon names related to [concept]"
```

Or search unpkg for the icon file listing:
```
WebFetch → https://unpkg.com/@fluentui/svg-icons@latest/icons/
→ prompt: "List all icon file names containing [keyword]"
```

## Tips

- **Default to `regular` variant** — use `filled` only for active/selected states or strong emphasis
- **Default to size 24** — use 20 for dense/compact UIs, 16 for inline/label icons, 28–32 for large feature icons
- **Always use `createNodeFromSvg()`** in Figma — never draw icons with basic shapes
- **Fluent icons are filled SVGs** (not stroke-based like Lucide) — recoloring targets `fills`, not `strokes`
- When inserting into a Figma component, flatten if needed: `figma.flatten([iconNode])`
