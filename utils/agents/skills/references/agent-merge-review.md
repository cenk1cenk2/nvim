# Agent Merge & Review

Shared merge + review phase for agent orchestration skills. Covers **per-layer** merge (after each layer of the DAG completes) and **end-of-run** review + verification + handoff. Used by `agent-plan`.

## Process

### 1. Merge worktrees (per-layer)

Agents in the completed layer ran in isolated worktrees in the runtime's agent-worktrees directory, each on its own branch. After the layer returns:

- Merge each layer worktree's branch back to the active branch sequentially.
- On merge conflicts:
  - Present the conflicting files and both sides to the user.
  - Wait for the user's resolution decision, or propose one and get approval.
  - Do NOT auto-resolve — the user decides.
- After all merges for this layer complete, verify the working tree is clean.
- **Cleanup:** remove each worktree with `git worktree remove <worktree-path>`. If removal fails (uncommitted state or locked worktree), surface the error to the user before force-removing — don't `--force` silently.

**Why per-layer?** Layer N+1's agents branch their worktrees from the *post-layer-N* state. They must see the merged output of earlier layers. End-of-run batch merging would break dependency semantics.

See the `agent-worktrees` reference for the worktree location rule, naming, and verification requirements.

### 2. Review (per-layer and/or end-of-run)

**Per-layer review** (runs after step 1 for each layer, if cadence is `per-layer`):

- Run `code-review-changes` against the **layer baseline** (recorded just before this layer launched).
- Catches integration issues across the parallel tasks within this layer.
- Present findings. Fix before proceeding to the next layer if the reviewer flags real issues.

**End-of-run review** (runs once after the final layer, regardless of cadence):

- Run `code-review-changes` against the **run-level baseline** (recorded before layer 0).
- Catches cross-layer integration issues that per-layer review can miss.
- Present findings. Fix if asked.

**Per-task cadence** (opt-in): the implementer + reviewer pair runs during layer execution, so no separate per-layer review is needed — skip this step for that cadence.

**Final-only cadence** (opt-in): skip the per-layer review entirely; only the end-of-run review runs.

### 3. Final verification

- Run the full verification command set discovered during planning (step 2 of `agent-plan-split`).
- Read the output. Confirm pass with evidence — paste the relevant lines into the chat.
- **Never claim completion without fresh verification output.** "Should pass" is not evidence.
- If verification fails, do not proceed to handoff. Diagnose the failure, fix it (directly or via a corrective agent), and re-run verification.

### 4. Completion handoff

Follow the `agent-completion` reference — summarize work, present options (commit, push, PR, leave uncommitted), execute the user's choice.

## Red flags during this phase

- Skipping per-layer merge and hoping layer N+1's worktrees see earlier work (they won't).
- Skipping review because "agents reported success" — agent summaries describe intent, not outcomes. Always diff.
- Running end-of-run review against the wrong baseline (layer baseline instead of run baseline, or vice versa).
- Claiming completion without running verification.
- Auto-resolving merge conflicts without user input.
- Force-removing a worktree silently when removal fails.
- Proceeding to handoff when review flagged unaddressed issues.
