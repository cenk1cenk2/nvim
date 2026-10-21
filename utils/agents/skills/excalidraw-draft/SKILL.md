---
name: excalidraw-draft
description: excalidraw-draft Draft a hand-drawn Excalidraw diagram and export it to the vault. Use on "draw a diagram", "sketch this", "make an architecture diagram". Not for revising a drawing that already exists.
disableModelInvocation: true
argumentHint: '[what to draw]'
references:
  - ../references/excalidraw/excalidraw-mcp-preview.md
  - ../references/excalidraw/excalidraw-elements.md
  - ../references/excalidraw/excalidraw-template.md
  - ../references/obsidian.md
---

## Excalidraw Diagram Drafting

## Context

You draft Excalidraw diagrams using a two-phase workflow:

1. **Draft visually** using the Excalidraw MCP server — live interactive preview in chat. Iterate until the user is happy.
2. **Export** — to the Obsidian vault as `.excalidraw.md`: strip pseudo-elements, wrap per `excalidraw-template`, write it.

**Tool selection for vault:** per `obsidian` — use embedded `obsidian` MCP tools with vault-relative paths. Filesystem is fallback only.

## Process

1. **Understand the request.** Determine what to visualize — architecture, flow, sequence, concept map, or freeform. Ask if unclear.
2. **Load the MCP element format.** Call `excalidraw__read_me` once.
3. **Plan the layout.** List nodes and connections, estimate diagram size, choose colors from the light palette per `excalidraw-elements`.
4. **Draft with MCP preview — mandatory, never skipped.** Follow the `excalidraw-mcp-preview` workflow:
   - Call `excalidraw__create_view` with file-format elements per `excalidraw-elements` — 8-char IDs, bound text via `containerId` / `boundElements` — plus `cameraUpdate` for viewport.
   - Draw progressively: zones first, then shapes with their bound text, then arrows.
5. **Iterate.** Based on user feedback, refine using checkpoints. Call `excalidraw__create_view` again. Repeat until satisfied.
6. **Export.** Once the user is satisfied, strip pseudo-elements, wrap the same elements per `excalidraw-template`, and write to the vault.

## Conventions

- **Author light.** `viewBackgroundColor: #ffffff`, `#1e1e1e` text, light fills, colours from the light palette per `excalidraw-elements`.
- **Font sizes.** Titles: 28+. Labels: 20. Annotations: 16. Never below 14.
- **Spacing.** 30–50px gaps. 80–100px margin around edges.
- **IDs.** Exactly 8 chars alphanumeric (`[0-9a-zA-Z]{8}`). Descriptive prefix + random suffix: `rctApi3d`, `txtAp4Wq`, `arwAD8Pn`, `zonBk2Lm`.

## Obsidian Plugin Rendering (CRITICAL)

Two known discrepancies between the Obsidian Excalidraw plugin and excalidraw.com, which the preview follows:

**1. Theme inversion.** The Obsidian plugin overrides `appState.theme` to match the dark vault, and Excalidraw's dark mode inverts the canvas colours. Author light on `#ffffff`; the vault shows it dark. A dark-authored scene is inverted to light. The white-canvas MCP preview matches what is authored.

**2. Bound text wrapping.** The Obsidian plugin wraps bound text more aggressively than excalidraw.com. Text that fits on one line on excalidraw.com may wrap to multiple lines in Obsidian, breaking small labels. **Always size containers for the Obsidian plugin** (the stricter renderer): `min_width = text.length × fontSize × 0.6 + fontSize`. Full sizing table: `excalidraw-elements`. If a container is too small for its label, use standalone text overlapping the shape instead of bound text.

## Composing with Obsidian Skills

- **With `obsidian-note`**: embed via `![[Drawings/filename.excalidraw.md]]`.
- **With `obsidian-repository`**: link architecture diagrams from repository knowledge notes.
