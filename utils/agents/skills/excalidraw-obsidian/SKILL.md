---
name: excalidraw-obsidian
description: 'excalidraw-obsidian Open an existing Excalidraw drawing from the Obsidian vault to revise or explain it. Triggers: "update this drawing", "revise the diagram", "explain this excalidraw", or a referenced .excalidraw.md file. Do NOT use for creating new drawings (excalidraw-draft).'
disable-model-invocation: true
argument-hint: "[filename or description of drawing to pick up]"
references:
  - ../references/present-first.md
  - ../references/excalidraw-mcp-preview.md
  - ../references/excalidraw-conversion.md
  - ../references/excalidraw-elements.md
  - ../references/excalidraw-template.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Excalidraw Drawing — Revise or Understand

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `excalidraw-mcp-preview` reference FIRST — it contains the absolute rule on using the MCP server for visual feedback. This is non-negotiable.

> Read the `excalidraw-conversion` reference for the full MCP ↔ Obsidian conversion algorithm — critical for both directions (reading existing drawings into MCP and writing back to vault).

> Read the `excalidraw-elements` reference for the element format, color palette (onedarker), and layout conventions.

> Read the `excalidraw-template` reference for the `.excalidraw.md` file structure and appState defaults.

> Read the `obsidian` reference for vault location and tool selection rules.

> Read the `output-diff` reference for presenting changes before writing.

## Context

You pick up an existing `.excalidraw.md` drawing from the Obsidian vault and either:

- **Revise** — modify elements, add/remove nodes, change layout or colors, then write back.
- **Understand** — analyze the diagram structure and explain what it shows.

In both modes, the Excalidraw MCP server is your visual feedback tool. Render the drawing in chat so the user can see what they're working with.

**Tool selection for vault:** Follow the `obsidian` reference — use embedded `obsidian` MCP tools with vault-relative paths. Filesystem is fallback only.

## Process

### Finding the Drawing

1. **Identify the drawing.** If the user provides a filename, use it. Otherwise:
   - List drawings with `obsidian__vault_list` on the `Drawings/` directory.
   - If the user describes the drawing by content, search with `obsidian__search_simple` or `obsidian__search_query`.
   - Present matches and let the user choose.

2. **Read the drawing.** Load the `.excalidraw.md` file from the vault:
   - Parse the `## Drawing` section — extract the JSON from the code block.
   - If that block is `compressed-json` (legacy files — the vault's `compress` setting is off, so new saves are plain `json`), decompress it natively first: `open_file` the drawing, then `command_execute` `obsidian-excalidraw-plugin:excalidraw-unzip-file`, then re-read. See the `excalidraw-conversion` reference.
   - Parse the `## Text Elements` section — note existing text content and IDs.
   - Identify the appState (dark/light mode, background color).

### Rendering in MCP Preview

3. **Load MCP format.** Call `excalidraw__read_me` once if not already loaded this conversation.

4. **Convert to MCP format and render.** Transform the standard Excalidraw elements into MCP preview format:
   - Bound text elements (`containerId`) → `label` on their parent shape.
   - Add a `cameraUpdate` as the first element, sized to fit the diagram.
   - Strip `seed`, `version`, `versionNonce` and other file-only fields.
   - Call `excalidraw__create_view` to render the preview.

5. **Show the user.** The preview lets the user see the current state of their drawing in chat.

### Understand Mode

If the user wants to understand the drawing:

6. **Analyze the structure.** From the parsed elements, identify:
   - All labeled nodes (shapes with bound text).
   - Connections between nodes (arrows with bindings).
   - Zones or groupings (background rectangles with low opacity).
   - Color coding patterns.
   - Layout structure (flow direction, hierarchy, clusters).

7. **Explain in chat.** Present a structured summary:
   - What the diagram represents.
   - Key nodes and their relationships.
   - Data flow or process flow direction.
   - Any patterns or groupings.

### Revise Mode

If the user wants to revise the drawing:

6. **Understand the change.** What does the user want to modify? Ask if unclear:
   - Add/remove nodes or connections.
   - Change labels, colors, or layout.
   - Restructure the diagram.

7. **Draft changes with MCP preview.** Use the checkpoint from step 4:
   - `restoreCheckpoint` to start from the current state.
   - `delete` elements being replaced.
   - Add new/modified elements.
   - Call `excalidraw__create_view` to render the updated preview.

8. **Iterate.** Based on user feedback, continue refining with checkpoints. Repeat until satisfied.

9. **Export to Obsidian.** Once approved, follow the `excalidraw-mcp-preview` conversion table:
   - Convert MCP elements back to standard Excalidraw JSON.
   - Expand `label` to bound text elements, strip pseudo-elements, add `seed` values.
   - Preserve the original appState (dark/light mode) unless the user changed it.
   - Rebuild the `.excalidraw.md` file: frontmatter, text elements section, drawing section.
   - Present changes with the `output-diff` convention.
   - Overwrite the original file (or write to a new file if the user prefers).

## Conventions

- **MCP preview is mandatory.** Always render the drawing before and after changes. The user must see both states.
- **Preserve existing style.** When revising, match the drawing's existing color scheme, font sizes, and layout patterns unless the user asks to change them.
- **Dark mode by default** for new elements. But respect the existing drawing's theme.
- **Colors from onedarker.** See the `excalidraw-elements` reference.
- **Overwrite carefully.** Always present changes and get approval before overwriting the vault file.

## Composing with Obsidian Skills

- **With `obsidian-note`**: when understanding a drawing, the explanation can be added to a note that embeds the drawing. Embedding is native — write `![[<drawing>.excalidraw]]` transclusion into any note and the plugin renders it (this vault: `embedType`/`previewImageType` = SVG, `renderImageInMarkdownReadingMode` on, plus an auto-exported `.svg` sidecar from `autoexportSVG`). No format conversion needed for display; conversion is only for editing the scene JSON.
- **With `obsidian-repository`**: revising architecture diagrams that are linked from repository notes.
- **With `excalidraw-draft`**: if the user wants a completely new drawing instead of revising, delegate to `excalidraw-draft`.
