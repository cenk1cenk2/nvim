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

## Dispatch Mode — background by default

> **★ BACKGROUND IS THE DEFAULT AND PREFERRED MODE (standing operator preference).** Dispatch detached so the lead stays free — the user can keep talking and you keep working while the agent runs. **Blocking is reserved for when you are essentially just waiting on the result** and would otherwise idle.

**Blocking**, when you do choose it, pauses the lead's turn and returns the agent's output as a normal tool result in the same turn. For a fan-out you need complete before proceeding, issue **several dispatches in one message**, all blocking — they run concurrently and land together when the slowest finishes. This is how `agents-plan` parallelises a DAG layer.

> **⛔ PROVIDER DISPATCH SEMANTICS DIFFER — read the active provider's `agents-tiers-<provider>` reference before your first dispatch.** The flag name, its default, and **how a background agent's result actually reaches you** are provider-specific: `agents-tiers-claude`, `agents-tiers-opencode`, `agents-tiers-codex`. Never assume one provider's behaviour carries to another.
>
> **The recurring trap is collection, not mode choice.** A background agent's final text may not be pushed into the lead's turn on its own; on Claude Code you can instead receive an `idle_notification` that reads exactly like an agent that gave up. It usually has not. Read its task output, or `SendMessage` its `name` to have it deliver. Diagnose the cause before re-dispatching — then re-dispatch freely; it is blind re-dispatch, not re-dispatch itself, that throws away completed work. `agents-tiers-claude` documents the full failure mode.

**Parallel blocking dispatch:** To run multiple agents concurrently while still blocking the lead's turn, issue **multiple subagent dispatches in a single message**. They execute in parallel, and their results are delivered together when all complete. The lead's turn blocks until the slowest one returns. This is how `agents-plan` parallelises each DAG layer (in both team and fire-and-forget modes) without "dropping" the conversation into background mode.

**When to use `run_in_background: true`:** Only when the user explicitly asks for fire-and-forget behaviour, or when the lead must remain responsive to mid-execution messages from a long-running agent. Prefer blocking — it keeps the conversation coherent and the user never misses updates.

**Consequences of blocking:**
- No `SendMessage` exchanges mid-execution — the lead is paused.
- User guidance arrives on the NEXT turn; re-dispatch there if needed.
- Permission requests (when `mode` is not `bypassPermissions`) are surfaced by the harness to the user for interactive approval while the lead is blocked.

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
