---
name: agent-delegate
description: agent-delegate Delegate one task to one subagent at a chosen tier - cheap, default, smart, max - or an explicit model. Use on "delegate this", "use a cheap/smart agent", "run this with opus". Not for multi-task or dependency-scheduled work, a separate agent session, or the offsite agent.
argumentHint: '[task] [optional: cheap|default|smart|max, or a model name]'
references:
  - ../references/long-running-work.md
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

Dispatch parameters, mechanics, and prompt structure per `agent-delegate`. Load the `agent-harness` skill to resolve tiers to concrete models.

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
   - For org-wide repository or code discovery, or a repo shortlist before SCM calls, start with a code-discovery MCP when the active profile has one, then verify live state with the workspace SCM tools. With none present, search from the SCM tools directly and say so. When that MCP is Sourcebot, load `sourcebot-discovery` before the first call.

2. **Resolve tier / model selection.**
   - Parse the user's input per `agent-delegate`:
     - **Explicit model name** (e.g., `haiku`, `opus`, `gpt-4o`, `gemini-2.5-pro`) → use verbatim, no remapping.
     - **Tier shorthand** (`cheap`, `smart`, `lesser`, `higher`, etc.) → resolve to a concrete model via the ecosystem's mapping.
   - Load the **`agent-harness`** skill and resolve the tier to a concrete model there (fetch `agent-delegate-harness-<provider>`) — the mapping depends on the active provider (Claude, OpenCode, Codex, …), not just Anthropic. If the provider's mapping is unknown, ask; persist to memory if stable across sessions.
   - If no preference is stated, infer the tier from task complexity and propose with reasoning.
   - **If the user's pick seems mismatched to the task** (e.g., cheap for architectural design, smart for a trivial rename), **ask before dispatching** — state the mismatch and propose an alternative. Do not silently comply.

3. **Establish conventions — mandatory whenever the task writes code.**
   - Follow the `agent-conventions` reference: discover the local patterns, then build the prompt block that makes the agent study its neighbours first, copy the local naming and structure, match comment density (usually none), and stay in scope.
   - Name the concrete files the agent should use as its pattern reference — the nearest siblings and the closest existing implementation of the same kind of thing. A generic "follow project conventions" line does nothing.
   - Skip only for genuinely read-only research.

4. **Discover verification commands** (when the task modifies code).
   - Follow the `project-tooling` reference to find lint/test/build commands.
   - Skip for read-only research.

5. **Draft the agent prompt.**
   - Build a self-contained prompt per `agent-delegate` Self-Contained Prompt Structure section.
   - For research: an exploration subagent, omit verification, omit write scope.
   - For implementation: a general-purpose subagent, include verification and write scope.
   - When the delegated task involves git operations, resolve the platform per `scm-detect` and state it in the prompt.
   - Present the prompt to the user for review before launching.

6. **Transition linked Linear issue to `In Progress` (when applicable).**
   - If the user's request mentions a Linear id (`K-xxx` / `CLOUD-xxx`) or a Linear URL, follow the `linear-state-transitions` reference: fetch current `statusType` and call `save_issue` with `state: "In Progress"` before dispatch, skipping when the issue is already at or past `In Progress` (never downgrade).
   - Report one line in the dispatch summary: `Linear state: moved K-xxx → In Progress (was Todo).`
   - Silent-with-report: no confirmation prompt. User opts out for the turn by saying "don't move the Linear state".
   - Skip when no Linear id is in scope — not every delegate is Linear-linked.

7. **Launch the agent — background by default.**
   - Dispatch the subagent via your runtime's dispatch mechanism, with parameters per `agent-delegate-harness-<provider>`.
   - **Dispatch in the BACKGROUND by default — this is the preferred mode.** The lead stays free, so the conversation keeps moving and you keep working while the agent runs. See the `agent-delegate` reference's Dispatch Mode section.
   - **Fetch `agent-delegate-harness-<provider>` before the first dispatch** — the flag name, its default, and how a background result actually reaches you. This differs per runtime: current Claude Code wakes you with a completion notification, Codex does not wake you at all.
   - **Block when the runtime will not deliver a detached result**, and when you simply need the answer to continue. For a fan-out you need complete before proceeding, issue several dispatches in one message, all blocking — they still run concurrently and land together.
   - **Never pre-empt a pending agent and never read its silence as a verdict.** A verification agent that has not reported has not passed anything. Equally, do not declare it broken on a runtime where delivery works — check the harness reference first.
   - `isolation`: `worktree` if the task modifies files — offer, confirm with user.
   - **Permissions: settle the context FIRST, but do not try to set it on the dispatch.** On current Claude Code the `mode` parameter is deprecated and ignored — subagents inherit the session's permission mode, so you cannot grant an agent more autonomy than the session already has. If the task needs more, raise it with the user; do not dispatch and hope. On runtimes with independent permissions, an unsurfaced gate stalls the agent silently — **highest risk: a task targeting a directory or repo other than the session's.** See `agent-delegate-harness-<provider>`.
   - **Collect deliberately.** On Claude Code, a background agent's result arrives as a completion notification — wait for it rather than polling, and note that a completed agent can be resumed by `SendMessage` to its name if you need more. Do NOT read a local agent's task-output file: it is a symlink to the full transcript and will overflow your context. **After two failed collection attempts, stop negotiating** — verify the underlying artifact yourself, or re-dispatch blocking. Diagnose the cause first; only blind re-dispatch wastes completed work.
   - **If worktree isolation is used**, verify the returned path is absolute and in the runtime's agent-worktrees directory per `agent-worktrees` — the concrete directory resolves via `provider-paths`, never hardcoded. If it falls outside, abort the result and recreate the worktree manually at the correct location (see the Manual Fallback section), then re-dispatch without worktree isolation and instruct the agent via the prompt to `cd` into the manual path.

8. **Handle the result.**
   - Relay the agent's summary to the user.
   - If files changed, verify the diff matches expectations — do not trust the agent's success report blindly.
   - **Check the diff for style drift**, per `agent-conventions`: naming that matches the neighbours, no comments restating the code, no docstrings or banners the surrounding files lack, no reformatting or refactors outside the task, no new abstraction where a local one existed. Bounce a mismatch back to the agent with the specific line — it still holds the context; fix by hand only when it is a one-liner.
   - If the user wants to commit/push/PR, follow the `agent-completion` reference or invoke the relevant SCM skill.

9. **REAP ONLY WHEN COMPLETELY DONE — reaping is terminal.**
   - **Stopping an agent destroys any chance of getting its report.** You cannot message, resume, or read it afterwards. So reap only when you have everything you need, have no further question for it, and the work has moved on.
   - **An idle/available agent is a candidate for COLLECTION, not reaping.** Idle usually means the work finished and only the report is stranded — killing it there turns a recoverable report into a permanent loss. **Order: collect → confirm you have what you need → then reap.** Never reap because it went quiet or because you are unsure whether it finished; uncertainty means collect.
   - Genuinely safe to reap: it delivered and the task is closed; you obtained and **verified** the answer another way so its report is redundant; its task was superseded or abandoned; it is demonstrably stale; or you are replacing it — **reap before re-dispatching** so two agents never write the same target (collect anything salvageable first).
   - **Completion does not self-clean.** A finished agent lingers in the runtime's task list, indistinguishable from a working one. Stop it explicitly via the runtime's own mechanism (per `agent-delegate-harness-<provider>`).
   - **Reap checkpoint at the end of the flow:** enumerate every agent you spawned and confirm each is stopped, or state that one is *deliberately* still running and what it waits on.
   - **Two concurrent writers on one target is the real hazard.** Re-dispatching over the same files, document, or resource without reaping the first lets the later write silently clobber the earlier one. Reap, verify the target's current state, then dispatch again.

## Model Selection

See the `agent-harness` skill for tier definitions, per-provider model lists, and user shorthand. Summary:

- **Tiers:** `cheap` (mechanical), `default` (integration), `smart` (architectural), `max` (absolute ceiling).
- **Concrete model depends on the provider** — load the `agent-harness` skill to resolve it (Claude: `haiku`/`sonnet`/`opus`/`fable`; OpenCode / Codex per its references). Ask if the provider's mapping is unknown.
- **Explicit model names** override tiers — use verbatim.

## Key Principles

- **One task, one agent.** Don't split or sequence — use `/agent-plan` for multi-task DAG-scheduled work.
- **User picks the tier/model.** This skill exists because the user wants control over cost/capability. Honor explicit choices.
- **User owns the mapping outside Anthropic.** For non-Anthropic ecosystems, ask the user what cheap/default/smart resolve to.
- **Ask on mismatch.** If the chosen tier/model looks wrong for the task, ask — don't silently comply.
- **Self-contained prompt.** The agent has no context outside its prompt.
- **Verify the result.** Don't relay agent success blindly — check the diff.

## Related Skills

- **`agent-plan`** — DAG-scheduled multi-task execution. Handles parallel, sequential, and mixed shapes via `depends_on` declarations. Modes: team (default, approval propagation) or fire-and-forget (bypass).
- **`agent-review`** — dispatch a review subagent to cross-check an artifact (plan, DAG, facts, freeform). Uses the same dispatch mechanism but with review-specific prompt templates and a cheap default tier.
- **`agent-coordinator`** — standing posture where dispatching is the default and the lead's context stays clean; uses this skill for each individual handoff.
- **`code-review-changes`** — review the diff after the delegate completes, if the result merits a review pass.
