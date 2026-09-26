# Excalidraw Element Format Reference

## Author Light — the Plugin Inverts the Canvas

**Every drawing is authored on a white canvas with dark strokes: `viewBackgroundColor: "#ffffff"`, text `#1e1e1e`.** The vault's Obsidian theme is dark and the Excalidraw plugin matches it on every open (`matchTheme` / `matchThemeAlways`). Excalidraw's dark mode renders the canvas through a colour inversion, so a light scene displays as a dark one. A scene authored dark — dark background, light strokes — is inverted into a light-looking drawing.

`appState.theme` does not decide what the user sees; the plugin overrides it. The white-canvas preview in chat is exactly what gets authored.

## Color Palette (Excalidraw light palette)

### Strokes, text, arrows

| Name | Hex | Use |
|------|-----|-----|
| Black | `#1e1e1e` | Primary text, outlines. |
| Dark gray | `#495057` | Secondary strokes. |
| Gray | `#868e96` | Muted annotations, ground, not-connected. |
| Blue | `#1971c2` | Primary actions, data series 1. |
| Green | `#2f9e44` | Success, output, data series 2. |
| Orange | `#f08c00` | Warnings, highlights, data series 3. |
| Red | `#e03131` | Errors, negative, data series 4. |
| Grape | `#9c36b5` | Accents, special items, data series 5. |
| Cyan | `#0c8599` | Info, secondary, data series 6. |
| Pink | `#c2255c` | Decorative, data series 7. |

### Fills (shape backgrounds)

| Color | Hex | Good For |
|-------|-----|----------|
| White | `#ffffff` | Plain node bodies. |
| Light Blue | `#a5d8ff` | Input, sources, primary nodes. |
| Light Green | `#b2f2bb` | Success, output, completed. |
| Light Yellow | `#ffec99` | Notes, decisions, planning. |
| Light Red | `#ffc9c9` | Error, critical, alerts. |
| Light Violet | `#d0bfff` | Processing, middleware, special. |
| Light Grape | `#eebefa` | Analytics, metrics. |
| Light Cyan | `#99e9f2` | Storage, data, memory. |
| Light Gray | `#e9ecef` | Zones, grouping backgrounds (use `opacity: 30–50`). |

### Text Contrast Rules

- Text on the white canvas: `#1e1e1e`, or `#868e96` for muted annotations. Never lighter than `#868e96`.
- On a coloured fill, use the stroke colour of the same hue for text: `#1971c2` on light blue, `#2f9e44` on light green.
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
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
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
  "strokeColor": "#9c36b5",
  "backgroundColor": "#eebefa",
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
  "strokeColor": "#f08c00",
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
  "strokeColor": "#1e1e1e",
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
  "strokeColor": "#2f9e44",
  "backgroundColor": "#b2f2bb",
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
  "strokeColor": "#1e1e1e",
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
  "strokeColor": "#1e1e1e",
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
