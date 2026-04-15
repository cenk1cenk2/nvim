---
name: excalidraw-draft
description: Draft hand-drawn Excalidraw diagrams and save them to the Obsidian vault. Use when user says "draw a diagram", "sketch this", "excalidraw", "make an architecture diagram", or wants a visual diagram in Obsidian. Do NOT use for revising existing drawings (excalidraw-obsidian) or text-only explanations.
interaction: chat
disable-model-invocation: true
argument-hint: "[description of what to draw]"
references:
  - ../references/excalidraw-elements.md
  - ../references/excalidraw-template.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## system

### Excalidraw Diagram Drafting

> **DO NOT enter plan mode.** This is an interactive, visual skill.

> Read the `excalidraw-elements` reference for the element format, color palette (onedarker), and layout conventions.

> Read the `excalidraw-template` reference for the `.excalidraw.md` file structure, appState defaults, and naming conventions.

> Read the `obsidian` reference for vault location and tool selection rules.

> Read the `output-diff` reference for presenting the diagram summary before writing.

### Context

You generate Excalidraw diagrams in standard Excalidraw JSON and save them as `.excalidraw.md` files to the Obsidian vault. The Obsidian Excalidraw plugin renders these as interactive, editable drawings.

**Default mode: dark.** Use dark appState and dark fill colors from the palette unless the user requests light mode.

**Tool selection:** Follow the `obsidian` reference — use built-in tools if CWD is `~/notes`, otherwise use `obsidian__*` MCP tools.

### Process

1. **Understand the request.** Determine what to visualize — architecture, flow, sequence, concept map, or freeform. Ask if unclear.
2. **Read references.** Load the element format, file template, and vault conventions.
3. **Plan the layout.** Before generating elements:
   - List the nodes (shapes) and connections (arrows) needed.
   - Estimate total diagram size.
   - Choose colors from the onedarker palette.
4. **Generate elements.** Build the elements array in standard Excalidraw JSON:
   - **Shapes**: rectangle, ellipse, diamond with `boundElements` for labels.
   - **Bound text**: separate text elements with `containerId` linking back to shapes.
   - **Arrows**: with `startBinding`/`endBinding` connecting shapes.
   - **Standalone text**: for titles and annotations only.
   - Include random `seed` values (1–999999999) for each element.
   - Follow z-order: zones (back) → shapes → arrows (front).
5. **Build the `.excalidraw.md` file.** Follow the `excalidraw-template` reference:
   - Frontmatter, warning message, text elements section, drawing section.
   - Use dark mode appState defaults.
6. **Present to user.** Show a summary of what was drawn:
   - Element count (shapes, arrows, text).
   - List of labeled nodes.
   - Chosen color scheme.
   - Target filename and path.
   - Do NOT dump raw JSON in chat — it's unreadable.
7. **Write to vault.** After user approval, write the file to `Drawings/`.

### Conventions

- **Dark mode by default.** Use dark appState, `#abb2bf` for text, dark fill variants for shapes.
- **Colors from onedarker.** `[600]` variants for strokes, dark fills (`[100]`/`[300]`) for shape backgrounds.
- **Bound text, not shortcuts.** Labels on shapes must be separate text elements with `containerId`/`boundElements`. No `label` shortcut exists in the Excalidraw file format.
- **Font sizes.** Titles: 28+. Labels: 20. Annotations: 16. Never below 14.
- **Spacing.** 30–50px gaps between elements. 80–100px margin around diagram edges.
- **IDs.** Descriptive prefixes: `rect_api`, `txt_api_label`, `arr_api_to_db`, `zone_backend`.
- **Seeds.** Each element gets a unique random `seed` integer for rendering variation.
- **Decompressed format.** Use `json` code block (not `compressed-json`). The plugin handles both.

### Composing with Obsidian Skills

This skill outputs to the same vault as `obsidian-note`, `obsidian-repository`, and `obsidian-todo`. When composed:

- **With `obsidian-note`**: the note can embed the drawing via `![[Drawings/filename.excalidraw.md]]`.
- **With `obsidian-repository`**: architecture diagrams can be linked from repository knowledge notes.
