---
name: code-annotations
description: code-annotations Work through review notes the captain left with annotate.nvim - typed notes pinned to file lines or diff sides - and act on each as its type asks. Use on "use the code-annotations skill", "work through my annotations", or an exported annotations file. Not for reviewing a diff or branch from scratch, or PR/MR review threads.
references:
  - ../references/review-findings.md
---

## Context

The captain annotates the repository in Neovim with annotate.nvim and exports a markdown file, linked from the prompt as `@<path>`. The file is self-describing:

- **The opening paragraph** is the captain's instruction for the whole review.
- **`## Description`** lists each type and reach in use as `[TYPE] (reach)` with what the captain expects for it. That line is the contract for every note in the matching section; read it before acting, because types, reaches and their meanings are configurable and change.
- **`## Reach`** appears only when configured and says what each reach means. `here` is the note's location only — its lines, its file for a whole-file note, the repository for a repository note; `pattern` takes the location as one example of something to handle wherever it occurs.
- **`## Compared`** appears only when notes came from a diff view, and names each comparison as `` `<left>` .. `<right>` ``.
- **`## [TYPE] (reach)` sections**, separated by `---`, hold the notes, one section per type and reach. Each note is a `### <location>` heading followed by the note itself as free markdown. The location is `` `path:line` ``, `` `path:start-end` `` for a range, a bare `` `path` `` for a whole-file note, `` @ <rev> `` when the note sits on a commit or stage side of a diff rather than the working tree, and the plain word `repository` for a note about the repository as a whole, attached to no file.

Paths are relative to the repository root.

## Process

1. Read the linked file whole. Line numbers were taken at export, so re-read each target around its line before acting, and find it by content when it moved. A `@ <rev>` note refers to that revision; check the working tree for whether it still applies.
2. Present the plan grouped by concern, one line per note: what you will do, per its section's Description line. Skip the plan when the captain already said to go.
3. Act on each note as its section's Description says, loading `code-style` before the first edit. Notes the Description says to settle together go back to the captain unanswered in code.
4. Everything that needs the captain — questions, push-backs, decisions, a suggestion you declined — goes back one item at a time: Load `output-chunks` and give each its own chunk, opening with the exact `path:line` and one line saying what the code there is.
5. When the captain asks to see a location, show it in their editor: through `hyprpilot-nvim` when its server is in the session (jump to one location, quickfix for a set); otherwise Load `editor-open` to open the repository first.
6. Report per `review-findings`, keyed by section and item, covering everything the opening paragraph asks the report to contain.
7. Leave the notes in the editor store. Clearing them is the captain's call.
