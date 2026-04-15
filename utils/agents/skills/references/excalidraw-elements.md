# Excalidraw Element Format Reference

## Color Palette (from onedarker)

### Primary Colors (strokes, accents, arrows — `[600]` variants)

| Name | Hex | Use |
|------|-----|-----|
| Blue | `#61afef` | Primary actions, links, data series 1. |
| Green | `#98c379` | Success, positive, data series 2. |
| Yellow | `#e5c07b` | Warnings, highlights, data series 3. |
| Red | `#e06c75` | Errors, negative, data series 4. |
| Purple | `#c678dd` | Accents, special items, data series 5. |
| Orange | `#d19a66` | Neutral, pending, data series 6. |
| Cyan | `#56b6c2` | Info, secondary, data series 7. |
| Magenta | `#a40778` | Decorative, data series 8. |

### Pastel Fills (shape backgrounds — `[900]` variants)

| Color | Hex | Good For |
|-------|-----|----------|
| Light Blue | `#98caf6` | Input, sources, primary nodes. |
| Light Green | `#98c379` | Success, output, completed (use with `opacity: 40`). |
| Light Yellow | `#eed5a8` | Notes, decisions, planning. |
| Light Red | `#ef9ea1` | Error, critical, alerts. |
| Light Purple | `#daa6ea` | Processing, middleware, special. |
| Light Orange | `#f1b862` | Warning, pending, external. |
| Light Cyan | `#94ced6` | Storage, data, memory. |
| Light Magenta | `#ca6da4` | Analytics, metrics. |

### Dark Fills (dark mode shape backgrounds — `[100]`/`[300]` variants)

| Color | Hex | Good For |
|-------|-----|----------|
| Dark Blue | `#051b2e` | Primary nodes. |
| Dark Green | `#16210f` | Success, output. |
| Dark Yellow | `#2c2009` | Notes, planning. |
| Dark Red | `#29090b` | Error, critical. |
| Dark Cyan | `#1a373a` | Storage, data. |
| Mid Blue | `#4676ac` | Active, focused nodes. |
| Mid Green | `#729c0c` | Positive, confirmed. |
| Mid Red | `#ce7277` | Warning, attention. |

### Background & Neutral

| Color | Hex | Use |
|-------|-----|-----|
| Background | `#1e2127` | Dark mode canvas (`bg[200]`). |
| Surface | `#22282f` | Dark zone backgrounds (`bg[300]`). |
| Border | `#2c333d` | Subtle dividers (`bg[400]`). |
| Muted text | `#5c6370` | Secondary annotations (`bg[600]`). |
| Foreground | `#abb2bf` | Primary text on dark (`bg[900]`). |
| White | `#efefef` | Bright text on dark. |
| Black | `#121212` | Text on light backgrounds. |

### Zone Backgrounds (use with `opacity: 25–35`)

| Color | Hex | Good For |
|-------|-----|----------|
| Blue zone | `#98caf6` | UI / frontend layer. |
| Purple zone | `#daa6ea` | Logic / agent layer. |
| Green zone | `#98c379` | Data / tool layer. |
| Yellow zone | `#eed5a8` | Config / planning layer. |

### Text Contrast Rules

- **Dark mode (default)** — text on dark background: use `#abb2bf` (fg) or `#efefef` (white). Never darker than `#5c6370`.
- **Light mode** — text `strokeColor` on white: use `#121212` (black) or `#5c6370` (muted). Never lighter than `#7c8a9d`.
- On colored fills, use the `[300]` variant of the same hue for text: `#4676ac` on light blue, `#729c0c` on light green, etc.
- No emoji — Excalidraw's font does not render them.

---

## Element Types

Every element needs at minimum: `type`, `id` (unique string), `x`, `y`, `width`, `height`.

Include `seed` (random integer 1–999999999) for hand-drawn rendering variation. The plugin fills other defaults (`angle: 0`, `roughness: 1`, `opacity: 100`, `groupIds: []`, `isDeleted: false`, `locked: false`).

### Rectangle

```json
{
  "type": "rectangle",
  "id": "rect1",
  "x": 100, "y": 100,
  "width": 200, "height": 80,
  "strokeColor": "#61afef",
  "backgroundColor": "#051b2e",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 481273645,
  "boundElements": [{ "id": "rect1_label", "type": "text" }]
}
```

- `roundness: { "type": 3 }` for rounded corners.
- `boundElements` lists text elements bound to this shape.

### Ellipse

```json
{
  "type": "ellipse",
  "id": "ell1",
  "x": 100, "y": 100,
  "width": 150, "height": 150,
  "strokeColor": "#c678dd",
  "backgroundColor": "#daa6ea",
  "fillStyle": "solid",
  "seed": 927364182
}
```

### Diamond

```json
{
  "type": "diamond",
  "id": "dia1",
  "x": 100, "y": 100,
  "width": 150, "height": 150,
  "strokeColor": "#e5c07b",
  "seed": 183746592
}
```

### Text (standalone — titles, annotations only)

```json
{
  "type": "text",
  "id": "txt_title",
  "x": 200, "y": 50,
  "width": 250, "height": 35,
  "text": "Architecture Overview",
  "fontSize": 28,
  "fontFamily": 5,
  "textAlign": "center",
  "strokeColor": "#abb2bf",
  "seed": 374928163
}
```

- `fontFamily`: `1` = Virgil (hand-drawn), `2` = Helvetica, `3` = Cascadia (monospace), `5` = Excalidraw (default).
- Estimate dimensions: `width ≈ text.length × fontSize × 0.5`, `height ≈ fontSize × 1.4`.
- `x` is the LEFT edge. To center at `cx`: `x = cx - width / 2`.

### Bound Text (labels inside shapes)

Create a separate text element linked to the container via `containerId` / `boundElements`.

**Container shape:**

```json
{
  "type": "rectangle",
  "id": "box1",
  "x": 100, "y": 100,
  "width": 200, "height": 80,
  "strokeColor": "#98c379",
  "backgroundColor": "#16210f",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 582937461,
  "boundElements": [{ "id": "box1_label", "type": "text" }]
}
```

**Bound text element:**

```json
{
  "type": "text",
  "id": "box1_label",
  "x": 150, "y": 120,
  "width": 100, "height": 25,
  "text": "API Server",
  "fontSize": 20,
  "fontFamily": 5,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#abb2bf",
  "containerId": "box1",
  "seed": 193847562
}
```

- `textAlign: "center"` + `verticalAlign: "middle"` for centered labels.
- The plugin auto-adjusts text position within the container — `x`/`y` are approximate.
- Convention: name bound text IDs as `{containerId}_label`.

### Arrow

```json
{
  "type": "arrow",
  "id": "arr1",
  "x": 300, "y": 140,
  "width": 150, "height": 0,
  "points": [[0, 0], [150, 0]],
  "strokeColor": "#abb2bf",
  "endArrowhead": "arrow",
  "startBinding": { "elementId": "box1", "focus": 0, "gap": 5, "fixedPoint": [1, 0.5] },
  "endBinding": { "elementId": "box2", "focus": 0, "gap": 5, "fixedPoint": [0, 0.5] },
  "seed": 847293615
}
```

- `points`: `[dx, dy]` offsets from element `x`, `y`.
- `endArrowhead`: `null` | `"arrow"` | `"bar"` | `"dot"` | `"triangle"`.
- Binding `fixedPoint`: `[0.5, 0]` top, `[0.5, 1]` bottom, `[0, 0.5]` left, `[1, 0.5]` right.
- `focus`: `-1` to `1`, controls arrow aim offset. `0` = center.
- `gap`: pixel gap between arrow endpoint and shape border.

**Labeled arrow** — bind text the same way as shapes: add `boundElements` to the arrow, create a text element with `containerId` pointing to the arrow.

### Line

Same as arrow but `"type": "line"` and no arrowheads.

---

## Layout Conventions

- **Minimum shape size**: 140×70 for labeled shapes.
- **Gaps**: 30–50px between elements.
- **Padding**: 80–100px margin around the entire diagram.
- **Font sizes**: 28+ for titles, 20 for labels, 16 for annotations. Never below 14.
- **Z-order**: array order = z-order (first = back). Draw zones → shapes → arrows.
- **ID naming**: descriptive prefixes — `rect_`, `txt_`, `arr_`, `ell_`, `dia_`, `zone_`.
