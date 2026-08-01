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

## Completion signals — which one applies to you

Three mechanisms, and the right choice depends on **who is waiting** and **how**.

### 1. Channels — a real push wake-up. Interactive Claude Code only.

When a turn ends the harness pushes `notifications/claude/channel`, which Claude Code renders as a channel block in the lead's next turn, naming the session and exit code. `mcp.harness.notifyOnComplete` defaults **true**.

**Do not build on it without confirming it reaches you:**

- **Interactive only** — a headless `claude -p` lead never receives one.
- **Claude Code only** — codex and opencode leads get nothing; it is a Claude Code protocol extension.
- **Registration is a launch flag** (`--dangerously-load-development-channels server:hyprpilot_harness`); there is no settings key.
- A client that has not registered **drops it silently and returns no error**, so a watcher built on it untested simply never fires — and looks exactly like a hung agent.

**Verify it rather than assuming it**, because the failure is invisible: read your own process argv and look for the flag.

```bash
tr '\0' '\n' < /proc/$PPID/cmdline | grep -c -- --dangerously-load-development-channels
```

`0` means no completion event will ever reach you and every detached session must be watched or polled. A verified session where a detached agent ran to completion produced **no channel block at all** with the flag absent — silence is the normal case, not a malfunction.

Where it does work it is strictly better than polling: no loop, no interval.

### 2. `session_status` — the cheap poll. Any MCP caller.

```jsonc
{ "status": "running" | "exited",
  "exitCode": 0,          // omitted while running
  "transcriptBytes": 41233,
  "hasResult": true,
  "vendorSessionId": "…" }
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
jq -r 'select(.type=="result") | .result' "$T"                                                   # claude
jq -r 'select(.type=="item.completed") | select(.item.type=="agent_message") | .item.text' "$T"  # codex
jq -r 'select(.type=="text") | .part.text' "$T"                                                  # opencode
```

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

## Limits

| | |
| --- | --- |
| Concurrent running sessions | 8 |
| Spawn nesting depth | 2 (`HYPRPILOT_SPAWN_DEPTH`) |
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
- **`wait: true` has no way to trim its output.** `spawn` / `session_send` return the whole raw event stream inline — no `tail`, no `cursor`. Measured on one trivial three-item task: 14 kB on opencode, 121 kB on claude. Detach with `wait: false` and pull the answer out of `files.transcript` instead.
- **`vendorSessionId` never backfills on a detached spawn.** It is `null` from `wait: false` and stays `null` on `session_read` even after the session exits, though the id is present inside the events. Only `session_send` populates it. Use the handle.
- **`sessionInfo.mode` reports the profile's mode, not the launched one.** A mode imposed through `args` (opencode `--agent plan`) does not show up there; `sessionInfo.argv` is the honest record. The same caveat as `model` under a `with_config` overlay.
- **`spawn` runs a profile's `command` as this user.** The `provider` picks a flag projection, not a sandbox.
