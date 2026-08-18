# Harness: Claude Code — agent-delegate

Runtime mechanics for delegation on Claude Code — how subagent dispatch actually behaves, plus the tier → model mapping. Read this before the first dispatch of a session running on Claude. For waiting and waking, see `agent-background-harness-claude`. Facts below come from the official subagent docs and the live tool schemas; version markers say when each behavior landed, because an older CLI behaves differently.

**Dispatch:** the built-in `Agent` tool.

## Tier → model

| Tier | Model |
|------|-------|
| cheap | `haiku` |
| default | `sonnet` |
| smart | `opus` |
| max | `fable` (`claude-fable-5`) |

Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

`max`/`fable` is the ceiling — reserve it for the single hardest problems; `smart`/`opus` covers most heavy work. The `model` parameter also accepts a full model ID or `inherit`; subagent frontmatter defaults to `inherit` (the main conversation's model).

## `Agent` tool parameters

| Param | Required | Purpose |
|-------|----------|---------|
| `description` | yes | Short (3-5 word) task summary. Shown in telemetry and to the user. |
| `prompt` | yes | Full self-contained task prompt. Agents do not share context with you or each other. |
| `subagent_type` | no | `general-purpose` (default), `Explore` for research-heavy work, or a specialized agent type. |
| `model` | no | `haiku`, `sonnet`, `opus`, `fable`, a full model ID, or `inherit`. Tier mapping above. |
| `effort` | no | Reasoning effort for this agent (`low`…`max`); overrides the session level. |
| `isolation` | no | `worktree` runs the agent in a temporary git worktree branched from the **default branch**, auto-removed if it changes nothing. Costs disk and setup time — use it only when parallel writers would collide. See `agent-worktrees`. |
| `name` | no | Agent name for `SendMessage` routing and for resuming it later. |
| `run_in_background` | no | Detached execution. **Default is background on Claude Code**; other runtimes differ. |
| `mode` | — | **Deprecated and ignored** on current Claude Code. See Permissions below. |

## Permissions — inherited, NOT set on the dispatch

**As of v2.1.212 the `Agent` tool's `mode` parameter is deprecated and ignored.** Subagents inherit the parent session's permission mode. A subagent definition's `permissionMode` frontmatter may override it, with these exceptions:

- Parent `bypassPermissions` or `acceptEdits` **takes precedence and cannot be overridden**.
- Parent `auto` mode is inherited and the subagent's own `permissionMode` is ignored; the parent's classifier rules evaluate its tool calls.
- `permissionMode` is ignored entirely for **plugin** subagents (as are `hooks` and `mcpServers`).

Practical consequence: **you cannot grant a subagent a looser posture than the session that launched it.** If a task needs autonomy the session does not have, that is a decision about the *session*, taken with the user — not a dispatch parameter you can set.

Since **v2.1.186**, a background subagent that reaches a tool call needing permission **surfaces the prompt in the main session**, naming the subagent that is asking; Esc denies that one call without stopping the subagent.

## Foreground vs background

- **Background is the default since v2.1.198.** Omit `run_in_background` and the subagent runs detached; the lead stays free.
- **`run_in_background: false`** runs it synchronously and returns its output as a tool result in the same turn.
- **Parallel:** several `Agent` calls in ONE message run concurrently, blocking or not.
- **Frontmatter `background: true`** forces a subagent to always run detached.
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` disables background tasks entirely; `CLAUDE_CODE_FORK_SUBAGENT=1` forces everything to background and removes the `run_in_background` parameter.

**Result delivery (v2.1.211+):** a background subagent's results reach the lead as a **completion notification in a later turn**, and the lead waits for that notification before reporting them. Asking about progress before it lands correctly reports "still running".

So: **never fabricate or pre-empt a pending agent's result, and never read its silence as a verdict** — but equally, do not assume collection is broken. The completion notification *is* the collection mechanism.

**On failure:** a background subagent that hits an API error is marked failed, and the message the lead receives names the error and includes the subagent's last output, so partial work is not lost.

## Background subagents get a REDUCED tool set

The most-missed dispatch consequence. Two filters apply:

1. A short list is removed from **every** subagent, even when named in `tools`.
2. A **background** subagent keeps every MCP tool but only these built-ins: `Read`, `Grep`, `Glob`, `Bash`, `PowerShell`, `Edit`, `Write`, `NotebookEdit`, `WebFetch`, `WebSearch`, `TodoWrite`, `Skill`, `ToolSearch`, `EnterWorktree`, `ExitWorktree`, `Monitor`, `TaskStop`, `SendMessage`, `Artifact`. Every other built-in is removed silently.

The same definition therefore resolves to different tools in the foreground and the background. When a task needs a built-in outside that list, dispatch it **foreground** (`run_in_background: false`) — the removal reports no error, so the symptom is an agent that simply cannot do what you asked. Forks skip both filters.

## Collecting and resuming

**Finishing does not put an agent out of reach — this is the runtime where the collection ladder in `agent-delegate` works in full.** A thin or vague report is recovered by messaging the agent that produced it, not by reconstructing the work from the diff. Use `ListAgents` to confirm which agent a name currently reaches before assuming it is gone.

- **`SendMessage` to the agent's name** reaches it, and a **completed** subagent that receives one **auto-resumes in the background** with no new `Agent` call. The same holds for one stopped with `TaskStop`.
- Since **v2.1.199**, `SendMessage` refuses a name that now points at a *different* agent (a re-spawned background agent that reused it) and reports which agent the name reaches. Address the earlier one by the agent ID from its spawn result.
- **`TaskOutput` is deprecated, and for a local agent task it is a trap** — its `.output` file is a symlink to the full subagent transcript (JSONL), and reading it overflows the lead's context. Use the `Agent` tool result instead. Reserve `TaskOutput` / reading the output file for background **shell** tasks.
- Since **v2.1.208**, a completed background subagent stays listed in `/tasks`, marked done, until the session cleans up. Failed or stopped ones leave the list.

## Talking to the lead — `SendMessage` is the only channel

**A subagent's plain text output is not visible to any other agent, the lead included.** The dispatch shape decides whether that matters:

| Dispatch | How the result reaches the lead | Prompt must carry |
|---|---|---|
| Unnamed, `run_in_background: false` | the tool result, same turn | nothing |
| Unnamed, background (the default) | a completion notification, later turn | nothing |
| **Named**, either value | **only** a `SendMessage` the agent sends itself | the delivery line below |

A named agent that is never told this emits an **idle notification** carrying no content:

```json
{"type":"idle_notification","from":"<name>","idleReason":"available"}
```

Verified on **v2.1.221**: a named `Explore` agent dispatched with `run_in_background: false` finished, emitted two idle notifications, and delivered nothing until it was told to call `SendMessage`. Its full report then arrived intact on the next turn.

Consequences:

- **`run_in_background: false` does not block for a named agent.** The dispatch returns `Spawned successfully … will receive instructions via mailbox` immediately. Treat `name` and synchronous collection as mutually exclusive: when you need the result as a tool result in the same turn, dispatch **without** a name.
- **An idle notification means "available", not "done" and not "failed".** It says the agent stopped producing; it says nothing about whether it holds an answer. Ask for the answer.

### Dispatch named agents in the BACKGROUND

`"main"` is the lead's address and is available to background subagents only. A named agent does not block anyway (above), so a foreground named dispatch buys nothing and costs the agent its only reliable route to you. **Name it and background it, or leave it unnamed** — those are the two shapes. Whether a foreground named agent can address the lead at all is **unverified**; do not rely on it.

### The delivery line — paste it into every named dispatch

> Your plain text output is not visible to the lead. Deliver your final report with one `SendMessage` call to `"main"`, in the report format this prompt specifies. Do not reply in plain text, and do not send JSON status objects — the report is prose.

Without that line the report is written into the void and the work has to be re-collected.

### The recipient is yours to supply — the agent cannot look it up

**`"main"` IS the lead's address** — a literal, not a name, needing no lookup.

**A background subagent can address nothing it was not given.** `ListAgents` is absent from the background built-in set above, so the agent holds `SendMessage` and no way to find a target. Its whole address book is:

1. **`"main"`** — the lead, when it is running in the background.
2. **The `from` attribute of a message it received** — copy it into `to`. Zero-config, but only once someone has spoken first.
3. **A name written into its dispatch prompt** — the only route to a peer, and the only route to the lead from a *foreground* named agent.

**So the dispatcher states the recipient in the prompt; it is never discoverable from inside.** The lead knows its own address and the agent never will. "Report back when done" names no route and produces exactly the silent finish this section exists to prevent.

### Receiving and replying

- An incoming message arrives wrapped as `<cross-session-message from="X">`. **Reply by copying its `from` into your `to`.**
- Delivery is automatic — there is no inbox to poll, and messages drain at the receiver's next tool round, so a busy peer is never a reason to hold off.
- Structured JSON is reserved for the `shutdown_request` / `plan_approval_response` protocol. Progress and findings go as prose.
- **Never ask a peer to run something your own session blocked.** Permission boundaries are per-session, and routing blocked work sideways launders the user's decision. Send it back to the lead instead.
- `SendMessage` survives the background tool filter above, so a background subagent always has it.

### Teams

`team_name` on the dispatch is **deprecated and ignored** — the session has one implicit team — and there is **no team create or delete tool**. A team is just named agents: `name` is the whole mechanism. `TaskStop` still accepts a teammate's `name@team` form alongside a plain name or task id.

## A quiet agent — steer it, never mark it failed

`SendMessage` to the agent's name is a live channel, and on Claude Code it reaches a **running, idle, completed, or `TaskStop`ped** agent alike — a completed or stopped one auto-resumes in the background with no new `Agent` call. Going quiet is therefore never grounds to declare failure, re-dispatch, or reap. Steering costs one message; every rung below it costs work.

Ladder, cheapest first:

1. **Ask for what it has.** `SendMessage` to its name, requesting the report in the required format and stating that partial results are acceptable.
2. **Name the delivery mechanism.** An agent that idled with no content has most likely answered in plain text. Tell it explicitly to call `SendMessage` with `to: "main"` and not to reply in plain text.
3. **Narrow or redirect.** Shrink the scope, restate the required output shape or path, or tell it to write incrementally.
4. **Only then diagnose** a concrete cause — auth failure, a tool erroring, an unreachable path, an unbounded scope — before considering a re-dispatch, and reap the old agent first so two writers never share a target.

Report a delegation as failed only after the channel itself produced nothing across those rungs, and say which rungs were tried.

## Reaping

`TaskStop` accepts the task id, a named background agent's name, or a teammate's `name@team`. Stopping ends the run, so **collect before you reap** — though a completed agent can still be resumed by `SendMessage`, so "quiet" is never itself a reason to kill one. Reap when the work is genuinely done, superseded, or about to be replaced (reap *before* re-dispatching over the same target, or two writers clobber each other).

## Limits

| Limit | Value | Control |
|-------|-------|---------|
| Nesting depth | 3 layers below the main conversation | At the limit the `Agent` tool is withheld from subagents. |
| Concurrent subagents | 20 (v2.1.217+) | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`; ultracode sessions exempt. Over the limit the spawn fails with `Concurrent subagent limit reached` and must NOT be retried. |
| Per-session spawns | 200 | `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`; `/clear` resets it. Finished subagents still count. |

## Worktree isolation

`isolation: "worktree"` gives the subagent a temporary git worktree — an isolated copy of the repo, **branched from the default branch, not the parent session's `HEAD`**. It is cleaned up automatically if the subagent makes no changes. Setup costs disk and a few hundred ms, so use it only when parallel writers would otherwise collide.

- Since **v2.1.203** a worktree subagent's Bash/PowerShell commands run inside its worktree, and a command whose working directory resolves to the main checkout fails instead of running there.
- Since **v2.1.210** that check covers the whole repository containing the launch directory — and, for a session already inside a linked worktree, the main checkout it links from.

The concrete on-disk location is a harness detail, not a documented contract: verify the path the dispatch returns rather than assuming one, and see `agent-worktrees` for the naming and cleanup conventions this setup expects.

## Other inherited context

- A subagent starts with a **fresh, isolated context window** — no conversation history, no files already read, no skills already loaded. Only a fork inherits the parent conversation.
- Since v2.1.198 subagents inherit the main conversation's **extended thinking** setting; there is no per-subagent thinking control.
- The built-in `Explore` agent inherits the main model, capped at Opus on the Claude API (v2.1.198+).
- `effort` (`low`…`max`) can be set per subagent and overrides the session effort level.
