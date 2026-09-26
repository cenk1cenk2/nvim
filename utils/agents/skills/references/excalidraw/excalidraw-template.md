# Excalidraw Obsidian File Template

> Verified against `zsviczian/obsidian-excalidraw-plugin` source code (`src/shared/ExcalidrawData.ts`, `src/constants/constants.ts`).

## appState Defaults

Author light per `excalidraw-elements` — the plugin inverts the canvas when it matches the vault's dark theme.

```json
{
	"theme": "dark",
	"viewBackgroundColor": "#ffffff",
	"currentItemStrokeColor": "#1e1e1e",
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
	"gridSize": null
}
```

`theme` is overridden by the plugin on open; `viewBackgroundColor` and the element colours are what render.

---

## `.excalidraw.md` File Structure

The file has two halves: **header** (frontmatter + warning) and **data** (excalidraw sections + JSON).

```
---

excalidraw-plugin: parsed
tags: [excalidraw]

---
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠== You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'


# Excalidraw Data

## Text Elements
<text content> ^<8-char-id>

<text content> ^<8-char-id>

## Element Links
<8-char-id>: <link>

## Embedded Files
<fileId>: [[path/to/file]]

%%
## Drawing
```json
{
	"type": "excalidraw",
	"version": 2,
	"source": "https://github.com/zsviczian/obsidian-excalidraw-plugin",
	"elements": [...],
	"appState": {...},
	"files": {}
}
```
%%
```

---

## Section Details

### Frontmatter

Exactly as the plugin generates it (blank lines inside are intentional):

```yaml
---

excalidraw-plugin: parsed
tags: [excalidraw]

---
```

Valid values for `excalidraw-plugin`: `parsed` (default), `raw`, `locked`.

### Warning Message

Copy verbatim (single line, immediately after frontmatter):

```
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠== You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'
```

Two blank lines follow the warning before `# Excalidraw Data`.

### `## Text Elements`

Extract every text element from the elements array. Each entry is the raw text content followed by ` ^{id}` and a blank line:

```
Hello world ^aB3dEf9g

API Server ^xY7zWq2r

```

**Critical: IDs must be exactly 8 characters.** The plugin uses `nanoid` with alphabet `1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ` and length 8. If an ID is longer than 8 chars, the plugin will replace it. Generate 8-char alphanumeric IDs for all elements.

The parsing regex is `/\s\^(.{8})[\n]+/g` — one whitespace, literal `^`, then exactly 8 characters.

This section makes text searchable in Obsidian even when the drawing JSON is compressed.

### `## Element Links` (optional)

Only include if any non-text elements have hyperlinks. Format per entry:

```
<8-char-id>: <link-url-or-wikilink>

```

Example:

```
aB3dEf9g: https://example.com
xY7zWq2r: [[Some Note]]

```

Omit the entire section header if no element links exist.

### `## Embedded Files` (optional)

Only include if there are embedded images, equations, or file references. Three entry formats:

- **Vault files**: `<fileId>: [[path/to/file.png]]`
- **URLs**: `<fileId>: https://example.com/image.png`
- **LaTeX equations**: `<fileId>: $$E = mc^2$$`

Each entry followed by a blank line. Omit the entire section header if none exist.

### `## Drawing`

The `%%\n` before `## Drawing` opens an Obsidian comment that hides the JSON from reading view. The `%%` after the closing code fence closes it.

```
%%
## Drawing
```json
{
	"type": "excalidraw",
	"version": 2,
	"source": "https://github.com/zsviczian/obsidian-excalidraw-plugin",
	"elements": [...],
	"appState": {...},
	"files": {}
}
```
%%
```

**JSON formatting**: tab-indented (`JSON.stringify(scene, null, "\t")`).

**Code block language**: use `json` (decompressed). The plugin also accepts `compressed-json` but we cannot LZ-compress from the agent.

Both `## Drawing` and `# Drawing` are accepted by the parser.

### JSON Scene Structure

Top-level keys in order:

| Key | Type | Value |
|-----|------|-------|
| `type` | string | `"excalidraw"` (fixed). |
| `version` | integer | `2` (fixed). |
| `source` | string | `"https://github.com/zsviczian/obsidian-excalidraw-plugin"`. |
| `elements` | array | Excalidraw element objects. |
| `appState` | object | App state (see defaults above). |
| `files` | object | `{}` (empty — binary files are saved to vault separately). |

---

## Reading a Drawing

Parse the JSON in the `## Drawing` code block; its `elements` array is used as-is for preview and edits.

A `compressed-json` block (legacy drawings — the vault's `compress` setting is off, so saves are plain `json`) is LZ-string encoded and cannot be decoded in-context. Decompress it natively:

1. `obsidian__open_file` the drawing — the command acts on the **active** file, not a path.
2. `obsidian__command_execute` with `obsidian-excalidraw-plugin:excalidraw-unzip-file`. It rewrites the block to plain `json` in place and prompts for permission, since it mutates the vault.
3. `obsidian__vault_read` again and parse.

If the command is unavailable or declined, read the `## Text Elements` section — always plain text — for content, or ask the user to run the command.

---

## ID Convention

All element IDs throughout the file (elements, text entries, links) must be **exactly 8 characters**, alphanumeric (`[0-9a-zA-Z]`). Use the same ID in:
- The element's `"id"` field in the JSON.
- The `^id` suffix in `## Text Elements`.
- The `id:` prefix in `## Element Links`.
- Any `containerId`, `boundElements[].id`, `startBinding.elementId`, `endBinding.elementId` references.

---

## Naming Convention

Files go in `Drawings/` in the vault (`~/notes/Drawings/`).

- **Default**: timestamp format `YYYY-MM-DDTHH.MM.SS.excalidraw.md` (e.g., `2026-04-15T15.48.03.excalidraw.md`).
- **Descriptive**: user-provided name as `name.excalidraw.md` (e.g., `mcp-architecture.excalidraw.md`).

---

## Embedding in Other Notes

```markdown
![[Drawings/filename.excalidraw.md]]
```

Renders the drawing inline in the note.
