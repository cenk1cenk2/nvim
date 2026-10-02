---
name: output-table
description: output-table Present a multi-step flow as one ordered table - who acts, the action, how it is checked, what it waits on - re-emitted as rows land. Use on "table it", "give me the flow", "merge order", "who does what". Not for presenting a write for approval, a single-step answer, or unordered independent items.
disableModelInvocation: true
argumentHint: '[on|off] [optional: the flow to lay out]'
references:
  - ../references/output-table.md
  - ../references/mode-toggle.md
  - ../references/identifier-legibility.md
  - ../references/output-diff.md
---

## Output Table On Demand

A presentation skill, not a workflow. The columns, the rules and the examples are owned by the `output-table` reference; this skill decides only how many tables come out of one invocation.

## Default — one table, then done

`/output-table` with no argument lays out the flow currently in play as **one** table, then stands down. Build it from live state: re-read every PR/MR, run, and agent a row names before writing its status.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/output-table on`, "keep the table", "track this as a table", "re-table as it moves".
- **Off:** "stop the table", "normal mode", or the last row reaching `done`.
- **Level:** none — on or off.
- **Survives disengage:** nothing. Presentation only; spawns nothing and writes nothing.
- Layers under every other mode and never turns one on or off. Under `caveman` the table stays; keep the cells terse.

While on, re-emit the table whenever a row moves, marked `[output-table]` per `mode-toggle`, and nowhere else.

## Boundaries

- **Presenting a write is `output-diff`**, not this. A row can name a write; its content is still presented per `output-diff` before it runs.
- **A full status report embeds the table.** When the user asks "where are we", load `output-status`; the flow table becomes its current-state section.
- **Not for unordered items.** Independent findings or a fleet of unrelated items are a plain table or a list.

## Examples

**User says:** "give me the merge order for these four MRs"

1. Re-read the four MRs: state, pipeline, target branch, what each builds on.
2. Emit one table: one row per MR, the user's merges as `you` rows, the bumps between them as `me` rows, `Needs` carrying the order, the MR with an open change request marked `blocked`.
3. Close with the next row to act on, then stand down.

**Result:** the order to merge in, who does each step, and what is in the way, in one scan.

---

**User says:** "keep the table going while the rollout runs"

1. Acknowledge in one line: output-table on, scoped to this rollout.
2. Each time a row moves — a merge lands, an apply finishes, a check passes — re-read that row's source and re-emit the table with one line naming what moved.
3. When the last row is `done`, report it and stand down.

**Result:** the user always sees where the rollout stands without asking.
