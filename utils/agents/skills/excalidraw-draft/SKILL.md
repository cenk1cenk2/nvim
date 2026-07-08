---
name: excalidraw-draft
description: Draft hand-drawn Excalidraw diagrams and export to Obsidian vault or as shareable excalidraw.com URL. Use when user says "draw a diagram", "sketch this", "excalidraw", "make an architecture diagram", or wants a visual diagram. Do NOT use for revising existing drawings (excalidraw-obsidian) or text-only explanations.
disable-model-invocation: true
argument-hint: "[description of what to draw]"
references:
  - ../references/present-first.md
  - ../references/excalidraw-mcp-preview.md
  - ../references/excalidraw-conversion.md
  - ../references/excalidraw-elements.md
  - ../references/excalidraw-template.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Excalidraw Diagram Drafting

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `excalidraw-mcp-preview` reference FIRST — it contains the absolute rule on using the MCP server for visual feedback. This is non-negotiable.

> Read the `excalidraw-conversion` reference for the full MCP ↔ Obsidian conversion algorithm with before/after examples.

> Read the `excalidraw-elements` reference for the element format, color palette (onedarker), and layout conventions.

> Read the `excalidraw-template` reference for the `.excalidraw.md` file structure, appState defaults, and naming conventions.

> Read the `obsidian` reference for vault location and tool selection rules.

> Read the `output-diff` reference for presenting the diagram summary before writing.

## Context

You draft Excalidraw diagrams using a two-phase workflow:

1. **Draft visually** using the Excalidraw MCP server — live interactive preview in chat. Iterate until the user is happy.
2. **Export** — either to the Obsidian vault (`.excalidraw.md`) or as a shareable excalidraw.com URL.

**Default mode: dark.** Use dark appState and dark fill colors unless the user requests light mode.

**Tool selection for vault:** Follow the `obsidian` reference — use embedded `obsidian` MCP tools with vault-relative paths. Filesystem is fallback only.

## Output Modes

| Mode | Tool | When to Use |
|------|------|-------------|
| **Obsidian** | Convert MCP→Obsidian, write `.excalidraw.md` to vault. | Combined with obsidian skills, user says "save", "vault", "obsidian", "note". Default when obsidian skills are co-invoked. |
| **URL** | `excalidraw__export_to_excalidraw` — uploads to excalidraw.com. | User asks for "URL", "link", "share", "excalidraw.com", "SVG", "PNG". NOT combined with obsidian skills. |

**Decision rules:**

- Obsidian skills co-invoked → **Obsidian** mode (no question).
- User explicitly requests URL/link/share/SVG/PNG → **URL** mode (no question).
- Neither signal present → **ask**: "Where should I export — Obsidian vault or shareable excalidraw.com URL?"

**URL mode notes:**

- Returns a shareable excalidraw.com URL with the full diagram.
- From the URL, users can manually export to SVG/PNG via excalidraw.com UI (menu → Export image).
- No local file is created — the diagram lives on excalidraw.com.
- No MCP→Obsidian conversion needed — pass the scene JSON directly (strip pseudo-elements only).
- The tool is `excalidraw__export_to_excalidraw` — takes a `json` parameter with the serialized scene.

## Process

1. **Understand the request.** Determine what to visualize — architecture, flow, sequence, concept map, or freeform. Ask if unclear.
2. **Load references.** Read element format, file template, vault conventions, and MCP preview rules. Call `excalidraw__read_me` once.
3. **Plan the layout.** List nodes and connections, estimate diagram size, choose onedarker colors.
4. **Draft with MCP preview.** Follow the `excalidraw-mcp-preview` reference workflow:
   - Call `excalidraw__create_view` with MCP format elements.
   - Use `label` on shapes, `cameraUpdate` for viewport, arrow bindings.
   - Draw progressively: zones → shapes with labels → arrows.
5. **Iterate.** Based on user feedback, refine using checkpoints. Call `excalidraw__create_view` again. Repeat until satisfied.
6. **Export.** Once approved, choose output mode per the decision rules above:
   - **Obsidian**: follow the `excalidraw-conversion` reference — expand `label` to bound text, strip pseudo-elements, add `seed` values, build `.excalidraw.md`, write to vault.
   - **URL**: strip pseudo-elements (`cameraUpdate`, `delete`, `restoreCheckpoint`) from the elements array, build the scene JSON (`{type, version, source, elements, appState, files}`), call `excalidraw__export_to_excalidraw` with the serialized JSON. Return the URL to the user.
   - **If ambiguous**: ask the user before exporting.

## Conventions

- **Dark mode by default.** Dark appState, `#abb2bf` for text, dark fills for shapes.
- **Colors from onedarker.** `[600]` for strokes, `[100]`/`[300]` for dark fills.
- **Font sizes.** Titles: 28+. Labels: 20. Annotations: 16. Never below 14.
- **Spacing.** 30–50px gaps. 80–100px margin around edges.
- **IDs.** Exactly 8 chars alphanumeric (`[0-9a-zA-Z]{8}`). Descriptive prefix + random suffix: `rctApi3d`, `txtAp4Wq`, `arwAD8Pn`, `zonBk2Lm`.

## Obsidian vs excalidraw.com Rendering (CRITICAL)

Two known discrepancies between the Obsidian Excalidraw plugin and excalidraw.com:

**1. Theme override.** The Obsidian plugin overrides `appState.theme` to match the vault theme. Always use dark mode (appState + colors) to match the user's dark-themed vault. The MCP preview uses a white canvas — design for the final dark output, not the preview.

**2. Bound text wrapping.** The Obsidian plugin wraps bound text more aggressively than excalidraw.com. Text that fits on one line on excalidraw.com may wrap to multiple lines in Obsidian, breaking small labels. **Always size containers for the Obsidian plugin** (the stricter renderer): `min_width = text.length × fontSize × 0.6 + fontSize`. See the `excalidraw-elements` reference for the full sizing table. If a container is too small for its label, use standalone text overlapping the shape instead of bound text.

## Composing with Obsidian Skills

When composed with Obsidian skills, **always use Obsidian output mode** — do not ask.

- **With `obsidian-note`**: embed via `![[Drawings/filename.excalidraw.md]]`.
- **With `obsidian-repository`**: link architecture diagrams from repository knowledge notes.

## Composing without Obsidian Skills

When invoked standalone (no obsidian skills co-invoked), the output mode depends on user intent. If the user explicitly requests a URL, link, or image export, use URL mode. Otherwise ask.
