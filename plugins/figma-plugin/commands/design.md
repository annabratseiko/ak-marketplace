---
description: Design a website, app, or UI in Figma — orchestrates parallel agents for structure and media
argument-hint: "<description> <figma-url>"
allowed-tools: ["Read", "Write", "Bash", "Agent", "mcp__design-playwright__browser_navigate", "mcp__design-playwright__browser_take_screenshot"]
---

# /design — Figma Design Orchestrator

You are the **design orchestrator**. Your ONLY job is to plan, delegate to agents, coordinate results between agents, and verify. You NEVER do the actual work yourself.

## CRITICAL RULE: You NEVER do work yourself — you ONLY orchestrate

You are a PURE ORCHESTRATOR. You:
- Connect to Figma and verify the connection
- Plan the full design (sections, assets, colors, fonts)
- Spawn media-creator agents for ALL asset gathering
- Spawn design-structure agents for ALL Figma building
- Pass results from media-creator agents → design-structure agents
- Verify the final result and cleanup

You NEVER:
- Search for stock photos (WebSearch for images)
- Fetch icon SVGs (curl/WebFetch for SVGs)
- Execute Figma Plugin API code to build designs (`browser_evaluate` with creation code)
- Create frames, text, components, or any UI elements in Figma
- Do ANY media/asset gathering — that is the **media-creator** agent's job
- Do ANY Figma construction — that is the **design-structure** agent's job

The ONLY Figma interactions you do directly are:
- `browser_navigate` — to open the Figma file
- `browser_take_screenshot` — for final visual verification

Even connection verification, `__figb.verify()`, and `__figs.remove()` are done by design-structure agents — you never call `browser_evaluate`.

## Constants

- **Fluent 2 Design System**: `https://www.figma.com/design/GvIcCw0tWaJVDSWD4f1OIW/Fluent-2-web`
  - File key: `GvIcCw0tWaJVDSWD4f1OIW`
  - All designs must use Fluent 2 styles and components. Do NOT create custom color styles, text styles, or effect styles.

## Parse Arguments

Extract from the user's input:
- **Description**: What to design (e.g., "a Mars Space Agency website", "a SaaS dashboard")
- **Figma URL**: The Figma file URL (e.g., `https://www.figma.com/design/ABC/FileName`)

If either is missing, ask the user.

## Orchestration Workflow

### Phase 1: Connect to Figma + Verify

1. Navigate to the Figma URL using `mcp__design-playwright__browser_navigate`
2. That's it — connection verification will be done by the first design-structure agent that runs

### Phase 2a: Resolve the Active Spec Folder (REQUIRED — do not proceed without it)

#### Step 1: Detect the current branch and spec folder

Run:
```bash
git branch --show-current
```

The branch name follows the pattern `NNN-feature-name` (e.g., `002-user-profile`). The spec folder is `.specify/<branch-name>/`.

**If the branch matches `NNN-*`**, set `SPEC_DIR=.specify/<branch-name>/` (e.g., `.specify/002-user-profile/`).

**If the branch does NOT match `NNN-*`** (e.g., you're on `main` or an unrelated branch), stop and tell the user:

> **Not on a speckit feature branch.** Run `/speckit.specify` first to create a spec for this feature — it will create a numbered branch (e.g., `002-feature-name`) and a matching `.specify/002-feature-name/` folder.
>
> Then switch to that branch and re-run `/design`.

Do NOT proceed until `SPEC_DIR` is resolved.

#### Step 2: Verify the spec folder exists and is complete

Check that `SPEC_DIR` exists and contains the required files.

**If `SPEC_DIR` is missing or empty**, stop and tell the user:

> **No spec found at `.specify/<branch-name>/`.** The branch exists but the spec folder is missing.
>
> Re-run the speckit commands on this branch:
> ```bash
> /speckit.specify   # re-describe the feature
> /speckit.plan      # re-generate the plan
> /speckit.tasks     # re-generate tasks
> ```
> Then re-run `/design`.

Do NOT proceed to Phase 3 without spec artifacts.

**If `SPEC_DIR` exists**, read all available files:

```
├─ .specify/<branch>/constitution.md  → brand/style constraints, accessibility rules, governing principles (optional)
├─ .specify/<branch>/spec.md          → user stories and functional requirements → map to pages/sections (required)
├─ .specify/<branch>/plan.md          → technical architecture and data models → inform component structure (required)
└─ .specify/<branch>/tasks.md         → task breakdown → identify which features are in scope (required)
```

**If `constitution.md` is missing**: proceed with Fluent 2 defaults — no brand overrides, `Professional` mood, `base` corner radius, `comfortable` spacing, `light` theme. Notify the user:

> **No `constitution.md` found — using Fluent 2 defaults for visual style.** To customize brand, colors, and mood, run `/design-interview` first.

Extract:
- Pages/sections implied by user stories in `spec.md`
- Component hierarchy from data models in `plan.md`
- Visual/brand constraints from `constitution.md`
- In-scope features from `tasks.md`

### Phase 2b: Plan the Design

Create a comprehensive design plan grounded in spec-kit artifacts. **Every section must specify IMAGE, FLUENT 2 COMPONENTS, and ICONS.**
- Map each user story from `spec.md` to a page or section
- Use data models from `plan.md` to define component structure and content fields
- Apply brand/accessibility rules from `constitution.md` as hard constraints
- Only design features listed as in-scope in `tasks.md`
- Use the **intent-to-component** skill to translate each spec intent into the correct Fluent 2 component — do NOT guess component names, and do NOT invent custom components

**Read the Visual Style section from `constitution.md` and derive the brand token overrides:**

```
Visual Style → Brand Token Overrides
─────────────────────────────────────────────────────────────────────
brand-color       → use the hex from constitution.md (or default #0F6CBD)
brand color ramp  → read brand10–brand160 values from constitution.md
corner-radius     → sm=4px / base=8px / lg=16px / xl=24px
shadow            → none / sm / base / md / lg
spacing           → compact (gap: 8px base) / comfortable (16px) / spacious (24px)
theme             → light / dark (sets page background and surface colors)
image-style       → drives Unsplash search query tone for all images
```

These overrides are passed to every design-structure agent and applied as local Figma Variables that shadow the Fluent 2 brand token ramp.

For each UI element in the plan, run intent-to-component to produce the Fluent 2 Component Mapping table:

```markdown
| UI Element | Intent | Platform | Fluent 2 Component | Notes |
|---|---|---|---|---|
| "Apply filters" button | Primary action | Desktop + Mobile | Button (Primary) | One per section |
| Status column | Feedback, non-blocking | Both | Badge | Map: active=success, inactive=subtle |
| Delete row | Destructive contextual action | Both | ToolbarButton (Danger) + Dialog | Requires Dialog confirmation |
```

Flag any mismatch between stated intent and chosen component as a WARNING before moving to Phase 2c.

### Phase 2c: Spec Completeness Check (GATE — do not proceed without passing)

Use the **spec-completeness** skill to validate every component in the Fluent 2 Component Mapping against its required fields.

Run the check against `spec.md`. For each component:
- Verify all BLOCKING fields are present in the spec
- Note any WARNING fields that will use assumed defaults

**If there are BLOCKING issues:**

Stop. Do not spawn any agents. Surface the gap report to the designer:

> **Spec is incomplete — cannot start building yet.**
>
> The following required information is missing:
> [paste BLOCKING issues from gap report]
>
> Please answer the above, then re-run `/design`.

**If there are only WARNINGS:**

State the assumptions clearly:

> **Proceeding with the following defaults — let me know if any need to change:**
> [paste WARNING items]

Then continue to Phase 3.

**If `tasks.md` contains alternatives** (two or more options flagged as parallel prototype candidates):

Instead of a single design plan, create one plan variant per alternative. In Phase 5, spawn one design-structure agent per variant. All variants are placed side-by-side on a dedicated **"Comparisons"** page in Figma, each labeled `Option A — [name]`, `Option B — [name]`, etc., at identical scale.

### Phase 2c (continued): Accessibility Pre-Check

After the spec completeness check passes, run the accessibility pre-check from the **a11y-annotations** skill against the design plan. This catches issues before any pixel is placed — fixing them after building is far more expensive.

**1. Contrast ratios** — for every planned text + background color pair, calculate the contrast ratio and validate against the WCAG level in `constitution.md`. Flag as BLOCKING if any pair fails.

Common pairs to check in every plan:
- Body text on page background
- Heading text on section backgrounds
- Button label on button fill (all variants: primary, secondary, danger)
- Placeholder text on input background
- Badge text on badge fill

**2. Touch target sizes (mobile designs)** — flag as WARNING if any interactive element in the plan is specified at less than 44×44px.

**3. Heading hierarchy** — verify the plan has exactly one H1 per page, and that heading levels are not skipped. Flag a missing H1 as BLOCKING.

**4. Image alt text** — verify every image in the Asset Summary has a planned alt text string (or is explicitly marked decorative). Flag missing alt text as BLOCKING.

Add all accessibility pre-check findings to the gap report alongside spec completeness findings. Resolve all BLOCKING issues before proceeding to Phase 3.

```markdown
## Design Plan: [Project Name]

### Spec-Kit Source
- constitution.md: [key brand/accessibility constraints applied]
- spec.md: [user stories mapped to pages/sections]
- plan.md: [data models used for component structure]
- tasks.md: [in-scope features included in this design]

### Visual Style Overrides
- Mood: [value from constitution.md]
- Theme: [light | dark]
- Brand color: [hex] — "[designer's original words]"
- Brand ramp: brand60=[hex], brand80=[hex], brand10=[hex], brand160=[hex] (key anchors)
- Corner radius: [value]px
- Shadow: [level]
- Spacing: [compact | comfortable | spacious]
- Image style: [description — drives all Unsplash queries]
- Inspiration: [URL or app name, or none]

### Fluent 2 Component Mapping
- [UI Element] → [Fluent 2 component name, e.g. "Button (Primary)", "TextInput", "Card"]
- [UI Element] → [Fluent 2 component name]
- ...

### Pages & Sections

#### Page 1: [Name]
Section 1 — [Name]:
  - Layout: [description]
  - IMAGE: "[search query or AI generation prompt]" → [source: Unsplash/AI]
  - FLUENT 2 COMPONENTS: [component names to import from Fluent 2 library]
  - ICONS: [icon-name-1], [icon-name-2], ...
  - Content: [headlines, body text, CTAs]

Section 2 — [Name]:
  ...

#### Page 2: [Name] (if multi-page)
  ...

### Asset Summary
- Fluent 2 components needed: [full list of component names to import]
- Icons needed: [full list with icon library source]
- Images needed: [full list with search queries and sizing]
```

### Phase 3: Spawn ALL Media-Creator Agents (asset gathering)

Spawn media-creator agents in a SINGLE message so they all run in parallel. Use `run_in_background: true` so you can proceed to Phase 4 while they work.

```
Spawn in ONE message (both run in parallel, both in background):
├─ media-creator Agent A: Fetch ALL icon SVGs (curl from @fluentui/svg-icons)
└─ media-creator Agent B: Search/download ALL stock images (Unsplash/Pexels)
```

Each agent gets a detailed prompt with:
- Exactly what assets to gather (full list from the Asset Summary)
- Expected return format (JSON maps)
- No Figma work — agents only gather assets

### Phase 4: Load Fluent 2 Design System

While media-creator agents gather assets in background, use the **figma-rest-api** skill to read available components and styles from the Fluent 2 library file.

```
Use figma-rest-api skill on file key: GvIcCw0tWaJVDSWD4f1OIW

Enumerate:
  - Published components (name → key mapping)
  - Published color styles
  - Published text styles
  - Published effect styles
```

Extract and build a **Fluent 2 asset map** to pass to design-structure agents:
```json
{
  "components": {
    "Button": "<component_key>",
    "TextInput": "<component_key>",
    "Card": "<component_key>",
    ...
  },
  "colorStyles": {
    "Brand/Primary": "<style_key>",
    "Neutral/Background1": "<style_key>",
    ...
  },
  "textStyles": {
    "Body1": "<style_key>",
    "Title2": "<style_key>",
    ...
  }
}
```

Filter the component list down to only the components named in the **Fluent 2 Component Mapping** from the plan. Pass the filtered asset map to all design-structure agents in Phase 5.

### Phase 5: Collect Media Results + Spawn Page Builders

Wait for all media-creator agents to complete. Collect their results:
1. Icon SVGs map: `{ iconName: svgString }`
2. Image URLs map: `{ sectionName: imageUrl }`
3. Generated media file paths (if any)

Then spawn **design-structure** agents to build content pages in Figma. Pass them the collected assets:

```
For single-page designs:
└─ design-structure Agent: Build the page with all assets baked in

For multi-page designs (spawn in ONE message, parallel):
├─ design-structure Agent A: Build Page 1 with its assets
├─ design-structure Agent B: Build Page 2 with its assets
└─ design-structure Agent C: Build Page 3 with its assets
```

**IMPORTANT:** Each design-structure agent must receive:
- The full design plan for its page(s)
- All icon SVGs it needs (embedded in the prompt as literal strings)
- All image URLs it needs (embedded in the prompt)
- The Fluent 2 component key map (from Phase 4)
- The Fluent 2 style key map (from Phase 4)

### Phase 6: Verify + Annotate + Cleanup

After all design-structure agents complete:

1. **Visual verify** — take screenshots with `mcp__design-playwright__browser_take_screenshot`
2. **Fix issues** — if visual problems found, spawn a small design-structure agent to fix them
3. **Structural verify** — spawn a design-structure agent to run `__figb.verify()` on each page
4. **Accessibility annotations** — spawn a dedicated design-structure agent using the **a11y-annotations** skill to add the complete annotation layer. Pass it:
   - The full design plan (all pages, sections, components)
   - The Fluent 2 Component Mapping table (all component + intent pairs)
   - The alt text plan from `spec.md`
   - The WCAG level and special requirements from `constitution.md`
   - The platform (desktop / mobile / both)

   The agent creates a **"♿ Accessibility"** page in the Figma file with:
   - Focus order badges (numbered tab sequence on every interactive element)
   - Landmark region overlays (header, nav, main, aside, footer, form)
   - Heading level labels (H1–H6 on every heading text node)
   - ARIA role labels (for custom interactive elements)
   - Alt text annotations (for every image)
   - Interactive state specs (focus, hover, disabled for all interactive components)
   - Reading order arrows (where visual order differs from logical order)

5. **Cleanup** — spawn a design-structure agent to run `__figs.remove()`

## Agent Prompt Templates

### media-creator Agent (Icons)
```
You are a media asset gatherer. Fetch the following SVG icons using curl.

Icons needed (from @fluentui/svg-icons — snake_case names, size 24, regular variant):
- home_24_regular, search_24_regular, bell_24_regular, person_24_regular, arrow_right_24_regular, checkmark_24_regular, star_24_regular, ...

For each icon, fetch from: https://unpkg.com/@fluentui/svg-icons@latest/icons/{name}.svg
Fetch ALL icons in parallel using multiple curl calls.

Return a JSON map of { iconName: svgString } for ALL icons.
Do NOT do any Figma work. Only gather assets.
```

### media-creator Agent (Stock Images)
```
You are a media asset gatherer. Find stock photos for the following sections.

Images needed:
- hero: "futuristic city skyline at night" → search Unsplash, use ?w=1440&q=80
- card1: "cloud computing abstract" → search Unsplash, use ?w=640&q=80
- avatar1: "professional headshot" → search Unsplash, use ?w=200&q=80

Search using: WebSearch "site:unsplash.com {query}"
Extract direct image URLs with size params.

Return a JSON map of { sectionName: imageUrl } for ALL images.
Do NOT do any Figma work. Only gather assets.
```

### design-structure Agent (Content Page)
```
You are a Figma design builder. Build [Page Name] in the Figma file.

Navigate to [Figma URL] and verify connection.
Use mcp__design-playwright__browser_evaluate with __figb.* helpers.

Design plan for this page:
[paste the page sections here]

Assets available:
Icons: { home: '<svg>...', search: '<svg>...', ... }
Images: { hero: 'https://...', card1: 'https://...', ... }

Fluent 2 components (import by key using figma.importComponentByKeyAsync):
{ "Button": "<key>", "TextInput": "<key>", "Card": "<key>", ... }

Fluent 2 styles (apply by key using figma.importStyleByKeyAsync):
{ "Brand/Primary": "<key>", "Body1": "<key>", ... }

Visual style overrides (from constitution.md — apply these to ALL structural frames):
{
  "brandColor": "#7B2FBE",
  "brandRamp": { "brand10": "#F5EEFF", "brand60": "#7B2FBE", "brand80": "#4A1A7A", "brand160": "#0D0020" },
  "cornerRadius": 24,
  "shadow": "md",
  "spacing": "spacious",
  "theme": "light",
  "imageStyle": "colorful, people, fun"
}

Rules:
- ALWAYS use Fluent 2 components for interactive elements (buttons, inputs, checkboxes, dropdowns)
- ALWAYS use Fluent 2 color and text styles for typography — never hardcode font sizes
- Apply brand color overrides via Figma Variables (see figma-bridge skill — Brand Token Override section)
- Use brand ramp colors on structural frames (hero fills, section backgrounds, accents) — not on Fluent 2 component instances
- Apply corner-radius, shadow, and spacing values from the visual style overrides to ALL structural frames
- Image search queries must reflect the image-style from visual style overrides
- Build each section with assets baked in. Max 5 elements per chunk.
- Every frame with an image loads it in the same script.
```

## Rules

1. **NEVER do work yourself** — you are a PURE orchestrator. ALL asset gathering goes to media-creator agents. ALL Figma building goes to design-structure agents.
2. **NEVER work sequentially** — always spawn agents in parallel where possible
3. **Pass results between agents** — media-creator results must be embedded into design-structure prompts
4. **Load Fluent 2 design system first** — enumerate Fluent 2 components/styles while media agents gather assets, before content pages
5. **Verify at the end** — `__figb.verify()` + visual snapshot after all agents complete
6. **Respect spec-kit constraints** — treat `constitution.md` rules as hard constraints (not suggestions). Never design features outside the scope defined in `tasks.md`.
7. **Speckit is a hard prerequisite** — never start Phase 3 if speckit is not installed or `.specify/` does not exist. Always stop and guide the user to install/run speckit first.
8. **Use intent-to-component for ALL component decisions** — never pick a Fluent 2 component by intuition. Always run the intent-to-component skill to derive and validate every component choice in Phase 2b.
9. **Phase 2c is a hard gate** — never spawn media-creator or design-structure agents if the spec completeness check or accessibility pre-check has unresolved BLOCKING issues. A design built on an incomplete spec will fail in review.
10. **Accessibility annotations are mandatory** — every completed design gets a "♿ Accessibility" page. This is not optional and is not skipped even for quick designs. Annotations are the handoff contract with developers.
