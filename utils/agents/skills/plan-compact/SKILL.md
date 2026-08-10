---
name: plan-compact
description: 'plan-compact Keep a compaction-resilient working anchor for a long in-session task - checkpoints progress, sources, and standing watches, then reconciles from them and resumes after compaction. Triggers: "plan compact", "stay compaction-safe". Do NOT use for cross-session handoff (/plan-handoff), new plans (/plan-hard), or loading plan files (/plan-pickup).'
disableModelInvocation: true
argumentHint: "[optional task note]"
references:
  - ../references/agent-delegate.md
  - ../references/mode-toggle.md
  - ../references/provider-paths.md
---

## Plan Compact — In-Session Compaction Anchor

## Context

Long in-session work risks **context compaction** — the conversation is summarized and detail is lost mid-task. This skill maintains a **live anchor document** so the post-compaction agent can re-orient instantly and pick up the exact task it was on, and defines the reconcile pass that runs before any other work once compaction has happened.

Unlike `plan-handoff` (a self-contained plan for a *different* session or repo), `plan-compact` is for the **current** session: the anchor is continuously updated as work proceeds, and its job is to point back at every source of truth so context is rebuilt from the source, not from a lossy summary.

**Activated explicitly once, autonomous thereafter.** The user invokes `plan-compact` a single time to turn on the discipline for the task. From then on, checkpointing and reconciling happen on their own — the user never has to ask for either.

## The Anchor Document

- **Location:** your internal plans directory — resolve it for the active runtime via `provider-paths`, never hardcode — as `YYYY-MM-DD-<project>-compact.md`, one per active task.
- **Live:** updated at every checkpoint; always reflects the latest done/next state.
- **Complete:** captures not just *what* is done but *how* the work is being done — the methodology, caveats, the source documents, and any standing watches — so the resuming agent picks up mid-flight with nothing lost.

## Process

Invoke `plan-compact` **once** to activate it for the current task. Everything below then runs automatically, without further prompting.

1. **Activate.** Create the anchor file (or locate an existing one for this task). State the anchor path in chat and commit to the discipline: checkpoint automatically, and reconcile first on any resume after compaction.

### Checkpoint — maintain the anchor (automatic)

Runs on its own, no user prompt, whenever a meaningful milestone lands, before a long or risky operation, or when the context is growing long. Refresh these sections in place, each terse but complete:

- **Task & goal** — what we are doing and the end state.
- **Operating model & posture** — the *stance*, not the steps. Compaction strips this hardest because it reads as tone rather than fact, and an agent that resumes with the wrong stance does the wrong things confidently. Record:
  - **Mode** — bulldozer ON, or default, or **PARKED**. When ON: never end a turn idle, always have a next action queued or a watcher armed, report finished/in-flight/queued each turn. **When OFF or PARKED: ending a turn idle is CORRECT** — investigate, propose, wait. Say which is active, name the **exact phrase that re-engages it**, and state that a watcher wake or task notification is never permission to switch mode.
  - **★ PARKED is its own state, not a synonym for OFF.** Record it explicitly when the user parked the work: **nothing is armed, nothing is re-armed on resume, and no push resumes until the user re-engages the mode by name.** A resuming agent that finds an ambiguous mode line will guess, and a confident wrong stance beats a hesitant right one — so write the parked state and its release phrase in the same line.
  - **Role** — who performs the irreversible acts. If the user merges, applies, confirms, or deploys and the agent never does, write that down as an invariant; it is the single easiest thing for a resuming agent to violate.
  - **Delegation stance** — whether work is delegated by default and what the main loop keeps for itself (typically: gates, go/no-go, fact-checking, and anything where a wrong claim is expensive). Note which agent types have proved reliable and which have gone silent, and any isolation requirement (e.g. worktrees for concurrent file-writers).
  - **Trust posture** — whether subagent and tool claims get re-verified before being acted on, and what that caught.
  - **Standing holds** — sequencing gates, no-go zones, timing holds; each with its release condition.
  - **What resuming does NOT authorise** — spell it out: opening PRs, applying, re-arming watchers, posting externally.
- **Methodology & approach** — *how* we are doing it: the working method, sequencing, conventions adopted, tooling/agent decisions, verification commands. The habits that would be silently dropped by a summary.
- **Source documents** — every authoritative external context, each as `identifier — what it holds` (Linear project/issue URLs+IDs and their attachments, Obsidian note paths, plan/handoff/internal-plan file paths, PR/MR URLs, key repo paths).
- **Standing watches / ongoing** — anything that must keep running after resume: PRs/MRs and CI/pipelines being monitored, background agents in flight, polling loops, review threads awaited — each with its identifier and what you are waiting for.
- **Scratchpad scripts & watchers — ★ INLINE THEM ALWAYS, UNCONDITIONALLY.** Any watcher command, poll loop, or helper script written to the scratchpad or a temp dir does NOT survive compaction, is NOT reliably shared across sessions or agents, and does NOT survive a reboot. **Every checkpoint copies them into the anchor verbatim** — the full body, its path, and what it is for (which watch it drives, how to re-run it). This is not conditional on expecting a compaction: **treat the scratchpad and `/tmp` as already gone, at every checkpoint.**
  - **Inline the body, not a reference to it.** A script *mentioned* but not inlined is unrecoverable — and it reads as recorded, which is worse than an obvious gap.
  - **Inline the durable-directory scripts too when the next task needs them.** A file under the user's home survives a reboot, but inlining the one the handoff depends on costs a few lines and removes the dependency entirely.
  - **Include the invariants that make a script safe to re-run** — absolute binary paths (a backgrounded shell has no user PATH), required environment, and any assertion the script performs.
  - Never leave a running watcher, or state referenced only by a path the next agent cannot read.
  - **A park, a reboot, or a handoff makes this mandatory before standing down**, per `mode-toggle`'s *Parking* section.
- **Done so far** — completed steps and decisions.
- **Next up** — planned steps, in order.
- **Next-task handoff** — a cold-executable brief for the immediate next task.
- **Caveats & constraints** and **Open decisions / blockers**.

Restate the anchor path in chat each time so it survives the next compaction summary.

**★★ The anchor serves the OBJECTIVE. It is not a session log — PRUNE, do not accumulate.**

Every checkpoint is a chance to cut, not only to add. Delete work that went nowhere: an artifact created then abandoned, an approach tried and dropped, a side quest that was never part of the goal, a question raised and answered. If it does not change what the next agent **does**, it does not belong. An anchor that records everything buries the objective in the middle of a diary, and the resuming agent then spends its first move reconstructing irrelevant history.

**The one test for keeping a dead end: would omitting it cause someone to redo it, or to repeat a mistake that cost real time?** If yes, keep one line — the conclusion and why, not the journey. If no, cut it entirely.

Concretely: an approach the user rejected is worth a line so it is not re-proposed. A directive that changed is worth marking superseded because acting on the old one is dangerous. A document that was created and then cancelled in favour of something else is worth a line *only* if someone might otherwise recreate it. Intermediate states, tool failures that were worked around, and self-corrections that changed nothing are worth **nothing** — cut them.

**★ When a mode, role, or hold CHANGES, mark every superseded instance as superseded — do not merely add the new one.** Contradictory directives are worse than stale ones: the agent acts on whichever it reads first, and a confident wrong stance beats a hesitant right one. Strike the old line through, label it `STALE — superseded <date>, see <where>`, and leave it in place so the *reason* it changed survives.

### Consistency check — drift detection (before compaction)

Before an anticipated compaction — when the context is growing long, or on the checkpoint you expect to be the last before a summary — verify the documentation agrees with itself:

1. **Cross-check for drift.** Compare the anchor against every source document, and the sources against each other: stale status, contradictory decisions, facts that have diverged, an anchor that no longer matches Linear / the plan file / live PR-MR state.
2. **Delegate when there are several sources.** This is a read-only comparison — dispatch it to a cheap-tier subagent (via the `agent-delegate` mechanics; load `agent-harness` to resolve the tier), handing it the anchor plus the source list and asking it to report only the inconsistencies. Keeps the diffing out of the main context.
3. **Report inconsistencies to the user before continuing.** Do not silently reconcile material drift — surface which sources disagree and on what, and let the user decide. Fold agreed resolutions into the anchor and the affected source.
4. **Self-check the anchor MECHANICALLY, not by reading it.** Reading misses these — a stale line reads as true, and a missing section reads as absent rather than wrong. `grep` for:
   - every scratchpad script named anywhere in prose has its **full body** inlined (a script mentioned but not inlined is unrecoverable after compaction);
   - no contradictory mode/role/hold directives — search the mode keywords and confirm every hit is either current or explicitly marked superseded;
   - headline counts agree with their own tables (`N of M done` versus what the table actually lists);
   - superseded blocks are labelled, not merely followed by newer ones.

   Report the check's output, not just "checked".

### Reconcile — rebuild after compaction (automatic, first task)

The moment the context has been compacted — the summary says so, or you notice you have lost specifics the summary references — run this **before any other action**, without waiting to be asked. **This is absolute: the first task after compaction is ALWAYS to run this ENTIRE pass — re-ground the guidelines, then re-read the anchor and every source document, and re-check every standing watch — rediscovering all of it from source. Every step below is mandatory and runs in order: never skip a step, never trust the summary in place of a source, never deviate, and never start the task work first. Everything the compaction passed through gets rediscovered, not just the system prompt.**

**The anchor IS the discovery document — read it before any source, and treat it as the boot sequence rather than a summary of one.** Run every step, in order, every time:

0. **Detect it.** A summary in context, or specifics missing that the summary references, means compaction happened. **If unsure, assume it did** — running the pass unnecessarily costs a few minutes; skipping it costs correctness.
1. **`agent-read`** — guidelines, skills catalog, caveman, local instructions. **Re-read every skill you are about to use, from its source; never work from a summary's memory of one** (see step 1 detail).
2. **Read the anchor FULLY**, top to bottom, **including blocks marked superseded** — a superseded block records what was believed and why it changed, which is often the thing that stops you repeating it.
3. **★ Establish the posture BEFORE any action.** Mode (on / off / **parked**), role (who merges/applies/confirms), standing holds, and what resuming does not authorise. **An agent that resumes pushing when it was told to park has failed regardless of what it accomplishes** — and one that resumes timid when told to bulldoze wastes the user's time. Get the stance right first.
4. **Re-read every source via its owning tool.** Sources win over the anchor; update the anchor where they disagree.
5. **Verify nothing is still running** (watchers, background agents), then re-arm **only** what the anchor says should be armed **and only if the posture permits arming at all** — see step 5 detail. Never re-arm speculatively.
6. **Report the reconstructed state, then act** — or **park and wait**, if the posture says so. **Ending the turn idle is CORRECT when parked.**

Detail on each step:

1. **Re-ground EVERYTHING first — run `agent-read` (absolute, never deviate).** Before touching the task, do the full discovery as if starting a new session: re-read the central `AGENTS.md` / system prompt fresh, rediscover the skills catalog, reload caveman, and re-read the local instructions — all via the `agent-read` skill. The guidelines and catalog that compaction summarized away come back inline before anything else. This is the mandatory first task; do not begin any task work until it is done.

   **★ Re-READ the skills, do not recall them.** Compaction leaves you *remembering* a skill's gist while the details — the traps, the exact parameters, the stop conditions — are gone, and a half-remembered skill is more dangerous than an unread one because it feels known. So:
   - **Enumerate the catalog fresh** so profile-filtered availability is current, not assumed.
   - **Load the body of every skill the resumed work will use**, from source, before using it — including the mode skills whose posture you are about to adopt and any per-runtime reference they point at. **A skill named in the anchor is a skill to re-read, not a skill you already know.**
   - **Re-load a skill's declared references** where the body directs it; a reference read before compaction is gone too.
   - If the anchor records a **standing operator directive that overrides a skill's default** (a voice mode, an authority to act without asking, a gate that was waived), re-establish it explicitly — those are exactly what a summary flattens into tone.
2. **Read the anchor document fully.**
3. **Re-read every source document it lists**, each via its owning tool — Linear issues/projects/attached documents via the Linear tools, vault notes via the Obsidian tools, plan/internal files via `Read`, PRs/MRs via the SCM tools, and any other recorded resource via the tool that owns it. Do NOT trust the summary — go back to source. **The anchor's Source Documents list is the recall list: every entry gets re-fetched, in the order given.**
4. **Re-establish standing watches and scripts — but only if the posture permits.**
   - **If the posture is PARKED or the mode is off, re-arm NOTHING.** Verify nothing is running, report that, and stop. An unexpected armed watcher reads as in-flight work that isn't, and re-arming while parked silently re-engages a mode the user turned off.
   - **When arming is permitted:** for every item under Standing Watches, re-check its **live state from source** (PR/MR status, pipeline result, run state, awaited thread) before arming anything — the state moved on while the context was being rebuilt, and a watcher armed against a stale assumption fires on the wrong condition.
   - **Arm one watcher per independent condition**, never bundled, via the background/watcher skill's own mechanics (`agent-background`). **⛔ Before arming anything, Read the active runtime's mechanics from `~/.config/nvim/utils/agents/skills/references/harness-<provider>-agent-background.md`** — `<provider>` resolves at runtime (`claude`, `opencode`, `codex`), the rest of the path is literal. It owns the watcher facility and its wake semantics; a missed read is silent and the watcher never wakes anyone. **Do not detach inside the command** — that produces a log, not a watcher.
   - **Treat the scratchpad as gone.** Re-materialize every script from the anchor's verbatim copy before arming the watch that depends on it. Never assume a scratchpad or temp path from before compaction still exists.
   - **Confirm each launch returned a handle**, and state which watchers are now armed and on what condition.
5. **Rebuild and reconcile.** Reconstruct the working model, including the methodology and caveats. Where the anchor and a live source disagree, the source wins — update the anchor to match.
6. **Report the reconstructed state** (task, methodology in brief, done, next task, active watches) in a few lines, then **resume** the exact task from the next-task handoff.

## Anchor Document Format

```markdown
# [Task title] — Compaction Anchor

> ⚠️ POST-COMPACTION: THIS FILE IS THE DISCOVERY DOCUMENT — read it FIRST, in full,
> including blocks marked superseded. If you are resuming with a summarized context, STOP:
> run `agent-read` (AGENTS.md + skills catalog + caveman + local instructions), read this
> file, **establish Posture below before any action**, re-read every Source Document via
> its owning tool (sources win over this file), verify nothing is still running and re-arm
> ONLY what Standing Watches says should be, and re-materialize every Scratchpad
> Script/Watcher (the scratchpad is gone). Then resume from Next-Task Handoff — or stop,
> if Posture says stop.
>
> **Project:** <project> · **Created:** YYYY-MM-DD · **Updated:** YYYY-MM-DD

## Task & Goal
[One or two lines: what we are doing and the end state.]

## Posture — VERIFY BEFORE ACTING
- **Mode:** bulldozer ON | OFF/default. If OFF, ending a turn idle is CORRECT.
- **Role:** who merges / applies / confirms / deploys. [If the user owns these and the
  agent never does, say so as an invariant.]
- **Delegation:** [delegate-by-default or not; what the main loop keeps — typically gates,
  go/no-go, fact-checking; which agent types proved reliable; isolation requirements.]
- **Trust:** [whether subagent/tool claims get re-verified before being acted on.]
- **Standing holds:** [gate — release condition.]
- **Resuming does NOT authorise:** [opening PRs, applying, re-arming, posting externally.]

## Methodology & Approach
[How we are doing it: working method, sequencing, conventions adopted, tooling/agent
decisions, verification commands. The "how" a summary would drop.]

## Source Documents
- `<Linear issue URL / ID>` — [what it holds].
- `<Linear project URL / ID>` (+ attachments) — [what it holds].
- `<Obsidian note path>` — [what it holds].
- `<plans-dir>/...-<name>.md` — internal plan file: [what it holds].
- `<PR/MR URL>` — [what it holds].
- `<repo path>` — [what it holds].

## Standing Watches / Ongoing
- `<PR/MR URL>` — [what we are watching for, e.g. CI green + review approval].
- `<pipeline / CI ref>` — [awaited result].
- `<background agent / loop>` — [what it is doing, how to check].

## Scratchpad Scripts & Watchers
[Scratchpad/temp files do NOT survive compaction and are NOT reliably shared — inline
anything that lives there so this section is the durable copy. For each: what it does,
its scratchpad path, and where/how it was used. Include the full body so it can be
re-materialized after compaction.]
- `<scratchpad path>` — [what it does; which watch it drives / how to re-run].
  ```
  <full command or script body, verbatim>
  ```

## Done So Far
- [Completed step / decision.]

## Next Up
1. [Next planned step.]

## Next-Task Handoff
[Cold-executable brief for the immediate next task: exact files, commands, acceptance
criteria, gotchas. Enough that a fresh agent could run it with no conversation history.]

## Caveats & Constraints
- [Thing to be careful about — invariant, constraint, non-obvious decision.]

## Open Decisions / Blockers
- [Unresolved item awaiting a decision or external event.]
```

## Composition with Other Skills

Reconcile reads the source documents and re-checks watches automatically through their owning tools — no user coordination.

- **`agent-read`** — runs first in the reconcile pass to re-read the central `AGENTS.md` / system prompt and rediscover skills, so the guidelines survive compaction before the task is rebuilt.
- **`agent-delegate`** — dispatches the pre-compaction consistency check to a cheap-tier read-only subagent that diffs the anchor against the source documents and reports drift, keeping the comparison out of the main context.
- **`plan-hard`** — builds the internal plan file; `plan-compact` tracks its execution and lists it as a source.
- **`plan-handoff`** — for handing work to a *different* session or repo; `plan-compact` is same-session compaction survival.
- **`plan-pickup`** — loads a plan file; the anchor's internal plan file can be one, but reconcile reads it directly.
- **`linear-*` / `obsidian-*`** — the owning tools reconcile uses to re-read issues, projects, attachments, and vault notes.

## Examples

**Example 1 — activate once, then autonomous:**

1. User: "plan compact" at the start of a long migration. Create the anchor; record the goal, the approach (module-by-module, `task test` after each), the Linear issue + internal plan file + two repo paths as sources, and the three MRs being watched for CI+approval; state the anchor path.
2. Without any further prompting, checkpoint after each module lands and as MR states change.
3. The context compacts. On the next turn, before anything else, reconcile: read the anchor, re-read the Linear issue and plan file via their tools, re-check the three MRs' live state, update drift, report "3 of 5 modules done, MR !2 merged, next is the auth module", and continue.

**Example 2 — reconcile fires with no user command:**

1. `plan-compact` was activated earlier; the anchor exists and lists PRs under Standing Watches.
2. The agent resumes into a summarized context, detects the compaction, reconciles from the anchor and its sources, re-checks the watched PRs, then picks up the next task. The user never said "reconcile".

## Key Principles

- **Activate once, then autonomous.** The user turns it on a single time; checkpointing and reconciling never need to be asked for again.
- **Reconcile first, act second.** After compaction, the reconcile pass runs before any other work.
- **Rediscover EVERYTHING first — absolute, never deviate.** After compaction the mandatory first task is the whole reconcile pass, in order: `agent-read` (system prompt, guidelines, skills catalog, caveman, local instructions), then the anchor, then every source document, then every standing watch — all re-read from source. Everything compaction touched gets rediscovered; none of it is optional and the summary never substitutes for a source. No task work until the full pass is done.
- **Check consistency before compaction.** When several documents describe the task, cross-check them (delegating to a cheap subagent when there are many) and surface any drift to the user before the context is compacted — never bury it.
- **Capture the how, not just the what.** Methodology, caveats, and standing watches are exactly what a summary drops — record them so the resuming agent works the same way and drops nothing it was monitoring.
- **Scratchpad is not durable — inline it.** Watchers, poll loops, and helper scripts written to the scratchpad/temp dir vanish on compaction and are not shared across sessions or agents. Record their full body, path, and use in the anchor, and re-materialize them from the anchor on resume — never leave the anchor pointing at a scratchpad path the next agent cannot read.
- **Source documents are truth.** Rebuild from the listed sources via their owning tools — never from the summary alone.
- **The anchor path is the lifeline.** Restate it at every checkpoint so it survives the compaction summary.
- **Terse and current.** The anchor is working memory, not a report — update in place, don't append history.
- **Serve the objective; prune everything else.** Every checkpoint cuts as well as adds. Abandoned artifacts, dropped approaches, side quests, intermediate states, worked-around tool failures, and self-corrections that changed nothing all come OUT. Keep a dead end only when omitting it would make someone redo it or repeat a costly mistake — and then keep the conclusion, not the journey.
- **Posture before action.** Mode, role, holds, and what resuming does not authorise get established before the first move. Resuming with the wrong stance — pushing when parked, or waiting when told to bulldoze — is a failure regardless of what gets done.
- **Contradiction is worse than staleness.** Two live directives that disagree are more dangerous than one out-of-date directive, because the agent acts on whichever it reads first and does so confidently. Mark superseded, never merely append.
- **Verify the anchor mechanically before compacting.** `grep` for uninlined scripts, contradictory directives, and counts that disagree with their own tables. Reading misses all three — a stale line reads as true.
- **The next-task handoff must run cold.** A fresh agent should execute it with zero conversation history.
