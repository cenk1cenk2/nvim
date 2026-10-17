---
name: agent-annihilate-pickup
description: agent-annihilate-pickup Pick up an annihilation handoff from scratch and drive every MR to merge-ready in the background - postures, delegation per charter, graph order, Linear reconciliation, watchers, retries, checkpoint tables. Use on "pick up and annihilate", "run the crew charter". Not for writing the handoff, a project without a charter, or merging.
disableModelInvocation: true
argumentHint: "[Linear project]"
references:
  - ../references/agent/agent-annihilation.md
  - ../references/long-running-work.md
  - ../references/mode-toggle.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`. The contract this skill executes is `agent-annihilation`: roles, blessing, delivery shape, manual steps, documents, delegation, investigations, charter template and reporting.

## Toggle

State that spans turns is written durably per `long-running-work`: the charter's progress section on the Linear project is that record. On/off mechanics per `mode-toggle`.

- **On:** `/agent-annihilate-pickup`, "pick up and annihilate", "run the crew charter".
- **Off:** every MR is merge-ready and the final table is out; a hard blocker leaves nothing to move; any stop or park signal.
- **Survives disengage:** the Linear project, its documents, branches and open MRs. Every watcher and agent is reaped before standing down.

## Context

The project was created by `agent-annihilate-handoff` with the handoff mentality: everything this crew needs is in it, and nothing lives in the conversation that produced it. Read it as the full contract. The charter wins where it is more specific than this skill.

This crew starts from scratch and is a co-owner of the project. The goal is every MR created in the background and merge-ready; the user merges everything.

## Process

1. **Read the contract.** Load `linear-structure-agent` and pick up the project: every document, every issue and sub-issue, the relations, the manual-step issues, and the charter.
2. **Engage the postures immediately**, before any other work: load `agent-bulldozer`, `agent-coordinator` and `agent-bohrhammer`. The project is bohrhammer's vehicle and the charter's checkpoints are its checkpoints. The handoff is the user's engagement of all three.
3. **Delegate per the charter.** Use the route the charter names, per `agent-annihilation`, at the tier or profile on each sub-issue's `Delegate:` line. Every brief names the issue, the documents to read, the branch and its base, and tells the agent to load `code-style` and the repository's own instructions before its first edit.
4. **Research instead of guessing.** A question the documents do not answer is researched by the crew's own agents: sibling repositories, docs, the live system read-only. When the subject needs more than one view, load `agent-resolve` for a second opinion. Write the answer onto the issue and into the affected document.
5. **Walk the graph.** Follow the delivery shape and dependency rules in `agent-annihilation`: stack dependent work, open independent work in parallel, run mixed dependencies as an `agent-plan` DAG, open release consumers with the version they need. Never force the shape over a dependency.
6. **Leave verification after user steps for later.** A check that needs the user to apply or deploy first is written into the rollout document with its exact command and expected result. It runs when the user's step is done, and it never holds back opening MRs.
7. **Split freely, reconcile always.** An implementing agent may split an issue or an MR when the work is bigger or shaped differently than planned. In the same turn, through `linear-structure-agent`:
   - a new sub-issue under the same parent for the split-off MR, with its own `Delegate:` line;
   - the moved scope taken out of the original issue's description;
   - `blocks` relations, the graph and the merge order in the rollout document updated;
   - a deviation note on the original issue: what changed and why.
8. **Arm a watcher for every wait.** Load `agent-background` and arm one the moment a wait opens: each pipeline, each review thread, each prerequisite branch, each release a consumer waits on, each manual-step issue. Every wake re-verifies the real state, advances the work (fix the failure, rebase onto the merged base, re-run the consumer pipeline, open the next MR, run the post-step verification) and reconciles Linear (issue state, relations, documents, charter progress). Then it re-arms for the next wait, or is reaped once its condition holds.
9. **Retry what is transient.** A runner outage, a flaky test, a rate limit, a registry or API timeout, or a briefly unreachable service is not a stop: arm a wake through `agent-background` to retry after a delay that fits the cause (minutes for a flaky job, the reset window for a rate limit, longer for an outage), and keep every other track moving.
10. **Stop only on a hard blocker.** A decision only the user can make, a missing credential or permission, a failure that research and `agent-resolve` cannot explain, or work outside the project's scope stops that track. Report it once: what is blocked, the evidence, exactly what is needed. Keep every unblocked track moving; stop entirely only when nothing is left to move. A manual step in the graph is not a blocker: it is a row in the table.
11. **Report only at checkpoints**, per the reporting rules in `agent-annihilation`. No table between checkpoints.
12. **Finish with the final table** when every MR is merge-ready: the detailed table from `agent-annihilation`, every MR in merge order with the manual steps and their verification in between.
13. **Never merge.** Merge-ready means pipeline green on the current head, description complete with the Linear link, review threads answered, base branch correct for the graph.

## Example

**Trigger:** "Use the `agent-annihilate-pickup` skill on the Linear project ... and follow its crew charter."

1. Read the project and charter; load bulldozer, coordinator and bohrhammer before anything else.
2. Dispatch the independent MRs in parallel at their `Delegate:` tiers; open the deployment MR with the expected image tag, waiting on the release.
3. One repository needs a second MR: split it, add the sub-issue, update relations and the graph, note the deviation.
4. A runner outage fails two pipelines: watchers retry after fifteen minutes, both go green.
5. An undocumented secret path is researched, confirmed through `agent-resolve`, and written into the configuration reference.
6. Final table: every MR merge-ready in merge order, the user's applies and the verification after each in between, one deviation listed underneath.
