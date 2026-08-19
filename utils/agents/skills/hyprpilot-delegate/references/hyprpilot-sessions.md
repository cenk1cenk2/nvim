# hyprpilot Agent Sessions — surface, completion signals, limits

Facts about sessions started through the **`hyprpilot-harness`** MCP server. Shared between the hyprpilot-facing skills; not part of the `harness-<provider>-*` family, which covers the mechanics of whichever runtime *you* are running under.

**A hyprpilot session is NOT an in-harness subagent, and the two do not mix.** The `agent-*` skills (`agent-delegate`, `agent-background`, `agent-coordinator`, `agent-bulldozer`) are about subagents your own runtime dispatches and tracks — it re-invokes you when they finish, so you do not poll them. A hyprpilot session is a separate OS process running a different vendor CLI, owned by an MCP sidecar, with its own transcript on disk. **Your runtime does not track it and will not wake you for it.**

So the `agent-*` "never poll harness-tracked work" rule does not cover these, and nothing here transfers to those skills either. Keep the two vocabularies apart.

## The preferred path — resources, then tasks, then tools

**Read a session through its RESOURCES. That is the default and it works on every client that can read an MCP resource.** The extraction each view performs is done server-side, so the answer arrives as the answer rather than as a transcript you have to mine.

Three tiers, and you pick the highest one your client supports:

| Tier | Poll with | Read the answer with | Available |
|---|---|---|---|
| **1. Tasks + resources** | `tasks/get` | `hyprpilot://sessions/<handle>/result` | only when `spawn` returns `resultType: "task"` |
| **2. Resources** *(the normal case)* | `session_status`, or the `/status` view | `hyprpilot://sessions/<handle>/result` | any client that reads MCP resources |
| **3. Tools and files** | `session_status` | `session_read`, or `jq` on `files.transcript` | always — the floor, and the only tier a shell can reach |

**Tier 2 is what you are on today.** No vendor CLI declares the tasks extension (measured — see *Tasks*), so tier 1 is aspirational; tier 2 works now and is verified.

**Dropping to tier 3 is a fallback, not a failure**, and two things legitimately land you there:

- **No resource-read facility**, or a shell watcher — bash cannot call an MCP tool, so the files are the only route.
- **You want a projection no view defines.** "Every tool it called", "just the errors", "how many files it read". The resource surface hands you views hyprpilot already defined; `jq` projects anything. See *Keeping context pure*.

## The resource tree

```
hyprpilot://profiles                          what can be launched (same as list_profiles)
hyprpilot://sessions                          every live session (same as session_list)
hyprpilot://sessions/<handle>                 the session: status + every turn's outcome and URI
hyprpilot://sessions/<handle>/status          status                     ┐
hyprpilot://sessions/<handle>/result          THE ANSWER                 │ latest turn
hyprpilot://sessions/<handle>/transcript      raw JSONL                  │
hyprpilot://sessions/<handle>/stderr          vendor stderr              ┘
hyprpilot://sessions/<handle>/turns/<n>/{status,result,transcript,stderr}
```

The bare `/<view>` forms are shortcuts to the **latest turn** — "what did it just say" is the usual question, so they save you reading the turn count first. Every view is also addressable per turn.

**`/result` is the one to reach for.** It performs the per-vendor extraction, and the two ways a hand-rolled version goes wrong are structurally impossible in it:

- **It slices by EVENT, never by line**, so a multi-line answer survives whole. A line-based scope truncates a three-paragraph answer to its last line.
- **An `error` event OUTRANKS text**, so an upstream 402 or auth failure is reported as the error rather than as "the agent returned nothing".

**Gate the read on the turn being finished.** While the turn is still running `/result` returns an **empty string** — not an error, and deliberately not the previous turn's answer. So empty means "ask again later", never "it produced nothing"; check `status: exited` (or `hasResult`) first rather than inferring anything from the emptiness.

**Once the turn is finished it never comes back blank.** The three no-answer shapes land in different places — an `error` event in the transcript, a launch failure in `stderr.log` with the transcript empty, or neither — and `/result` falls through transcript, stderr and exit code, then names which one happened.

**`hyprpilot://sessions/<handle>` answers "which turns exist and which is worth fetching" in one read**, so you never walk `turns/1`, `turns/2`, … probing for the end:

```jsonc
{ "session": "…", "status": "exited", "turn": 2, "exitCode": 0, "hasResult": true,
  "transcriptBytes": 1032, "profile": "…", "provider": "opencode",
  "createdAt": 1786634041, "lastTurnAt": 1786634047,
  "turns": [
    { "turn": 1, "status": "exited", "exitCode": 0, "uri": "hyprpilot://sessions/…/turns/1/result" },
    { "turn": 2, "status": "exited", "exitCode": 0, "uri": "hyprpilot://sessions/…/turns/2/result" } ] }
```

That `turns` array is the routing view — outcome plus the URI that fetches it, per turn. The same array rides `session_status`.

**`/transcript` and `/stderr` are capped at 60 000 bytes and cut from the FRONT**, since the answer is at the end. `session_read` stays the pager when you need the whole stream, because a resource read has no cursor.

**How your runtime reads a resource is a runtime mechanic** — the tool name and its parameters live in `agent-background-harness-<provider>`, not here.

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

**No tool takes a filter, query or `jq` expression.** The full parameter set is `spawn { profile, prompt, file, cwd, mode, args, with_config, wait, timeout_seconds }`, `session_send { session, prompt, file, mode, wait, timeout_seconds }`, `session_read { session, cursor, tail, wait, timeout_seconds }`, and `{ session }` alone for status/kill. Projection happens either by picking a resource view or by `jq` on disk — never as an argument.

## Tasks — the same session, addressed by protocol

Served on the same server for clients that declare `io.modelcontextprotocol/tasks`. Not a different feature: the same launch, reached by a standard protocol instead of hyprpilot's own tools.

**How to tell which one you got:** look at the `spawn` result. `resultType: "task"` means you are on the task path; anything else means you are not. Do not check capabilities and guess — the server decides per request, and a client that declared nothing gets the ordinary result whatever it believes about itself.

| | Session tools | Tasks |
| --- | --- | --- |
| Start | `spawn` → `session` handle | `spawn` → `resultType: "task"`, `taskId` |
| Poll | `session_status` | `tasks/get` |
| Stop | `session_kill` | `tasks/cancel` |
| Read output | `/result` resource, `session_read`, or `jq` | `/result` resource, or the `result` inside a `completed` task |

**As of claude 2.1.220, codex 0.146.0 and opencode 1.18.11, no vendor CLI declares the extension** — measured against a real handshake. Tasks became official in the 2026-07-28 spec, but the reference implementation still carries an experimental disclaimer, the client support matrix does not track it, and Claude Code shipped its own auto-backgrounding for long MCP calls instead. Re-check the handshake when it matters; never write a step that assumes the task path is there.

If you are on it:

- **A task id is `<session-handle>:<turn>` — it names ONE TURN, not the conversation.** Terminal states are immutable, so turn 1's task keeps reporting `completed` forever while the session moves on. `session_send` mints a new task.
- **A terminal task's payload never moves.** Every field of its `sessionInfo` — provenance, `pid`, `turnStartedAt`, file paths — is read off that turn's own record, so re-polling a finished task after a later turn returns the bytes it returned the first time.
- **Do not parse the id to get the handle.** It rides `_meta["io.hyprpilot/session"]` on the `spawn` result and every `tasks/get`.
- **The session tools still work on a task-created session.** Both paths address the same thing.
- **Every exit is `completed`, including a non-zero one.** `failed` is reserved for a JSON-RPC error; an agent that ran and failed is a *successful call reporting a failure*. Read the `exitCode` inside the completed result before calling it a success — this server never populates `status_message`, so waiting for one waits forever.
- **`tasks/cancel` cancels that TURN.** Cancelling an already-terminal task is a no-op and will not stop a later turn.
- **`tasks/update` is unimplemented** (`-32601`). The harness never emits `input_required`.
- **Task ids die with the sidecar**, and finished ones are dropped by session eviction. `ttl_ms` is `null` because retention is bounded by count and process lifetime, not duration.

## Storage — each turn owns a directory

```
<sessionInfo.files.dir>/
├── session.json          the breadcrumb: pid / pgid / owning sidecar
└── turns/
    ├── 1/
    │   ├── turns.jsonl   this turn's events
    │   ├── stderr.log    this turn's stderr
    │   └── done.json     this turn's completion marker
    └── 2/ …
```

Three consequences worth holding, because each retires a trap that used to need a workaround:

- **Reading turn 1 cannot reach turn 2.** A turn's output is a whole file rather than a byte range of a shared one, so no boundary has to be guessed and no offset arithmetic is involved.
- **"`stderr` is non-empty" means THIS turn wrote it.** Nothing from an earlier turn can appear there.
- **A fresh turn is a fresh directory, so no marker is ever cleared.** Turn 2 cannot see turn 1's `done.json`, which means a watcher can be armed whenever you like — there is no stale-marker window and no arm-order rule.

`sessionInfo.files` names the session's paths plus the CURRENT turn's:

| Key | Points at | What it buys you |
| --- | --- | --- |
| `dir` | the session directory | its absence is the "cleaned up" signal |
| `breadcrumb` | `session.json` | pid / pgid / owning sidecar, for diagnosing an orphan |
| `turnsDir` | `turns/` | the parent of every turn |
| `turn` | a number | which turn the four keys below describe |
| `turnDir` | `turns/<n>/` | what a watcher tests |
| `transcript` | `turns/<n>/turns.jsonl` | `jq` a projection; `wc -c` it as a shell-side `transcriptBytes` |
| `stderr` | `turns/<n>/stderr.log` | **launch** failure text (a flag the vendor rejected) |
| `done` | `turns/<n>/done.json` | what `test -f` tests |

Earlier turns are not listed: they are `<turnsDir>/<n>/` for every `n` up to `turn`, which is inferable. Everything under `files` can vanish — treat a missing file as "cleaned up", never as an error.

## Completion signals — which one applies to you

### 1. Channels — a push wake-up that does NOT work here. Assume silence.

The harness pushes `notifications/claude/channel` when a turn ends, and `mcp.harness.notifyOnComplete` defaults **true**, so the server side is live. The *client* side is what fails.

**Registration was tried on this setup and did not work; the launch flag has been reverted.** Nothing registers the channel today, so no completion event reaches anyone. Treat the mechanism as unavailable rather than untested.

Even where it works it is narrow: **interactive only** (a headless `claude -p` lead never receives one), **Claude Code only**, and a client that has not registered **drops it silently with no error** — which is exactly why the failure went unnoticed. An unfired watcher looks identical to a hung agent.

**So every detached session must be watched or polled.** Silence after a spawn is the normal case, not a malfunction.

### 1b. Resource notifications — real, and not yours to arm

A `session_send` turn starting emits `resources/updated` for its session, and a turn ending emits `updated` and `list_changed`. A fresh `spawn` announces itself with `list_changed` alone — there is no prior state to invalidate. A **client** that opens `subscriptions/listen` is woken by them and can then read only the view it wants.

**That is a client capability, not an agent one.** No resource-subscribe tool is exposed to you, so you cannot arm it and must not plan around being woken by it. What it changes for you is nothing about waiting — and everything about the read *after* you wake, which is now one small resource fetch.

`notifications/tasks` is pushed on the task path with the same caveat: rmcp refuses to route task notifications through a subscription, so it arrives unsolicited and a client that does not handle the method drops it silently. Poll `tasks/get` and honour its `pollIntervalMs`; treat any push you happen to receive as permission to poll sooner.

### 2. `session_status` — the cheap poll. Any MCP caller.

```jsonc
{ "status": "running" | "exited",
  "exitCode": 0,          // omitted while running
  "turn": 2,
  "transcriptBytes": 41233,
  "hasResult": true,
  "turns": [ { "turn": 1, "status": "exited", "exitCode": 0, "uri": "…/turns/1/result" }, … ] }
```

Costs a handle lookup and one `stat`. Prefer it over `session_list` (every session) and `session_read` (up to 60 kB) whenever the question is "is it done".

**`transcriptBytes` is the field worth building on.** It answers what `status` cannot: is a running agent *progressing* or *wedged*?

```
t+0s  running 0 B → t+6s running 8567 B → t+9s running 8834 B
t+15s running 8834 B   ← plateau: thinking, or a long tool call
t+18s running 9568 B   ← moving again
t+21s exited  13725 B  exit 0  hasResult: true
```

"running, and `transcriptBytes` unchanged for N minutes" is a hung agent. PID liveness can never see that — a wedged process is perfectly alive. Tune N in minutes, and treat it as a report rather than a kill trigger.

**`hasResult`** is `false` for any running session, then scans the turn's tail (200 lines) per vendor.

### 3. `done.json` — a marker file. Any shell.

Written into the turn's own directory by the same `child.wait()` task that owns the exit code:

```json
{ "handle": "3b5ce010-…", "exitCode": 0, "finishedAt": 1785584247 }
```

This is the one MCP-only truth with a first-class **bash** signal, which matters because a bash watcher cannot call an MCP tool.

```bash
[ ! -d "$TURN_DIR" ] || [ -f "$TURN_DIR/done.json" ]
```

**Both halves are required.** The marker is advisory — reap, eviction and sidecar shutdown delete the whole session directory, so testing only for the file waits forever on a session that was cleaned up. A missing **directory** means finished-and-gone.

Take `$TURN_DIR` from the `sessionInfo.files.turnDir` of the call that started the turn: each turn writes into its own directory, so the marker you are waiting on cannot be a previous turn's.

## Watching a turn live — stream the turn's transcript

`session_status` and `done.json` both answer *is it done*. Neither shows a turn **in progress**, and `session_read { wait: true }` blocks your own call to do it. The third option: `turns.jsonl` is append-only, so tailing it gives per-event notifications while the agent works, with no blocking call and no raw payloads in context.

**Whether that can run in the background is a property of YOUR runtime** — see `agent-background-harness-<provider>`. What is hyprpilot's side is the file, its event vocabulary, and the flush discipline.

```bash
tail -F "$TURN_DIR/turns.jsonl" | jq -r --unbuffered '
  if .type=="tool_use" then "TOOL: " + .part.tool
  elif .type=="text" then "TEXT: " + (.part.text | .[0:160])
  elif .type=="error" then "ERROR: " + (.error.data.message // .error.name)
  else empty end'
```

- **No byte offset is needed.** The turn's file starts empty and belongs to this turn alone, so tailing it from the beginning captures the whole turn — `tail -F` also waits out the moment before the file exists.
- **Every pipe stage must flush per line** — `jq --unbuffered`, `grep --line-buffered`. Without it events arrive in blocks or not at all.
- **Filter, never pipe raw.** `tool_use` payloads are the bulk of the file; emitting them whole defeats the point.

### The opencode event vocabulary — get the field paths right

Verified against opencode 1.18.11. A filter keyed on the wrong shape matches nothing and emits nothing, which is indistinguishable from a quiet agent:

| `.type` | Where the payload is | Note |
| --- | --- | --- |
| `tool_use` | `.part.tool` — the tool name | **Not** `.type=="tool"`, and the name is not at the top level. One measured run had 9 `tool_use` events and a filter on `.type=="tool"` emitted zero. |
| `text` | `.part.text` | One per emitted text block, several per turn — opencode emits one before its tool calls and another at the end, so a single block is never the whole answer. |
| `step_start` / `step_finish` | `.part.reason` on `step_finish` | Bracket each step. `reason: "stop"` ends the turn; `reason: "tool-calls"` is intermediate. |
| `error` | `.error.data.message` // `.error.name` | Upstream failures (auth, quota) land here, not in `stderr.log`. |

## Keeping context pure — projecting without paying for the stream

Reading `/result` costs what the answer costs. Everything else has a price, and the ranking is the whole point:

| Want | Use | Cost |
| --- | --- | --- |
| The answer | `/result` resource | The answer's own size |
| One earlier turn's answer | `…/turns/<n>/result` | Same |
| Which turns exist, and how they ended | `hyprpilot://sessions/<handle>` | A few hundred bytes |
| Only "is it done" | `session_status` | A `stat` |
| A projection no view defines | `jq` on `files.transcript` | What you project |
| Progress while it runs | filtered tail of the turn's `turns.jsonl` | One small event per step |
| The raw stream | `/transcript`, `session_read`, or `wait: true` | Up to 60 kB, untrimmable |

**`jq` on disk is the tool for anything the views do not cover** — "every tool it called", "just the errors", "how many files it read". Its advantage is structural: it filters **before** the bytes reach your context, which no resource read and no `session_read` can do. That is why it survives the resource surface rather than being replaced by it.

```sh
jq -r 'select(.type=="tool_use") | .part.tool' "$T" | sort | uniq -c   # what did it actually do
jq -r 'select(.type=="error") | .error.data.message // .error.name' "$T"
```

**What `jq` no longer has to do is find the answer.** `/result` performs the per-vendor extraction, the turn scoping, and the error precedence — correctly, and without a shell. Hand-rolling those is how a multi-line answer gets truncated to its last line and how a billing error gets reported as "returned nothing".

**`session_read` is situational, not forbidden.** Reach for it when you want the event stream itself, when the run was small enough that the difference does not matter, when you need the vendor's raw shape to diagnose something, or when no shell is available. The rule is *know which one you are paying for*.

**On opencode the raw-stream cost is extreme and not proportional to the work.** Its `read` tool embeds each file's entire contents in the event *and* re-attaches every loaded instruction file (`AGENTS.md`, `CLAUDE.md`) as a system-reminder per call. Measured: a ten-file read survey produced a **389 kB** transcript whose answer was twelve lines. Transcript size tracks tool calls and instruction-file size — never treat it as a proxy for how much the agent produced.

### Where a failure hides

**Launch failure → `stderr.log`, transcript empty. Runtime failure → transcript `error` event, `stderr.log` empty.** A real 402 from the model provider produced exactly the second shape, with a zero-byte `stderr.log`.

`/result` already checks both and names which happened, which is the reason to prefer it over a hand-rolled query that can only see one. When you are working from the files instead, check both before reporting an exit code — and note that each turn's `stderr.log` is its own, so a non-empty one always refers to the turn you are looking at.

**A run that answered AND warned shows the warning only in `/stderr`.** `/result` consults stderr only when there is no answer, so a successful turn's deprecation notices, TLS complaints and rate-limit warnings are invisible there by design. Read `/stderr` when you are diagnosing something the answer does not explain.

## Limits

| | |
| --- | --- |
| Concurrent running sessions | 8 |
| Spawn nesting depth | 1 by default (`[mcp.harness].maxDepth`, stamped as `HYPRPILOT_SPAWN_DEPTH`) — a session you spawn cannot spawn its own |
| Sessions retained | 64 — oldest **finished** evicted, with their transcripts |
| Bytes per read, and per `/transcript` or `/stderr` view | 60 000, cut from the front |
| Default tail | 200 lines |
| Default turn timeout | 300 s |

## Rules that bite

- **A session is `exited` after every TURN**, not only when the conversation ends. "Is it done" always means "is this turn done".
- **`exitCode: 0` and `hasResult: true` mean the TURN ended cleanly, never that the TASK was completed.** They are process and transcript facts; neither inspects whether the agent did what it was asked. A measured run gave a 4-step prompt to a small model, which answered steps 1 and 2, stopped, and exited 0 with `hasResult: true` and no error event anywhere — the harness reported that success faithfully. Read the answer against what you asked before relaying it, and `session_send` the remainder rather than treating exit status as an acceptance test.
- **One turn at a time.** `session_send` to a running session is refused; no vendor supports two concurrent turns on one conversation. `session_kill` still works on it.
- **A timeout is not a failure.** The turn returning `running` means the agent is still working — poll, never re-`spawn`.
- **Sessions die with the sidecar.** No persistence. If it restarts, running agents are killed and transcripts are lost — capture anything that must outlive the connection.
- **`session_send` replays the launch.** `cwd` / `args` / `with_config` are inherited and **rejected** if passed; only the prompt, `mode`, `wait` and `timeout_seconds` are per-turn.
- **Paging is MCP-style, and the cursor carries its turn.** `cursor` in, `nextCursor` out, opaque (`<turn>.<offset>`). **No `nextCursor` means finished AND fully read.** Pass one back verbatim; never parse or construct one. An unrecognised cursor is an error, not a silent reset.
- **Launches are detached — `wait` defaults to false.** `spawn` / `session_send` return as soon as the turn starts. Opting into `wait: true` is rarely right: it returns the whole raw event stream with no `tail` and no `cursor` to trim it (measured on one trivial three-item task: 14 kB on opencode, 121 kB on claude), and it still comes back `running` if the turn outlives `timeout_seconds`. Poll, then read `/result`.
- **A runtime that auto-backgrounds slow MCP calls does NOT make `wait: true` cheap.** Some runtimes move an MCP call that outlives a threshold into a background task — the turn stops stalling, and the payload arrives later in a notification. **Later is not smaller.** Measured: a `wait: true` follow backgrounded on schedule and then delivered a 60 kB slice of raw events to answer what one `/result` read answers in a line.
- **The handle is the only id.** Minted at `spawn`, arrives in the first result, never changes, and is what every tool and every URI takes. There is no vendor session id on the wire — hyprpilot keeps the vendor's own id internally as the token `session_send` resumes with.
- **`sessionInfo` is per TURN.** `model`, `effort`, `mode`, `argv`, `pid`, `turnStartedAt` and the file paths all describe the turn that call started, not the session's current state.
- **`sessionInfo.mode` reports the profile's mode, not the launched one.** A mode imposed through `args` (opencode `--agent plan`) does not show up there; `sessionInfo.argv` is the honest record. Same caveat as `model` under a `with_config` overlay.
- **`spawn` runs a profile's `command` as this user.** The `provider` picks a flag projection, not a sandbox.
