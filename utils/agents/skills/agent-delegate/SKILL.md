---
name: agent-delegate
description: agent-delegate Delegate one task to one subagent at a chosen tier - cheap, default, smart, max - or an explicit model. Use on "delegate this", "use a cheap/smart agent", "run this with opus". Not for multi-task or dependency-scheduled work, a separate agent session, or the offsite agent.
argumentHint: '[task] [optional: cheap|default|smart|max, or a model name]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-worktrees.md
  - ../references/project-tooling.md
  - ../references/agent/agent-conventions.md
  - ../references/agent/agent-completion.md
  - ../references/scm/scm-detect.md
  - ../references/linear/linear-state-transitions.md
  - ../references/harness/provider-paths.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

## Single-Task Delegation

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

Dispatch parameters, mechanics, and prompt structure per `agent-delegate`. Load `agent-harness` to resolve tiers to concrete models.

## Context

This skill delegates one focused task to one subagent. Unlike the sibling skills, it does NOT split work, does NOT run multiple agents, and does NOT sequence tasks. It's a one-shot handoff where the user picks the tier or model based on cost/capability trade-offs.

Use it when:

- The task is well-scoped and fits one agent.
- The user wants to pick the tier or model explicitly (cheap, default, smart, or a specific model name).
- You want to offload a focused job from your own context.

**If the request carries several units** — several PRs, repos, worktrees, or issues — this skill covers one of them. Run it once per unit, or route the set through `agent-plan` / `agent-coordinator`; do not widen one dispatch to swallow the rest.

## Process

1. **Understand the task.**
   - Read the user's request. If ambiguous, ask ONE clarifying question before proceeding.
   - Gather minimal codebase context needed to brief the agent — don't over-explore; the agent will explore on its own.
   - For org-wide repository or code discovery, or a repo shortlist before SCM calls, start with a code-discovery MCP when the active profile has one, then verify live state with the workspace SCM tools. With none present, search from the SCM tools directly and say so. When that MCP is Sourcebot, load `sourcebot-discovery` before the first call.

2. **Resolve tier / model selection** per `agent-delegate` Model Selection — an explicit model name is used verbatim, a tier word resolves through `agent-harness` against `agent-delegate-harness-<provider>`. If the provider's mapping is unknown, ask; persist to memory if stable across sessions.
   - If no preference is stated, infer the tier from task complexity and propose with reasoning — always, and per task. A tier the user named for an earlier task, or stated generically, does not settle this one.
   - **If the user's pick seems mismatched to the task** (e.g., cheap for architectural design, smart for a trivial rename), **ask before dispatching** — state the mismatch and propose an alternative. Do not silently comply.

3. **Establish conventions — mandatory whenever the task writes code.**
   - Discover the local patterns and fill in the prompt block per `agent-conventions`.
   - Name the concrete files the agent should use as its pattern reference — the nearest siblings and the closest existing implementation of the same kind of thing. A generic "follow project conventions" line does nothing.
   - Skip only for genuinely read-only research.

4. **Discover verification commands** (when the task modifies code).
   - Find lint/test/build commands per `project-tooling`.
   - Skip for read-only research.

5. **Draft the agent prompt.**
   - Build a self-contained prompt per `agent-delegate` Self-Contained Prompt Structure section.
   - For research: an exploration agent type, omit verification, omit write scope.
   - For implementation: a general-purpose agent type, include verification and write scope. Where the runtime fixes tools and effort per agent type, pick a type that has what the task needs.
   - When the delegated task involves git operations, resolve the platform per `scm-detect` and state it in the prompt.
   - **Carry the delivery instruction, naming the recipient**, only where the runtime does not deliver the report on its own — the agent cannot look up who to send it to. Whether it is needed, and the wording, per `agent-delegate-harness-<provider>`.
   - Present the prompt to the user for review before launching.

6. **Transition linked Linear issue to `In Progress` (when applicable).**
   - If the user's request mentions a Linear id (`K-xxx` / `CLOUD-xxx`) or a Linear URL, move it to `In Progress` before dispatch per `linear-state-transitions`.
   - Report one line in the dispatch summary: `Linear state: moved K-xxx → In Progress (was Todo).`
   - Silent-with-report: no confirmation prompt. User opts out for the turn by saying "don't move the Linear state".
   - Skip when no Linear id is in scope — not every delegate is Linear-linked.

7. **Launch the agent — background by default.**
   - **Fetch `agent-delegate-harness-<provider>` before the first dispatch** — the dispatch parameters, whether blocking exists at all, and how a detached result actually reaches you all differ per runtime.
   - Dispatch mode per `agent-delegate` Dispatch Mode: detached where the runtime delivers the result; when you need the answer to continue, hold for it — blocking where the runtime offers it, otherwise by collecting its completion before the dependent step.
   - `isolation`: `worktree` if the task modifies files — offer, confirm with user.
   - **Settle the permission context FIRST**, per `agent-delegate` — it is never a dispatch parameter. If the task needs more autonomy than the session has, raise it with the user; do not dispatch and hope.
   - **Collect deliberately**, per the collection ladder in `agent-delegate` (including its two-failed-attempts rule) and the harness reference.
   - **If worktree isolation is used**, verify the returned path per `agent-worktrees`. If it does not conform, abort the result and create the worktree yourself per that reference, then re-dispatch without worktree isolation and instruct the agent via the prompt to `cd` into that path.

8. **Handle the result.**
   - Relay the agent's summary to the user.
   - If files changed, verify the diff matches expectations — do not trust the agent's success report blindly.
   - **Check the diff for style drift**, per `agent-conventions`: naming that matches the neighbours, no comments restating the code, no docstrings or banners the surrounding files lack, no reformatting or refactors outside the task, no new abstraction where a local one existed. Bounce a mismatch back to the agent with the specific line — it still holds the context; fix by hand only when it is a one-liner.
   - If the user wants to commit/push/PR, follow the `agent-completion` reference or invoke the relevant SCM skill.

9. **Reap only when completely done — collect first**, per `agent-delegate` Reaping, and run its reap checkpoint at the end of the flow.

## Key Principles

- **One task, one agent — one agent per logical unit.** Two PRs, worktrees, repos or issues are two dispatches, not one prompt with a list. Don't split or sequence here — use `/agent-plan` for multi-task DAG-scheduled work.
- **Always propose the tier.** State it with the signal that picked it before dispatching, even when the user said nothing.
- **User picks the tier/model.** This skill exists because the user wants control over cost/capability. Honor explicit choices.
- **User owns the mapping outside Anthropic.** For non-Anthropic ecosystems, ask the user what cheap/default/smart resolve to.
- **Ask on mismatch.** If the chosen tier/model looks wrong for the task, ask — don't silently comply.
- **Self-contained prompt.** The agent has no context outside its prompt.
- **Verify the result.** Don't relay agent success blindly — check the diff.

## Related Skills

- **`agent-plan`** — multi-task work with dependencies.
- **`agent-review`** — cross-checking an artifact with a reviewer.
- **`agent-coordinator`** — a standing posture where dispatching is the default.
- **`code-review-changes`** — review the diff after the delegate completes, if the result merits a review pass.
