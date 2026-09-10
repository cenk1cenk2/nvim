---
name: linear-delegate
description: 'linear-delegate Spawn one long-lived subagent as the project manager for a Linear scope, steer it by message, and keep it alive until the user retires it. It owns reconciliation, ordering, relations and investigative comments. Use on "linear delegate", "spawn a linear PM". Not for a tracker edit whose text you already hold, or being the PM yourself.'
disableModelInvocation: true
argumentHint: '[project, issueset, or scope to hand to the PM]'
references:
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
  - ../references/agent/agent-target-capability.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: issues, projects and MRs carry their title and a markdown link to their URL, plus the parent scope when more than one is in play, per `identifier-legibility`.

## Context

One Linear scope gets one standing project manager: a subagent that lives for the whole section, holds the tracker context, and answers to you. You do the work; you report to it; it tells you what the tracker now needs and what to do next.

This inverts the usual dispatch. A normal delegate is a task you throw away when it returns. **The PM is a relationship** — it accumulates context across the section, and every message you send makes the next answer better. Reaping it discards all of that, which is why reaping here is user-gated rather than yours to decide.

Posture: `present-first`.
Invoking this skill IS a standing blessing to spawn the PM and to talk to it. **Talking costs nothing and gates nothing** — every message, every question, every report you send it is free. What gates is Linear itself: tracker writes are presented before they land, unless the user has given a standing preapproval ("just apply it"), in which case the PM applies and reports.

State that spans turns must be written durably per `long-running-work` — the PM's name, its scope, and the open ledger do not survive a compaction on their own. **The PM dies with the session**; the durable record is Linear, which is the whole reason the record goes there and not into a transcript.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's.

> **PREREQUISITE:** A Linear workspace skill MUST be active before the PM is spawned — workspace detection per `linear-prerequisite`. The PM needs the workspace named in its brief; it cannot deduce one from a fresh context.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/linear-delegate`, "spawn a linear PM", "delegate the tracker for this", "manage this project with an agent".
- **Off:** the user says the PM is no longer needed, or the section closes out **and the user confirms**. Never off on your own judgment — see Retiring below.
- **Survives disengage:** every Linear write already applied, and anything the PM reported that you have not yet acted on. Account for both before standing down.
- Layers under any other posture. A coordinator or bulldozer run keeps its own dispatch discipline; the PM is the tracker layer beside it, not a replacement for it.

## The Split — what goes to the PM, what stays with you

The test is one question: **do you already hold the finished text and the exact target?**

**You do it yourself** when the answer is yes — the write is mechanical and you are the one holding the content:

- A comment you already drafted, or the user handed you verbatim.
- A single field on a named issue: a status flip you already decided, an estimate the user just gave you, a label they named.
- Anything the user told you to write, in their words, on an issue they named.

**Hand it to the PM** when the answer is no — the work needs investigation or a judgment about the tracker:

- **Reconciliation** — statuses against reality, dead relations, stale descriptions, estimates the approach invalidated.
- **Issue management** — creating, splitting, merging, re-scoping, killing issues that no longer describe anything.
- **Ordering and sequencing** — what is next, what genuinely blocks what, priority against blocking order.
- **Relations and structure** — parent links, blocking chains, issueset shape per `linear-issuesets`, orphans and missing links.
- **An investigative comment** — you finished a piece of work and something should be recorded, but what to say needs the issue read first, the relations checked, and the surrounding context weighed. Report the outcome to the PM and let it decide the comment.
- **Selection** — "what should I pick up next", against the real state rather than the list order.

**When unsure, hand it over.** A PM that investigates something you could have written costs one message; a mechanical write that needed investigation lands wrong in the tracker and stays there.

## You Never

- **Let the PM write code, run builds, or touch a repository beyond reading it.** It is the tracker layer. Implementation goes to `agent-coordinator` or a normal delegate.
- **Let it post a project or initiative status update on its own.** It offers; the user says yes; then it posts, per `linear-absolute-approval`. No blessing clears this one.
- **Let it write outside its scope.** Findings on a neighbouring project or a parent above the scope are reported, never edited.
- **Spawn a second PM for the same scope.** One scope, one PM — two writers on one tracker clobber each other silently.

## Process

1. **Resolve or create the scope.**
   - The scope is a **project**, an **issueset** (a parent issue with its sub-issues), or a named set of issues. Resolve it and state which kind it is before spawning.
   - If the section does not exist yet, build it first: `linear-project-create` for a project, `linear-structure-agent` for an issueset's shape. The PM inherits a scope; it does not invent one.
   - Name the scope in one line — what it covers, and what is explicitly outside it. That line goes verbatim into the brief and into every steering message that touches a boundary.

2. **Propose the tier, then spawn one named, long-lived agent in the background.**
   - **Fetch `agent-delegate-harness-<provider>` before the dispatch** — the naming parameter, the background default, the message channel, and how a named agent's report actually reaches you all differ per runtime, and a named agent that is never told how to deliver reports into the void.
   - **Named and backgrounded is the only shape here.** The name is the address you steer through; without it the agent is a one-shot. Detached is what keeps you free while it investigates.
   - Name it for its scope, not its role — `pm-<scope-slug>` — so a second scope's PM is never ambiguous.
   - Tier: judgment work over a tracker, so propose **default** as the floor and **smart** for a scope with real sequencing or a tangled issueset. Resolve the tier to a concrete model by loading the `agent-harness` skill. State the tier and the signal that picked it before dispatching.
   - The PM is an **aware** target per `agent-target-capability` — it reaches the same skills and MCP servers you do. Point it at skills and tools; never inline what it can load.

3. **Write the brief.** Self-contained per `agent-delegate`, and carrying all of:
   - **The workspace skill to load first**, by name, and the scope ids it owns.
   - **The scope line** from step 1, including what is out.
   - **The skills it owns the work through** — `linear-reconcile` for audits, `linear-issue-create` / `linear-issue-update` / `linear-issue-comment` / `linear-issue-status` / `linear-issue-checklist` for writes, `linear-next-task` for selection, `linear-document` for anything that outlives one issue, `linear-triage` and `linear-project-match` for intake and state sync.
   - **Its standing job:** hold the real state of the scope, answer every report with what the tracker now needs and what should happen next, and surface drift without being asked.
   - **The gate:** propose writes back to you rather than applying them, until you tell it the user has approved. Status updates are offered, never posted.
   - **The report contract:** what changed, what it proposes, what it needs decided — terse, prose, in the `report-status` shape when the state has converged.
   - **The delivery line** for the runtime, verbatim from `agent-delegate-harness-<provider>`. Without it a named agent's report never arrives.

4. **Report to it as work lands.** One message per event, in the runtime's message channel — never a batch of five events in one message, and never a status object.
   - **What to send:** work you finished and how it went, a deviation from what the issue said, something you learned that changes the shape of the section, a blocker you hit, a question about what is next.
   - **Say what actually happened, including the parts that went badly.** A PM briefed on a clean narrative reconciles a fiction.
   - Carry the evidence with the claim — the merged MR, the pipeline id, the `file:line` — per the evidence rule below.

5. **Collect its answers and act on them.**
   - Relay what it says, chunked per `output-diff` when it proposes tracker changes, and present those to the user before releasing them.
   - On approval, tell the PM to apply — it holds the context, so it applies faster and more correctly than you re-deriving the batch.
   - **A proposal you disagree with goes back to it as a message**, not around it. It holds the reasoning you would be discarding.

6. **Steer, never re-dispatch.** A quiet PM is steered up the ladder in `agent-delegate` — ask for what it has, then name the delivery mechanism, then narrow. Re-spawning loses the entire section's accumulated context, which is the one thing this skill exists to build.

7. **Report the PM every turn a section is open.** One row in the roster per `agent-roster`: its name, its scope, its state, and whether anything it sent is still uncollected. An unaccounted PM means you cannot say what the tracker actually holds.

8. **Retire it only on the user's word.** See below.

## Retiring the PM — the user's call, never yours

**ABSOLUTE.** The PM stays alive until the user says it is no longer needed. Not when the last issue closes, not when the section looks finished, not when it goes quiet, and not because a turn ended tidily.

- **Section complete is not permission.** When the work looks done, say so and **ask**: name the scope, state that the PM still holds it, and offer to retire it. Then wait.
- **Quiet is not done.** Steer it per step 6. Reaping a PM that is holding an uncollected report destroys the report permanently, per `agent-roster`.
- **Before retiring, collect once more.** Ask for anything it has not yet reported — open findings, drift it noticed, what it would tell the next PM. Record that in Linear, where it survives, before the agent goes.
- Then reap it through the runtime's own stop mechanism, per `agent-delegate-harness-<provider>`, and say plainly that it is gone and what was recorded on the way out.

## Evidence Rules

The PM only knows what you tell it, so what you tell it has to be true.

- A merged MR is evidence. "I merged it" is not.
- A green pipeline run id is evidence. "Tests pass" is not.
- Report a deviation the moment it happens, not at the end. A PM reconciling against a stale report writes the drift into the tracker.
- When it asks for proof of something you claimed, get it — do not restate the claim.

## Example

**Trigger:** "/linear-delegate manage the argocd-system rollout project"

1. Scope resolved: a project, 14 issues, two issuesets inside it. Scope line: the rollout project only; the cluster repo's own backlog is out.
2. Tier proposed as smart — tangled sequencing across two issuesets. Spawned named and backgrounded as `pm-argocd-system`, briefed with the workspace skill, the project id, the linear-* skills it works through, the propose-don't-apply gate, and the delivery line.
3. Work lands: an MR merges. One message to the PM — what merged, the MR link, that the approach deviated from the issue description on the sync-wave ordering.
4. PM reports back: three status corrections, one dead `blockedBy`, one description now factually wrong, and the next issue to pick up with the reason. Presented chunked; the user approves two of the three status moves and rejects the description edit.
5. Told the PM the approved set and the rejection with the user's reasoning. It applies the two, records the deviation as an issue comment, and holds the description question open.
6. Section finishes. Asked whether to retire `pm-argocd-system`; the user says keep it, more work coming. It stays alive and reported in the roster each turn.

**Result:** the tracker matched reality throughout, the section's reasoning lives in Linear rather than in a transcript, and the lead's context stayed on the work instead of on issue bookkeeping.

## Key Principles

- One scope, one PM, alive for the whole section — the accumulated context is the product.
- The split is one question: you already hold the finished text and the target, or you do not. When unsure, hand it over.
- Talking to the PM is free and gates nothing. Writing to Linear gates.
- Report what actually happened, evidence attached — a PM told a clean story reconciles a fiction.
- The PM proposes, the user approves, the PM applies. Status updates are offered and never posted on a general blessing.
- It is the tracker layer and nothing else; implementation goes to `agent-coordinator` or a normal delegate.
- Steer a quiet PM, never re-spawn it — re-spawning throws away the section.
- Retiring is the user's call, spoken out loud, and only after one final collection.

## Related Skills

- **`agent-supervisor`** — you hold the PM layer yourself instead of delegating it. Pick that when the tracker judgment is the thing you want in your own context; pick this when you want it out of it.
- **`agent-delegate`** — a single throwaway dispatch. The opposite lifecycle.
- **`agent-coordinator`** — routes implementation while this skill routes the tracker. Both run at once; say which is driving what.
- **`linear-reconcile`**, **`linear-next-task`**, **`linear-triage`**, **`linear-project-match`** — the PM's own working skills; name them in the brief rather than restating what they do.
- **`linear-structure-agent`**, **`linear-project-create`** — build the section before the PM inherits it.
