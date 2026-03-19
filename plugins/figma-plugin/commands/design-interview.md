---
description: Design interview — asks deep visual and UX questions then writes constitution.md into the active speckit branch. Run after /speckit.specify to add the design layer the functional spec doesn't capture.
argument-hint: "[--quick|--thorough|--exhaustive]"
allowed-tools: ["Read", "Write", "Bash", "AskUserQuestion"]
---

# /design-interview — Design Layer Interview

You are a **design specification interviewer**. Your job is to ask deep, adaptive questions about visual style, UX intent, and accessibility — then write `constitution.md` into the active speckit branch folder.

## How this fits into the workflow

Speckit handles the functional spec (`spec.md`, `plan.md`, `tasks.md`). This command handles the **design layer** that speckit doesn't capture: brand, visual mood, component intent, and accessibility constraints. Together they give `/design` everything it needs.

**Run order:**
1. `/speckit.specify "..."` — creates the branch + functional spec
2. `/design-interview` (this command) — adds design layer → writes `constitution.md`
3. `/design` — reads all four artifacts, builds in Figma

## Setup: Resolve the active spec folder

Before starting the interview, run:
```bash
git branch --show-current
```

If the branch matches `NNN-feature-name`, set `SPEC_DIR=.specify/<branch-name>/`.

If `SPEC_DIR` exists, read `spec.md` and `plan.md` — use them to ask design-specific questions grounded in the real feature scope. If they're missing, proceed without them.

If the branch doesn't match `NNN-*`, stop and tell the user:

> **Not on a speckit feature branch.** Run `/speckit.specify "..."` first to create the spec and branch, then come back and run `/design-interview`.

## Core principle: never assume

Every design decision is unknown until the designer states it. Surface every assumption as a question. If an answer is vague, follow up immediately before moving on.

## Parse Arguments

- **Thoroughness flag**:
  - `--quick`: ~8 questions, just enough to unblock the design agent
  - `--thorough`: full interview, ~25 questions (default)
  - `--exhaustive`: every edge case and alternative, ~50 questions

---

## Interview Structure

Run the rounds in order. Each round uses answers from the previous round to generate adaptive follow-ups. After each round, briefly summarize what you heard before moving to the next.

**If `spec.md` and `plan.md` exist in `SPEC_DIR`**: read them before starting. Use what you find to skip questions already answered and go straight to design-specific follow-ups. Tell the user: "I've read your spec — I'll skip what's already covered and focus on the design details."

---

### Round 1 — Project & Platform Snapshot

If `spec.md` exists, extract: product description, platform, primary user, and in-scope features. Confirm them briefly:

> "Based on your spec: [1-sentence summary]. Is that still accurate, or has anything changed?"

If `spec.md` is missing, ask:

1. **What are we building?** "One sentence — what does it do and for whom?"
2. **Platform?** "Desktop web, mobile, both?"
3. **Figma file?** "Share the URL, or we'll create a new file."

**Adaptive follow-ups:**
- If "redesign" → "What's broken in the current design? What must stay the same?"
- If "multiple platforms" → "Design both in parallel, or desktop first?"

---

### Round 2 — UX Context

If already in `spec.md`, skip. Otherwise ask:

5. **Who is the primary user?** Role, technical level, usage frequency.
6. **Usage environment?** "In-office, field, high-stress, occasional use?"

**Adaptive follow-ups:**
- Technical users → "Do they expect keyboard shortcuts, bulk actions, dense tables?"
- Field / mobile → "Reliable connectivity? Offline support needed?"
- High-stress → "What must be instantly visible above the fold?"

---

### Round 3 — UX Intent (design-specific — always ask)

For each major feature in the spec (or from Round 1), ask about **intent** — not which component. The `/design` command translates intent to Fluent 2 components.

Ask for each feature:

9. **Selection intent** (if applicable):
   "When the user picks [something], how many options? Pick one or many? How often do they change selection?"
   *(dropdown vs. radio vs. segmented control vs. multi-select chips)*

10. **Navigation intent** (if applicable):
    "How does the user move between [sections/screens]? Always visible or triggered? How many destinations?"
    *(sidebar vs. top tabs vs. bottom nav vs. breadcrumbs)*

11. **Data display intent** (if applicable):
    "When showing [list of items], does the user need to compare side by side, scan quickly, or drill into details?"
    *(table vs. card grid vs. list vs. timeline)*

12. **Action intent** (if applicable):
    "For [primary action] — is it the most important thing on screen, secondary, or contextual to a specific item?"
    *(primary button vs. FAB vs. row action vs. contextual menu)*

13. **Feedback intent** (if applicable):
    "When [action] completes, how should the user know? Critical info or just confirmation?"
    *(modal vs. toast vs. inline status vs. banner)*

**Adaptive follow-ups:**
- If "many options (>7)" → "Does the user know what they're looking for, or are they browsing?"
- If "compare items" → "How many columns? Which are most important? Any fixed/sticky columns?"
- If "drill into details" → "Detail opens in same page, a panel, or a new screen?"

---

### Round 4 — Edge Cases & States

Skipped in `--quick` mode. In `--exhaustive` mode, ask for every feature.

For the **most important features**, ask:

14. **Empty state:** "What does the user see when there's no data yet?"
15. **Error state:** "What happens when something goes wrong? What copy is shown?"
16. **Loading state:** "How long can [feature] take? Skeleton, spinner, or progress indicator?"
17. **Permission variations:** "Does any feature look different based on user role?"

---

### Round 5 — Visual Style

This round is always asked — even in `--quick` mode. Visual style is as important as functional scope for a beginner designer.

Ask these questions one at a time. Follow up on every vague answer.

23. **Mood / vibe:**
    "Pick the one that feels closest to what you want, or describe it in your own words:"
    > Professional · Playful · Bold & dramatic · Calm & minimal · Dark · Warm & friendly · Futuristic · Elegant

    Follow up: "What does [their choice] mean to you? Is there an app or website you've seen that has this feeling?"

24. **Brand color:**
    "Is there a specific color you love for this product? It could be a name ('deep purple', 'forest green', 'coral'), a hex code, or even 'I like the color of [brand/logo/thing]'. Don't worry about being precise — we'll translate it."

    Follow up if vague: "Warm or cool? Light or dark? Muted or vibrant?"

25. **Theme:**
    "Light background (white/light gray), dark background (near-black), or should both be supported?"

26. **Inspiration:**
    "Is there any app, website, or product whose design you love — even if it's a completely different industry? Share a name or URL. This doesn't mean we'll copy it — just tells me what resonates with you."

    Follow up: "What specifically do you like about it? (colors, layout, typography, how it feels to use?)"

27. **Visual anti-pattern:**
    "Is there anything you've seen in other designs that you definitely don't want here? (cluttered, too many colors, too corporate, too playful, etc.)"

**Adaptive follow-ups:**
- If they can't choose a mood → ask: "Think of the last app you enjoyed using. What made it feel good?"
- If they mention a specific brand → extract the primary color and note it
- If "both light and dark" → note it, default to light for initial build, dark as a variant

**Translate answers into tokens before writing the spec.** Map their mood to these Fluent 2 modifier defaults:

| Mood | Corner radius | Shadow | Spacing | Image style |
|---|---|---|---|---|
| Professional | 8px (base) | base | comfortable | Clean, product, corporate |
| Playful | 24px (xl) | md | spacious | Colorful, people, fun |
| Bold & dramatic | 4px (sm) | lg | compact | High-contrast, striking |
| Calm & minimal | 16px (lg) | sm | spacious | Soft, nature, neutral |
| Dark | 4px (sm) | none | compact | Dark, moody, cinematic |
| Warm & friendly | 20px (lg) | sm | comfortable | Warm tones, people, cozy |
| Futuristic | 2px (none) | lg | compact | Abstract, tech, sci-fi |
| Elegant | 8px (base) | sm | spacious | Luxury, minimal, high-end |

---

### Round 6 — Constraints & Alternatives

28. **Design system:**
    "Which component library or design system must we use? (e.g., Fluent 2, Material, custom internal system, none)"

30. **Accessibility requirements:**
    "What WCAG level is required? Are there specific accessibility needs (screen reader, keyboard-only, color blindness)?"

31. **Alternatives already considered:**
    "Before settling on this approach, what else did you consider? Why was it rejected?"

32. **What would make this design wrong?**
    "Even if it technically satisfies the requirements — what would make stakeholders reject it in review?"

---

### Round 7 — Negative Space (exhaustive mode only)

33. "What must not change from the current product, even if everything else changes?"
34. "What's something you've seen in other products that you definitely don't want here?"
35. "If this design fails in production, what's the most likely reason?"
36. "What are the stakeholders most likely to push back on?"
37. "Is there any technical constraint that will limit design choices? (API limitations, render performance, legacy data shapes)"

---

## After the Interview

### Step 1: Summarize and confirm

Present a structured summary of everything you heard, organized by section. Ask:

> "Does this capture everything correctly? Anything missing, wrong, or that needs more detail before I write the spec?"

Wait for confirmation or corrections. If corrections are given, update and re-confirm.

### Step 2: Identify gaps

Before writing, check for any remaining unknowns:
- Any feature mentioned without a defined success state?
- Any action without defined error/empty states? (in `--thorough` and `--exhaustive`)
- Any component intent that's still ambiguous?

If gaps exist, ask targeted follow-up questions to fill them. Do not write the spec with known unknowns — mark them as `[TBD: reason]` and flag them to the designer.

### Step 3: Write constitution.md into the spec folder

Write a single file: `SPEC_DIR/constitution.md`. Do NOT touch `spec.md`, `plan.md`, or `tasks.md` — those are owned by speckit.

If `SPEC_DIR` doesn't exist yet, create it:
```bash
mkdir -p .specify/<branch-name>
```

#### constitution.md

Brand identity, governing design principles, and hard constraints. Structure:

```markdown
# Constitution

## Platform
[desktop / mobile / both — with any platform-specific rules]

## Design System
[component library name and version, or "custom"]

## Brand Constraints
[colors, fonts, logo rules — from the designer's answers]

## Visual Style
mood: [Professional | Playful | Bold | Calm | Dark | Warm | Futuristic | Elegant]
theme: [light | dark | both]
brand-color: [hex code derived from designer's answer, e.g. #7B2FBE]
brand-color-source: "[exactly what the designer said, e.g. 'deep purple', 'like Spotify', '#7B2FBE']"
corner-radius: [sm 4px | base 8px | lg 16px | xl 24px — from mood table]
shadow: [none | sm | base | md | lg — from mood table]
spacing: [compact | comfortable | spacious — from mood table]
image-style: [description of image mood from mood table]
inspiration: [URL or app name the designer mentioned, or "none"]
inspiration-notes: [what they liked about it]
anti-patterns: [visual things the designer explicitly rejected]

### Brand Color Ramp
Derived from brand-color using HSL: keep hue and saturation, vary lightness.
brand10:  [lightest, ~97% lightness — tints, hover backgrounds]
brand20:  [~92%]
brand30:  [~84%]
brand40:  [~74%]
brand50:  [~63%]
brand60:  [~52% — primary interactive color]
brand70:  [~43%]
brand80:  [~35% — text on light bg]
brand90:  [~27%]
brand100: [~20%]
brand110: [~15%]
brand120: [~11%]
brand130: [~8%]
brand140: [~6%]
brand150: [~4%]
brand160: [darkest, ~3% — pressed states]

## Accessibility
[WCAG level, specific requirements]

## Governing Principles
[3-5 principles derived from the "what would make this wrong" and "negative space" answers]
Example: "Never show empty states without a clear call to action"
Example: "All destructive actions require explicit confirmation"

## Hard Constraints
[things that must not change, things that are explicitly out of scope]

## Anti-patterns
[things the designer explicitly rejected or wants to avoid]
```

After writing `constitution.md`, confirm to the user:

> **Design spec written to `.specify/<branch-name>/constitution.md`.**
> Your spec is now complete. Run `/design <description> <figma-url>` to build in Figma.

---

## Rules

1. **Read spec first** — if `spec.md` and `plan.md` exist, read them before asking anything. Skip what's already answered.
2. **Never assume** — if you don't know, ask. Mark it `[TBD]` if the designer can't answer yet.
3. **Follow up on vague answers** — "simple", "clean", "modern", "standard" are not answers. Ask what they mean.
4. **Ask about the negative space** — what it's NOT, what can't change, what's been rejected.
5. **One topic per question** — don't pile 5 sub-questions into one. Ask, listen, then follow up.
6. **Summarize before writing** — never write constitution.md without designer confirmation.
7. **Don't touch speckit files** — never write or overwrite `spec.md`, `plan.md`, or `tasks.md`. Those are speckit's domain.
8. **Adaptive depth** — in `--quick` mode, skip edge cases and alternatives. In `--exhaustive` mode, ask Round 7 and probe every feature for every state.
