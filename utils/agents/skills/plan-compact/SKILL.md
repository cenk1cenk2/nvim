---
name: plan-compact
description: 'plan-compact Keep a compaction-resilient working anchor for a long in-session task - checkpoints progress, sources, and standing watches, then reconciles from them and resumes after compaction. Triggers: "plan compact", "stay compaction-safe". Do NOT use for cross-session handoff (/plan-handoff), new plans (/plan-hard), or loading plan files (/plan-pickup).'
disable-model-invocation: true
argument-hint: "[optional task note]"
references:
  - ../references/present-first.md
  - ../references/agents-delegate.md
---

## Plan Compact — In-Session Compaction Anchor

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `agents-delegate` reference for dispatching the pre-compaction consistency check to a cheap-tier read-only subagent. Resolve tiers via the `agents-tiers` skill.

## Context

Long in-session work risks **context compaction** — the conversation is summarized and detail is lost mid-task. This skill maintains a **live anchor document** so the post-compaction agent can re-orient instantly and pick up the exact task it was on, and defines the reconcile pass that runs before any other work once compaction has happened.

Unlike `plan-handoff` (a self-contained plan for a *different* session or repo), `plan-compact` is for the **current** session: the anchor is continuously updated as work proceeds, and its job is to point back at every source of truth so context is rebuilt from the source, not from a lossy summary.

**Activated explicitly once, autonomous thereafter.** The user invokes `plan-compact` a single time to turn on the discipline for the task. From then on, checkpointing and reconciling happen on their own — the user never has to ask for either.

## The Anchor Document

- **Location:** your internal plans directory, as `YYYY-MM-DD-<project>-compact.md` — one per active task.
- **Live:** updated at every checkpoint; always reflects the latest done/next state.
- **Complete:** captures not just *what* is done but *how* the work is being done — the methodology, caveats, the source documents, and any standing watches — so the resuming agent picks up mid-flight with nothing lost.

## Process

Invoke `plan-compact` **once** to activate it for the current task. Everything below then runs automatically, without further prompting.

1. **Activate.** Create the anchor file (or locate an existing one for this task). State the anchor path in chat and commit to the discipline: checkpoint automatically, and reconcile first on any resume after compaction.

### Checkpoint — maintain the anchor (automatic)

Runs on its own, no user prompt, whenever a meaningful milestone lands, before a long or risky operation, or when the context is growing long. Refresh these sections in place, each terse but complete:

- **Task & goal** — what we are doing and the end state.
- **Methodology & approach** — *how* we are doing it: the working method, sequencing, conventions adopted, tooling/agent decisions, verification commands. The habits that would be silently dropped by a summary.
- **Source documents** — every authoritative external context, each as `identifier — what it holds` (Linear project/issue URLs+IDs and their attachments, Obsidian note paths, plan/handoff/internal-plan file paths, PR/MR URLs, key repo paths).
- **Standing watches / ongoing** — anything that must keep running after resume: PRs/MRs and CI/pipelines being monitored, background agents in flight, polling loops, review threads awaited — each with its identifier and what you are waiting for.
- **Scratchpad scripts & watchers** — any watcher command, poll loop, or helper script you wrote to the scratchpad/temp dir does NOT survive compaction and is NOT reliably shared across sessions or agents. Capture it in the anchor **verbatim**: the full command/script body, its scratchpad path, and where and how it was used (which watch it drives, how to re-run it). The scratchpad copy is disposable — the anchor is the durable one. Never leave a running watcher or a script that produced state referenced only by a path the next agent cannot read.
- **Done so far** — completed steps and decisions.
- **Next up** — planned steps, in order.
- **Next-task handoff** — a cold-executable brief for the immediate next task.
- **Caveats & constraints** and **Open decisions / blockers**.

Restate the anchor path in chat each time so it survives the next compaction summary.

### Consistency check — drift detection (before compaction)

Before an anticipated compaction — when the context is growing long, or on the checkpoint you expect to be the last before a summary — verify the documentation agrees with itself:

1. **Cross-check for drift.** Compare the anchor against every source document, and the sources against each other: stale status, contradictory decisions, facts that have diverged, an anchor that no longer matches Linear / the plan file / live PR-MR state.
2. **Delegate when there are several sources.** This is a read-only comparison — dispatch it to a cheap-tier subagent (via the `agents-delegate` mechanics; resolve the tier with `agents-tiers`), handing it the anchor plus the source list and asking it to report only the inconsistencies. Keeps the diffing out of the main context.
3. **Report inconsistencies to the user before continuing.** Do not silently reconcile material drift — surface which sources disagree and on what, and let the user decide. Fold agreed resolutions into the anchor and the affected source.

### Reconcile — rebuild after compaction (automatic, first task)

The moment the context has been compacted — the summary says so, or you notice you have lost specifics the summary references — run this **before any other action**, without waiting to be asked. **This is absolute: the first task after compaction is ALWAYS to run this ENTIRE pass — re-ground the guidelines, then re-read the anchor and every source document, and re-check every standing watch — rediscovering all of it from source. Every step below is mandatory and runs in order: never skip a step, never trust the summary in place of a source, never deviate, and never start the task work first. Everything the compaction passed through gets rediscovered, not just the system prompt.**

1. **Re-ground EVERYTHING first — run `agent-read` (absolute, never deviate).** Before touching the task, do the full discovery as if starting a new session: re-read the central `AGENTS.md` / system prompt fresh, rediscover the skills catalog, reload caveman, and re-read the local instructions — all via the `agent-read` skill. The guidelines and catalog that compaction summarized away come back inline before anything else. This is the mandatory first task; do not begin any task work until it is done. Only after `agent-read` completes do you work through the rest of this compaction documentation — the anchor and every source below.
2. **Read the anchor document fully.**
3. **Re-read every source document it lists**, each via its owning tool — Linear via `linear-*` (issues, projects, attached documents), Obsidian via `obsidian__*`, plan/internal files via `Read`, PRs/MRs via `scm-*`. Do NOT trust the summary — go back to source.
4. **Re-establish standing watches and scripts.** For every item under Standing Watches, re-check its live state (PR/MR status, pipeline result, background agent, awaited thread) so nothing being monitored is dropped. For every scratchpad script or watcher recorded in the anchor, treat the scratchpad as gone — re-materialize the script from the anchor's verbatim copy (rewrite it to the scratchpad if needed) and re-arm the watch. Never assume a scratchpad path from before compaction still exists.
5. **Rebuild and reconcile.** Reconstruct the working model, including the methodology and caveats. Where the anchor and a live source disagree, the source wins — update the anchor to match.
6. **Report the reconstructed state** (task, methodology in brief, done, next task, active watches) in a few lines, then **resume** the exact task from the next-task handoff.

## Anchor Document Format

```markdown
# [Task title] — Compaction Anchor

> ⚠️ POST-COMPACTION: if you are resuming here with a summarized context, STOP and
> re-ground FIRST — run `agent-read` (re-read AGENTS.md + rediscover skills), then read
> this file, re-read every Source Document below via its owning tool, re-check every
> Standing Watch, and re-materialize every Scratchpad Script/Watcher (scratchpad is gone)
> before taking any action. Then resume the task from Next-Task Handoff.
>
> **Project:** <project> · **Created:** YYYY-MM-DD · **Updated:** YYYY-MM-DD

## Task & Goal
[One or two lines: what we are doing and the end state.]

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
- **`agents-delegate`** — dispatches the pre-compaction consistency check to a cheap-tier read-only subagent that diffs the anchor against the source documents and reports drift, keeping the comparison out of the main context.
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
- **The next-task handoff must run cold.** A fresh agent should execute it with zero conversation history.
