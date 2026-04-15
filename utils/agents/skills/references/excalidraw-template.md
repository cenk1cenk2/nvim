# Excalidraw Obsidian File Template

## appState Defaults

### Dark Mode (default)

```json
{
  "theme": "dark",
  "viewBackgroundColor": "#1e2127",
  "currentItemStrokeColor": "#abb2bf",
  "currentItemBackgroundColor": "transparent",
  "currentItemFillStyle": "solid",
  "currentItemStrokeWidth": 2,
  "currentItemStrokeStyle": "solid",
  "currentItemRoughness": 1,
  "currentItemOpacity": 100,
  "currentItemFontFamily": 5,
  "currentItemFontSize": 20,
  "currentItemTextAlign": "left",
  "currentItemStartArrowhead": null,
  "currentItemEndArrowhead": "arrow",
  "gridSize": null,
  "gridColor": { "Bold": "#C9C9C9FF", "Regular": "#EDEDEDFF" },
  "frameRendering": { "enabled": true, "clip": true, "name": true, "outline": true },
  "objectsSnapModeEnabled": false
}
```

### Light Mode

Override these fields:

```json
{
  "theme": "light",
  "viewBackgroundColor": "#ffffff",
  "currentItemStrokeColor": "#121212"
}
```

---

## `.excalidraw.md` File Structure

```
---

excalidraw-plugin: parsed
tags: [excalidraw]

---
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠== You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'


# Excalidraw Data

## Text Elements
{text} ^{id}

%%
## Drawing
```json
{"type":"excalidraw","version":2,"source":"https://github.com/zsviczian/obsidian-excalidraw-plugin","elements":[...],"appState":{...},"files":{}}
```
%%
```

---

## Assembling the File

### Frontmatter

Always use exactly:

```yaml
---

excalidraw-plugin: parsed
tags: [excalidraw]

---
```

Note the blank lines inside the frontmatter — this matches the existing vault pattern.

### Warning Message

Copy verbatim (single line):

```
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠== You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'
```

### Text Elements Section

Extract every text element from the elements array and list them. Each entry is the `text` field value followed by ` ^{id}`, separated by blank lines:

```
First label text ^txt1

Second label text ^txt2

Title text ^txt_title
```

This makes text content searchable in Obsidian even though the drawing data is in JSON.

### Drawing Section

Wrapped in `%%` (Obsidian comment markers — hides raw data in reading view). Use a `json` code block (decompressed format — the plugin handles both compressed and decompressed).

The JSON object fields:
- `"type": "excalidraw"` — fixed.
- `"version": 2` — fixed.
- `"source": "https://github.com/zsviczian/obsidian-excalidraw-plugin"` — fixed.
- `"elements": [...]` — the elements array.
- `"appState": {...}` — use dark mode defaults above.
- `"files": {}` — empty (no embedded images).

---

## Naming Convention

Files go in `Drawings/` in the vault (`~/notes/Drawings/`).

- **Default**: timestamp format `YYYY-MM-DDTHH.MM.SS.excalidraw.md` (e.g., `2026-04-15T15.48.03.excalidraw.md`).
- **Descriptive**: user-provided name as `name.excalidraw.md` (e.g., `mcp-architecture.excalidraw.md`).

---

## Embedding in Other Notes

To embed a drawing in another Obsidian note:

```markdown
![[Drawings/filename.excalidraw.md]]
```

This renders the drawing inline in the note.
