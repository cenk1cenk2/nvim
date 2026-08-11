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

Every element needs at minimum: `type`, `id` (unique 8-char alphanumeric string), `x`, `y`, `width`, `height`.

**IDs must be exactly 8 characters** (`[0-9a-zA-Z]{8}`). The Obsidian plugin enforces this — longer IDs get replaced. Use the same 8-char IDs in element `id`, `containerId`, `boundElements[].id`, and binding `elementId` fields.

Include `seed` (random integer 1–999999999) for hand-drawn rendering variation. The plugin fills other defaults (`angle: 0`, `roughness: 1`, `opacity: 100`, `groupIds: []`, `isDeleted: false`, `locked: false`).

### Rectangle

```json
{
  "type": "rectangle",
  "id": "rct1Ab3d",
  "x": 100, "y": 100,
  "width": 200, "height": 80,
  "strokeColor": "#61afef",
  "backgroundColor": "#051b2e",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 481273645,
  "boundElements": [{ "id": "rct1Lb3d", "type": "text" }]
}
```

- `roundness: { "type": 3 }` for rounded corners.
- `boundElements` lists text elements bound to this shape.

### Ellipse

```json
{
  "type": "ellipse",
  "id": "elp1Xk9z",
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
  "id": "dmd1Wq7r",
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
  "id": "ttl1Mn4p",
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
- Estimate dimensions: `width ≈ text.length × fontSize × 0.6`, `height ≈ fontSize × 1.4`.
- `x` is the LEFT edge. To center at `cx`: `x = cx - width / 2`.

### Bound Text (labels inside shapes)

Create a separate text element linked to the container via `containerId` / `boundElements`.

**Container sizing for bound text (CRITICAL):**

The Obsidian Excalidraw plugin wraps bound text when it exceeds the container's inner width. Inner width = `container.width - fontSize` (padding is `fontSize / 2` per side). If text wraps, the label becomes multi-line and unreadable in small shapes.

**Minimum container width for single-line text:**

```
min_width = text.length × fontSize × 0.6 + fontSize
```

| fontSize | 5-char label | 6-char label | 7-char label |
|----------|-------------|-------------|-------------|
| 14 | 56px | 64px | 73px |
| 16 | 64px | 74px | 83px |
| 20 | 80px | 92px | 104px |

**If the container is too small for bound text**, use standalone text overlapping the shape instead — standalone text never wraps. Position the standalone text centered over the shape manually.

> **Discrepancy warning:** excalidraw.com uses narrower font metrics than the Obsidian plugin. Text that fits on one line on excalidraw.com WILL wrap in Obsidian. Always size containers for the Obsidian plugin (the stricter renderer).

> **Unicode characters** (`→`, `←`, `↔`, `━`) render significantly wider in the Obsidian plugin's Excalifont than in excalidraw.com. Each Unicode arrow occupies ~1.5-2x the width of an ASCII character. For labels containing Unicode, either increase the multiplier to `0.8` or use standalone text.

**Practical rule for small labels (under 80px container width):** Always use standalone text overlapping the shape. Bound text in small containers is fragile across renderers. Reserve bound text for large shapes (140px+ width) where wrapping is unlikely.

**Container shape:**

```json
{
  "type": "rectangle",
  "id": "box1Hj6t",
  "x": 100, "y": 100,
  "width": 200, "height": 80,
  "strokeColor": "#98c379",
  "backgroundColor": "#16210f",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 582937461,
  "boundElements": [{ "id": "bx1lHj6t", "type": "text" }]
}
```

**Bound text element:**

```json
{
  "type": "text",
  "id": "bx1lHj6t",
  "x": 150, "y": 120,
  "width": 100, "height": 25,
  "text": "API Server",
  "fontSize": 20,
  "fontFamily": 5,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#abb2bf",
  "containerId": "box1Hj6t",
  "seed": 193847562
}
```

- `textAlign: "center"` + `verticalAlign: "middle"` for centered labels.
- The plugin auto-adjusts text position within the container — `x`/`y` are approximate.
- Convention: use a related 8-char ID for bound text (e.g., container `box1Hj6t` → label `bx1lHj6t`).

### Arrow

```json
{
  "type": "arrow",
  "id": "arw1Pf8n",
  "x": 300, "y": 140,
  "width": 150, "height": 0,
  "points": [[0, 0], [150, 0]],
  "strokeColor": "#abb2bf",
  "endArrowhead": "arrow",
  "startBinding": { "elementId": "box1Hj6t", "focus": 0, "gap": 5, "fixedPoint": [1, 0.5] },
  "endBinding": { "elementId": "box2Ry5m", "focus": 0, "gap": 5, "fixedPoint": [0, 0.5] },
  "seed": 847293615
}
```

- `points`: `[dx, dy]` offsets from element `x`, `y`.
- `endArrowhead`: `null` | `"arrow"` | `"bar"` | `"dot"` | `"triangle"`.
- Binding `fixedPoint`: `[0.5, 0]` top, `[0.5, 1]` bottom, `[0, 0.5]` left, `[1, 0.5]` right.
- `focus`: `-1` to `1`, controls arrow aim offset. `0` = center.
- `gap`: pixel gap between arrow endpoint and shape border.

**Labeled arrow (PREFERRED for wires)** — bind text to the arrow the same way as shapes: add `boundElements` to the arrow, create a text element with `containerId` pointing to the arrow. The label auto-positions at the arrow's midpoint and moves with the arrow when rearranged. Unlike shape-bound text, arrow-bound text does NOT wrap — it renders as a single line at the midpoint, making it safe for any label length.

Use this for identifying what a wire/connection carries: wire color, signal name, pin numbers, data type. This is the preferred approach because labels stay attached to their wires.

**Fallback: standalone text near arrows.** Only use when you need a multi-line annotation or when the label applies to multiple arrows (e.g., a shared annotation for a group of wires). Standalone text does NOT move with the arrow.

### Line

Same as arrow but `"type": "line"` and no arrowheads.

---

## Layout Conventions

- **Minimum shape size**: 140×70 for labeled shapes.
- **Gaps**: 30–50px between elements.
- **Padding**: 80–100px margin around the entire diagram.
- **Font sizes**: 28+ for titles, 20 for labels, 16 for annotations. Never below 14.
- **Z-order**: array order = z-order (first = back). Draw zones → shapes → arrows.
- **ID naming**: 8-char alphanumeric. Use 3-4 char descriptive prefix + 4-5 char random suffix: `rctApSv3` (rectangle), `txtDb4Wq` (text), `arwXk9Pn` (arrow), `zonBe2Lm` (zone).

## Wire Routing Conventions

When drawing wiring diagrams or flow charts with many connecting lines:

- **No wire crossings unless intentional.** Wires MUST NOT cross each other or overlap with components they don't connect to. Wires can take longer routes to avoid crossings — clarity is more important than shortest path.
- **Use corridor-based routing.** Assign each wire a unique corridor (x-band for vertical segments, y-band for horizontal segments). Wires sharing the same corridor at different y/x levels don't cross. Plan corridors before drawing.
- **Route long wires along the diagram perimeter.** For wires connecting distant components (e.g., bottom-left to top-right), route along the edges: go down to the bottom, right along the bottom, up the right side, etc. This keeps the center clear.
- **Use multi-point arrow paths** with intermediate waypoints to create right-angle routing. Example: `points: [[0,0],[0,100],[300,100],[300,0]]` creates an L-shaped route.
- **Use different colors** for different wire types/functions — even if wires run close together, color distinguishes them.
- **Label wires with bound text on the arrow** (preferred). Bind a text element to each arrow via `containerId`/`boundElements` — the label auto-positions at the midpoint and moves with the wire. Include the wire's identity (color name, signal type, pin numbers). Arrow-bound text does NOT wrap, so it's safe regardless of label length.
- **Space components generously.** More space between components = easier wire routing with fewer crossings. Plan the layout with wire routing in mind before placing components.
- **Group related components** with zone rectangles (low-opacity background rects) — e.g., a push/pull pot grouped with its DPDT switch.
- **No element overlap unless intentional.** Text labels, shapes, and wires should not overlap with other elements they don't belong to. Intentional overlaps: labels inside their container, zone backgrounds behind grouped elements, lug annotations near their pot edge.
