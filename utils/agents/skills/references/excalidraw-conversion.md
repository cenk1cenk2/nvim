# Excalidraw Format Conversion

Converting between the MCP server's simplified element format and the standard Excalidraw JSON used in Obsidian `.excalidraw.md` files.

## MCP → Obsidian (after visual preview, before writing to vault)

### Step 1: Strip Pseudo-Elements

Remove all elements with these types — they exist only in the MCP preview:

- `cameraUpdate` — viewport animation control.
- `delete` — element removal during preview iteration.
- `restoreCheckpoint` — checkpoint restore marker.

### Step 2: Expand `label` to Bound Text Elements

The MCP format uses `label: { text, fontSize }` on shapes. The Obsidian format requires separate text elements linked via `containerId` / `boundElements`.

**MCP input:**

```json
{
  "type": "rectangle",
  "id": "b1",
  "x": 100, "y": 100,
  "width": 200, "height": 100,
  "backgroundColor": "#051b2e",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "label": { "text": "API Server", "fontSize": 20 }
}
```

**Obsidian output** (two elements):

```json
{
  "type": "rectangle",
  "id": "rctApi3d",
  "x": 100, "y": 100,
  "width": 200, "height": 100,
  "strokeColor": "#61afef",
  "backgroundColor": "#051b2e",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 481273645,
  "boundElements": [{ "id": "txtApi3d", "type": "text" }]
}
```

```json
{
  "type": "text",
  "id": "txtApi3d",
  "x": 150, "y": 130,
  "width": 100, "height": 25,
  "text": "API Server",
  "fontSize": 20,
  "fontFamily": 5,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#abb2bf",
  "containerId": "rctApi3d",
  "seed": 739182465
}
```

**Conversion rules:**

- Generate a new 8-char ID for the text element.
- Add `boundElements: [{ id: "<textId>", type: "text" }]` to the shape.
- Set `containerId: "<shapeId>"` on the text element.
- Set `textAlign: "center"`, `verticalAlign: "middle"` on the text element.
- Set `fontFamily: 5` (Excalidraw default) unless specified otherwise.
- Approximate `x`/`y` — the plugin auto-adjusts text position within the container.
- Set `strokeColor` for text based on theme: `#abb2bf` (dark mode) or `#121212` (light mode).

### Step 3: Expand Arrow Labels

Same pattern as shape labels. If an arrow has `label: { text }`:

- Create a separate text element with `containerId` pointing to the arrow.
- Add `boundElements: [{ id: "<textId>", type: "text" }]` to the arrow.

### Step 4: Normalize IDs

MCP preview IDs can be any length. Obsidian requires exactly 8 characters (`[0-9a-zA-Z]{8}`).

- If an MCP ID is already 8 chars and alphanumeric, keep it.
- Otherwise, generate a new 8-char ID and update all references (`id`, `containerId`, `boundElements[].id`, `startBinding.elementId`, `endBinding.elementId`).

### Step 5: Add `seed` Values

Each element in the Obsidian file needs a unique `seed` (random integer 1–999999999) for hand-drawn rendering variation. The MCP format doesn't require seeds.

### Step 6: Add Missing Default Fields

The Obsidian plugin fills defaults, but explicitly setting these improves reliability:

- `strokeColor` — `"#abb2bf"` (dark) or `"#1e1e1e"` (light) if not set.
- `strokeWidth` — `2` if not set.
- `fontFamily` — `5` on text elements if not set.

### Step 7: Assemble the File

Follow the `excalidraw-template` reference for the complete `.excalidraw.md` structure:

1. Extract all text elements → build `## Text Elements` section.
2. Tab-indent the full JSON (`JSON.stringify(scene, null, "\t")`).
3. Wrap in frontmatter + warning + `# Excalidraw Data` + sections + `## Drawing`.

---

## Obsidian → MCP (reading existing drawings for preview)

### Step 1: Parse the `.excalidraw.md` File

Extract the JSON from the `## Drawing` section:

- Look for `` ```json `` or `` ```compressed-json `` code block after `## Drawing`.
- If compressed, the data is LZ-string encoded — **cannot decompress from the agent**. Fall back to reading the `## Text Elements` section for content understanding.
- If decompressed (`json`), parse the JSON directly.

### Step 2: Collapse Bound Text to `label`

Reverse of expansion. For each text element with a `containerId`:

- Find the parent shape by matching `containerId` to a shape's `id`.
- Add `label: { text: "<text>", fontSize: <fontSize> }` to the parent shape.
- Remove the text element from the array.
- Remove the `boundElements` entry from the parent shape.

### Step 3: Strip File-Only Fields

Remove fields that the MCP format doesn't use:

- `seed`, `version`, `versionNonce`.
- `isDeleted`, `updated`, `link`, `locked`.
- `groupIds` (unless actually grouped).
- `frameId`.

### Step 4: Add Camera

Insert a `cameraUpdate` as the first element to frame the diagram:

```json
{ "type": "cameraUpdate", "width": 800, "height": 600, "x": <minX - padding>, "y": <minY - padding> }
```

Calculate bounds from all element positions, add 50-80px padding, and choose the nearest 4:3 camera size.

### Step 5: Render

Call `excalidraw__create_view` with the converted elements array.

---

## Quick Reference Table

| Feature | MCP Format | Obsidian Format |
|---------|-----------|-----------------|
| Labels on shapes | `label: { text, fontSize }` | Separate text element + `containerId` / `boundElements`. |
| Labels on arrows | `label: { text }` | Separate text element + `containerId` / `boundElements`. |
| Camera viewport | `cameraUpdate` pseudo-element | Not applicable — strip. |
| Element deletion | `delete` pseudo-element | Not applicable — strip. |
| Checkpoint restore | `restoreCheckpoint` | Not applicable — strip. |
| Element IDs | Any length string | Exactly 8 chars (`[0-9a-zA-Z]{8}`). |
| Random seed | Not needed | Required — unique int per element. |
| JSON formatting | Compact (single line) | Tab-indented. |
| Text `strokeColor` | Often omitted (defaults to dark) | Explicit: `#abb2bf` (dark) or `#121212` (light). |
| Arrow bindings | `startBinding` / `endBinding` with `fixedPoint` | Same — carries over directly. |
| `strokeStyle` | `"dashed"` supported | Same — carries over directly. |

---

## Handling Compressed Files

Some existing `.excalidraw.md` files use `compressed-json` (LZ-string compression). The agent cannot decompress or compress this format.

**Reading compressed files:**

- The `## Text Elements` section is always in plain text — use it to understand diagram content.
- For full element access, ask the user to run the Obsidian command: `Decompress current Excalidraw file` — this converts `compressed-json` to `json` in place.

**Writing files:**

- Always write with `json` code block (decompressed). The plugin handles both formats.
- The user can compress later via the command palette if desired.
