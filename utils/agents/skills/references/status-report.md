# Status Report

Shape for the recurring status report a persistent posture mode gives the user each turn — `agent-coordinator`, `agent-supervisor`, `agent-bulldozer`, or any mode that runs across many turns and accumulates state. Read this whenever you **report progress**, as opposed to answering a question.

The problem it solves: a long-running mode produces a mix of durable state, fresh findings, explanation, and asks. Delivered as prose they blur together, and the reader cannot separate what is true *now* from what just *changed* from what is *wanted from them*. A stable layout keeps those apart and lets the reader's eye learn where to look instead of re-parsing every report.

## ⛔ NOT every turn — this is the full-report shape, not the default reply

**Do not emit the full four-part report on every turn.** Two triggers, and nothing else:

1. **The user asks** — status, a summary, "where are we", "give me the full picture".
2. **You judge it warranted, having CONVERGED INTO A STATE** — the work reached a settled point worth summarizing rather than a moment mid-flight. **A milestone is the canonical case**: a stage completed, a wave finished, a verdict reached, a phase closed out.

**Converged is the operative word.** The report describes a state that has settled, so emitting one mid-transition is both premature and misleading — half the rows are in motion and will read as stale within a minute. If the picture is still moving, give the terse update and report properly once it lands.

**Otherwise match the tone of the conversation.** A line or two on what happened and what is next, in whatever register the exchange is already in. A watcher firing, one agent reporting, or a single check completing is a **terse update**, not a report. Re-tabulating unchanged state every turn buries the one thing that actually moved and costs the reader more attention than it returns.

**Any active voice or brevity mode still governs.** This reference sets the *structure* of a report; it never licenses more words than the active voice mode allows. Under a terse mode, a full report keeps these sections but fills them tightly — short rows, clipped bullets, no restatement.

When in doubt, give the terse update and offer the full picture.

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

#### ⛔ Mark an item's prerequisite inline

**When an item cannot yet be acted on because something else has to land first, say so in the item itself** with a leading marker:

```
- **[PREREQUISITE: <the unmet thing>]** <the ask> — <why it is blocked>.
```

For example: `- **[PREREQUISITE: verification agent's report]** Confirm the six stacks — gated clean on my own checks, but the deep content verify has not landed.`

**Why this is not optional.** An item listed plainly reads as *ready to act on*. If it actually depends on an unlanded check, an unfinished job, or another decision, presenting it bare invites the user to act on an unverified thing — and if it then goes wrong, the report caused it. Burying the dependency in a trailing clause ("…though X hasn't reported yet") is the same failure: the marker exists so the blocker is visible *before* the ask is read, not after.

Rules:

- **The marker names the specific unmet thing**, not a vague "pending" — the user should be able to tell whether it is worth waiting for.
- **Keep the item listed.** Do not silently drop a blocked ask; the user often wants to know it is coming.
- **Remove the marker the moment the prerequisite lands**, and say in the lede that it cleared.
- **If you are choosing to recommend acting anyway**, say that explicitly alongside the marker and carry the reason — "my own checks are clean, the outstanding one is belt-and-braces". Never let an unmarked item imply verification that did not happen.
- The same marker works anywhere an item is conditional, including a `Current state` row.

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
