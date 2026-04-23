# Agent Delegation

Shared logic for creating and dispatching subagents via the `Agent` tool (or other delegation mechanisms). Used by all `agents-*` skills.

## Agent Tool Parameters

The built-in `Agent` tool is Anthropic-only — its `model` parameter accepts `haiku`, `sonnet`, or `opus`. For non-Anthropic ecosystems, delegation runs through a different mechanism (Claude API SDK, OpenAI SDK, custom dispatch) and the `model` value is whatever that mechanism expects. The parameter table below is specific to the `Agent` tool.

| Param | Required | Purpose |
|-------|----------|---------|
| `description` | yes | Short (3-5 word) task summary. Shown in telemetry and to the user. |
| `prompt` | yes | Full self-contained task prompt. Agents do not share context with you or each other. |
| `subagent_type` | no | `general-purpose` (default), `Explore` for research-heavy work, or a specialized agent type. |
| `model` | no | `haiku`, `sonnet`, or `opus` (Anthropic-only via this tool). See Model Selection below. |
| `isolation` | no | `worktree` creates a temporary git worktree in `.claude/worktrees/` (harness default). See the `agents-worktrees` reference for naming, verification, and cleanup — agent worktrees MUST NOT live anywhere else. |
| `mode` | no | `bypassPermissions` skips approvals (fire-and-forget). Default: let permission requests bubble up. |
| `team_name` | no | Team context for coordinated work (agents in team mode). |
| `name` | no | Agent name for `SendMessage` routing. |
| `run_in_background` | no | Background (non-blocking) execution. Default is foreground/blocking — see Blocking Dispatch below. |

## Blocking Dispatch (default)

Agent tool calls are **foreground and blocking** by default — the lead's turn pauses until the agent returns, and the result comes back as a normal tool result in the same conversation turn. This is the preferred mode.

**Parallel blocking dispatch:** To run multiple agents concurrently while still blocking the lead's turn, issue **multiple `Agent` tool uses in a single message**. They execute in parallel, and their results are delivered together when all complete. The lead's turn blocks until the slowest one returns. This is how `agents` parallelises each DAG layer (in both team and fire-and-forget modes) without "dropping" the conversation into background mode.

**When to use `run_in_background: true`:** Only when the user explicitly asks for fire-and-forget behaviour, or when the lead must remain responsive to mid-execution messages from a long-running agent. Prefer blocking — it keeps the conversation coherent and the user never misses updates.

**Consequences of blocking:**
- No `SendMessage` exchanges mid-execution — the lead is paused.
- User guidance arrives on the NEXT turn; re-dispatch there if needed.
- Permission requests (when `mode` is not `bypassPermissions`) are surfaced by the harness to the user for interactive approval while the lead is blocked.

## Model Selection

Delegation picks a **tier** based on task complexity, then resolves the tier to a **concrete model** based on the ecosystem in use.

### Tiers

| Tier | Intended for | Signals |
|------|--------------|---------|
| cheap | Mechanical implementation | 1-2 files, clear spec, isolated function, template/boilerplate work. |
| default | Integration work | Multi-file, pattern matching, moderate judgment. |
| smart | Architecture/design/review | Design decisions, broad codebase understanding, complex reasoning. |

Cost and capability vary by an order of magnitude across tiers — pick the cheapest tier that will succeed.

### Resolving Tiers to Concrete Models

The tier → concrete model mapping depends on the ecosystem:

- **Anthropic via the `Agent` tool** — default mapping:
  - cheap → `haiku`
  - default → `sonnet`
  - smart → `opus`
  - These are the only values the `Agent` tool's `model` parameter accepts.
- **Other ecosystems (OpenAI, Google, mixed, custom)** — **the user decides the mapping**. There is no fixed "cheap = X" rule outside Anthropic. Ask the user what their cheap/default/smart models are, then reuse that mapping for the session. Persist the answer in memory if it looks stable across sessions.

If the user has not declared a mapping and the delegation uses the `Agent` tool, use the Anthropic defaults. If it uses any other mechanism, **ask** — do not guess.

### User Input → Tier

When the user picks a tier by word rather than model name:

| User says | Tier |
|-----------|------|
| "cheap", "fast", "lesser", "quick", "small", "lightweight" | cheap |
| "default", "balanced", "normal", "mid", "medium" | default |
| "smart", "higher", "best", "hard", "heavy", "powerful" | smart |

After resolving to a tier, apply the ecosystem's mapping (Anthropic defaults or user-declared) to get the concrete model.

### User Names an Explicit Model

If the user names a specific model directly (e.g., `haiku`, `opus`, `gpt-4o`, `gemini-2.5-pro`, `o1-mini`), use it verbatim — do not remap. The tier system is a shorthand; an explicit model name is the ground truth.

### Ambiguous Wording

If the user's wording is ambiguous (e.g., "better" without reference to what it's better than), present the inferred tier with reasoning and confirm before dispatching.

### Mismatched Choice — Ask, Don't Silently Comply

If the user requests a tier or model that seems mismatched to the task (e.g., cheap tier for architectural work, smart tier for a trivial rename), **ask before dispatching**. State the mismatch and the reason, propose an alternative, and wait for the user's call. A mismatched choice wastes cost on the high end and produces low-quality work on the low end. The user may have a reason (cost control, experimentation) and will say so; otherwise they'll accept the alternative.

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
5. Is isolation right? `worktree` for file mods, omit for read-only.
6. Is permission mode right? `bypassPermissions` only for fire-and-forget with user consent.

## Key Principles

- **Self-contained prompts.** Agents do not share context — everything must be in the prompt.
- **Tiers, not model names.** Think in cheap/default/smart; resolve to a concrete model at dispatch time.
- **User owns the mapping outside Anthropic.** When the ecosystem is anything other than Anthropic's `Agent` tool defaults, the user decides what cheap/default/smart mean.
- **Match tier to task.** Don't over-invest in smart for trivial work; don't under-invest in cheap for complex work.
- **Ask on mismatch.** If the user's choice seems wrong for the task, ask before dispatching. Don't silently comply.
- **Verify results.** Agent summaries describe intent, not outcomes. Check the diff.
