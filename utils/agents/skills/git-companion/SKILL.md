---
name: git-companion
description: 'git-companion Spawn one long-lived subagent as the standing shepherd for a set of open GitHub PRs or GitLab MRs and steer it by message until the user retires it. Use on "git companion", "spawn an MR shepherd", "have an agent watch my PRs". Not for one MR you are already fixing, a review of a single diff, or local git work.'
disableModelInvocation: true
argumentHint: '[repo, branch set, or MR/PR list] [optional: tier or model]'
references:
  - ../references/agent/agent-companion.md
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/mode-toggle.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/scm/scm-detect.md
  - ../references/scm/commit-trailers-linear.md
  - ../references/agent/agent-watchers.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-roster.md
  - ../references/agent/agent-target-capability.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

Never hand back a bare identifier: MRs, PRs, pipelines and branches carry their title and a markdown link to their URL, plus the repository when more than one is in play, per `identifier-legibility`.

## Context

A set of open merge requests gets one standing shepherd: a subagent that lives for the whole section, holds the state of every MR in scope, and answers to you. You push, you fix, you merge; you report each of those to it; it tells you which MR now needs what, and in what order.

The whole lifecycle — the split test, tier selection, the spawn shape, the brief, steering, collection, the roster row, and the user-gated retirement — is `agent-companion`. This skill supplies the SCM domain on top of it.

**What the companion is actually holding is the merge-order graph.** Which MR must land before which, which are stacked, which will conflict, which are blocked on a human and which on a machine. That graph is expensive to rebuild and cheap to keep current, which is the whole case for a standing agent over a fresh review each time.

Posture: `present-first`.
Invoking this skill IS a standing blessing to spawn the shepherd and to talk to it. **Talking costs nothing and gates nothing.** What gates is the platform: MR writes are presented before they land, unless the user has given a standing preapproval, in which case the companion applies and reports. Merging never falls under that — see below.

State that spans turns must be written durably per `long-running-work` — the companion's name and spawn id, its scope, its tier, and the live watcher set do not survive a compaction on their own.

Reconcile drift per `reconcile-state`.

> **PREREQUISITE:** Resolve the platform per `scm-detect` **before** the spawn, and name it in the brief. GitHub and GitLab have different tools and different skills, and a companion that has to guess wastes its first turns discovering what you already knew.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/git-companion`, "spawn an MR shepherd", "have an agent hold my open PRs", "who's blocking what across these MRs".
- **Off:** the user says the shepherd is no longer needed, or every MR in scope is merged or closed **and the user confirms**. Never off on your own judgment.
- **Survives disengage:** every platform write already applied, every armed watcher, and anything the companion reported that you have not yet acted on. Account for all three before standing down.
- Layers under any other posture. A coordinator run keeps its own dispatch discipline; the shepherd is the MR layer beside it.

## The Split, in SCM terms

The test is `agent-companion`'s: do you already hold the finished text and the exact target?

**You do it yourself:**

- Write code, push a branch, run the build. The companion never touches the working tree.
- Apply a fix you already know how to make, including one the companion diagnosed for you.
- Post a comment or a thread reply you already drafted.
- Merge. Always you, always with the user's word — see the absolute below.

**The companion takes it:**

- **Merge order** — what must land before what, across a stack or across repos, and which MR is now unblocked.
- **Review-thread triage** — which open threads are real change requests, which are questions you can answer in a sentence, which are already addressed by a later push and just need resolving.
- **CI diagnosis** — read the failing job, find the actual cause, and hand back the fix as a concrete instruction. It diagnoses; you apply.
- **Conflict and rebase calls** — whether an MR needs a rebase, against what, and whether a sibling MR is about to conflict with it.
- **Description drift** — the branch moved on and the description no longer describes it. It drafts the correction, subject to the linking-surface carve-out below.
- **Staleness** — an MR nobody has touched in weeks, a branch whose work landed elsewhere, a draft that should be undrafted or closed.
- **The status question** — "what is the state of my MRs", answered against the platform rather than against your memory of it.

## The Companion Never

> **ABSOLUTE — it never merges, never force-pushes, never closes an MR, and never touches a branch.** Those are irreversible or outward-facing, they belong to the lead under the user's explicit word per the central `AGENTS.md` gates, and **no standing preapproval clears them.** The companion recommends a merge and says why it is ready; the merge itself is a separate decision the user makes.

- **Writes no code and pushes nothing.** It reads diffs, it diagnoses, it drafts prose. Implementation goes to you, to `agent-coordinator`, or to a normal delegate.
- **Approves nothing.** An approval is a claim about review that the companion is not entitled to make on your account.
- **Writes outside its scope.** An MR in a repository the scope did not name is reported, never edited.
- **Edits the tracker.** That is `linear-companion`'s domain, and two companions writing the same record is exactly the silent-clobber case in `agent-companion`.

> **ABSOLUTE — the linking surfaces are not part of its description authority.** Body prose is its to draft. The **magic-word trailers in the description, the issue id in the title, and the branch name** are not, per `commit-trailers-linear`: those are what link and close a tracker issue on merge, so redrafting one moves tracker state from inside the wrong domain. A proposed change to any of them comes to you and routes through `linear-companion`. This is the one place the domains genuinely overlap, and it is invisible when it goes wrong — the description reads better and an issue silently stops closing.

## Watchers: the lead arms, the companion is told

**The companion is message-driven and cannot observe the platform changing.** A pipeline going green, an MR merging, a reviewer approving — none of that reaches a detached subagent, and it must not be the one arming loops either, because a wake fired inside a background agent never reaches you.

So the split is fixed:

1. **You arm every watcher**, through the `agent-background` skill, with the discipline in `agent-watchers` — one watcher per independent condition, armed the moment the condition opens.
2. **A wake is a report to the companion.** Re-verify authoritatively on the main loop first, then send one message saying what actually changed.
3. **The companion tells you what to arm next.** "That merged, so the stacked MR is now rebaseable — watch its pipeline" is exactly the answer this shape exists to produce.

An MR the companion is holding with no watcher on it is a gap: you will be reporting from memory instead of from events.

## Process

1. **Resolve the scope and the platform.**
   - The scope is a **repository's open MRs**, a **branch set** (a stack, a feature's MRs across repos), or a **named list**. Resolve it, list what is in it, and state what is outside.
   - Detect the platform per `scm-detect` and note the project path or `owner/repo`.

2. **Pick the tier and spawn**, per `agent-companion`. SCM-specific signals when the user named no tier:

   | Signal | Tier |
   |---|---|
   | One or two independent MRs in one repo | `cheap`, and say why |
   | A handful of MRs in one repo with ordinary review churn | `default` |
   | A stack, cross-repo ordering, or MRs that will conflict with each other | `smart` |

   Name it `mr-<scope-slug>`.

3. **Write the brief** with the contract in `agent-companion`, filled in for SCM:
   - **The platform**, the project path, the target branch, and the MR or PR ids in scope.
   - **The skills it works through** — the platform's read, review, and description skills (`gitlab-mr-read` / `gitlab-mr-review` / `gitlab-mr-create` / `gitlab-mr-comment` / `gitlab-ci-fix`, or the `github-pr-*` equivalents). Name only the platform's own set; the other platform's skills are noise in its context. Several are manual-only, and being named here is what authorises them — say so, or the companion declines to load them and fails silently.
   - **The never list** above, verbatim — above all that it never merges, never pushes, and never edits a linking surface.
   - **The re-read rule** from `agent-companion`: it re-reads the MRs before asserting their state, and labels every claim observed or reported. An MR's state changes without anyone telling it.

4. **Report to it as work lands**, per `agent-companion`'s steering rules: you pushed, a pipeline went green or red, a reviewer commented, an MR merged, you made a fix it suggested and it did or did not work. A wake burst that resolves one chain — a merge and the rebase it unblocked — is the causal group that shares a message.

5. **Collect, present, release.** Its answers come back as a per-MR ledger — the shape below. Present anything that writes to the platform chunked per `output-diff`.

6. **Report the companion and its watchers every turn**, per `agent-companion` and `agent-watchers`, and retire it only on the user's word. Before it goes, get its final read of the merge order and record it wherever the section's work lives — the tracker issue, the plan file — because the graph is the thing you cannot rebuild from the MRs alone.

## The MR Ledger

Ask for its state in this shape, so a report is scannable rather than a paragraph per MR:

| MR | Blocked on | Next action | Whose |
|---|---|---|---|
| [rustfs!315 — Revert the renovate kustomize bump](https://gitlab.example.com/cluster/workloads/rustfs/-/merge_requests/315) | nothing | ready to merge, pipeline green | user's call |
| [rustfs!319 — Point alerts at the new ruler](https://gitlab.example.com/cluster/workloads/ruler/-/merge_requests/319) | !315 | rebase after !315 lands | you |
| [ruler!320 — Drop the legacy ruler CRDs](https://gitlab.example.com/cluster/workloads/ruler/-/merge_requests/320) | 2 open threads | one real change, one answerable | you |

**Whose** is the column that makes it actionable — yours, the user's, or a reviewer's. An MR whose next action belongs to nobody is a stale MR, and that is a finding.

## Example

**Trigger:** "/git-companion the three ruler MRs"

1. Scope: three MRs across two repos, one stacked on another. Platform resolved as GitLab.
2. No tier named, so stated: smart — a stack plus cross-repo ordering. Spawned as `mr-ruler-rollout`, briefed with the platform, the project paths, the three ids, the `gitlab-mr-*` skills, the never-merge absolute, and that it is blind to events.
3. Armed three pipeline watchers and one merge watcher, one per condition.
4. A pipeline goes red. Re-verified on the main loop, then reported it to the companion with the job id. It reads the log and hands back a concrete cause and a one-line fix. Applied it, pushed, told the companion the push happened.
5. Green, then merged after the user said so. Reported the merge; the companion says the stacked MR is now rebaseable and its two open threads are one real change and one answerable question. Armed a watcher on the rebased pipeline.
6. All three land. Asked whether to retire `mr-ruler-rollout`; the user says yes. Collected its final merge-order read, recorded it on the tracker issue, reaped it, and reported that it is gone.

**Result:** three MRs landed in the right order, the CI diagnosis happened outside the lead's context, and no merge happened without the user saying so.

## Key Principles

- The companion holds the merge-order graph; that graph is the product, and every MR state it quotes is re-read rather than remembered.
- It diagnoses, drafts and orders. You write, push, and merge.
- **It never merges, force-pushes, closes, or touches a branch** — no preapproval clears that.
- **It never edits a linking surface** — trailers, the title's issue id, the branch name. Those move tracker state on merge.
- It is blind to events: every watcher is yours to arm, and every wake is a message to it.
- One scope, one companion. It does not cross into the tracker — that is `linear-companion`.
- Ask for the ledger, not a narrative. The **whose** column is what makes it actionable.

## Related Skills

- **`agent-companion`** — the generic entry point, for a domain with no dedicated skill. It owns the fit test; this skill is the platform instance.
- **`linear-companion`** — the same shape over the tracker. Run both; the PM holds the issues, the shepherd holds the MRs, and drift between them reaches each through you.
- **`plan-companion`** — the same shape over a plan's design.
- **`agent-background`** — arms every watcher this skill depends on. The mechanics live there; the duty to arm lives here.
- **`gitlab-mr-review`** / **`github-pr-review`** — a real review pass on one diff. Fresh eyes beat accumulated context for reviewing, so run these rather than asking the companion to review.
- **`gitlab-mr-fix`** / **`github-pr-fix`** — apply thread changes. The companion triages the threads; this skill does the work.
- **`agent-coordinator`** — routes the implementation the companion says is needed.
- **`git-commit`**, **`git-push`**, **`git-branch`**, **`git-conflict`** — local git, and none of it is the companion's. It reasons about the platform's view of your branches; the working tree is always yours.
