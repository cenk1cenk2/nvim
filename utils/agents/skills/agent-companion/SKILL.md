---
name: agent-companion
description: 'agent-companion Spawn one long-lived subagent as a standing manager for a domain needing project-management supervision, and steer it by message until the user retires it. Use on "agent companion", "spawn a companion for this", "have an agent supervise X". Not for a domain a dedicated companion already covers, a one-shot question, or work with no durable record.'
disableModelInvocation: true
argumentHint: '[domain and scope to supervise] [optional: tier or model]'
references:
  - ../references/agent/agent-companion.md
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/mode-toggle.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-roster.md
  - ../references/agent/agent-watchers.md
  - ../references/agent/agent-target-capability.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: whatever the domain's objects are, they carry their title and a markdown link to their URL where one exists, per `identifier-legibility`.

## Context

The generic entry point to the companion shape: one named subagent that lives for a whole section of work, owns a domain, and is steered by message. Use it when a domain needs standing project-management supervision and **no dedicated companion skill covers it**.

`linear-companion`, `git-companion` and `plan-companion` are the three domains that earned their own skill. This one handles everything else — and, first, decides whether the request is a companion at all.

The lifecycle itself is the `agent-companion` reference: the split test, tier selection, the spawn shape, the brief contract, steering, collection, the roster row, and user-gated retirement. This skill adds the fit test and the domain definition the dedicated skills get for free.

Posture: `present-first`.
Invoking this skill IS a standing blessing to run the fit test, define the domain, and spawn the companion once the domain is agreed. **Talking to it costs nothing and gates nothing.** What gates is the domain's durable record: writes are presented before they land, unless the user gives a standing preapproval.

State that spans turns must be written durably per `long-running-work` — the companion's name and spawn id, its domain, its tier, and the open ledger do not survive a compaction on their own.

Reconcile drift per `reconcile-state`.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/agent-companion`, "spawn a companion for this", "have an agent supervise X", "keep something on top of X while I work".
- **Off:** the user says the companion is no longer needed, or the section closes out **and the user confirms**. Never off on your own judgment.
- **Survives disengage:** every write already applied, every armed watcher, and anything the companion reported that you have not yet acted on.
- Layers under any other posture, and composes with the dedicated companions — one per domain, never two on one record.

## Step One: does this fit?

**Run this before proposing anything, and say the verdict out loud.** A companion is an expensive shape — it holds a runtime slot for the whole section and it cannot be reaped without the user — so the wrong domain costs more than it returns.

Five conditions. **All five must hold.**

| # | Condition | Why it is required |
|---|---|---|
| 1 | **A durable record exists outside the session** — a tracker, a platform, a file, a live system it can query. | The companion re-reads that record before every claim. With none, it can only remember, and a companion that remembers is a cache with no invalidation. This is the hard one. |
| 2 | **The domain holds judgment the record does not** — ordering, relations, why a decision was made, what was rejected. | If the record holds everything, a one-shot delegate handed the record's path is cheaper and gives a fresher answer. |
| 3 | **The work spans a section**, many turns and many events. | Accumulation needs time. A single question accumulates nothing. |
| 4 | **You generate events it needs to hear.** | A companion you never report to is a query you could have run yourself. |
| 5 | **The work is reading, judging, and recording** — not building, merging, or deploying. | Companions never perform the irreversible act. A domain whose whole job is doing belongs to a delegate or a coordinator. |

### Rejecting — name the failed condition and the better tool

**If any condition fails, say so plainly in a sentence, name which one, point at what to use instead, and stop.** Do not spawn a companion "anyway" with a caveat; do not silently downgrade the request into a delegate without saying so. The user asked for a specific shape and deserves to know it does not fit.

| The request | Fails | Say instead |
|---|---|---|
| "Be a companion for this conversation" / hold context with no external store | 1 | There is nothing for it to re-read, so it would only mirror what you already told it and go stale silently. Nothing to route to — this is what the session itself is for. |
| "Have a companion review my diffs as they land" | 2, 5 | Reviewing wants fresh eyes; accumulated context anchors a reviewer onto the design it already believes. Use `code-review-changes`, or the platform's own review skill, one pass per diff. |
| "Spawn a companion to answer this one question" | 3 | One question is one dispatch. Use `agent-delegate`, and pick the tier there. |
| "A companion to watch for the deploy to finish" | 3, 4 | Waiting on an external condition is a watcher, not an agent. Use `agent-background`, with the discipline in `agent-watchers`. |
| "A companion to implement the backlog" | 5 | Building is a different shape. Use `agent-coordinator` to route it, or `agent-plan` for a dependency-scheduled run. |
| "A companion for my Linear project" / "for these MRs" / "for this plan" | none — it fits | Route to the dedicated skill: `linear-companion`, `git-companion`, or `plan-companion`. They carry the domain's absolutes, which this skill does not know. |

**A domain that fits but has no dedicated skill is the case this skill exists for.** Say that too — a clean fit deserves a stated verdict as much as a rejection does.

**Two or three of these fitting well and recurring is a signal to author a dedicated skill**, the way the first three were. Raise it; do not build it mid-flow.

## Step Two: define the domain

The dedicated skills hardcode this. Here you establish it with the user, and it goes in the brief verbatim. Present it before spawning.

1. **The domain, in one line** — what the companion owns.
2. **The durable record and how to reach it** — the exact server, path, ids, or query. This is what it re-reads, so a vague answer here produces a companion that guesses.
3. **The scope line** — what is in, and what is explicitly outside.
4. **The boundary** — what it must never touch. Every domain has at least one: the irreversible act, and any record another companion owns. **Name the irreversible acts explicitly**; a companion with no stated boundary will eventually take one.
5. **The working skills and servers** it should load, by name — including that a manual-only skill named here is authorised by being named.
6. **What "the ledger" looks like** for this domain — the table shape you want its state reported in, so its answers are scannable rather than prose.
7. **Its peers, if any companion is already running** — each address with the one line on what that peer owns, so the two can correlate directly where the runtime supports it. A companion cannot discover a peer, so an address omitted here is a peer that does not exist as far as it is concerned. Peer traffic rules per the `agent-companion` reference.

## Process

1. **Run the fit test** and state the verdict. Reject and stop if any condition fails.
2. **Define the domain** with the user, per step two, and present it.
3. **Pick the tier and spawn**, per the `agent-companion` reference. With no dedicated skill's signal table to lean on, judge it from the domain: a flat scope with few objects and no sequencing is `cheap` with a stated reason, an ordinary section is `default`, and cross-cutting dependencies or a scope the user is actively reshaping is `smart`. Name it `<domain>-<scope-slug>`.
4. **Write the brief** with the reference's contract, filled in from step two — including the re-read rule and the observed/reported labels, which matter more here than anywhere, because a domain with no dedicated skill has no other guardrail.
5. **Arm the watchers yourself.** If the domain has conditions that change without anyone telling the companion — and most do — every watcher is yours, through the `agent-background` skill with the discipline in `agent-watchers`. A wake is re-verified on the main loop and then relayed as one message.
6. **Report to it as work lands**, and **collect, present, release** — both per the reference.
7. **Report the companion every turn** the section is open, and **retire it only on the user's word**, collecting once more and writing the final read into the domain's record before it goes.

## Example

**Trigger:** "/agent-companion keep something on top of the cluster while I do this rollout"

1. Fit test, stated: passes all five. The record is live cluster state reachable through the ArgoCD and Kubernetes servers (1); what is not in it is which alerts are known-noisy here and what healthy looked like before this rollout (2); a rollout spans hours (3); every merge and sync is an event (4); it reads and judges while the applying stays with the user (5). No dedicated skill covers it, so this one is right.
2. Domain defined and presented: the applications in the rollout's project; the record is the ArgoCD app tree plus the workload namespaces; out of scope is every other project in the cluster; boundary is that it never syncs, never rolls back, never scales, and never edits the tracker; working skills are the estate's own read skills; the ledger is one row per application with sync state, health, and what it is waiting on.
3. Tier stated: smart — sync waves with cross-application ordering. Spawned as `estate-argocd-rollout`.
4. Merge lands, watcher on the sync fires, re-verified, reported to the companion in one message.
5. It answers: two apps converged, one degraded on a pre-existing alert it recognises as noisy, one still waiting on its predecessor's wave. That third judgment is the one no query would have produced.
6. Rollout finishes. Asked whether to retire it; the user says yes. Collected its final read of what was noisy, recorded it, reaped it, said it is gone.

**Result:** the rollout was supervised without the lead holding cluster state, and the noise-versus-signal judgment survived the whole section.

## Key Principles

- **The fit test runs first and its verdict is spoken.** A clean fit gets stated as plainly as a rejection.
- **Rejecting is a sentence and a better tool, not a lecture.** Name the failed condition, point at what to use, stop.
- **No durable record, no companion.** That is the condition most often argued around, and the one whose failure is silent.
- **The domain definition is the whole difference** between this and a dedicated skill. Vague in, guessing out.
- **Name the irreversible acts explicitly.** A companion with no stated boundary eventually takes one.
- **Watchers are yours.** A wake fired inside a detached agent never reaches the session.
- **A shape you reach for repeatedly deserves its own skill.** Raise it; do not build it mid-flow.

## Related Skills

- **`linear-companion`**, **`git-companion`**, **`plan-companion`** — the three domains with dedicated skills. Route to them rather than defining those domains by hand; they carry absolutes this skill does not know.
- **`agent-delegate`** — one task, one agent, thrown away when it returns. The shape a failed condition 3 usually wants.
- **`agent-background`** — arms every watcher a companion depends on, and the right answer when the request is really a wait.
- **`agent-coordinator`**, **`agent-plan`** — where building goes when condition 5 fails.
- **`agent-supervisor`** — you hold the supervision layer in your own context instead of delegating it. Pick that when the judgment is what you want in front of you.
- **`config-skills`** — for authoring the dedicated skill once a domain proves recurrent.
