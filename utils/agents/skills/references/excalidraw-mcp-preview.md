# Excalidraw MCP Visual Preview

## Absolute Rule

> **ALWAYS use the Excalidraw MCP server for visual feedback. This is non-negotiable.**
>
> Never write to Obsidian without previewing first. Never skip the preview to "save time." The user MUST see the diagram rendered live before anything touches the vault.

## Tools

- **`excalidraw__read_me`** — call once per conversation to load the MCP element format (color palettes, element types, camera controls, examples). Do NOT call again after the first time.
- **`excalidraw__create_view`** — call to render diagrams. Returns an interactive preview and a `checkpointId` for iterating.

## MCP Element Format

The MCP server uses a simplified element format with conveniences that do NOT exist in the Excalidraw file format:

| MCP Convenience | What It Does |
|-----------------|-------------|
| `label: { text, fontSize }` on shapes | Auto-centered text inside the shape. No separate text element needed. |
| `cameraUpdate` pseudo-element | Controls viewport — animates smoothly between positions. Use generously. |
| `delete` pseudo-element | Removes elements by id. For iterating within a single `create_view` call. |
| `restoreCheckpoint` | Restores a previous diagram state by checkpoint id. Append new elements on top. |

These are stripped during conversion to Obsidian format.

## Camera Usage (CRITICAL for quality)

`cameraUpdate` is the biggest quality differentiator. Use it at every stage:

- **Start every `create_view` call** with a `cameraUpdate` as the FIRST element.
- **Zoom into sections** as you draw them, then zoom out for the full picture.
- **Camera sizes** (4:3 ratio ONLY): S=400×300, M=600×450, L=800×600 (default), XL=1200×900, XXL=1600×1200.
- **Font size adjusts with camera**: at XL minimum 18, at XXL minimum 21.

## Preview Workflow

1. **Call `excalidraw__read_me`** once to load the format reference.
2. **Call `excalidraw__create_view`** with elements in MCP format. Use `label`, `cameraUpdate`, arrow bindings.
3. **Show the user** the rendered preview. Discuss what to change.
4. **Iterate** using checkpoints:
   - Start with `{"type":"restoreCheckpoint","id":"<checkpointId>"}`.
   - Use `{"type":"delete","ids":"..."}` to remove elements.
   - Append new/replacement elements.
   - Call `excalidraw__create_view` again.
5. **Repeat** until the user is satisfied.
6. **Only then** convert to Obsidian format and write to vault.

## MCP → Obsidian Conversion

When converting from MCP preview to Obsidian `.excalidraw.md`:

| MCP Format | Obsidian Format |
|------------|-----------------|
| `label: { text, fontSize }` on shape | Separate text element with `containerId`, shape gets `boundElements`. |
| `cameraUpdate` pseudo-element | Strip — not part of the file format. |
| `delete` pseudo-element | Strip — not part of the file format. |
| `restoreCheckpoint` | Strip — not part of the file format. |
| Minimal fields | Add `seed` (random int 1–999999999) per element. |
| Arrow `startBinding`/`endBinding` | Carries over directly. |
| Text `strokeColor` | Adjust for dark mode if needed (`#abb2bf` on dark). |

## Progressive Drawing Order

When building diagrams in MCP format, emit elements progressively for the best streaming experience:

- **Good**: zone → shape1 → its label → its arrows → shape2 → its label → its arrows
- **Bad**: all shapes → all labels → all arrows

This matters because elements stream in one by one with draw-on animations.
