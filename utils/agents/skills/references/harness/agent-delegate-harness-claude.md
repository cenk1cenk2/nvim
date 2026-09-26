# Harness: Claude Code — agent-delegate

Runtime mechanics for delegation on Claude Code — how subagent dispatch actually behaves, plus the tier → model mapping. Read this before the first dispatch of a session running on Claude. For waiting and waking, see `agent-background-harness-claude`. Facts below come from the official subagent docs and the live tool schemas; version markers say which build each claim was read from, because an older CLI behaves differently.

**Dispatch:** the built-in `Agent` tool.

## Tier → model

| Tier | Model |
|------|-------|
| cheap | `haiku` |
| default | `sonnet` |
| smart | `opus` |
| max | `fable` (`claude-fable-5`) |

Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

`max`/`fable` is the ceiling — reserve it for the single hardest problems; `smart`/`opus` covers most heavy work.

## `Agent` tool parameters (v2.1.283)

| Param | Required | Purpose |
|-------|----------|---------|
| `description` | yes | Short (3-5 word) task summary. Shown in telemetry and to the user. |
| `prompt` | yes | Full self-contained task prompt. A fresh agent shares no context with you or with other agents. |
| `subagent_type` | no | `general-purpose` (the default), `Explore` for read-only search, a defined agent type, or **`fork`**. A fork inherits your full conversation context and always runs on your model. |
| `model` | no | `haiku`, `sonnet`, `opus`, or `fable` — nothing else. Overrides the agent definition's model; omitted, the definition's model applies, else the default subagent model, else the parent's. Ignored for a fork. |
| `isolation` | no | `worktree` — an isolated git worktree for the agent, auto-removed if it changes nothing. `remote` — a remote cloud environment, always background, availability gated. |
| `name` | no | Makes the agent addressable by `SendMessage` while it runs and after it finishes. |
| `mode` | — | **Deprecated and ignored.** See Permissions below. |
| `team_name` | — | **Deprecated and ignored.** The session has one implicit team. |

**What the dispatch cannot set (v2.1.283):** there is no `run_in_background` and no `effort` parameter. Reasoning effort and the tool set come from the agent type's definition (`.claude/agents/*.md` frontmatter, or SDK `agents`), so a task that needs a different effort or tool set needs a different agent type, not a parameter.

## Permissions — inherited, NOT set on the dispatch

**As of v2.1.212 the `Agent` tool's `mode` parameter is deprecated and ignored** (still so on v2.1.283). Subagents inherit the parent session's permission mode. A subagent definition's `permissionMode` frontmatter may override it, with these exceptions:

- Parent `bypassPermissions` or `acceptEdits` **takes precedence and cannot be overridden**.
- Parent `auto` mode is inherited and the subagent's own `permissionMode` is ignored; the parent's classifier rules evaluate its tool calls.
- `permissionMode` is ignored entirely for **plugin** subagents (as are `hooks` and `mcpServers`).

Practical consequence: **you cannot grant a subagent a looser posture than the session that launched it.** If a task needs autonomy the session does not have, that is a decision about the *session*, taken with the user — not a dispatch parameter you can set.

Since **v2.1.186**, a background subagent that reaches a tool call needing permission **surfaces the prompt in the main session**, naming the subagent that is asking; Esc denies that one call without stopping the subagent.

## Every dispatch runs in the background (v2.1.283)

- **There is no foreground dispatch.** The `Agent` call returns at once, the subagent runs detached, and the lead stays free. Its result never arrives as a tool result in the same turn.
- **Parallel:** several `Agent` calls in ONE message run concurrently.
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` disables background tasks entirely (v2.1.198 docs; unverified on v2.1.283).

**Result delivery:** the subagent ends by calling **`SubagentHandback { message }`** with its full report, and that report reaches the lead as a **completion notification in a later turn**. Plain text the subagent writes at the end of its turn is **not** delivered. The runtime tells the subagent this itself, so the dispatch prompt needs no delivery instruction — it needs the report's format.

So: **never fabricate or pre-empt a pending agent's result, and never read its silence as a verdict** — but equally, do not assume collection is broken. The completion notification *is* the collection mechanism. A question asked before it lands is answered "still running".

The report is not shown to the user; relay what matters from it.

**On failure:** a background subagent that hits an API error is marked failed, and the message the lead receives names the error and includes the subagent's last output, so partial work is not lost (v2.1.211 docs).

## The subagent's tool set comes from its definition

Tools are fixed by the agent type, not by the dispatch. Two things follow:

1. **When a task needs a tool the agent type lacks, pick an agent type that has it**, or keep that step in the lead. A missing tool reports no error at dispatch — the symptom is an agent that simply cannot do what you asked.
2. **Deferred tools still count.** Observed on v2.1.283 in a background `general-purpose` subagent: `Agent`, `Artifact`, `Bash`, `Edit`, `Read`, `Write`, `Skill`, `ToolSearch` and `SubagentHandback` loaded; `EnterWorktree`, `ExitWorktree`, `Monitor`, `NotebookEdit`, `SendMessage`, `TaskStop`, `WebFetch`, `WebSearch` and every MCP tool deferred behind `ToolSearch`; `Grep`, `Glob`, `TodoWrite`, `ListAgents` and `TaskOutput` absent. Whether that list is the background filter or the `general-purpose` definition is **unverified**. Tell the agent to load a deferred tool before use when its task depends on one.

## Collecting and resuming

**Finishing does not put an agent out of reach — this is the runtime where the collection ladder in `agent-delegate` works in full.** A thin or vague report is recovered by messaging the agent that produced it, not by reconstructing the work from the diff.

- **`SendMessage` to the agent's name, or its agent ID when it has none,** reaches it, and a **completed** subagent that receives one **resumes from its transcript** with no new `Agent` call (v2.1.283). The same holds for one stopped with `TaskStop`. A new `Agent` call starts fresh, except a fork.
- A message sent to a **running** subagent is delivered as a course correction at its next tool round (v2.1.283).
- When a newer agent reuses a name, the name reaches the latest one; address the earlier one by the agent ID from its spawn result (v2.1.283).
- **Never read a local agent task's output file** — it is a symlink to the full subagent transcript (JSONL), and reading it overflows the lead's context. Use the completion notification instead.
- Since **v2.1.208**, a completed background subagent stays listed in `/tasks`, marked done, until the session cleans up. Failed or stopped ones leave the list.

## Talking to the lead mid-task — `SendMessage` to `"main"`

**A subagent's plain text output is not visible to any other agent, the lead included.** The final report travels by `SubagentHandback`; anything before that — a question, a blocker, an interim finding — travels by `SendMessage`.

- **`"main"` is the lead's address** — a literal, available to background subagents, needing no lookup (v2.1.283). Every subagent is a background one on this build.
- **A subagent can address nothing it was not given.** Beyond `"main"`, its address book is the `from` attribute of a message it received and any name written into its dispatch prompt. State a peer's name in the prompt when agents must talk to each other; it is never discoverable from inside.
- An incoming message arrives wrapped as `<cross-session-message from="X">`. **Reply by copying its `from` into your `to`.**
- Delivery is automatic — there is no inbox to poll, and messages drain at the receiver's next tool round, so a busy peer is never a reason to hold off.
- Structured JSON is reserved for the `shutdown_request` / `plan_approval_response` protocol. Progress and findings go as prose.
- **Never ask a peer to run something your own session blocked.** Permission boundaries are per-session, and routing blocked work sideways launders the user's decision. Send it back to the lead instead.

Whether a named agent's final report still arrives through `SubagentHandback`, or needs a `SendMessage` as it did on v2.1.221, is **unverified on v2.1.283** — the handback was observed from inside a dispatched subagent whose name was not visible to it.

### Teams

`team_name` on the dispatch is **deprecated and ignored** — the session has one implicit team — and there is **no team create or delete tool**. A team is just named agents: `name` is the whole mechanism. `TaskStop` accepts a teammate's `name@team` form alongside a plain name or task id (v2.1.283).

## A quiet agent — steer it, never mark it failed

`SendMessage` to the agent's name is a live channel, and on Claude Code it reaches a **running, idle, completed, or `TaskStop`ped** agent alike — a completed or stopped one resumes with no new `Agent` call. Going quiet is therefore never grounds to declare failure, re-dispatch, or reap. Steering costs one message; every rung below it costs work.

Ladder, cheapest first:

1. **Ask for what it has.** `SendMessage` to its name, requesting the report in the required format and stating that partial results are acceptable.
2. **Name the delivery mechanism.** An agent that finished with no report most likely answered in plain text. Tell it explicitly to deliver the report through `SubagentHandback`.
3. **Narrow or redirect.** Shrink the scope, restate the required output shape or path, or tell it to write incrementally.
4. **Only then diagnose** a concrete cause — auth failure, a tool erroring, an unreachable path, an unbounded scope — before considering a re-dispatch, and reap the old agent first so two writers never share a target.

Report a delegation as failed only after the channel itself produced nothing across those rungs, and say which rungs were tried.

## Reaping

`TaskStop { task_id }` accepts the task id, a named background agent's name, or a teammate's `name@team` (v2.1.283). Stopping ends the run, so **collect before you reap** — though a completed agent can still be resumed by `SendMessage`, so "quiet" is never itself a reason to kill one. Reap when the work is genuinely done, superseded, or about to be replaced (reap *before* re-dispatching over the same target, or two writers clobber each other).

## Limits

| Limit | Value | Control |
|-------|-------|---------|
| Nesting depth | 3 layers below the main conversation | At the limit the `Agent` tool is withheld from subagents. |
| Concurrent subagents | 20 (v2.1.217+) | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`; ultracode sessions exempt. Over the limit the spawn fails with `Concurrent subagent limit reached` and must NOT be retried. |
| Per-session spawns | 200 | `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`; `/clear` resets it. Finished subagents still count. |

Limits unverified on v2.1.283; a subagent on that build still holds the `Agent` tool.

## Worktree isolation

`isolation: "worktree"` gives the subagent a temporary git worktree — an isolated copy of the repo, **branched from the default branch, not the parent session's `HEAD`**. It is cleaned up automatically if the subagent makes no changes. Setup costs disk and a few hundred ms, so use it only when parallel writers would otherwise collide.

- Since **v2.1.203** a worktree subagent's Bash/PowerShell commands run inside its worktree, and a command whose working directory resolves to the main checkout fails instead of running there.
- Since **v2.1.210** that check covers the whole repository containing the launch directory — and, for a session already inside a linked worktree, the main checkout it links from.

The concrete on-disk location is a harness detail, not a documented contract: verify the path the dispatch returns rather than assuming one, and see `agent-worktrees` for the naming and cleanup conventions this setup expects.

`isolation: "remote"` (v2.1.283) runs the agent in a remote cloud environment instead; it is always background and gated per account. Its checkout, branch and cleanup behavior are **unverified**.

## Other inherited context

- A subagent starts with a **fresh, isolated context window** — no conversation history, no files already read, no skills already loaded. Only a fork inherits the parent conversation, and a fork keeps its tool output out of the lead's context.
- Since v2.1.198 subagents inherit the main conversation's **extended thinking** setting; there is no per-subagent thinking control.
- The built-in `Explore` agent inherits the main model, capped at Opus on the Claude API (v2.1.198+).
- Reasoning effort is per agent type, set in its definition — not per dispatch (v2.1.283).
