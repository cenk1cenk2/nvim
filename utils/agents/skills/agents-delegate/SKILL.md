---
name: agents-delegate
description: 'agents-delegate Delegate a single task to one subagent at a chosen tier (cheap/default/smart/max) or explicit model. Use on "delegate this", "use a cheap/smart agent", "run this with opus/haiku". Do NOT use for multi-task plans or DAG-scheduled work (use /agents-plan).'
disable-model-invocation: true
argument-hint: "[task description] [optional: tier 'cheap'|'default'|'smart'|'max' or explicit model name]"
references:
  - ../references/present-first.md
  - ../references/agents-delegate.md
  - ../references/agents-worktrees.md
  - ../references/project-tooling.md
  - ../references/agents-conventions.md
  - ../references/agents-completion.md
  - ../references/scm-detect.md
  - ../references/sourcebot-discovery.md
  - ../references/linear-state-transitions.md
---

## Single-Task Delegation

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `agents-delegate` reference for agent parameters, dispatch mechanics, and prompt structure. Resolve tiers to concrete models via the `agents-tiers` skill (and its per-provider references).
> Read the `agents-worktrees` reference when dispatching with worktree isolation — worktrees MUST live in the runtime's agent-worktrees directory. Covers naming, verification, and cleanup.
> Read the `agents-conventions` reference when the task modifies code — establishes conventions to include in the agent prompt. Skip for read-only research tasks.
> Read the `project-tooling` reference when the task modifies code — for verification commands to include in the agent prompt. Skip for read-only research tasks.
> Read the `agents-completion` reference if the user wants to commit/push/PR after the agent reports back.
> Read the `scm-detect` reference if the delegated task involves git operations.
> Read the `sourcebot-discovery` reference when the delegated task is read-only org-wide repository/code discovery or needs a repo shortlist before SCM calls.
> Read the `linear-state-transitions` reference if the task is linked to a Linear issue — the dispatcher advances the issue to `In Progress` before launching the agent. Skip when the task has no Linear id.

## Context

This skill delegates one focused task to one subagent. Unlike the sibling skills, it does NOT split work, does NOT run multiple agents, and does NOT sequence tasks. It's a one-shot handoff where the user picks the tier or model based on cost/capability trade-offs.

Use it when:

- The task is well-scoped and fits one agent.
- The user wants to pick the tier or model explicitly (cheap, default, smart, or a specific model name).
- You want to offload a focused job from your own context.

## Process

1. **Understand the task.**
   - Read the user's request. If ambiguous, ask ONE clarifying question before proceeding.
   - Gather minimal codebase context needed to brief the agent — don't over-explore; the agent will explore on its own.

2. **Resolve tier / model selection.**
   - Parse the user's input per the `agents-delegate` reference:
     - **Explicit model name** (e.g., `haiku`, `opus`, `gpt-4o`, `gemini-2.5-pro`) → use verbatim, no remapping.
     - **Tier shorthand** (`cheap`, `smart`, `lesser`, `higher`, etc.) → resolve to a concrete model via the ecosystem's mapping.
   - Resolve the tier to a concrete model via the **`agents-tiers`** skill (read the active provider's `agents-tiers-<provider>` reference) — the mapping depends on the active provider (Claude, OpenCode, Codex, …), not just Anthropic. If the provider's mapping is unknown, ask; persist to memory if stable across sessions.
   - If no preference is stated, infer the tier from task complexity and propose with reasoning.
   - **If the user's pick seems mismatched to the task** (e.g., cheap for architectural design, smart for a trivial rename), **ask before dispatching** — state the mismatch and propose an alternative. Do not silently comply.

3. **Establish conventions** (when the task modifies code).
   - Follow the `agents-conventions` reference — only the conventions relevant to the task scope.
   - Skip entirely for read-only research.

4. **Discover verification commands** (when the task modifies code).
   - Follow the `project-tooling` reference to find lint/test/build commands.
   - Skip for read-only research.

5. **Draft the agent prompt.**
   - Build a self-contained prompt per the `agents-delegate` reference's Self-Contained Prompt Structure section.
   - For research: an exploration subagent, omit verification, omit write scope.
   - For implementation: a general-purpose subagent, include verification and write scope.
   - Present the prompt to the user for review before launching.

6. **Transition linked Linear issue to `In Progress` (when applicable).**
   - If the user's request mentions a Linear id (`K-xxx` / `CLOUD-xxx`) or a Linear URL, follow the `linear-state-transitions` reference: fetch current `statusType` and call `save_issue` with `state: "In Progress"` before dispatch, skipping when the issue is already at or past `In Progress` (never downgrade).
   - Report one line in the dispatch summary: `Linear state: moved K-xxx → In Progress (was Todo).`
   - Silent-with-report: no confirmation prompt. User opts out for the turn by saying "don't move the Linear state".
   - Skip when no Linear id is in scope — not every delegate is Linear-linked.

7. **Launch the agent (blocking).**
   - Dispatch the subagent via your runtime's dispatch mechanism, with parameters resolved from the reference's parameter table.
   - Dispatch is **foreground/blocking** by default — this turn pauses until the agent returns. Results are pushed into this turn as a tool result and then summarised for the user. See the `agents-delegate` reference's Blocking Dispatch section.
   - `isolation`: `worktree` if the task modifies files — offer, confirm with user.
   - `mode`: default (permissions bubble up to the harness). Use `bypassPermissions` only if the user explicitly opts in.
   - `run_in_background`: leave unset (blocking). Only set it to `true` if the user explicitly asks for fire-and-forget.
   - **If worktree isolation is used**, verify the returned path is absolute and in the runtime's agent-worktrees directory per the `agents-worktrees` reference. If it falls outside, abort the result and recreate the worktree manually at the correct location (see the Manual Fallback section), then re-dispatch without worktree isolation and instruct the agent via the prompt to `cd` into the manual path.

8. **Handle the result.**
   - Relay the agent's summary to the user.
   - If files changed, verify the diff matches expectations — do not trust the agent's success report blindly.
   - If the user wants to commit/push/PR, follow the `agents-completion` reference or invoke the relevant SCM skill.

## Model Selection

See the `agents-tiers` skill for tier definitions, per-provider model lists, and user shorthand. Summary:

- **Tiers:** `cheap` (mechanical), `default` (integration), `smart` (architectural), `max` (absolute ceiling).
- **Concrete model depends on the provider** — resolve via the `agents-tiers` skill (Claude: `haiku`/`sonnet`/`opus`/`fable`; OpenCode / Codex per its references). Ask if the provider's mapping is unknown.
- **Explicit model names** override tiers — use verbatim.

## Key Principles

- **One task, one agent.** Don't split or sequence — use `/agents-plan` for multi-task DAG-scheduled work.
- **User picks the tier/model.** This skill exists because the user wants control over cost/capability. Honor explicit choices.
- **User owns the mapping outside Anthropic.** For non-Anthropic ecosystems, ask the user what cheap/default/smart resolve to.
- **Ask on mismatch.** If the chosen tier/model looks wrong for the task, ask — don't silently comply.
- **Self-contained prompt.** The agent has no context outside its prompt.
- **Verify the result.** Don't relay agent success blindly — check the diff.

## Related Skills

- **`agents-plan`** — DAG-scheduled multi-task execution. Handles parallel, sequential, and mixed shapes via `depends_on` declarations. Modes: team (default, approval propagation) or fire-and-forget (bypass).
- **`agents-review`** — dispatch a review subagent to cross-check an artifact (plan, DAG, facts, freeform). Uses the same dispatch mechanism but with review-specific prompt templates and a cheap default tier.
- **`code-review-changes`** — review the diff after the delegate completes, if the result merits a review pass.
