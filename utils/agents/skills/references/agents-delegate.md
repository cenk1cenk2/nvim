# Agent Delegation

Shared logic for creating and dispatching subagents via your runtime's dispatch mechanism. Used by all `agents-*` skills.

## Agent Tool Parameters

Delegation is **not Claude-specific** — each provider exposes its own subagent-spawning mechanism, and the tier → model resolution (see Model Selection) applies to whichever one is active:

- **Claude / Anthropic** — the built-in `Agent` tool. Its `model` parameter accepts `haiku`, `sonnet`, `opus`, or `fable`. The parameter table below is specific to this tool.
- **OpenCode** — the `task` tool (subagent dispatch, allowed in `opencode.jsonc`). Spawn a subagent and set its model to the resolved `kilic/*` slug.
- **Codex** — its own task/subagent spawning. Set the resolved `gpt-*` model.
- **Other / custom** — Claude API SDK, OpenAI SDK, or a custom dispatch; the `model` value is whatever that mechanism expects.

Whatever the mechanism, the flow is the same: pick a tier from task complexity, resolve it to a concrete model via the active provider's list, build a self-contained prompt, dispatch.

| Param | Required | Purpose |
|-------|----------|---------|
| `description` | yes | Short (3-5 word) task summary. Shown in telemetry and to the user. |
| `prompt` | yes | Full self-contained task prompt. Agents do not share context with you or each other. |
| `subagent_type` | no | `general-purpose` (default), `Explore` for research-heavy work, or a specialized agent type. |
| `model` | no | `haiku`, `sonnet`, `opus`, or `fable` (Anthropic-only via this tool). See Model Selection below. |
| `isolation` | no | `worktree` creates a temporary git worktree in `.claude/worktrees/` (harness default). See the `agents-worktrees` reference for naming, verification, and cleanup — agent worktrees MUST NOT live anywhere else. |
| `mode` | no | `bypassPermissions` skips approvals (fire-and-forget). Default: let permission requests bubble up. |
| `team_name` | no | Team context for coordinated work (agents in team mode). |
| `name` | no | Agent name for `SendMessage` routing. |
| `run_in_background` | no | Detached execution. **Background is the preferred mode** — see Dispatch Mode below. Provider defaults differ; check `agents-tiers-<provider>`. |

## ⛔ FIRST: a subagent may not inherit your permissions

**Before mode, tier, or prompt shape — settle the permission context.** On some runtimes a subagent runs with **independent permissions**: tools pre-approved in the parent session are not pre-approved for it. When it then hits a gate the runtime cannot surface to the parent, it **waits forever on an approval nobody can see** — and the symptom is indistinguishable from a broken agent: an idle/available signal, no tool calls, no response to follow-up messages, no error, no timeout.

Consequences to internalise:

- **Pre-allowing tools in settings is not a substitute** — the failure is that the allowlist is *not inherited*. Set the permission mode **on the dispatch**.
- **A task targeting a directory or repo other than the session's is the highest-risk case** — in a multi-repo workspace that is the normal case, not an edge case. Isolation flags can make it worse when settings are scoped to a filesystem path.
- **Granting autonomous permission is a security decision, not a default.** Get the user's explicit opt-in, scope the prompt to exact paths with an explicit do-not-touch list, and keep irreversible steps on the main loop.
- **Diagnose by inspecting the artifact, never the notification.** No files/resources touched means a permission stall and nothing was done — re-dispatch with the mode fixed. Work present but no report means only the report was stranded — verify and move on, do **not** re-run. **Silence is neither success nor failure.**

**Read the active provider's `agents-tiers-<provider>` reference for that runtime's permission-mode parameter, whether it inherits, and the known failure signature.** Do not assume one runtime's behaviour carries to another.

## Dispatch Mode — background by default

> **★ BACKGROUND IS THE DEFAULT AND PREFERRED MODE (standing operator preference).** Dispatch detached so the lead stays free — the user can keep talking and you keep working while the agent runs.
>
> **⛔ With one hard exception: if the agent's REPORT is the deliverable, dispatch BLOCKING.** Research, verification, audits, log digging, "go find out X" — work that leaves no artifact to inspect, where the text is the whole point. Detached reports are **unreliable to collect** (see the per-provider reference: on at least one runtime, completed agents routinely fail to deliver, and the resume path can fail too). Blocking such an agent costs no parallelism — several blocking dispatches in ONE message run concurrently and land together.
>
> Decide by asking **what you will inspect afterwards.** A side effect you can verify yourself (files changed, resources written) means background is safe. Nothing to inspect but prose means blocking. **Never treat a detached agent's silence as a verdict** — no report is not a pass.

**Blocking**, when you do choose it, pauses the lead's turn and returns the agent's output as a normal tool result in the same turn. For a fan-out you need complete before proceeding, issue **several dispatches in one message**, all blocking — they run concurrently and land together when the slowest finishes. This is how `agents-plan` parallelises a DAG layer.

> **⛔ PROVIDER DISPATCH SEMANTICS DIFFER — read the active provider's `agents-tiers-<provider>` reference before your first dispatch.** The flag name, its default, and **how a background agent's result actually reaches you** are provider-specific: `agents-tiers-claude`, `agents-tiers-opencode`, `agents-tiers-codex`. Never assume one provider's behaviour carries to another.
>
> **Two distinct traps, in order of how much damage they do.** First, **permission context** (see the section above): a subagent that stalls on an unsurfaced gate does no work at all and looks identical to one that finished. Second, **collection**: an agent that *did* the work may fail to deliver its final text, showing an idle/available signal that reads exactly like giving up. Distinguish them by **inspecting the artifact**, then act — re-dispatch with the mode fixed for the first, verify-and-move-on for the second. Diagnose before re-dispatching; blind re-dispatch is what throws away completed work. The active provider's `agents-tiers-<provider>` reference documents both signatures.

**Parallel blocking dispatch:** To run multiple agents concurrently while still blocking the lead's turn, issue **multiple subagent dispatches in a single message**. They execute in parallel, and their results are delivered together when all complete. The lead's turn blocks until the slowest one returns. This is how `agents-plan` parallelises each DAG layer (in both team and fire-and-forget modes) without "dropping" the conversation into background mode.

**When to background vs block:** background is the default and preferred mode (see above); block when the agent's **report is the deliverable**, or when you are simply waiting with nothing else to push. Decide by asking what you will inspect when it finishes — a side effect you can verify yourself means background is safe; prose only means block.

**Consequences of blocking:**
- No mid-execution message exchanges — the lead is paused.
- User guidance arrives on the NEXT turn; re-dispatch there if needed.
- **⚠ Do NOT assume a permission request will be surfaced to the user just because the lead is blocked.** On at least one runtime the subagent's gate cannot reach the parent UI at all, so blocking buys you nothing: the agent waits invisibly and the lead waits on the agent. Blocking is **not** a mitigation for the permission trap — set the permission mode on the dispatch instead.

## ⛔ Reaping — spawning without retiring is an incomplete dispatch

**An agent is finished when it is stopped, not when it has answered.** Leaving them alive costs resources and, worse, makes the run state unreadable: a stale agent is indistinguishable from a working one, so you cannot tell what is actually in flight.

Reap when the agent stops earning its keep — **not only on success**:

- it delivered and you acted on the result,
- you got the answer another way (inspected the artifact directly),
- it went idle without delivering and you took the work back in-house,
- its task was superseded, re-scoped, or abandoned,
- **you are about to replace it — reap BEFORE re-dispatching.**

**Completion does not self-clean.** A finished agent, and a background task whose command already exited, can both linger in the runtime's task list. Stop them explicitly using the runtime's own mechanism (per the active provider's `agents-tiers-<provider>` reference).

**★ The concrete hazard is two concurrent writers.** Re-dispatching over the same files, document, or resource without reaping the first agent lets the later write silently clobber the earlier one — and neither agent reports the collision. Reap, verify the target's current state, then dispatch again.

**Reap checkpoint:** before declaring the work done, enumerate everything you spawned and confirm each is stopped, or state explicitly that one is *deliberately* still running and what it waits on.

## Model Selection

Delegation picks a **tier** from task complexity, then resolves it to a **concrete model** for the active provider. The tier system, user-wording mapping, and per-provider model lists live in the **`agents-tiers`** skill and its `agents-tiers-<provider>` references — load `agents-tiers` (or read the active provider's reference: `agents-tiers-claude`, `agents-tiers-opencode`, `agents-tiers-codex`) to resolve.

- **Tiers:** `cheap` (mechanical), `default` (integration), `smart` (architecture/review), `max` (absolute ceiling — use sparingly).
- **Explicit model names override tiers** — use verbatim.
- **Ask on mismatch** — if the chosen tier/model looks wrong for the task, state it and propose an alternative before dispatching.

## Self-Contained Prompt Structure

Agents have zero context outside their prompt. Every dispatch prompt must include:

1. **Role and scope** — one-sentence framing of what the agent is responsible for.
2. **Task** — concrete description, detailed enough that another engineer could execute.
3. **Files** — exact paths the agent owns (reads anywhere, writes only within scope).
4. **Context** — relevant architecture, patterns, conventions, adjacent work.
5. **Boundaries** — what NOT to touch (other agents' scope, read-only files).
6. **Verification** — commands to run after implementation (from `project-tooling` discovery).
7. **Conventions** — project-specific patterns (from `agents-conventions`).
8. **Report** — expected status format (DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED).

## Dispatch Checklist

Before dispatching the agent:

1. Is the prompt self-contained? Could someone execute it with no other context?
2. Is the tier right for the task? Is the concrete model resolved correctly for the target ecosystem?
3. Are file boundaries explicit? No "and related files."
4. Are verification commands included when the task modifies code?
5. Is isolation right? Worktree isolation for file mods, omit for read-only.
6. Is permission mode right? `bypassPermissions` only for fire-and-forget with user consent.

## Key Principles

- **Self-contained prompts.** Agents do not share context — everything must be in the prompt.
- **Tiers, not model names.** Think in cheap/default/smart/max; resolve to a concrete model at dispatch time via the `agents-tiers` skill / per-provider reference.
- **`max` is the ceiling — use sparingly.** Reserve it for the single hardest problems; `smart` covers most heavy work.
- **User owns the mapping for unlisted providers.** For providers not in `agents-tiers`, the user decides what cheap/default/smart/max mean.
- **Match tier to task.** Don't over-invest in smart for trivial work; don't under-invest in cheap for complex work.
- **Ask on mismatch.** If the user's choice seems wrong for the task, ask before dispatching. Don't silently comply.
- **Verify results.** Agent summaries describe intent, not outcomes. Check the diff.
