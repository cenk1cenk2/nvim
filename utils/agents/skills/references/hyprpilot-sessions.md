# hyprpilot Agent Sessions — surface, completion signals, limits

Facts about sessions started through the **`hyprpilot_harness`** MCP server. Shared between the hyprpilot-facing skills; not part of the `harness-<provider>-*` family, which covers the mechanics of whichever runtime *you* are running under.

**A hyprpilot session is NOT an in-harness subagent, and the two do not mix.** The `agent-*` skills (`agent-delegate`, `agent-background`, `agent-coordinator`, `agent-bulldozer`) are about subagents your own runtime dispatches and tracks — it re-invokes you when they finish, so you do not poll them. A hyprpilot session is a separate OS process running a different vendor CLI, owned by an MCP sidecar, with its own transcript on disk. **Your runtime does not track it and will not wake you for it.**

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

**Do not plan around it arriving.** Tasks became an official extension in the 2026-07-28
spec, but the reference implementation still carries an experimental disclaimer, the
official client support matrix does not track the extension at all, and neither Claude
Code nor opencode has announced work on it — Claude Code shipped its own auto-backgrounding
for long MCP calls instead, which removes most of the pressure to adopt the spec. Neither
project publishes a roadmap, so this is *no signal* rather than a commitment either way:
re-check the handshake when it matters, and never write a skill step that assumes the task
path is available.

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

**The marker is cleared when a turn STARTS**, not only written when one ends. `session_send` reuses the handle and directory, so once the next turn is running the previous turn's marker is gone. Corollary: absence means *not finished*, never *error*.

**Which makes arm ORDER load-bearing: arm the watcher AFTER `session_send` returns, never before.** The clear happens when the turn starts, not when you decide to watch, so anything armed ahead of the send sees the previous turn's leftover `done.json` and fires instantly on stale state. Measured: a watcher armed before a `session_send` reported "turn finished" before the new turn had produced a single event. `session_send` returns once the turn is running and the marker is already cleared, so its result is the correct arming point.

## Watching a turn live — stream the transcript file

`session_status` and `done.json` both answer *is it done*. Neither shows a turn **in progress**, and `session_read { wait: true }` blocks your own call to do it. The third option: `turns.jsonl` is an append-only JSONL file, so tailing it gives per-event notifications while the agent works, with no blocking call and no raw payloads in context.

**Whether that can run in the background is a property of YOUR runtime, not of hyprpilot** — see `harness-<provider>-agent-background`. What is hyprpilot's side is the file, its event vocabulary, and the two ways a naive tail goes wrong.

```bash
# BEFORE the send — capture the byte offset
OFF=$(wc -c < "$T")
# ...session_send...
# AFTER it returns — arm on the offset, not on `tail -n0`
tail -c +$((OFF+1)) -F "$T" | jq -r --unbuffered '
  if .type=="tool_use" then "TOOL: " + .part.tool
  elif .type=="text" then "TEXT: " + (.part.text | .[0:160])
  elif .type=="error" then "ERROR: " + (.error.data.message // .error.name)
  else empty end'
```

- **`tail -n0` silently loses the head of the turn.** Everything written between `session_send` returning and the tail attaching is skipped — one measured run lost the agent's entire first step that way. The byte offset captured before the send is the only gap-free start.
- **Every pipe stage must flush per line** — `jq --unbuffered`, `grep --line-buffered`. Without it events arrive in blocks or not at all.
- **Filter, never pipe raw.** `tool_use` payloads are the bulk of the file; emitting them whole defeats the point of not using `wait: true`.

### The opencode event vocabulary — get the field paths right

Verified against opencode 1.18.11. A filter keyed on the wrong shape matches nothing and emits nothing, which is indistinguishable from a quiet agent:

| `.type` | Where the payload is | Note |
| --- | --- | --- |
| `tool_use` | `.part.tool` — the tool name | **Not** `.type=="tool"`, and the name is not at the top level. One measured run had 9 `tool_use` events and a filter on `.type=="tool"` emitted zero. |
| `text` | `.part.text` | One per emitted text block, several per turn. |
| `step_start` / `step_finish` | `.part.reason` on `step_finish` | Bracket each step. **`reason: "stop"` marks the end of a TURN; `reason: "tool-calls"` is an intermediate step.** That field is the only turn boundary in the file — see *Extracting the answer*. |
| `error` | `.error.data.message` // `.error.name` | Upstream failures (auth, quota) land here, not in `stderr.log`. |

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

**Pick by what you actually want — this ranking is the whole point, and every row below the first costs more tokens for the same answer:**

| Want | Use | Cost |
| --- | --- | --- |
| The answer | `jq` on `files.transcript` | The answer's own size |
| Progress while it runs | filtered tail of `turns.jsonl` (see *Watching a turn live*) | One small event per step |
| Only "is it done" | `session_status` | A `stat` |
| The raw stream, or a shell you cannot reach | `session_read`, or `wait: true` | Up to 60 kB per read, untrimmable |

**`session_read` is situational, not forbidden.** `jq` is the cheap default and should be the reflex, but the ranking is about cost, not permission. Reach for `session_read` when you actually want the event stream, when the run was small enough that the difference does not matter, when you need the vendor's raw shape to diagnose something, or when no shell is available to `jq` with. The rule is *know which one you are paying for* — not "never page".

**What it costs when you do page it:** it returns the vendor's raw event stream, and the `tool_use` events can dwarf the answer.

**On opencode the amplification is extreme, and it is not proportional to the work.** Its `read` tool embeds the file's entire contents in the event *and* re-attaches every loaded instruction file (`AGENTS.md`, `CLAUDE.md`) as a system-reminder on each call. Measured: a ten-file read survey produced a **389 kB** transcript whose actual answer was twelve lines. Transcript size therefore tracks how many tools the agent called and how big the instruction files are — never treat it as a proxy for how much the agent produced.

The terminal event differs per vendor. **Scope to the latest turn inside `jq`, never with `tail`:**

```sh
jq -rs '[ .[] | select(.type=="result") | .result ] | last' "$T"                                          # claude
jq -rs '[ .[] | select(.type=="item.completed" and .item.type=="agent_message") | .item.text ] | last' "$T" # codex
jq -rs '                                                                                                   # opencode
  [ .[] | select(.type=="text" or (.type=="step_finish" and .part.reason=="stop")) ] as $e
  | ($e | map(.type) | rindex("step_finish")) as $end
  | ($e[:$end] | map(.type) | rindex("step_finish")) as $prev
  | $e[(($prev // -1) + 1):$end] | map(.part.text) | join("\n")' "$T"
```

**`| tail -n1` is WRONG here and the earlier version of this file had it.** `tail` counts **lines**, not events — so it truncates any multi-line answer down to its final line. Measured: a three-paragraph opencode answer came back as the single word `DONE-TURN-TWO.`, the other two paragraphs silently gone. The scoping has to happen where the events are still events, which is inside `jq` — hence `-s` (slurp) plus `last`. Same correction applies to all three vendors; the selects themselves are unchanged and still verified, only the way the latest one is picked was broken. The opencode slice is measured against a 2-turn transcript; the claude and codex lines are the same mechanical line-to-element fix, not a fresh measurement.

**Why scoping is needed at all:** `session_send` **appends to the same `turns.jsonl`**, so on turn N an unscoped query matches every turn's answer, oldest first. Take the first match and you report turn 1's answer as the reply to turn 5 — confidently, and forever.

**opencode needs the extra work because it emits no terminal event and no per-turn event.** Its stream ends `step_finish`, and it emits a `text` part per block of prose — a measured turn produced one `text` part mid-turn (before its tool calls) and another at the end, so "the last `text` part" is one block of the answer, not the answer. The turn boundary is **`step_finish` with `.part.reason == "stop"`**; intermediate steps carry `reason: "tool-calls"`. That is what the slice above keys on. Other stop reasons exist (length, error), so treat a turn with no `reason: "stop"` as unfinished or failed and check `session_status` / the `error` query rather than widening the match.

Corollary: "a text part exists" never means "finished"; only `status: exited` does. This is why `hasResult` exists and why hand-rolling it goes wrong.

### The answer query goes blind on a failed run — always pair it with the error query

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
- **`exitCode: 0` and `hasResult: true` mean the TURN ended cleanly, never that the TASK was completed.** They are process and transcript facts; neither inspects whether the agent did what it was asked. A measured run gave a 4-step prompt to a small model, which answered steps 1 and 2, stopped, and exited 0 with `hasResult: true` and no error event anywhere — the harness reported that success faithfully. Read the answer against what you asked for before relaying it, and re-`session_send` the remainder rather than treating the exit status as an acceptance test.
- **One turn at a time.** `session_send` to a running session is refused; no vendor supports two concurrent turns on one conversation. `session_kill` still works on it.
- **A timeout is not a failure.** The turn returning `running` means the agent is still working — poll, never re-`spawn`.
- **Sessions die with the sidecar.** No persistence. If it restarts, running agents are killed and transcripts are lost — capture anything that must outlive the connection.
- **`session_send` replays the launch.** `cwd` / `args` / `with_config` are inherited and **rejected** if passed; only the prompt, `mode`, `wait` and `timeout_seconds` are per-turn.
- **Paging is MCP-style.** `cursor` in, `nextCursor` out, opaque. **No `nextCursor` means finished AND fully read.** An unrecognised cursor is an error, not a silent reset.
- **Launches are detached — `wait` defaults to false.** `spawn` / `session_send` return as soon as the turn starts. Opting into `wait: true` is rarely right: it returns the whole raw event stream with no `tail` and no `cursor` to trim it (measured on one trivial three-item task: 14 kB on opencode, 121 kB on claude), and it still comes back `running` if the turn outlives `timeout_seconds`, so it never even guarantees an answer. Poll `session_status`, then pull the answer out of `files.transcript`.
- **A runtime that auto-backgrounds slow MCP calls does NOT make `wait: true` cheap.** Some runtimes move an MCP call that outlives a threshold into a background task — the turn stops stalling, and the payload arrives later in a notification. **Later is not smaller.** Measured: a `wait: true` follow backgrounded on schedule and then delivered a 60 kB slice of raw events to answer what `jq` on the same transcript answered in fourteen lines. Read the auto-background threshold as a fix for *blocking* only; the token cost is identical either way, and the ranking below is unchanged by it.
- **The handle is the only id.** It is minted at `spawn`, arrives in the first result, never changes, and is what every tool takes. There is no vendor session id on the wire — hyprpilot keeps the vendor's own id internally as the token `session_send` resumes with, and that is all it ever meant.
- **`sessionInfo.mode` reports the profile's mode, not the launched one.** A mode imposed through `args` (opencode `--agent plan`) does not show up there; `sessionInfo.argv` is the honest record. The same caveat as `model` under a `with_config` overlay.
- **`spawn` runs a profile's `command` as this user.** The `provider` picks a flag projection, not a sandbox.
