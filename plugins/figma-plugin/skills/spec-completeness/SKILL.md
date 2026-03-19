---
name: spec-completeness
description: >
  Validates a design spec against component requirements — checks that every component in the
  plan has all the information needed to build and connect it correctly. Use after the Fluent 2
  Component Mapping is finalised and before spawning any design-structure agents. Outputs a
  gap report with BLOCKING issues (must fix before building) and WARNINGS (should fix, won't
  block). Common checks: icon buttons without tooltip labels, tables without column headers,
  actions without error states, empty states missing from any list or table.
---

# Spec Completeness

Validate the design spec before building begins. Every component has a minimum set of required information. Missing it means the design agent guesses — and guesses compound into incoherence.

## When to Use

- After the Fluent 2 Component Mapping is complete (Phase 2b of `/design`)
- Before any design-structure agent is spawned
- When reviewing a spec.md to find gaps before handing it to a designer for approval

## When NOT to Use

- During the interview phase (use speckit for that)
- After agents have started building — fix the spec first, then build

---

## Severity Levels

| Level | Meaning | Action |
|---|---|---|
| **BLOCKING** | Component cannot be built correctly without this | Stop. Get answer from designer before proceeding. |
| **WARNING** | Component will be built with a reasonable default, but designer should confirm | Surface the assumption. Proceed if designer doesn't object. |
| **INFO** | Optional enhancement that would improve quality | Note it. Don't block. |

---

## Required Fields by Component

### Button (Primary / Secondary / Outline / Ghost)

| Field | Required | Level if missing |
|---|---|---|
| Label text | Yes | BLOCKING |
| Variant (primary/secondary/outline/ghost/danger) | Yes | WARNING — assume Primary |
| Action / destination | Yes | BLOCKING |
| Disabled state condition | No | INFO |

### Button (Icon-only)

| Field | Required | Level if missing |
|---|---|---|
| Tooltip label (aria-label) | **Yes** | **BLOCKING** — accessibility violation |
| Icon name | Yes | BLOCKING |
| Action / destination | Yes | BLOCKING |
| Variant | No | WARNING — assume Secondary |

### DataGrid / Table

| Field | Required | Level if missing |
|---|---|---|
| Column headers (label for each column) | **Yes** | **BLOCKING** |
| Column data type (text / number / date / status / action) | Yes | BLOCKING |
| Empty state copy | Yes | BLOCKING |
| Empty state CTA (if applicable) | No | WARNING |
| Loading state type (skeleton / spinner) | No | WARNING — assume skeleton |
| Row selection behaviour (single / multi / none) | No | WARNING — assume none |
| Sort behaviour (which columns, default sort) | No | WARNING — assume none |
| Pagination type (pages / infinite scroll / none) | No | WARNING — assume none |
| Row actions list (if any) | No | INFO |
| Bulk action list (if row selection enabled) | No | WARNING if selection enabled |

### List (flat list of items)

| Field | Required | Level if missing |
|---|---|---|
| Item content fields (what each row shows) | Yes | BLOCKING |
| Empty state copy | Yes | BLOCKING |
| Loading state | No | WARNING — assume spinner |
| Swipe actions (mobile) | No | INFO |
| Item tap/click destination | No | WARNING if items look interactive |

### TextInput / Input Field

| Field | Required | Level if missing |
|---|---|---|
| Label | **Yes** | **BLOCKING** — accessibility violation |
| Placeholder text | No | WARNING |
| Required vs optional | Yes | WARNING — assume required |
| Validation rule(s) | No | WARNING |
| Error message copy | No | WARNING — assume generic message |
| Helper text (below input) | No | INFO |
| Input type (text / email / password / number / date) | No | WARNING — assume text |

### Select / Dropdown / ComboBox

| Field | Required | Level if missing |
|---|---|---|
| Label | Yes | BLOCKING |
| Options list (all option labels) | Yes | BLOCKING |
| Default / placeholder text | No | WARNING — assume "Select an option" |
| Empty state (no options available) | No | WARNING |
| Disabled state condition | No | INFO |

### RadioGroup / CheckboxGroup

| Field | Required | Level if missing |
|---|---|---|
| Group label | Yes | BLOCKING |
| Label for each option | Yes | BLOCKING |
| Default selected value | No | WARNING — assume none pre-selected |
| Error state message | No | WARNING |

### Switch (Toggle)

| Field | Required | Level if missing |
|---|---|---|
| Label | Yes | BLOCKING |
| On/off state labels (if shown) | No | INFO |
| Default state | No | WARNING — assume off |
| Effect description (what happens when toggled) | Yes | BLOCKING — without this, agent can't connect it |

### Dialog / Modal

| Field | Required | Level if missing |
|---|---|---|
| Title | Yes | BLOCKING |
| Confirm button label | **Yes** | **BLOCKING** — never "OK" or "Yes" |
| Cancel / dismiss label | No | WARNING — assume "Cancel" |
| Body copy | Yes | BLOCKING |
| Trigger element | Yes | BLOCKING — what opens this dialog? |
| Dismissable by clicking outside? | No | WARNING — assume yes for non-destructive |
| Destructive confirmation? | No | WARNING — flag if action is irreversible |

### Toast / MessageBar

| Field | Required | Level if missing |
|---|---|---|
| Message copy | Yes | BLOCKING |
| Severity (info / success / warning / error) | Yes | BLOCKING |
| Auto-dismiss duration | No | WARNING — assume 4s for Toast, persistent for MessageBar |
| Action label + action (if actionable) | No | INFO |
| Trigger condition | Yes | BLOCKING — what causes this to appear? |

### Navigation (Sidebar / TabList / TabBar)

| Field | Required | Level if missing |
|---|---|---|
| Label for each item | **Yes** | **BLOCKING** |
| Icon for each item (if icons used) | Yes if icon-only | BLOCKING if no label |
| Active/selected state definition | Yes | BLOCKING |
| Destination for each item | Yes | BLOCKING |
| Badge/notification indicator (if applicable) | No | INFO |

### Tabs (TabList within a page)

| Field | Required | Level if missing |
|---|---|---|
| Label for each tab | Yes | BLOCKING |
| Content description for each tab panel | Yes | BLOCKING |
| Default active tab | No | WARNING — assume first tab |

### Form (collection of fields)

| Field | Required | Level if missing |
|---|---|---|
| Submit button label | Yes | BLOCKING |
| Submit action / destination | Yes | BLOCKING |
| Cancel action (if applicable) | No | WARNING |
| Validation mode (inline / on-submit) | No | WARNING — assume on-submit |
| Success state (what happens after submit) | Yes | BLOCKING |
| Error state (what happens if submit fails) | Yes | BLOCKING |

### Empty State (any list, table, or dashboard section)

| Field | Required | Level if missing |
|---|---|---|
| Heading copy | Yes | BLOCKING |
| Body / explanation copy | No | WARNING |
| CTA label + action | No | WARNING — missing CTA leaves user stuck |
| Illustration or icon | No | INFO |

### Badge / Status Indicator

| Field | Required | Level if missing |
|---|---|---|
| Value-to-label mapping (what each value shows) | Yes | BLOCKING |
| Color / severity mapping | No | WARNING — use default Fluent 2 colours |
| Screen reader label (if icon-only badge) | Yes if icon-only | BLOCKING |

### Card (dynamic content)

| Field | Required | Level if missing |
|---|---|---|
| Content fields (title, body, meta, image) | Yes | BLOCKING |
| Actions on card (if any) | No | INFO |
| Empty / missing content fallback | No | WARNING |
| Click / tap destination | No | WARNING if card looks interactive |

---

## How to Run the Check

For each component in the Fluent 2 Component Mapping from Phase 2b:

1. Look up its required fields in the tables above
2. Check `spec.md` for each required field — is it specified?
3. If BLOCKING fields are missing → add to the **Blocking Issues** list
4. If WARNING fields are missing → add to the **Warnings** list
5. After checking all components, output the gap report

---

## Gap Report Format

```markdown
## Spec Completeness Report

### BLOCKING — Must resolve before building

1. **[Component: icon button "Delete row"]** — Missing tooltip label.
   Icon-only buttons require an accessible label. What should the tooltip say?

2. **[Component: DataGrid "User table"]** — Missing empty state copy.
   What should the user see when the table has no rows? Include heading, optional body, and CTA.

3. **[Component: Dialog "Delete confirmation"]** — Confirm button label is "OK".
   "OK" is not descriptive. What should the confirm button say? (e.g. "Delete user", "Remove item")

### WARNINGS — Assumed defaults, please confirm

4. **[Component: DataGrid "User table"]** — No sort behaviour specified.
   Assuming columns are not sortable. Confirm, or specify which columns should sort.

5. **[Component: Form "Invite user"]** — Validation mode not specified.
   Assuming on-submit validation. Confirm, or specify inline validation.

6. **[Component: Toast "Save success"]** — No dismiss duration specified.
   Assuming auto-dismiss after 4 seconds.

### INFO — Optional improvements

7. **[Component: Empty state "No users"]** — No illustration specified.
   Consider adding an icon or illustration to improve the empty state.

---
Blocking issues: 3 — design build cannot start until resolved.
Warnings: 3 — proceeding with stated defaults unless designer objects.
```

---

## Rules

1. **Every BLOCKING issue must be resolved** before any design-structure agent is spawned. Ask the designer. Do not guess.
2. **Warnings may be proceeded on** — state the assumption clearly and give the designer one chance to object before building.
3. **Check every component in the plan** — do not spot-check. A missed gap will surface during design review, which is far more expensive.
4. **Icon-only buttons and unlabelled nav items are always BLOCKING** — they are accessibility violations, not just missing content.
5. **Empty states are always BLOCKING for any list or table** — an unspecified empty state means the design agent will invent copy, which will never match the product's tone.
6. **Dialog confirm labels of "OK", "Yes", "Confirm"** are always BLOCKING — they are vague and fail both accessibility and UX standards. Always get a specific verb phrase.
