---
name: report-status
description: report-status Emit the four-part status report - lede, current state, what happened, waiting on you. One report by default; toggled on it fires at every milestone until stopped. Use on "status", "where are we", "full picture", "keep reporting at milestones". Not for a terse mid-flight update, and not for presenting a write for approval.
disableModelInvocation: true
argumentHint: '[on|off]'
references:
  - ../references/report-status.md
  - ../references/mode-toggle.md
---

## Status Report On Demand

A presentation skill, not a workflow. The report's shape, its converged-state gate, and its prerequisite marking are owned by the `report-status` reference; this skill decides only how many reports come out of one invocation.

Use it when the work has accumulated state the conversation no longer carries — several agents in flight, a multi-stage migration, a long audit, a supervised project. Works in any posture, including none.

## Default — one report, then done

`/report-status` with no argument emits **exactly one** report of the current state, then stands down. No mode engages, nothing persists, and the next turn returns to whatever register the conversation was already in.

Build it from live state, not from memory of earlier turns: re-read the state file, the tracker, the task list, the watcher list, the artifacts. A report assembled from stale context is worse than none, because it reads as verified.

If the picture is still moving, say so and give the terse update instead — the `report-status` reference gates the full shape on a converged state, and that gate holds here.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/report-status on`, "keep reporting", "report at every milestone", "status report each milestone", "stay on status".
- **Off:** "stop reporting", "no more status reports", "one-off from here", "normal mode", or the scope agreed at engage time completing.
- **Level:** none — on or off.
- **Survives disengage:** nothing. Presentation only; spawns nothing, arms nothing, writes nothing.
- Layers under every other mode and never turns one on or off. Under a voice mode, keep the four parts and fill them tightly.

While on, mark the posture in each report per `mode-toggle` — `[report-status]`, or both names when another posture is driving.

## While the toggle is on

- **Report at milestones, not at turns.** The trigger is the `report-status` reference's converged-state rule. A watcher firing, one agent reporting, or a single check landing is a terse update.
- **A user asking for status still gets one immediately**, milestone or not.
- **Say when a milestone passed without a report** and why — usually the state had not settled. Silence reads as no progress.

## Boundaries

- **Presenting a write is `output-diff`**, not this. A create or update to a file or an external resource follows that convention.
- **Answering a question is not a report.** One question gets one answer, in the conversation's own register.
- **A mode that already reports every turn does not need this.** Coordinator and supervisor carry the shape in their own process steps; engaging this on top adds a marker and nothing else.

## Examples

**User says:** "/report-status" after four agents were dispatched across a migration

1. Re-read the state file, the task list, and each agent's last report.
2. Emit one report: lede on what landed, a table per agent group, bullets on what each outcome means, the two decisions being waited on.
3. Stand down — next turn is normal conversation.

**Result:** the standing picture once, with no mode left running.

---

**User says:** "keep giving me a status report at every milestone"

1. Acknowledge in one line: report-status posture on, scoped to this migration.
2. Stay quiet through dispatches and watcher wakes, answering in the conversation's register.
3. When wave one finishes and its verdicts settle, emit the full report marked `[report-status]`.
4. Continue until the user stops it or the migration closes out.

**Result:** one report per milestone instead of a re-tabulated wall every turn.
