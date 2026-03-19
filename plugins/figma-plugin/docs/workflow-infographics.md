# Figma Plugin — Workflow Infographic

> **One-Pager** · Render with any Mermaid-compatible viewer (GitHub, VS Code Mermaid Preview, Notion, etc.)

```mermaid
flowchart TB
    %% ── Entry ──
    USER(["👤 Designer"])

    subgraph CMD["Commands"]
        direction LR
        SPECKIT["/speckit\nInteractive interview\n—quick · —thorough · —exhaustive"]
        DESIGN["/design\nOrchestrated build\ndescription + Figma URL"]
    end

    %% ── Speckit output ──
    subgraph SPEC[".specify/ Artifacts"]
        direction LR
        S1["📜 constitution.md\nBrand · A11y · Principles"]
        S2["📋 spec.md\nPersonas · Stories · Scope"]
        S3["🏗️ plan.md\nData models · Components"]
        S4["✅ tasks.md\nPhased priorities"]
    end

    %% ── Planning & Gating ──
    subgraph GATE["Phase 2 · Plan & Quality Gate"]
        direction TB
        G1["intent-to-component\nMap spec intents → Fluent 2 components"]
        G2["spec-completeness\nValidate every component has required props"]
        G3["a11y pre-check\nContrast · Touch targets · Headings · Alt text"]
        BLOCK{{"🔴 BLOCKING\nissues?"}}
        G1 --> G2 --> G3 --> BLOCK
    end

    %% ── Parallel work ──
    subgraph PARALLEL["Phase 3-5 · Parallel Execution"]
        direction TB

        subgraph MEDIA["media-creator agents ×2"]
            direction LR
            MA["🖼️ Icons\nLucide · Heroicons · Tabler"]
            MB["📷 Photos\nUnsplash · Pexels"]
        end

        DS_API["figma-rest-api\nLoad Fluent 2 Design System\nComponent keys + Style keys"]

        subgraph BUILD["design-structure agents ×N"]
            direction LR
            B1["Page 1"]
            B2["Page 2"]
            BN["Page N"]
        end

        MEDIA --> BUILD
        DS_API --> BUILD
    end

    %% ── figma-bridge ──
    BRIDGE["figma-bridge\nChunked browser_evaluate\n≤5 elements per chunk\n→ Figma Plugin API"]

    %% ── Finalize ──
    subgraph FINAL["Phase 6 · Verify & Annotate"]
        direction LR
        VER["__figb.verify()\nScreenshot review"]
        A11Y["a11y-annotations\n♿ Accessibility page\nFocus order · Landmarks\nHeadings · ARIA · Alt text"]
    end

    %% ── Output ──
    subgraph OUTPUT["🎨 Figma Output"]
        direction LR
        O1["🎨 Design Language"]
        O2["📄 Content Pages"]
        O3["♿ Accessibility"]
    end

    %% ── Optional ──
    subgraph POST["Optional Post-Processing"]
        direction LR
        T1["design-tokens\nCSS · Tailwind · Style Dictionary"]
        T2["design-to-code\nReact · HTML output"]
        T3["design-system\nConsistency audit"]
    end

    %% ── Connections ──
    USER --> CMD
    SPECKIT --> SPEC
    SPEC --> DESIGN
    DESIGN --> GATE
    BLOCK -- "Yes → fix spec" --> SPEC
    BLOCK -- No --> PARALLEL
    BUILD --> BRIDGE
    BRIDGE --> FINAL
    VER --> OUTPUT
    A11Y --> OUTPUT
    OUTPUT -.-> POST

    %% ── Styling ──
    classDef cmd fill:#4F46E5,color:#fff,stroke:#3730A3
    classDef gate fill:#F59E0B,color:#000,stroke:#D97706
    classDef agent fill:#10B981,color:#fff,stroke:#059669
    classDef output fill:#8B5CF6,color:#fff,stroke:#7C3AED
    classDef post fill:#6B7280,color:#fff,stroke:#4B5563

    class SPECKIT,DESIGN cmd
    class G1,G2,G3 gate
    class MA,MB,B1,B2,BN,DS_API agent
    class O1,O2,O3 output
    class T1,T2,T3 post
```

---

### Legend

| Color | Meaning |
|-------|---------|
| 🟣 Indigo | Commands (`/speckit`, `/design`) |
| 🟡 Amber | Planning & quality gate skills |
| 🟢 Green | Parallel agents & API skills |
| 🟣 Purple | Figma output pages |
| ⚫ Gray | Optional post-processing |

### Skills (9)

| Skill | Role |
|-------|------|
| `figma-bridge` | Build in Figma via browser — chunked Plugin API calls |
| `figma-rest-api` | Read Fluent 2 Design System — component & style keys |
| `design-tokens` | Extract CSS / Tailwind / Style Dictionary tokens |
| `design-to-code` | Generate React or HTML from Figma designs |
| `design-system` | Audit design consistency across pages |
| `icon-library` | Fetch SVGs from Lucide, Heroicons, Tabler |
| `a11y-annotations` | Pre-check a11y + build annotation overlay page |
| `intent-to-component` | Map spec intents → Fluent 2 component selection |
| `spec-completeness` | Validate component props — BLOCKING / WARNING / INFO |

### Agents (2)

| Agent | Spawned By | Parallelism |
|-------|-----------|-------------|
| `media-creator` | `/design` Phase 3 | 2+ instances (icons, photos) |
| `design-structure` | `/design` Phase 5 | 1 per page (N instances) |

### MCP Server

| Server | Purpose |
|--------|---------|
| `design-playwright` | Browser automation — `npx @playwright/mcp` — drives Figma Plugin API |

---

*figma-plugin v2.2.1 · 9 skills · 2 agents · 2 commands · 1 MCP server*
