---
name: code-annotations
description: code-annotations Work through review annotations the captain left in the editor - issues, suggestions, notes, praise pinned to file lines - and apply or answer each one. Use on "use the code-annotations skill", "work through my annotations", or an exported annotations file. Not for reviewing a diff or branch from scratch, or PR/MR review threads.
references:
  - ../references/review-findings.md
---

## Context

The captain annotates the repository in Neovim and exports a markdown file, linked from the prompt as `@<path>`. The file names the repository root, then one numbered line per annotation:

```
N. **[TYPE]** `path:line` - text
```

- Paths are relative to the repository root. `line-end` is a range, a bare path is a whole-file comment, and `~` before a line number points at the old side of a diff.
- Multi-line text continues on indented lines.

| Type | Means |
|---|---|
| `ISSUE` | A defect. Fix it. |
| `SUGGESTION` | A requested change. Apply it unless it conflicts with another annotation or breaks something, and say so when it does. |
| `NOTE` | Context or a question. Answer it, or treat it as a constraint on the other fixes. Changes code only when it says to. |
| `PRAISE` | Keep this. Do not refactor it away while fixing its neighbours. |

## Process

1. Read the linked file. Line numbers were taken when the export ran, so re-read each target around its line before editing; if the code moved, find it by content.
2. Group annotations that touch the same concern and present the plan, one line per annotation: fix, answer, or push back. Skip the plan when the captain already said to go.
3. Apply fixes one annotation at a time, issues first, then suggestions. Load `code-style` before the first edit.
4. Report per `review-findings`, keyed by annotation number: what changed, what was answered, and what was pushed back on and why.
5. Leave the annotations in the editor store. Clearing them is the captain's call.
