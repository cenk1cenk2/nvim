# Status Report

Shape for the recurring status report a persistent posture mode gives the user each turn — `agent-coordinator`, `agent-supervisor`, `agent-bulldozer`, or any mode that runs across many turns and accumulates state. Read this whenever you **report progress**, as opposed to answering a question.

The problem it solves: a long-running mode produces a mix of durable state, fresh findings, explanation, and asks. Delivered as prose they blur together, and the reader cannot separate what is true *now* from what just *changed* from what is *wanted from them*. A stable layout keeps those apart and lets the reader's eye learn where to look instead of re-parsing every report.

## Shape

**The lede comes first and carries no header.** Everything else sits under a header.

```
<lede — what changed this turn, no header>

## Current state
<table(s), optionally with ### subheaders per group, optionally a short summary under each>

## What happened
<bullets that explain>

## Waiting on you
<bullets of what is needed from the user>
```

### The lede — this turn, unheaded

**Open with what actually changed or was discovered since the last report.** This is the summary, so it needs no header and gets none — a header here just delays the thing the reader came for.

The delta only, never the standing picture. New findings, completed steps, verdicts reached, things that turned out wrong. If a finding **contradicts something reported earlier**, say so here plainly rather than quietly restating it correctly. If nothing changed, say nothing changed.

### `## Current state`

**Tables.** The standing picture: every tracked item and its live status, one row per item, concrete values. A reader who reads nothing else should still know where things stand. Keep columns stable across turns so rows compare turn to turn.

Tables rather than bullets, because this section is *scanned* rather than read.

- **Use `###` subheaders to group** when items fall into distinct sets — one table per group beats one wide table with a discriminator column.
- **A short summary under a table is welcome** when the rows share something worth stating once (a fleet-wide zero, a common baseline, an exception that applies to all rows). Put it under the table, not inside it.

### `## What happened`

**Bullets that explain.** For each item that moved: what occurred, whether it is resolved, and why where the cause is known.

This is the section most often skipped, and skipping it is what makes a report unreadable — a table says a state changed but never says what that means or whether anyone should care.

Cover explicitly:

- **Whether each item is resolved**, not merely what its status field says.
- **Self-resolved transients** — report them anyway, with magnitude, duration, and recovery.
- **"Not caused by X" versus "not happening"** — different findings, never conflated.
- **Anything still open**, stated plainly and not buried at the end of a bullet.

### `## Waiting on you`

**Bullets of what is wanted from the user** — decisions, approvals, manual steps, anything blocked on them. One bullet each, each naming the concrete action.

**Include this section even when it is empty**, and say so ("nothing needed from you"). Its absence is ambiguous: the reader cannot tell whether nothing is needed or whether you forgot to ask.

## Rules

These are the shape's intent, not a rigid template — adapt within them.

- **The four parts keep their order**, and the lede stays unheaded. That much is fixed; how you fill each part is not.
- **Tables carry state, bullets carry narrative.** Do not put explanation in a table cell or standing state in a paragraph.
- **Sections and subheaders are cheap — use them.** When a part gets complicated, split it with `###` rather than growing one dense block. A report that needs three grouped tables should have three.
- **Lists are allowed anywhere they help**, including under a table or inside `Current state`, when the content is genuinely a list. The section names say what each part is *for*, not what markup it must use.
- **Omit a part only when genuinely empty** — and for `Waiting on you`, say it is empty rather than dropping the header.
- **Never paste a subagent's or tool's raw output.** Synthesize. The report is the product, not a relay.
- **Keep it scannable.** When a part outgrows a screen, the detail belongs in a durable artifact and the report should point at it.
- **Prefer splitting over adding a fifth top-level part.** Anything that fits none of the four is usually detail belonging in a file, a tracker comment, or a document.
