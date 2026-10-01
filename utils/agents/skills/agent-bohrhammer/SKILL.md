---
name: agent-bohrhammer
description: agent-bohrhammer End-to-end delivery posture - agree the goal and its checkpoints, then drive it to merge-ready PRs/MRs through coordinated agents, stacked where dependencies demand, stopping at every checkpoint for a blessing. Use on "bohrhammer". Not for a single change, pure tracker work, or a push with no checkpoints.
disableModelInvocation: true
argumentHint: '[goal] [scope: project, issueset, issue, or none] [checkpoint]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/mode-toggle.md
  - ../references/output-diff.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/delivery-decisions.md
  - ../references/agent/agent-companion-offload.md
  - ../references/agent/agent-watchers.md
  - ../references/agent/agent-roster.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link, per `identifier-legibility`.

## Toggle

State that spans turns is written durably per `long-running-work`. On/off mechanics per `mode-toggle`.

- **On:** `/agent-bohrhammer`, "bohrhammer".
- **Off:** "stop the bohrhammer", "normal mode", any park signal, or the last agreed checkpoint reached and reported.
- **Survives disengage:** open PRs/MRs, tracker writes, and the state file. Watchers, agents and companions come down with the park, companions on the user's word.

## Context

The bohrhammer takes a goal from agreement to merge-ready PRs/MRs, up to a point the user names. It composes the other postures rather than replacing them, and you stay on top of all of it yourself; delegation spends agents, never your grip on the state.

The user sets the pace. A blessing covers the stretch up to the next checkpoint, nothing further. **Inside a blessed stretch the bohrhammer owns the rhythm**: the composed postures' wait-for-the-user points collapse into the checkpoints, so dispatch, verify and advance without pausing per step. Their gates on external writes and destructive actions still hold. `agent-bulldozer` stays off unless the user engages it. Eagerness past a checkpoint is the failure.

## Process

1. **Take the blessing.** The user names the vehicle: adopt or create a Linear project, an issueset, a single issue, or no tracker at all. Linear is optional. When it is used, shape it through `linear-structure-agent`, and load `agent-supervisor` to keep the record.
2. **Understand before building.** Anything not fully understood gets investigated and discussed, never figured out along the way. Present the approach, the PR/MR breakdown, the stacking and the checkpoints in chunks per `output-diff`, and finalize them with the user. For a genuinely complicated design, run `plan-hard` in auto mode with yourself and hand the approved plan to agents through `agent-delegate`.
3. **Read back the checkpoints and holds.** Name each checkpoint, what is done at it, and every gate the user set. They bound every stretch that follows.
4. **Implement under coordination.** Load `agent-coordinator` and route the work with `agent-delegate`. Fewer PRs/MRs is the target, but the structure is yours. When one change depends on another, stack it per `git-branch` and the PR/MR create skill rather than waiting for the merge. The user merges in the right order; trust that.
5. **Weigh the calls.** Single, stacked or parallel PRs/MRs, and review now or later, get a fast second opinion per `delivery-decisions`. Use `agent-review` when a second opinion on the work itself is worth it, or when reviewing in-house would pollute your context.
6. **Offload what you cannot hold.** When coordinating leaves a domain without standing attention, bring in its companion per `agent-companion-offload`.
7. **Cover every wait.** Each merge, pipeline, review or approval gets a watcher through `agent-background` the moment it opens, per `agent-watchers`. On wake, re-verify and act.
8. **Stop at the checkpoint.** Report per `report-status`: every PR/MR and issue in a table with state and merge order, the manual steps the user must run between them, and an explicit list of what is waiting on the user at the end. List every live companion and ask whether to keep or retire it. Ask for the blessing to continue.

## Steering

A steer from the user is a rule change, not a one-off. Apply it to the PR/MR it was aimed at, then trace every stacked or sibling PR/MR it affects and amend those too once the fix is final. Same for a rule or convention that changes mid-run: everything already open that it touches gets brought in line. Report what was amended and where.

## Boundaries

- Destructive actions, credentials, and external writes keep their own gates, per the central guidelines. A blessing for a stretch never covers them.
- Never cross a checkpoint without the user's word.
- Never merge. Opening and updating PRs/MRs is the bohrhammer's job; merging is the user's.

## Example

**Trigger:** "/agent-bohrhammer adopt the auth-rotation issueset, stop when the first two MRs are up"

1. Load `agent-supervisor`, read the issueset, and present the breakdown: two MRs in the same repo, the second stacked on the first because it builds on the first's code, and one manual secret rotation before the second merges. `decision` reads the dependency the same way at 0.93.
2. User adjusts the second MR's scope; finalize and read back the checkpoint.
3. Load `agent-coordinator`, dispatch both implementations, stack the second branch on the first.
4. Both MRs open with pipelines and review threads to track; bring in `git-companion` for them and arm the pipeline watchers. A pipeline fails, a fix is dispatched, it goes green.
5. Checkpoint report: two linked MRs with merge order, the rotation step between them, and "waiting on you: review and merge the first MR, then run the rotation".

**Result:** the agreed stretch lands as reviewable MRs with a clear merge path, and the bohrhammer waits for the next blessing.
