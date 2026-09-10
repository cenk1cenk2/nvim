---
name: plan-companion
description: 'plan-companion Spawn one long-lived subagent as the standing architect for a plan and steer it by message as implementation deviates, until the user retires it. Use on "plan companion", "spawn an architect", "have an agent hold the design". Not for writing the plan in the first place, a one-off revision, or a handoff.'
disableModelInvocation: true
argumentHint: '[plan file or scope] [optional: tier or model]'
references:
  - ../references/agent/agent-companion.md
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/mode-toggle.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/agent/agent-write-plans.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-roster.md
  - ../references/agent/agent-target-capability.md
  - ../references/harness/provider-paths.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: issues, MRs and plan tasks carry their title and, where one exists, a markdown link to their URL, per `identifier-legibility`.

## Context

One plan gets one standing companion: a subagent that lives for the whole implementation, holds the design and its reasoning, and answers to you. You build; you report each deviation to it; it tells you what that deviation broke downstream and what the plan now says.

The whole lifecycle — the split test, tier selection, the spawn shape, the brief, steering, collection, the roster row, and the user-gated retirement — is `agent-companion`. This skill supplies the planning domain on top of it.

**What the companion holds is the reasoning the plan file cannot carry.** A plan records decisions; it does not record which decisions were load-bearing, what was considered and rejected, or which task's assumptions quietly depend on another task's shape. That is exactly what makes a deviation expensive: the plan still reads fine after reality diverges from it, and nothing in the file knows that task 7 was only correct because task 3 chose one of two options. A companion that sat through the design holds that; a fresh reader of the file does not.

Posture: `present-first`. Invoking this skill is the standing blessing to spawn the companion and to talk to it; the gate is the plan file, per `agent-companion`.

State that spans turns must be written durably per `long-running-work` — the companion's name and spawn id, its plan path, its tier, and the open design questions. Reconcile drift per `reconcile-state`.

> **PREREQUISITE:** A plan must exist before the companion is spawned. Load `plan-hard` and write it first; the plan file's absolute path goes in the brief, resolved per `provider-paths`. The companion inherits a design; it does not invent one.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/plan-companion`, "spawn an architect", "have an agent hold the design", "keep the plan honest while I build".
- **Off:** the user says the companion is no longer needed, or the plan is fully implemented **and the user confirms**. Never off on your own judgment.
- **Survives disengage:** every plan-file revision already applied, and every open design question the companion raised that you have not resolved. Both must be written into the plan file before standing down.
- Layers under any other posture, and **does not enter plan mode** — you are implementing, not planning. It is the design layer beside the build, not a return to planning.

## The Split, in planning terms

The test is `agent-companion`'s: do you already hold the finished text and the exact target?

**You do it yourself:**

- Implement the tasks. The companion never writes code.
- Tick a task done in the plan file, or fix a typo in it.
- Apply a design decision the user already made in their own words.

**The companion takes it:**

- **Blast radius** — you deviated from a task; what else in the plan is now wrong. This is the whole reason it exists.
- **Re-sequencing** — a task turned out to depend on something the plan put after it, or two tasks turned out to be one.
- **A design question that surfaced mid-build** — the plan did not anticipate it, and answering it needs the surrounding decisions weighed, not just the file read.
- **Plan-file revisions** — rewriting the affected tasks per `agent-write-plans`, keeping files, steps and verification concrete, and recording the deviation with its date.
- **Coverage** — is everything the plan promised still covered after three deviations, or has a requirement quietly fallen out.
- **What is next** — the next task to pick up given what actually landed, not the file's original order.

## The Companion Never

- **Writes code, runs builds, or touches anything but the plan file.** It is the design layer. Implementation is yours, `agent-coordinator`'s, or a delegate's.
- **Restarts the design.** A deviation revises the affected tasks; it does not reopen settled decisions. When a deviation genuinely invalidates the plan's direction, it says so and **stops** — that is the user's call, and the route is `plan-revise`, not a companion quietly redesigning.
- **Writes outside the plan file.** The tracker is `linear-companion`'s, MR descriptions are `git-companion`'s.
- **Accepts a task as done on your word alone.** A task is done when its stated verification ran — see below.

## The Deviation Report

The one message shape that matters here. Every deviation goes to the companion as:

1. **The task** it belongs to, by id.
2. **What the plan said**, in one line.
3. **What you actually did**, in one line.
4. **Why** — the constraint the plan did not know about.

That fourth line is the one that gets dropped and the one that decides everything downstream. "Used a different table name" is noise; "used a different table name because the migration framework reserves that prefix" tells the companion that every other task naming a table is now suspect.

**Report the deviation when it happens, not at the end of the task.** A companion reconciling three deviations at once cannot tell which one caused the fourth.

## Process

1. **Resolve the plan.** Its absolute path per `provider-paths`, plus which tasks are already done. State both before spawning.

2. **Pick the tier and spawn**, per `agent-companion`. Planning-specific signals when the user named no tier:

   | Signal | Tier |
   |---|---|
   | A short linear plan, few tasks, no branching decisions | `cheap` |
   | An ordinary multi-task plan in one repo | `default` |
   | Cross-repo, a DAG with real dependencies, or a design with rejected alternatives that could come back | `smart` |

   Name it `arch-<plan-slug>`.

3. **Write the brief** with the contract in `agent-companion`, filled in for planning:
   - **The plan file's absolute path**, and the instruction to **re-read it before every answer that quotes it** — you tick tasks and apply revisions to that file, so the copy it read at spawn goes stale within a few turns. Per `agent-companion` it labels each claim observed or reported.
   - **Which tasks are done**, so it does not re-derive completed state.
   - **`agent-write-plans`** as the standard every revision it drafts must meet — concrete files, steps, verification, pattern references, and no placeholders.
   - **The never list** above, above all that it stops rather than redesigns when direction breaks.
   - **The deviation report shape**, so it can ask for a missing fourth line rather than guessing.

4. **Report each deviation as it happens**, in the shape above. Also report: a task finished and verified, a design question you hit, a task that turned out to be impossible as written.

5. **Collect, present, release.** Revisions come back as edits to named tasks; present them chunked per `output-diff` before they land in the plan file.

6. **Report the companion every turn**, and retire it only on the user's word — both per `agent-companion`. The final collection goes into the plan file: open questions, what it would tell the next implementer, and which decisions turned out to be load-bearing. That file is what survives the session.

## Verification Is the Done Signal

- A task is done when **its own stated verification ran** and passed — the command in the plan, with its expected output.
- "I implemented it" is not done. Send the command and its exit code.
- A task whose verification you had to change is itself a deviation: report it, because a weakened check is the quietest way a plan stops meaning anything.
- When the plan's verification for a task turns out to be wrong or unrunnable, that is a design question, not a formality to skip.

## Example

**Trigger:** "/plan-companion the auth migration plan"

1. Plan resolved at its internal path, 9 tasks, 2 already done.
2. No tier named, so stated: smart — a DAG with cross-repo dependencies and two rejected alternatives in the design. Spawned as `arch-auth-migration`, briefed with the plan path, the done set, `agent-write-plans`, the never list, and the delivery line.
3. Task 4 deviates: the plan said to add a middleware, but the framework resolves middleware after the session loads, so the check had to move into the session factory. Reported with all four lines.
4. It answers: tasks 6 and 8 both assumed the middleware position, task 6 is now wrong and task 8 is unaffected. It drafts the revision to task 6 and flags that the plan's original rejected alternative was rejected for the same reason that just bit us — worth recording.
5. Presented the revision, applied on approval, implemented task 6 against the new shape, sent the verification command and its exit code.
6. Plan finishes. Asked whether to retire `arch-auth-migration`; the user says yes. Collected its final read — one open question about the session factory's lifetime — wrote that into the plan file, reaped it, and reported that it is gone.

**Result:** a deviation in task 4 was caught reaching task 6 before task 6 was written, and the reasoning behind it lives in the plan file rather than in a transcript.

## Related Skills

- **`plan-hard`** — writes the plan this companion then holds. Always first.
- **`plan-revise`** — when the direction itself broke, not just a task. The companion names that moment; the user makes the call.
- **`plan-compact`** — the compaction anchor. It records the companion's name, plan path and open questions alongside its other state.
- **`agent-companion`** — the generic entry point, for a domain with no dedicated skill. It owns the fit test; this skill is the plan instance.
- **`linear-companion`**, **`git-companion`** — the same shape over the tracker and over MRs; one record each. Drift reaches the others through you. The judgment worth passing on: a deviation that changes what a stacked branch must contain.
- **`agent-coordinator`** — routes the implementation while the companion holds the design.
- **`agent-plan`** — DAG-scheduled execution of the plan's tasks. The companion judges what a deviation broke; that skill runs the tasks.
