---
name: intent-to-component
description: >
  Bidirectional mapping between design intent and Fluent 2 components, platform-aware. Use when
  translating spec intent into concrete component choices ("what component should I use for
  single-selection from 8 options on mobile?"), or validating that a chosen component matches
  its stated intent ("is a dropdown right here?"). Also resolves component → intent for
  spec review. Always call this skill before finalising the Fluent 2 Component Mapping in the
  design plan.
---

# Intent-to-Component

Translate design intent into the correct Fluent 2 component — and validate component choices against stated intent. Intent is always the starting point; components are an implementation detail.

## When to Use

- During design planning: converting spec intent into a Fluent 2 Component Mapping
- During spec review: validating that component choices match stated intent
- When the spec names a component without justifying it — derive the intent and check it fits
- When intent is ambiguous — use the decision factors to surface alternatives

## When NOT to Use

- User is asking about non-Fluent-2 design systems → adapt the component names but keep the intent logic
- User already has a finalised component list they're happy with → skip to spec-completeness skill

---

## Intent Categories & Decision Tables

### 1. Selection Intent
*The user needs to pick value(s) from a set of options.*

| Context | Decision Factor | Fluent 2 Component |
|---|---|---|
| Pick one, 2–3 options, always visible | Mutually exclusive, compact | **ToggleButton** group |
| Pick one, 2–5 options, always visible, desktop | Standard choice | **RadioGroup** |
| Pick one, 4–12 options, space-constrained | Hidden until triggered | **Dropdown** / **Select** |
| Pick one, 12+ options | Needs search | **ComboBox** (searchable dropdown) |
| Pick one, 4–12 options, mobile | Native feel | **Select** → renders as bottom-sheet picker on mobile |
| Pick many, 2–5 options | All visible | **CheckboxGroup** |
| Pick many, 6+ options | Space-constrained | **TagPicker** / **MultiSelect** |
| Pick many, free-form tags | User types values | **TagInput** |
| Binary yes/no, immediate effect | No form submit needed | **Switch** (Toggle) |
| Binary yes/no, part of a form | Submit-time value | **Checkbox** |

**Validation rules:**
- If intent is "single selection" but spec says Checkbox → flag: checkboxes imply multi-select
- If intent is "binary toggle with immediate effect" but spec says RadioGroup → flag: consider Switch
- If option count > 7 and RadioGroup is chosen → flag: consider Dropdown for space efficiency

---

### 2. Navigation Intent
*The user needs to move between sections, screens, or destinations.*

| Context | Decision Factor | Desktop | Mobile |
|---|---|---|---|
| 2–6 peer destinations, primary nav | Always visible, equal weight | **TabList** (top) | **TabBar** (bottom) |
| 5–10 destinations, primary nav | Hierarchical, with labels | **Nav** (vertical sidebar) | **Drawer** (hamburger triggered) |
| 2–4 destinations, secondary nav | Within a page section | **TabList** (horizontal, smaller) | **TabList** or segmented |
| Hierarchical path, wayfinding | User is deep in hierarchy | **Breadcrumb** | **Back button stack** |
| Utility/settings navigation | Low-frequency, secondary | **Nav** footer section | **Settings screen** (new screen) |
| Contextual jump | From one item to a related item | **Link** | **Link** |

**Validation rules:**
- More than 7 items in a TabList → flag: tabs don't scale; consider Nav sidebar
- Bottom TabBar on desktop → flag: bottom nav is a mobile pattern; use top TabList
- Breadcrumb with only 1 level → flag: breadcrumb implies hierarchy; likely unnecessary here
- Drawer on desktop (unless forced) → flag: sidebars are preferred on desktop

---

### 3. Data Display Intent
*The user needs to see a collection of items.*

| Context | Decision Factor | Fluent 2 Component |
|---|---|---|
| Compare items across many attributes | Structured, scannable rows | **DataGrid** / **Table** |
| Scan a flat list quickly | Sequential, single-column | **List** |
| Browse visually | Images/thumbnails important | **Card** grid (custom layout) |
| Few items, rich detail per item | Expanded info per card | **Card** stack (vertical) |
| Chronological events | Order and time matter | Custom timeline (frames + connectors) |
| Key metrics at a glance | Single values, prominent | **Badge** / stat card (custom frame) |
| Hierarchical data | Parent/child relationships | **Tree** |
| Real-time feed | New items appear at top | **List** with live update |

**Decision factors to ask about:**
- Does the user need to **sort** columns? → DataGrid (not List or Cards)
- Does the user need to **filter**? → DataGrid with FilterBar, or List with SearchBox
- Does the user need to **select rows** for bulk action? → DataGrid with selection
- Are there **row-level actions**? → DataGrid with RowActions, or List with swipe (mobile)
- Are items **primarily visual**? → Cards
- Is the data **sparse or dense**? → Cards for sparse, DataGrid for dense

**Validation rules:**
- Spec says "table" for 2–3 attributes → flag: consider Card or List for readability
- Spec says "cards" but user needs to compare attributes → flag: DataGrid is better for comparison
- Spec says "list" but has sortable columns → flag: use DataGrid

---

### 4. Action Intent
*The user needs to trigger an operation.*

| Context | Decision Factor | Fluent 2 Component |
|---|---|---|
| Primary action on a page/form | One per screen, most important | **Button** (Primary) |
| Secondary action alongside primary | Supportive, less prominent | **Button** (Secondary/Outline) |
| Destructive action | Irreversible, needs caution | **Button** (Danger variant) |
| Contextual action on a row/item | Tied to a specific item | **ToolbarButton** / row action **Menu** |
| Overflow actions (3+) | Too many to show inline | **Menu** (triggered by `more-horizontal` icon) |
| Icon-only action | Space-constrained, recognisable | **Button** (icon-only) — requires tooltip |
| Global create/add action | Always accessible, mobile | **Button** (Primary, sticky bottom) |
| Toolbar actions | Multiple related actions | **Toolbar** with **ToolbarButton** items |

**Validation rules:**
- More than 2 primary buttons on one screen → flag: only one action can be "primary"
- Icon-only button without tooltip → flag: accessibility violation; tooltip label required (see spec-completeness)
- Destructive action without confirmation step → flag: add Dialog confirmation
- Row action as a full Button → flag: use ToolbarButton or Menu for inline row actions

---

### 5. Feedback Intent
*The user needs to know the result of an action or the state of the system.*

| Context | Decision Factor | Fluent 2 Component |
|---|---|---|
| Non-critical confirmation, auto-dismisses | Low urgency, transient | **Toast** (MessageBar, auto-dismiss) |
| Important status, stays until dismissed | Persistent, page-level | **MessageBar** (warning/error/info) |
| Blocks the flow, requires a decision | Modal — user must respond | **Dialog** |
| Inline field-level validation | Tied to a specific input | **TextInput** error state + helper text |
| Loading — short wait (<2s) | Indeterminate, small | **Spinner** |
| Loading — longer or progress known | Progress visible | **ProgressBar** |
| Loading — content is loading | Skeleton of final layout | **Skeleton** |
| Empty state | No data yet | Custom frame (illustration + copy + CTA) |

**Validation rules:**
- Dialog for non-blocking info → flag: Toast or MessageBar is less disruptive
- Toast for a critical error that blocks the user → flag: use MessageBar or Dialog
- Spinner with no timeout handling → flag: add error state for long waits
- No empty state specified for any list/table → flag: required (see spec-completeness)

---

## Reverse Direction: Component → Intent

When a spec lists a component name without stating intent, derive the intent and validate:

| Component in Spec | Inferred Intent | Validate |
|---|---|---|
| Dropdown | Single selection, space-constrained | How many options? Is search needed? |
| RadioGroup | Single selection, always visible | Are there ≤5 options? |
| Switch | Binary toggle, immediate effect | Does it save immediately or on form submit? |
| DataGrid | Structured comparison of many attributes | Does the user need to sort/filter/select? |
| Dialog | Blocking decision or critical info | Is it truly blocking, or can Toast be used? |
| Tabs | Peer navigation, 2–6 destinations | Are there too many for tabs? |
| Toast | Non-critical transient feedback | Is the message critical enough to persist? |

---

## Platform Variants Summary

| Intent | Desktop | Mobile |
|---|---|---|
| Single selection (4–12 options) | Dropdown | Select (bottom-sheet) |
| Primary navigation (5–10 items) | Vertical sidebar Nav | Hamburger + Drawer |
| Tab navigation | Top TabList | Bottom TabBar |
| Overflow actions | Hover dropdown Menu | Long-press or swipe action sheet |
| Primary CTA | Inline Button | Sticky bottom Button |
| Data table | DataGrid (dense) | List (simplified, detail on tap) |
| Confirmation | Dialog | Action Sheet |

---

## Output Format

When using this skill to produce a component mapping, output a table in this format:

```markdown
### Fluent 2 Component Mapping

| UI Element | Intent | Platform | Fluent 2 Component | Notes |
|---|---|---|---|---|
| "Apply filters" button | Primary action | Desktop + Mobile | Button (Primary) | One per section |
| Column sort | Data navigation | Desktop | DataGrid (built-in sort) | — |
| Status indicator | Feedback, non-blocking | Both | Badge | Map: active=success, inactive=subtle |
| Delete row | Destructive contextual action | Both | ToolbarButton (Danger) + Dialog confirm | Requires confirmation |
| "No results" | Empty state feedback | Both | Custom frame | Needs copy + CTA |
```

Flag any mismatch between stated intent and chosen component as a **WARNING** before proceeding to spec-completeness.
