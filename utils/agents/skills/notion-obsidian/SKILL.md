---
name: notion-obsidian
description: notion-obsidian Convert an Obsidian note into Notion-flavored markdown plus an exported asset list - wikilinks, callouts, embeds, images and Excalidraw drawings rendered to SVG. Use when a vault note is headed for Notion, "convert this note for Notion". Not for reading or writing Notion pages, or editing the vault note.
references:
  - ../references/obsidian.md
---

## Obsidian Note to Notion Conversion

A conversion step only. It reads one vault note and returns two things: the converted body and an asset manifest. Fetching, creating, or updating the Notion page belongs to the composing skill, and the source note is never modified.

Vault access and path rules per `obsidian`.

## Process

1. **Read the note** with `obsidian__vault_read`, vault-relative path. Note its folder: relative embeds resolve from there, then by vault-wide filename match.
2. **Split frontmatter from body.** Return frontmatter as a property map for the composing skill. Drop `aliases`. Hand `tags` and `bookmarks` over as properties, not body text. Keep `notion-url` as the target hint.
3. **Title.** The first `# heading` is the page title and is removed from the body. With no heading, use the first alias, then the filename stem.
4. **Convert the body** per Conversion Rules below.
5. **Collect assets** per Assets below, staging every exported file in a session temp directory.
6. **Return** the title, property map, converted body, and asset manifest. List every construct that had no Notion equivalent and was degraded, with its line.

## Conversion Rules

| Obsidian | Notion |
|---|---|
| `[[note]]`, `[[note\|alias]]` | Link to the target's Notion page when its frontmatter carries `notion-url`; otherwise plain text of the alias or note name, listed as degraded. |
| `[[note#heading]]` | Same as above. The heading anchor is dropped. |
| `![[note]]` (note transclusion) | Inline the target's body under a toggle titled with the note name. One level deep; deeper transclusions become links. |
| `![[image.png]]`, `![](image.png)` | Image block pointing at the manifest entry. |
| `![[drawing.excalidraw]]`, `![[drawing.excalidraw.md]]` | Image block pointing at the drawing's exported SVG manifest entry. |
| `![[file.pdf]]` | File block pointing at the manifest entry. |
| `> [!type] Title` callouts | Callout block, title in bold on its first line; foldable `[!type]-` becomes a toggle. |
| `==highlight==` | Yellow background color span. |
| `%% comment %%` | Removed. |
| `^block-id` | Removed. |
| `- [ ]` / `- [x]` | To-do blocks. |
| Fenced code, incl. `mermaid` | Code block, language kept. |
| `$inline$`, `$$block$$` math | Inline and block equations. |
| Footnotes `[^1]` | Footnote text moved inline in parentheses, listed as degraded. |
| `#tag` in body | Plain text; tags travel as the property. |

Target syntax is the connector's Notion-flavored markdown spec. Read it before the first conversion in a session instead of assuming a block's syntax.

## Assets

Every embedded file becomes one manifest row: vault path, staged local path, kind (`image`, `drawing`, `file`), and the placeholder the body references. The composing skill uploads or hosts each row and swaps the placeholder for the final URL; an asset that already has a public `http(s)` URL is kept inline and gets no row.

- **Images** — copy the file as is. Resolve the path with `obsidian__vault_list` / `obsidian__search_query` when the embed gives only a filename.
- **Excalidraw drawings** — stage the `<drawing>.excalidraw.svg` file next to the drawing, which the vault's SVG auto-export writes on every save. When it is missing or older than the `.excalidraw.md`, export it through Obsidian:
  1. `obsidian__open_file` the `.excalidraw.md` with `newLeaf: true`, so the drawing becomes the active pane.
  2. `obsidian__command_execute` with `obsidian-excalidraw-plugin:save`. The save re-serializes the `.excalidraw.md` and writes the `.svg` next to it.
  3. Re-check the `.svg` timestamp against the drawing, then `obsidian__command_execute` with `workspace:close` to close the tab you opened.

  The plugin's `export-image` command opens a dialog and is not used. The SVG carries the vault theme and embeds its fonts.
- **PDFs and other files** — copy as is, kind `file`.

Read files from `~/notes` directly for binary copies; the vault tools return text.

## Example

**Composed by a push:** a skill sending `Work/rollout-plan.md` to Notion loads this one first.

1. Read the note: title `Rollout plan`, `tags: [infra]`, one `[[runbook]]` link, `![[cutover.excalidraw]]`, one `> [!warning]` callout.
2. `runbook.md` has no `notion-url`, so the link becomes plain text and is listed as degraded.
3. `Drawings/cutover.excalidraw.svg` exists and is newer than the drawing, so it is staged as a `drawing` row.
4. Callout converted; body, properties `{tags: [infra]}`, a one-row manifest, and one degraded item returned.

**Result:** the composing skill uploads the SVG, swaps the placeholder, and writes the page.
