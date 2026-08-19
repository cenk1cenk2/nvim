# Harness: Claude Code — agent-background

Runtime mechanics for the `agent-background` skill on Claude Code: how to wait on external state and get woken. The skill body owns the intent and the discipline; this file owns the tool names, parameters, and defaults.

## Facilities

| Need | Mechanism | Notes |
|------|-----------|-------|
| Wake once when a condition holds | `Bash` with **`run_in_background: true`** and a command that exits when satisfied | The default watcher. Exit delivers a task-notification that re-invokes the session. |
| One notification per occurrence | `Monitor` | Each stdout line becomes an event. `persistent: true` for session-length watches; otherwise `timeout_ms` (default 300000, max 3600000). Also accepts a `ws` WebSocket source. |
| No bash-reachable signal | `ScheduleWakeup` (dynamic `/loop`) | Deferred re-invocation; delay clamped to 60–3600 s. |
| Genuinely recurring cadence | `CronCreate` / the `/schedule` skill | Outlives the session. Never for a one-shot wait. |
| Work you dispatched yourself | **nothing — do not poll** | Subagent and Workflow completion re-invokes the session automatically. |

**Foreground `sleep` is blocked.** Use a background loop or a `Monitor` until-loop; never chain short foreground sleeps.

## `run_in_background` is a parameter ON the call

Set it on the tool invocation. Putting `&`, `nohup`, `disown`, or `setsid` inside the command string instead produces an OS-detached process with **no task id, no output-file registration, and no task-notification** — it will never wake the session. One launch per condition, each its own call: a single call that backgrounds several loops internally yields one wake at best, usually none.

Confirm the launch returned a **task id**. If it did not, you detached instead of arming.

## Loop shape

```
for i in $(seq 1 N); do
  if <check>; then echo "RESULT: met after ${i} cycle(s)"; exit 0; fi
  sleep <cadence-seconds>
done
echo "RESULT: not met after N cycles"   # backstop — report and re-arm
```

Monitor's own guidance applies when you use it instead: every pipe stage must flush per line (`grep --line-buffered`, `awk` + `fflush()`), poll remote APIs no faster than ~30 s, and the filter must match failure signatures as well as success — a monitor that greps only the happy path stays silent through a crashloop.

## Reading an MCP resource

`ReadMcpResourceTool { server, uri }` — `server` is the bare server name (`hyprpilot-harness`), `uri` the full resource URI. `ListMcpResourcesTool { server? }` enumerates what a server publishes.

**A resource read lands in context, not in a shell.** There is no way to pipe one into `jq`, `grep`, or a file, and no filter parameter — you get the view the server defines, whole. So when you want a *projection* of something large, the on-disk route below is the only one that filters before the bytes arrive.

## MCP calls background automatically, but you cannot ask them to

Two separate facts, and conflating them produces the wrong plan:

- **You cannot request it.** `run_in_background` is a parameter on **`Bash`** alone; no MCP tool call accepts one, and a backgrounded shell cannot call MCP tools either. There is no way to *choose* that a given MCP call runs detached.
- **The runtime does it for you past a threshold.** Since **v2.1.212**, an MCP call in the main conversation that outlives the auto-background threshold moves to a background task on its own: the call returns a task id, the turn continues, and the result arrives later as a task notification. It appears in `/tasks` and can be stopped there.

Consequences worth planning around:

- **Below the threshold, an MCP call blocks the turn** — there is no way to shorten that except finishing sooner.
- **A backgrounded task does not survive leaving the session.** Anything that must outlive the session needs a durable artifact, not a task id.
- **Per-call limits still apply while it runs backgrounded** — the wall-clock limit from the per-server timeout or `MCP_TOOL_TIMEOUT`, and the idle limit from `CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT`.
- **The threshold is configurable per install** via `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` (`0` disables auto-backgrounding; `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` disables it along with every other background-task feature). **Never assume the default** — read the value in play before reasoning about whether a given call will block, and lower it only deliberately: every call that starts backgrounding costs a round trip it did not previously need.

**Auto-backgrounding fixes the blocking, NOT the context cost — do not read it as permission to use a blocking follow.** A backgrounded call still delivers its full payload later, whole, into the notification. Measured on `hyprpilot-harness__session_read { wait: true }` against a 45 000 ms threshold: it backgrounded at exactly 45 s and the turn stayed usable, then the notification landed carrying a 60 kB slice of raw event stream — to answer a question that one `hyprpilot://sessions/<handle>/result` read answers in a line.

So the ranking is unchanged, and the filesystem route below is still the default:

| Want | Use | Why |
|------|-----|-----|
| The answer | the server's own extracted view, where it has one | Costs what the answer costs |
| A projection of something large | `jq` the artifact on disk | Filters before the bytes reach context |
| Progress, as it happens | `Monitor` + filtered `tail -F` | One small event per step |
| Only "is it done" | the cheap status poll | No payload at all |
| The entire raw stream, deliberately | a blocking follow | The only case it wins |

Deferred cost is still cost. The threshold decides whether your *turn* stalls; it has no effect on how many tokens the result spends.

**Watch whatever it writes to disk, and keep the authoritative MCP check on the main loop.** Two shapes, by how many notifications you need:

| Want | Mechanism | Shape |
|------|-----------|-------|
| One wake when it finishes | `Bash` + `run_in_background` | until-loop on a marker file, exits when present |
| An event per unit of progress | `Monitor` | `tail -F` the append-only output/transcript file, filtered |

```bash
# progress streaming — Monitor
tail -c +$((OFF+1)) -F "$FILE" | jq -r --unbuffered '<select + truncate>'
```

Rules that bite on this pattern:

- **Capture the byte offset BEFORE triggering the work**, then `tail -c +$((OFF+1))`. `tail -n0` drops everything written between the trigger returning and the tail attaching — a measured run lost the first step of a job that way.
- **Check whether the marker is per-run before deciding when to arm.** Where one path is reused across runs, a previous run's marker sits there until the new one clears it, so a watcher armed early fires instantly on stale state — arm after the call returns. Where each run writes its own path, take the path from that call's result and arm whenever you like.
- **`jq --unbuffered`** (and `grep --line-buffered`) or the events arrive in blocks, or never.
- **Verify the field paths against a real line of the file first.** A filter keyed on the wrong shape emits nothing, which looks exactly like a quiet job.
- **A `Monitor` on `tail -F` never exits by itself.** Pair it with a background loop that kills the tail once the marker appears, or it burns to `timeout_ms`.

## Reading and stopping

- **`TaskStop <task-id>`** stops a watcher. It also accepts a named background agent's name or a teammate's `name@team`.
- **Background *shell* output:** read the output file path returned at launch (`Read`, or `TaskOutput`). This is safe for shells.
- **Never read a local *agent* task's output file** — it is a symlink to the full subagent transcript (JSONL) and will overflow the lead's context.
- **`run_in_background` shells do not appear in `TaskList`** — that lists the task-management system, not local shells. Track the returned id yourself.
- `PushNotification` is available when an event is one the user would want to act on immediately.

## Persistence and compaction

Background shells survive across turns until they exit or are stopped, and the session is re-invoked on exit. Size `cap × cadence` to a sane ceiling (e.g. 45 × 60 s ≈ 45 min) and re-arm past it.

**Compaction drops the task id, the loop's script body, and anything in the scratchpad.** Anything armed for longer than a checkpoint must be recorded in durable text — chat, and the `plan-compact` anchor — so a resumed agent can re-materialize the script and re-arm rather than lose the watch.

## Traps

- **Command strings are parsed by zsh, inside an `eval`.** `Bash` and `Monitor` hand the command to `zsh -c '… eval …'`, so a nested `\"` inside an embedded PromQL selector, JSON body, or regex fails as `(eval):1: parse error near …` and the task exits 1 on the spot. Put the text in a file and make the command `cat <path>`.
- **Task-notifications are not user input.** A completion event is never approval, consent, or an answer to a pending question.
- **Bash cannot call MCP tools.** Poll a bash-visible proxy and keep the authoritative MCP check on the main loop.
- **`ps` proves nothing.** A detached loop and a runtime-managed one look identical in a process list — judge by how it was launched.
- **If you are re-reading a watcher's log each turn, it is not waking you.** That is the detached-process symptom; re-arm through the tool parameter.
