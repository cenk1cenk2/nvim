---
name: excalidraw-draft
description: excalidraw-draft Draft a hand-drawn Excalidraw diagram and export it to the vault or a shareable URL. Use on "draw a diagram", "sketch this", "make an architecture diagram". Not for revising a drawing that already exists.
disableModelInvocation: true
argumentHint: '[what to draw]'
references:
  - ../references/present-first.md
  - ../references/excalidraw/excalidraw-mcp-preview.md
  - ../references/excalidraw/excalidraw-conversion.md
  - ../references/excalidraw/excalidraw-elements.md
  - ../references/excalidraw/excalidraw-template.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Excalidraw Diagram Drafting

Posture: `present-first`.
## Context

You draft Excalidraw diagrams using a two-phase workflow:

1. **Draft visually** using the Excalidraw MCP server — live interactive preview in chat. Iterate until the user is happy.
2. **Export** — either to the Obsidian vault (`.excalidraw.md`) or as a shareable excalidraw.com URL.

**Default mode: dark.** Use dark appState and dark fill colors unless the user requests light mode.

**Tool selection for vault:** per `obsidian` — use embedded `obsidian` MCP tools with vault-relative paths. Filesystem is fallback only.

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
2. **Load the MCP element format.** Call `excalidraw__read_me` once.
3. **Plan the layout.** List nodes and connections, estimate diagram size, choose onedarker colors per `excalidraw-elements`.
4. **Draft with MCP preview — mandatory, never skipped.** Follow the `excalidraw-mcp-preview` workflow:
   - Call `excalidraw__create_view` with MCP format elements.
   - Use `label` on shapes, `cameraUpdate` for viewport, arrow bindings.
   - Draw progressively: zones → shapes with labels → arrows.
5. **Iterate.** Based on user feedback, refine using checkpoints. Call `excalidraw__create_view` again. Repeat until satisfied.
6. **Export.** Present the diagram summary per `output-diff`, then once approved choose output mode per the decision rules above:
   - **Obsidian**: per `excalidraw-conversion` — expand `label` to bound text, strip pseudo-elements, add `seed` values, build the `.excalidraw.md` per `excalidraw-template`, write to vault.
   - **URL**: strip pseudo-elements (`cameraUpdate`, `delete`, `restoreCheckpoint`) from the elements array, build the scene JSON (`{type, version, source, elements, appState, files}`), call `excalidraw__export_to_excalidraw` with the serialized JSON. Return the URL to the user.
   - **If ambiguous**: ask the user before exporting.

## Conventions

- **Dark mode by default.** Dark appState, `#abb2bf` for text, dark fills for shapes.
- **Colors from onedarker** per `excalidraw-elements`. `[600]` for strokes, `[100]`/`[300]` for dark fills.
- **Font sizes.** Titles: 28+. Labels: 20. Annotations: 16. Never below 14.
- **Spacing.** 30–50px gaps. 80–100px margin around edges.
- **IDs.** Exactly 8 chars alphanumeric (`[0-9a-zA-Z]{8}`). Descriptive prefix + random suffix: `rctApi3d`, `txtAp4Wq`, `arwAD8Pn`, `zonBk2Lm`.

## Obsidian vs excalidraw.com Rendering (CRITICAL)

Two known discrepancies between the Obsidian Excalidraw plugin and excalidraw.com:

**1. Theme override.** The Obsidian plugin overrides `appState.theme` to match the vault theme. Always use dark mode (appState + colors) to match the user's dark-themed vault. The MCP preview uses a white canvas — design for the final dark output, not the preview.

**2. Bound text wrapping.** The Obsidian plugin wraps bound text more aggressively than excalidraw.com. Text that fits on one line on excalidraw.com may wrap to multiple lines in Obsidian, breaking small labels. **Always size containers for the Obsidian plugin** (the stricter renderer): `min_width = text.length × fontSize × 0.6 + fontSize`. Full sizing table: `excalidraw-elements`. If a container is too small for its label, use standalone text overlapping the shape instead of bound text.

## Composing with Obsidian Skills

When composed with Obsidian skills, **always use Obsidian output mode** — do not ask.

- **With `obsidian-note`**: embed via `![[Drawings/filename.excalidraw.md]]`.
- **With `obsidian-repository`**: link architecture diagrams from repository knowledge notes.

## Composing without Obsidian Skills

When invoked standalone (no obsidian skills co-invoked), the output mode depends on user intent. If the user explicitly requests a URL, link, or image export, use URL mode. Otherwise ask.
