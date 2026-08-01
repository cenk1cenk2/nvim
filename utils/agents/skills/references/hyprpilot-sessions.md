# hyprpilot Agent Sessions — surface, completion signals, limits

Facts about sessions started through the **`hyprpilot_harness`** MCP server. Shared between the hyprpilot-facing skills; not part of the `harness-<provider>-*` family, which covers the mechanics of whichever runtime *you* are running under.

**⛔ A hyprpilot session is NOT an in-harness subagent, and the two do not mix.** The `agent-*` skills (`agents-delegate`, `agent-background`, `agent-coordinator`, `agent-bulldozer`) are about subagents your own runtime dispatches and tracks — it re-invokes you when they finish, so you do not poll them. A hyprpilot session is a separate OS process running a different vendor CLI, owned by an MCP sidecar, with its own transcript on disk. **Your runtime does not track it and will not wake you for it.**

So the `agent-*` "never poll harness-tracked work" rule does not cover these, and nothing here transfers to those skills either. Keep the two vocabularies apart.

## The tool surface (7)

| Tool | Use |
| --- | --- |
| `list_profiles` | Discovery. Always first — ids are captain-defined and the harness is opt-in per profile, so a configured profile may be absent. |
| `spawn` | Start a NEW session. Returns a `session` handle. |
| `session_send` | Next turn on the SAME conversation. Never `spawn` again for a follow-up. |
| `session_status` | **The cheap poll.** State without reading the transcript. |
| `session_read` | The transcript itself, paginated. |
| `session_list` | Recover a handle you lost. |
| `session_kill` | Stop a running session, or reap a finished one. |

## Two ways to drive a session — pick by what your client supports

The **session tools** (`spawn` / `session_*`) are the path that always works, on every
client. Everything below in this document describes them.

There is also a **SEP-2663 Tasks path**, served on the same server, for clients that
declare `io.modelcontextprotocol/tasks`. It is not a different feature — it is the same
launch, addressed by a standard protocol instead of hyprpilot's own tools.

**How to tell which one you got:** look at the `spawn` result. `resultType: "task"` means
you are on the task path; anything else means you are on the session tools. Do not check
capabilities and guess — the server decides per request, and a client that declared
nothing gets the ordinary result whatever it believes about itself.

| | Session tools | Tasks |
| --- | --- | --- |
| Start | `spawn` → `session` handle | `spawn` → `resultType: "task"`, `taskId` |
| Poll | `session_status` | `tasks/get` |
| Stop | `session_kill` | `tasks/cancel` |
| Read output | `session_read`, or `jq` the transcript | the `result` inside a `completed` task |

**As of claude 2.1.220, codex 0.146.0 and opencode 1.18.11, no vendor CLI declares the
extension** — measured against a real handshake. So in practice you are on the session
tools. The task path exists so that a client which grows support works immediately.

### If you are on the task path

- **A task id is `<session-handle>:<turn>` — it names ONE TURN, not the conversation.**
  Terminal states are immutable per the spec, so turn 1's task keeps reporting
  `completed` forever, while the session handle moves on. `session_send` mints a new task.
- **Do not parse the id to get the handle.** It rides `_meta["io.hyprpilot/session"]` on
  both the `spawn` result and every `tasks/get`. You need the handle for any session tool.
- **The session tools still work on a task-created session.** `session_status`,
  `session_read` and `session_kill` all take the handle as usual — the two paths address
  the same thing.
- **Every exit is `completed`, including a non-zero one.** `failed` is reserved for a
  JSON-RPC error; an agent that ran and failed is a *successful call reporting a failure*.
  Read `status_message` and the `exitCode` in the result before calling it a success.
- **`tasks/cancel` cancels that TURN.** Cancelling an already-terminal task is a no-op and
  leaves the conversation alone — it will not stop a later turn that is running.
- **`tasks/update` is unimplemented** (`-32601`). The harness never emits `input_required`,
  so no task can have outstanding input requests.
- **Task ids die with the sidecar**, and finished ones are dropped by session eviction.
  SEP-2663 presents a task id as a durable handle you can resume polling after a restart;
  that does not hold here. `ttl_ms` is `null` because retention is bounded by count and
  process lifetime, not by a duration.
- **`notifications/tasks` is pushed, but do not build on it** — see below.

## Completion signals — which one applies to you

Four mechanisms, and the right choice depends on **who is waiting** and **how**.

### 1. Channels — a push wake-up that does NOT work here. Assume silence.

The harness pushes `notifications/claude/channel` when a turn ends, and `mcp.harness.notifyOnComplete` defaults **true**, so the server side is live. The *client* side is what fails.

**Registration was tried on this setup and did not work; the launch flag has been reverted.** Nothing registers the channel today, so no completion event reaches anyone. Treat the mechanism as unavailable rather than untested — it is not a knob you can turn on by remembering a flag.

Why it stays documented at all: the server keeps emitting, so if a future client registers successfully it becomes strictly better than polling — no loop, no interval. Until something demonstrates a channel block actually arriving, it is not a wake-up you may build on.

Even where it does work it is narrow:

- **Interactive only** — a headless `claude -p` lead never receives one.
- **Claude Code only** — codex and opencode leads get nothing; it is a Claude Code protocol extension.
- A client that has not registered **drops it silently and returns no error** — which is exactly why the failure went unnoticed long enough to be worth this warning. An unfired watcher looks identical to a hung agent.

**So: every detached session must be watched or polled.** Silence after a spawn is the normal case here, not a malfunction — do not read it as the agent still working, and do not wait on a push that is never coming.

### 1b. `notifications/tasks` — spec-named, same silence problem.

On the task path the harness also pushes `notifications/tasks` when a turn ends, carrying
the full task state. It is real and it is standard — but treat it exactly like channels:

- **It cannot be subscribed to.** SEP-2663 has clients opt in via `subscriptions/listen`,
  and rmcp refuses to route task notifications through a subscription (its
  `SubscriptionFilter` has no `taskIds` field). Only resource notifications are routable.
  So this arrives unsolicited on the peer channel.
- A client that does not handle the method **drops it silently**, exactly as with channels.

**Poll `tasks/get` and honour its `pollIntervalMs`.** Treat any push you happen to receive
as a bonus that lets you poll sooner, never as the thing you are waiting on.

### 2. `session_status` — the cheap poll. Any MCP caller.

```jsonc
{ "status": "running" | "exited",
  "exitCode": 0,          // omitted while running
  "turn": 2,              // which turn of the conversation
  "transcriptBytes": 41233,
  "hasResult": true }
```

Costs a handle lookup and one `stat`. Prefer it over `session_list` (returns every session) and over `session_read` (returns up to 60 kB of transcript) whenever the question is "is it done".

**`transcriptBytes` is the field worth building on.** It answers what `status` cannot: is a running agent *progressing* or *wedged*? A real run —

```
t+0s  running 0 B → t+6s running 8567 B → t+9s running 8834 B
t+15s running 8834 B   ← plateau: thinking, or a long tool call
t+18s running 9568 B   ← moving again
t+21s exited  13725 B  exit 0  hasResult: true
```

"running, and `transcriptBytes` unchanged for N minutes" is a hung agent. PID liveness can never see that — a wedged process is perfectly alive. Tune N in minutes, not seconds, and treat it as a report rather than a kill trigger.

**`hasResult`** is `false` for any running session, then scans the transcript tail per vendor. Do not reimplement it (see *Extracting the answer*).

### 3. `done.json` — a marker file. Any shell.

Written into the session directory by the same `child.wait()` task that owns the exit code:

```json
{ "handle": "3b5ce010-…", "exitCode": 0, "finishedAt": 1785584247 }
```

This is the one MCP-only truth that has a first-class **bash** signal, which matters because a bash watcher cannot call an MCP tool.

```bash
[ ! -d "$SESSION_DIR" ] || [ -f "$SESSION_DIR/done.json" ]
```

**Both halves are required.** The marker is advisory — reap, eviction and sidecar shutdown delete the whole directory, so testing only for the file waits forever on a session that was cleaned up. A missing **directory** means finished-and-gone.

**The marker is cleared when a turn STARTS**, not only written when one ends. `session_send` reuses the handle and directory, so a watcher armed for the next turn does not fire on the previous turn's leftover. Corollary: absence means *not finished*, never *error*.

## `sessionInfo.files` — the session's own directory

Every result from `spawn` / `session_send` / `session_read` names them:

| Key | File | What it buys you |
| --- | --- | --- |
| `dir` | — | its absence is the "cleaned up" signal |
| `transcript` | `turns.jsonl` | `jq` the answer out instead of paging 60 kB; `wc -c` it as a shell-side `transcriptBytes` |
| `stderr` | `stderr.log` | the **launch** failure text (a flag the vendor rejects). **Empty when the failure is upstream** — see *Extracting the answer* |
| `done` | `done.json` | what `test -f` tests |
| `breadcrumb` | `session.json` | pid / pgid / owning sidecar, for diagnosing an orphan |

Everything under `files` points into a directory that can vanish. Treat a missing file as "cleaned up", never as an error.

## Extracting the answer

The terminal event differs per vendor — all three verified against the installed CLIs:

```sh
jq -r 'select(.type=="result") | .result' "$T" | tail -n1                                                   # claude
jq -r 'select(.type=="item.completed") | select(.item.type=="agent_message") | .item.text' "$T" | tail -n1   # codex
jq -r 'select(.type=="text") | .part.text' "$T" | tail -n1                                                   # opencode
```

**⛔ The `tail -n1` is not cosmetic.** `session_send` **appends to the same `turns.jsonl`**, so on turn N these queries match every turn's answer, oldest first. Drop the tail and a caller taking the first line reports turn 1's answer as the reply to turn 5 — confidently, and forever. (opencode is worse: it emits a `text` part per *sentence*, so even within one turn the query returns many lines.) This is the same trap `hasResult` avoids by scanning the tail rather than the whole file; a hand-rolled query gets no such protection.

**opencode emits no terminal event at all** — its stream ends `step_finish(reason=stop)`, and it emits a `text` part for *every* completed sentence. So "a text part exists" does not mean "finished"; only `status: exited` does. This is why `hasResult` exists and why hand-rolling it goes wrong.

### ⛔ The answer query goes blind on a failed run — always pair it with the error query

None of the three one-liners above matches anything when the turn failed upstream, so a caller running only them reports "the agent returned nothing" for what was actually an auth or billing error. Run both:

```sh
jq -r 'select(.type=="error") | .error.data.message // .error.name' "$T"
```

A real failure looked like this — **`stderr.log` was zero bytes** and the entire diagnosis lived in `turns.jsonl`:

```
Payment Required: this model uses extra usage only … your extra usage balance is empty  (statusCode 402)
```

The split to remember: **launch failure → `stderr.log`, transcript empty. Runtime failure → transcript `error` event, `stderr.log` empty.** Check both before reporting an exit code.

**That split is a turn-1 reading.** `stderr.log` is opened in append mode on every resume, exactly like the transcript, so from turn 2 onward "`stderr.log` is non-empty" no longer means *this* turn failed to launch — it may be an earlier turn's wreckage. On a multi-turn session, size it before the turn and compare, or trust the transcript's `error` events, which at least carry their own ordering.

## Limits

| | |
| --- | --- |
| Concurrent running sessions | 8 |
| Spawn nesting depth | 1 (`HYPRPILOT_SPAWN_DEPTH`) — a session you spawn cannot spawn its own |
| Sessions retained | 64 — oldest **finished** evicted, with their transcripts |
| Bytes per read | 60 000 |
| Default tail | 200 lines |
| Default turn timeout | 300 s |

## Rules that bite

- **A session is `exited` after every TURN**, not only when the conversation ends. "Is it done" always means "is this turn done".
- **One turn at a time.** `session_send` to a running session is refused; no vendor supports two concurrent turns on one conversation. `session_kill` still works on it.
- **A timeout is not a failure.** The turn returning `running` means the agent is still working — poll, never re-`spawn`.
- **Sessions die with the sidecar.** No persistence. If it restarts, running agents are killed and transcripts are lost — capture anything that must outlive the connection.
- **`session_send` replays the launch.** `cwd` / `args` / `with_config` are inherited and **rejected** if passed; only the prompt, `mode`, `wait` and `timeout_seconds` are per-turn.
- **Paging is MCP-style.** `cursor` in, `nextCursor` out, opaque. **No `nextCursor` means finished AND fully read.** An unrecognised cursor is an error, not a silent reset.
- **Launches are detached — `wait` defaults to false.** `spawn` / `session_send` return as soon as the turn starts. Opting into `wait: true` is rarely right: it returns the whole raw event stream inline with no `tail` and no `cursor` to trim it (measured on one trivial three-item task: 14 kB on opencode, 121 kB on claude), and it still comes back `running` if the turn outlives `timeout_seconds`, so it never even guarantees an answer. Poll `session_status`, then pull the answer out of `files.transcript`.
- **The handle is the only id.** It is minted at `spawn`, arrives in the first result, never changes, and is what every tool takes. There is no vendor session id on the wire — hyprpilot keeps the vendor's own id internally as the token `session_send` resumes with, and that is all it ever meant.
- **`sessionInfo.mode` reports the profile's mode, not the launched one.** A mode imposed through `args` (opencode `--agent plan`) does not show up there; `sessionInfo.argv` is the honest record. The same caveat as `model` under a `with_config` overlay.
- **`spawn` runs a profile's `command` as this user.** The `provider` picks a flag projection, not a sandbox.
