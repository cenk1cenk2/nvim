---
name: agent-annihilate-handoff
description: agent-annihilate-handoff Turn agreed work into a self-contained Linear project a from-scratch crew can run to merge-ready - converged plan, agreed names, dependency graph, documents, user-step issues, crew charter, kickoff line. Use on "hand this off for annihilation", "write the annihilation handoff". Not for executing the work, a single change, or a plan file for one session.
disableModelInvocation: true
argumentHint: "[goal or plan path] [cue: step by step | fully annihilate]"
references:
  - ../references/agent/agent-annihilation.md
  - ../references/long-running-work.md
  - ../references/mode-toggle.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`. The contract this skill writes is `agent-annihilation`: roles, blessing, delivery shape, manual steps, documents, delegation, investigations, charter template and reporting.

## Toggle

State that spans turns is written durably per `long-running-work`. On/off mechanics per `mode-toggle`.

- **On:** `/agent-annihilate-handoff`, "hand this off for annihilation", "write the annihilation handoff".
- **Off:** the kickoff sentence is delivered, or any stop or park signal.
- **Survives disengage:** the Linear project, its documents, and anything created with the user.

## Context

This session made the decisions; the crew never sees them. Crews run `agent-annihilate-pickup` as remote agents starting from scratch, so everything they need goes into the project. Write with the handoff mentality: a question the crew would have to ask back is a gap in the project.

This session is the project's owner. The user blessed creating the project by invoking this skill.

## Process

1. **Wait for every input.** When the user says more input is coming (another session's message, a decision still open), wait for it and fold it into the plan before anything else.
2. **Converge the whole plan.** Load `agent-resolve` and run it over the entire plan, including everything just folded in, not only the newest part. Continue only when every question is answered, written down as a manual step, or written down as an intent question with a recommended answer.
3. **List what must exist and agree names.** Present to the user, in one message: every new repository or project to create, every manual step, and every name the crew will rely on (repositories, base branches, users and bots, channels, apps, hostnames, secret paths). Classify each manual step per `agent-annihilation`, choosing IaC wherever the estate already manages that kind of resource. Wait for the user's agreement on the names.
4. **Run the together-via-CLI steps the crew needs to start.** With the user, run the steps the crew cannot start without (for example creating the repositories so branches can exist). Load the matching `command-*` skill before each CLI. The rest stay as issues for when the graph reaches them.
5. **Fix the delivery shape.** Take the user's cue per `agent-annihilation`; with no cue it is fewest MRs. Draw the dependency graph: every MR with its repository and base branch, every stack, every parallel branch, every release dependency, every user step and the verification after it.
6. **Build the project.** Load `linear-structure-agent` and shape the work: one parent issue per repository, one sub-issue per MR. Aim for the minimum number of MRs per repository; a second MR in a repository exists only for a dependency or a stage boundary. Mirror the graph's merge order with `blocks` relations.
7. **Write the documents.** Load `agent-aware` first. Write every document `agent-annihilation` lists, very detailed. For the implementation reference, open the sibling repositories (for example the existing bridges for an external-service integration, the workload repositories for deployment) and cite the exact files for each integration and component, plus the estate's mechanisms the work must follow. Load `sourcebot-discovery` to find them across the estate.
8. **Fold in investigations.** Every related idea the user raised becomes an investigation issue in the same project, outside the implementation issuesets, per `agent-annihilation`.
9. **Make manual steps durable gates.** Record every unfinished together-via-CLI or user-runs step per `agent-annihilation`'s bounded-wait and apply-gate policy, with its issue assigned to the user and blocking only what needs it.
10. **Designate delegation.** Pick the route per `agent-annihilation` and put a `Delegate:` line on every sub-issue.
11. **Write the charter.** Fill the template in `agent-annihilation`: shape, checkpoints, ownership, the three postures, route, graph, apply gates, wait/retry budgets, suspension and resume conditions, holds, investigations, final report.
12. **Review.** Load `agent-review` with `type=plan` on the manifest, the rollout document and the charter. Fold every finding back into the documents.
13. **Kick off.** End with one sentence the user pastes into each crew session: *"Use the `agent-annihilate-pickup` skill on the Linear project `<link>` and follow its crew charter."*

## Example

**Trigger:** "/agent-annihilate-handoff the webhooks bridge, fully annihilate — another session will send the ArgoCD notifications part"

1. Wait for the other session's message; fold the ArgoCD notifications source in.
2. `agent-resolve` converges the whole plan.
3. Present the two new repositories, the bot user, the channel and the four manual steps; the user agrees the names.
4. Create the two repositories together via CLI.
5. Full push; graph: one MR per repository, the deployment MR waits on the image release, enabling the hooks is verified after the user's apply.
6. Project built; documents written with the implementation reference citing the existing bridges' config, queue, Slack and GitLab client files and the sourcebot workload's deployment files.
7. A Kargo in-flight board becomes an investigation issue.
8. Route `harness`, tiers on every sub-issue; charter written; review folds two findings back; kickoff sentence delivered.
