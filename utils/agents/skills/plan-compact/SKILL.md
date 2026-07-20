---
name: plan-compact
description: Keep a compaction-resilient working anchor during a long in-session task. Activated explicitly once, it then automatically checkpoints progress — the task, methodology, caveats, source documents, and standing watches (e.g. PRs/CI being monitored) — and, the moment the context is compacted, reconciles from the anchor and every source it lists before doing anything else, then resumes the exact task. Use when user says "plan compact", "keep a working anchor", "stay compaction-safe", or "track this so we survive compaction". Do NOT use for cross-session or cross-repo handoff (use /plan-handoff), building a new plan (use /plan-hard), or loading an existing plan file (use /plan-pickup).
disable-model-invocation: true
argument-hint: "[optional task note]"
references:
  - ../references/present-first.md
---

## Plan Compact — In-Session Compaction Anchor

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Context

Long in-session work risks **context compaction** — the conversation is summarized and detail is lost mid-task. This skill maintains a **live anchor document** so the post-compaction agent can re-orient instantly and pick up the exact task it was on, and defines the reconcile pass that runs before any other work once compaction has happened.

Unlike `plan-handoff` (a self-contained plan for a *different* session or repo), `plan-compact` is for the **current** session: the anchor is continuously updated as work proceeds, and its job is to point back at every source of truth so context is rebuilt from the source, not from a lossy summary.

**Activated explicitly once, autonomous thereafter.** The user invokes `plan-compact` a single time to turn on the discipline for the task. From then on, checkpointing and reconciling happen on their own — the user never has to ask for either.

## The Anchor Document

- **Location:** `~/.claude/plans/YYYY-MM-DD-<project>-compact.md` — one per active task.
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
- **Done so far** — completed steps and decisions.
- **Next up** — planned steps, in order.
- **Next-task handoff** — a cold-executable brief for the immediate next task.
- **Caveats & constraints** and **Open decisions / blockers**.

Restate the anchor path in chat each time so it survives the next compaction summary.

### Reconcile — rebuild after compaction (automatic, first task)

The moment the context has been compacted — the summary says so, or you notice you have lost specifics the summary references — run this **before any other action**, without waiting to be asked:

1. **Read the anchor document fully.**
2. **Re-read every source document it lists**, each via its owning tool — Linear via `linear-*` (issues, projects, attached documents), Obsidian via `obsidian__*`, plan/internal files via `Read`, PRs/MRs via `scm-*`. Do NOT trust the summary — go back to source.
3. **Re-establish standing watches.** For every item under Standing Watches, re-check its live state (PR/MR status, pipeline result, background agent, awaited thread) so nothing being monitored is dropped.
4. **Rebuild and reconcile.** Reconstruct the working model, including the methodology and caveats. Where the anchor and a live source disagree, the source wins — update the anchor to match.
5. **Report the reconstructed state** (task, methodology in brief, done, next task, active watches) in a few lines, then **resume** the exact task from the next-task handoff.

## Anchor Document Format

```markdown
# [Task title] — Compaction Anchor

> ⚠️ POST-COMPACTION: if you are resuming here with a summarized context, STOP and
> reconcile FIRST — read this file, re-read every Source Document below via its owning
> tool, and re-check every Standing Watch before taking any action. Then resume the
> task from Next-Task Handoff.
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
- `<~/.claude/plans/...-<name>.md>` — internal plan file: [what it holds].
- `<PR/MR URL>` — [what it holds].
- `<repo path>` — [what it holds].

## Standing Watches / Ongoing
- `<PR/MR URL>` — [what we are watching for, e.g. CI green + review approval].
- `<pipeline / CI ref>` — [awaited result].
- `<background agent / loop>` — [what it is doing, how to check].

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
- **Capture the how, not just the what.** Methodology, caveats, and standing watches are exactly what a summary drops — record them so the resuming agent works the same way and drops nothing it was monitoring.
- **Source documents are truth.** Rebuild from the listed sources via their owning tools — never from the summary alone.
- **The anchor path is the lifeline.** Restate it at every checkpoint so it survives the compaction summary.
- **Terse and current.** The anchor is working memory, not a report — update in place, don't append history.
- **The next-task handoff must run cold.** A fresh agent should execute it with zero conversation history.
