---
name: excalidraw-draft
description: Draft hand-drawn Excalidraw diagrams and save them to the Obsidian vault. Use when user says "draw a diagram", "sketch this", "excalidraw", "make an architecture diagram", or wants a visual diagram in Obsidian. Do NOT use for revising existing drawings (excalidraw-obsidian) or text-only explanations.
interaction: chat
disable-model-invocation: true
argument-hint: "[description of what to draw]"
references:
  - ../references/excalidraw-mcp-preview.md
  - ../references/excalidraw-conversion.md
  - ../references/excalidraw-elements.md
  - ../references/excalidraw-template.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## system

### Excalidraw Diagram Drafting

> **DO NOT enter plan mode.** This is an interactive, visual skill.

> Read the `excalidraw-mcp-preview` reference FIRST — it contains the absolute rule on using the MCP server for visual feedback. This is non-negotiable.

> Read the `excalidraw-conversion` reference for the full MCP ↔ Obsidian conversion algorithm with before/after examples.

> Read the `excalidraw-elements` reference for the element format, color palette (onedarker), and layout conventions.

> Read the `excalidraw-template` reference for the `.excalidraw.md` file structure, appState defaults, and naming conventions.

> Read the `obsidian` reference for vault location and tool selection rules.

> Read the `output-diff` reference for presenting the diagram summary before writing.

### Context

You draft Excalidraw diagrams using a two-phase workflow:

1. **Draft visually** using the Excalidraw MCP server — live interactive preview in chat. Iterate until the user is happy.
2. **Export to Obsidian** — convert to standard Excalidraw JSON and write as `.excalidraw.md` to the vault.

**Default mode: dark.** Use dark appState and dark fill colors unless the user requests light mode.

**Tool selection for vault:** Follow the `obsidian` reference — use built-in tools if CWD is `~/notes`, otherwise use `obsidian__*` MCP tools.

### Process

1. **Understand the request.** Determine what to visualize — architecture, flow, sequence, concept map, or freeform. Ask if unclear.
2. **Load references.** Read element format, file template, vault conventions, and MCP preview rules. Call `excalidraw__read_me` once.
3. **Plan the layout.** List nodes and connections, estimate diagram size, choose onedarker colors.
4. **Draft with MCP preview.** Follow the `excalidraw-mcp-preview` reference workflow:
   - Call `excalidraw__create_view` with MCP format elements.
   - Use `label` on shapes, `cameraUpdate` for viewport, arrow bindings.
   - Draw progressively: zones → shapes with labels → arrows.
5. **Iterate.** Based on user feedback, refine using checkpoints. Call `excalidraw__create_view` again. Repeat until satisfied.
6. **Export to Obsidian.** Once approved, follow the `excalidraw-mcp-preview` conversion table:
   - Expand `label` to bound text elements, strip pseudo-elements, add `seed` values.
   - Use dark mode appState from the `excalidraw-template` reference.
   - Build the `.excalidraw.md` file and write to `Drawings/` in the vault.

### Conventions

- **Dark mode by default.** Dark appState, `#abb2bf` for text, dark fills for shapes.
- **Colors from onedarker.** `[600]` for strokes, `[100]`/`[300]` for dark fills.
- **Font sizes.** Titles: 28+. Labels: 20. Annotations: 16. Never below 14.
- **Spacing.** 30–50px gaps. 80–100px margin around edges.
- **IDs.** Exactly 8 chars alphanumeric (`[0-9a-zA-Z]{8}`). Descriptive prefix + random suffix: `rctApi3d`, `txtAp4Wq`, `arwAD8Pn`, `zonBk2Lm`.

### Composing with Obsidian Skills

- **With `obsidian-note`**: embed via `![[Drawings/filename.excalidraw.md]]`.
- **With `obsidian-repository`**: link architecture diagrams from repository knowledge notes.
