---
name: linear-companion
description: 'linear-companion Spawn one long-lived subagent as the standing project manager for a Linear scope and steer it by message until the user retires it. Use on "linear companion", "spawn a linear PM", "have an agent hold the tracker". Not for a tracker edit whose text you already hold, or being the PM yourself.'
disableModelInvocation: true
argumentHint: '[project, issueset, or scope] [optional: tier or model]'
references:
  - ../references/agent/agent-companion.md
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/mode-toggle.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-issuesets.md
  - ../references/linear/linear-absolute-approval.md
  - ../references/linear/linear-state-transitions.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-roster.md
  - ../references/agent/agent-watchers.md
  - ../references/agent/agent-target-capability.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: issues, projects and MRs carry their title and a markdown link to their URL, plus the parent scope when more than one is in play, per `identifier-legibility`.

## Context

One Linear scope gets one standing project manager: a subagent that lives for the whole section, holds the tracker context, and answers to you. You do the work; you report to it; it tells you what the tracker now needs and what to do next.

The whole lifecycle — the split test, tier selection, the spawn shape, the brief, steering, collection, the roster row, and the user-gated retirement — is `agent-companion`. This skill supplies the Linear domain on top of it.

Posture: `present-first`. Invoking this skill is the standing blessing to spawn the PM and to talk to it; the gate is Linear, per `agent-companion`.

State that spans turns must be written durably per `long-running-work` — the PM's name and spawn id, its scope, its tier, the armed watchers, and the open ledger. Reconcile drift per `reconcile-state`.

> **PREREQUISITE:** A Linear workspace skill MUST be active before the PM is spawned — workspace detection per `linear-prerequisite`. The PM needs the workspace named in its brief; it cannot deduce one from a fresh context.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/linear-companion`, "spawn a linear PM", "companion the tracker for this", "manage this project with an agent".
- **Off:** the user says the PM is no longer needed, or the section closes out **and the user confirms**. Never off on your own judgment.
- **Survives disengage:** every Linear write already applied, and anything the PM reported that you have not yet acted on. Account for both before standing down.
- Layers under any other posture. A coordinator or bulldozer run keeps its own dispatch discipline; the PM is the tracker layer beside it, not a replacement for it.

## The Split, in Linear terms

The test is `agent-companion`'s: do you already hold the finished text and the exact target?

**You write it yourself:**

- A comment you already drafted, or the user handed you verbatim.
- A single field on a named issue — a status flip you already decided, an estimate the user just gave you, a label they named.

**The PM takes it:**

- **Reconciliation** — statuses against reality, dead relations, stale descriptions, estimates the approach invalidated.
- **Issue management** — creating, splitting, merging, re-scoping, killing issues that no longer describe anything.
- **Ordering and sequencing** — what is next, what genuinely blocks what, priority against blocking order.
- **Relations and structure** — parent links, blocking chains, issueset shape per `linear-issuesets`, orphans and missing links.
- **An investigative comment** — you finished a piece of work and something should be recorded, but what to say needs the issue read first and the surrounding context weighed. Report the outcome; let the PM decide the comment.
- **Selection** — what to pick up next, against the real state rather than the list order.

## The PM Never

- **Writes code, runs builds, or touches a repository beyond reading it.** It is the tracker layer. Implementation goes to `agent-coordinator` or a normal delegate.
- **Posts a project or initiative status update on its own.** It offers; the user says yes; then it posts, per `linear-absolute-approval`. **No blessing clears this one**, including a standing preapproval that covers every other write.
- **Touches an MR or PR** — description, title, threads, merge state. That record is `git-companion`'s, and its trailers move Linear state on merge.
- **Writes outside its scope.** Findings on a neighbouring project or a parent above the scope are reported, never edited.

## Watchers

Watchers per `agent-companion` — you arm them, never the PM. **A PM who does not learn that something happened reconciles the tracker against a stale narrative**, which is the first failure a tracker layer exists to prevent. An in-flight issue whose MR or pipeline has no watcher is a gap, and the PM should name it.

## Process

1. **Resolve or create the scope.**
   - The scope is a **project**, an **issueset** (a parent issue with its sub-issues), or a named set of issues. Resolve it and state which kind it is before spawning.
   - If the section does not exist yet, build it first: load `linear-project-create` for a project, or `linear-structure-agent` for an issueset's shape. The PM inherits a scope; it does not invent one.
   - Name the scope in one line — what it covers, and what is explicitly outside it.

2. **Pick the tier and spawn**, per `agent-companion`. Linear-specific signals when the user named no tier:

   | Signal | Tier |
   |---|---|
   | Flat scope, under ~10 issues, no cross-issue sequencing | `cheap` |
   | A single project or issueset with ordinary dependencies | `default` |
   | Multiple issuesets, cross-cutting blocking chains, or a scope the user is actively re-shaping | `smart` |

   Name it `pm-<scope-slug>`.

3. **Write the brief** with the contract in `agent-companion`, filled in for Linear:
   - **The workspace skill to load first**, by name, and the scope ids it owns.
   - **The skills it works through** — `linear-reconcile` for audits, `linear-issue-create` / `linear-issue-update` / `linear-issue-comment` / `linear-issue-status` / `linear-issue-checklist` for writes, `linear-next-task` for selection, `linear-document` for anything that outlives one issue, `linear-triage` and `linear-project-match` for intake and state sync.
   - **The status-update absolute** from above, stated in the brief rather than assumed.
   - **The re-read rule** from `agent-companion`: it re-reads the issues before asserting any state, and labels every claim observed or reported, quoting what it read. A tracker answer from memory is the one thing that makes a PM worse than no PM.
   - State transitions follow `linear-state-transitions` — name it so the PM never downgrades a state.

4. **Report to it as work lands**, per `agent-companion`'s steering rules. In Linear terms that is: an MR merged, a piece of work finished, a deviation from what the issue said, a blocker, or a question about what is next.

5. **Collect, present, release.** Its proposals come back as a change ledger; present them chunked per `output-diff`, and on approval tell the PM to apply.

6. **Report the PM every turn the section is open**, and retire it only on the user's word — both per `agent-companion`. The final collection is written into Linear before the agent goes, because Linear is what survives the session.

## Example

**Trigger:** "/linear-companion manage the argocd-system rollout project"

1. Scope resolved: a project, 14 issues, two issuesets inside it. Scope line: the rollout project only; the cluster repo's own backlog is out.
2. No tier named, so stated: smart — two issuesets with cross-cutting sequencing. Spawned as `pm-argocd-system`, named and backgrounded, briefed with the workspace skill, the project id, the `linear-*` skills, the propose-don't-apply gate, the status-update absolute, and the delivery line.
3. An MR merges. One message to the PM: what merged, the MR link, and that the approach deviated from the issue description on the sync-wave ordering.
4. PM reports back: three status corrections, one dead `blockedBy`, one description now factually wrong, and the next issue to pick up with its reason. Presented chunked; the user approves two status moves and rejects the description edit.
5. Told the PM the approved set and the rejection with the user's reasoning. It applies the two, records the deviation as an issue comment, and holds the description question open.
6. Section finishes. Asked whether to retire `pm-argocd-system`; the user says keep it, more work coming. It stays alive and reported in the roster each turn.

**Result:** the tracker matched reality throughout, the section's reasoning lives in Linear rather than in a transcript, and the lead's context stayed on the work instead of on issue bookkeeping.

## Related Skills

- **`agent-supervisor`** — you hold the PM layer yourself instead of delegating it. Pick that when the tracker judgment is the thing you want in your own context; pick this when you want it out of it.
- **`agent-companion`** — the generic entry point, for a domain with no dedicated skill. It owns the fit test; this skill is the Linear instance.
- **`git-companion`**, **`plan-companion`** — the same shape over MRs and over a plan; one record each. Drift between them reaches each through you.
- **`agent-coordinator`** — routes implementation while this skill routes the tracker. Both run at once; say which is driving what.
- **`linear-reconcile`**, **`linear-next-task`**, **`linear-triage`**, **`linear-project-match`** — the PM's own working skills; name them in the brief rather than restating what they do.
- **`linear-structure-agent`**, **`linear-project-create`** — build the section before the PM inherits it.
- **`agent-background`** — arms every watcher this skill depends on. The mechanics live there; the duty to arm lives here.
