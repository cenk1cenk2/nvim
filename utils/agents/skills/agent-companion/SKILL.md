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

The lifecycle is the `agent-companion` reference. This skill adds the fit test and the domain definition the dedicated skills get for free.

Posture: `present-first`. Invoking this skill is the standing blessing to run the fit test, define the domain, and spawn once the domain is agreed; the gate is the record, per `agent-companion`.

State that spans turns must be written durably per `long-running-work` — the companion's name and spawn id, its domain, its tier, and the open ledger. Reconcile drift per `reconcile-state`.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/agent-companion`, "spawn a companion for this", "have an agent supervise X", "keep something on top of X while I work".
- **Off:** the user says the companion is no longer needed, or the section closes out **and the user confirms**. Never off on your own judgment.
- **Survives disengage:** every write already applied, every armed watcher, and anything the companion reported that you have not yet acted on.
- Layers under any other posture, and composes with the dedicated companions — one per domain, never two on one record.

## Step One: does this fit?

**Run this before proposing anything, and say the verdict out loud.** A companion holds a runtime slot for the whole section and cannot be reaped without the user, so a wrong domain costs more than it returns.

**All four must hold.**

| # | Condition | Why it is required |
|---|---|---|
| 0 | **The runtime can message a live agent across turns.** | Where dispatch is blocking and leaves nothing to address, there is no companion to steer — it answers once and vanishes while you keep talking to a dead name. Confirm in `agent-delegate-harness-<provider>`. |
| 1 | **A durable record exists outside the session** — a tracker, a platform, a file, a live system it can query. | The companion re-reads that record before every claim. With none it can only remember, and a companion that remembers is a cache with no invalidation. |
| 2 | **The domain holds judgment the record does not** — ordering, relations, why a decision was made, what was rejected. | If the record holds everything, a one-shot delegate handed the record's path is cheaper and gives a fresher answer. |
| 3 | **A stream of events over many turns** — the work spans a section, and you generate news it needs. | Accumulation needs time and input. A companion you never report to is a query you could have run yourself. |

**The boundary is not a condition.** Every companion reads, judges and records rather than building, merging or deploying — that is defined per domain in step two, not tested here. A domain whose *work* is building still fits; the building simply goes to `agent-coordinator` beside it.

### Rejecting — name the failed condition and the better tool

**If a condition fails, say so plainly in a sentence, name which one, point at what to use instead, and stop.** Do not spawn "anyway" with a caveat, and do not silently downgrade to a delegate without saying so.

| The request | Fails | Say instead |
|---|---|---|
| Any of this on a runtime with no cross-turn agent channel | 0 | The runtime cannot hold a steerable agent. Use `agent-supervisor` — the same job, held in your own context. |
| "Be a companion for this conversation" / hold context with no external store | 1 | Nothing for it to re-read, so it would mirror what you told it and go stale silently. Nothing to route to — that is what the session is for. |
| "Have a companion review my diffs as they land" | 2 | Reviewing wants fresh eyes; accumulated context anchors a reviewer onto the design it already believes. Use `code-review-changes`, one pass per diff. |
| "Spawn a companion to answer this one question" | 3 | One question is one dispatch. Use `agent-delegate`, and pick the tier there. |
| "A companion to watch for the deploy to finish" | 3 | Waiting on an external condition is a watcher, not an agent. Use `agent-background`, with the discipline in `agent-watchers`. |
| "A companion to manage the backlog while I build it" | none — it fits | Spawn it, and route the building to `agent-coordinator` beside it. The domain fits; only the verb was wrong. |
| "A companion for my Linear project" / "for these MRs" / "for this plan" | none — it fits | Route to `linear-companion`, `git-companion`, or `plan-companion`. They carry the domain's absolutes, which this skill does not know. |

**A clean fit gets a stated verdict too**, not just a rejection.

**Two or three fits of the same shape recurring is the signal to author a dedicated skill**, the way the first three were. Raise it; do not build it mid-flow.

## Step Two: define the domain

The dedicated skills hardcode this. Here you establish it with the user, and it goes into the brief verbatim. Present it before spawning.

1. **The domain, in one line** — what the companion owns.
2. **The durable record and how to reach it** — the exact server, path, ids, or query. This is what it re-reads, so a vague answer produces a companion that guesses.
3. **The scope line** — what is in, and what is explicitly outside.
4. **The boundary** — what it must never touch. **Name the irreversible acts explicitly**, plus any record another companion owns; a companion with no stated boundary eventually takes one.
5. **The working skills and servers** it should load, by name — including that a manual-only skill named here is authorised by being named.
6. **The ledger's columns** for this domain, on top of the four in `agent-companion`.

## Process

1. **Run the fit test** and state the verdict. Reject and stop on a failed condition.
2. **Define the domain** per step two, and present it.
3. **Pick the tier and spawn**, per the reference. With no dedicated signal table to lean on:

   | Signal | Tier |
   |---|---|
   | Flat scope, few objects, no sequencing | `cheap` |
   | An ordinary section | `default` |
   | Cross-cutting dependencies, or a scope the user is actively reshaping | `smart` |

   Name it `<domain>-<scope-slug>`.
4. **Write the brief** with the reference's contract, filled in from step two — including the re-read rule, the observed/reported labels, and the filing duty. These matter more here than anywhere, because a domain with no dedicated skill has no other guardrail.
5. **Arm the watchers yourself**, per the reference. Most domains have conditions that change without anyone telling the companion.
6. **Report to it as work lands**, and **collect, present, release** — both per the reference.
7. **Report one roster row every turn** the section is open, and **retire only on the user's word**.

## Example

**Trigger:** "/agent-companion keep something on top of the cluster while I do this rollout"

1. Fit test, stated: passes all four. The runtime holds steerable agents (0); the record is live cluster state through the ArgoCD and Kubernetes servers (1); what is not in it is which alerts are known-noisy here and what healthy looked like before this rollout (2); a rollout spans hours and every merge and sync is news (3). No dedicated skill covers it.
2. Domain presented: the applications in the rollout's project; record is the ArgoCD app tree plus the workload namespaces; out of scope is every other project; boundary is that it never syncs, never rolls back, never scales, never edits the tracker; working skills are the estate's read skills; ledger adds sync state and health.
3. Tier stated: smart — sync waves with cross-application ordering. Spawned as `estate-argocd-rollout`, read tools allowlisted first.
4. Merge lands, the sync watcher fires, re-verified, reported in one message.
5. It answers: two apps converged (observed, quoting each `syncedAt`), one degraded on an alert it recognises as pre-existing noise, one waiting on its predecessor's wave. It files the noise judgment as a comment on the rollout issue rather than holding it.
6. Rollout finishes. Asked whether to retire it; the user says yes. Final collection is a short delta because the judgment was already filed. Reaped, and said so.

**Result:** the rollout was supervised without the lead holding cluster state, and the noise-versus-signal judgment outlived the agent.

## Key Principles

- **The fit test runs first and its verdict is spoken.** A clean fit is stated as plainly as a rejection.
- **Rejecting is a sentence and a better tool, not a lecture.**
- **Condition 0 is the one that invalidates everything** — no cross-turn agent channel, no companion.
- **No durable record, no companion.** The condition most often argued around, and the one whose failure is silent.
- **The domain definition is the whole difference** between this and a dedicated skill. Vague in, guessing out.
- **A shape you reach for repeatedly deserves its own skill.** Raise it; do not build it mid-flow.

## Related Skills

- **`linear-companion`**, **`git-companion`**, **`plan-companion`** — the three domains with dedicated skills. Route to them rather than defining those domains by hand.
- **`agent-supervisor`** — the same job held in your own context. The fallback when condition 0 fails, and the right pick when the judgment is what you want in front of you.
- **`agent-delegate`** — one task, one agent, reaped on return. What a failed condition 3 usually wants.
- **`agent-background`** — arms every watcher a companion depends on, and the answer when the request is really a wait.
- **`agent-coordinator`**, **`agent-plan`** — where the building goes, beside the companion rather than inside it.
- **`config-skills`** — for authoring the dedicated skill once a domain proves recurrent.
