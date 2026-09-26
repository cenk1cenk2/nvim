# Excalidraw MCP Visual Preview

## Absolute Rule

> **ALWAYS use the Excalidraw MCP server for visual feedback. This is non-negotiable.**
>
> Never write to Obsidian without previewing first. Never skip the preview to "save time." The user MUST see the diagram rendered live before anything touches the vault.

## Tools

- **`excalidraw__read_me`** — call once per conversation to load the MCP element format (color palettes, element types, camera controls, examples). Do NOT call again after the first time.
- **`excalidraw__create_view`** — call to render diagrams. Returns an interactive preview and a `checkpointId` for iterating.
- **`excalidraw__export_to_excalidraw`** — uploads diagram JSON to excalidraw.com, returns a shareable URL. Use for URL output mode. Pass the complete scene JSON (elements + appState) with pseudo-elements stripped.

## One Element Format

`excalidraw__create_view` renders file-format elements directly. Author every element per `excalidraw-elements` — 8-char IDs, text bound to its shape or arrow through `containerId` / `boundElements` — and the same array is what gets written to the vault. Never use the `label` shorthand the MCP `read_me` offers: it exists only in the preview and has no place in the file.

The preview adds three pseudo-elements that are stripped before writing:

| Pseudo-element | What It Does |
|----------------|-------------|
| `cameraUpdate` | Controls viewport — animates smoothly between positions. Use generously. |
| `delete` | Removes elements by id. For iterating within a single `create_view` call. |
| `restoreCheckpoint` | Restores a previous diagram state by checkpoint id. Append new elements on top. |

## Camera Usage (CRITICAL for quality)

`cameraUpdate` is the biggest quality differentiator. Use it at every stage:

- **Start every `create_view` call** with a `cameraUpdate` as the FIRST element.
- **Zoom into sections** as you draw them, then zoom out for the full picture.
- **Camera sizes** (4:3 ratio ONLY): S=400×300, M=600×450, L=800×600 (default), XL=1200×900, XXL=1600×1200.
- **Font size adjusts with camera**: at XL minimum 18, at XXL minimum 21.

## Preview Workflow

1. **Call `excalidraw__read_me`** once to load the format reference.
2. **Call `excalidraw__create_view`** with file-format elements plus `cameraUpdate`.
3. **Show the user** the rendered preview. Discuss what to change.
4. **Iterate** using checkpoints:
   - Start with `{"type":"restoreCheckpoint","id":"<checkpointId>"}`.
   - Use `{"type":"delete","ids":"..."}` to remove elements.
   - Append new/replacement elements.
   - Call `excalidraw__create_view` again.
5. **Repeat** until the user is satisfied.
6. **Only then** export — either write to the vault, OR upload to excalidraw.com for a shareable URL. See the skill's Output Modes section for decision rules.

## Export Paths

### To Obsidian (`.excalidraw.md`)

Strip the pseudo-elements and wrap the array per `excalidraw-template`. The elements themselves do not change.

### To excalidraw.com URL

1. Strip pseudo-elements (`cameraUpdate`, `delete`, `restoreCheckpoint`) from the elements array.
2. Build the scene JSON: `{type: "excalidraw", version: 2, source: "...", elements: [...], appState: {...}, files: {}}`.
3. Call `excalidraw__export_to_excalidraw` with the serialized JSON string.
4. Returns a shareable URL. From the URL, users can export SVG/PNG via the excalidraw.com UI.

### From Obsidian

Read the elements per `excalidraw-template`, prepend a `cameraUpdate` framing their bounds (nearest 4:3 size, 50-80px padding), and render with `create_view`. The elements go in unchanged.

## Progressive Drawing Order

Emit elements progressively for the best streaming experience:

- **Good**: zone → shape1 → its bound text → its arrows → shape2 → its bound text → its arrows
- **Bad**: all shapes → all text → all arrows

This matters because elements stream in one by one with draw-on animations.
