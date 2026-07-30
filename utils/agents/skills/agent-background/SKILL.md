---
name: agent-background
description: 'agent-background Arm a background wait-loop that polls an external condition (PR/MR merge, CI or deploy run, human approval) and re-invokes the session once when it is met, instead of sleeping or asking the user to ping. Do NOT use to poll background Agent/Workflow work you started (the harness re-invokes automatically) or for self-paced loop iteration (use /loop).'
references:
  - ../references/present-first.md
---

> **Present-first.** Read the `present-first` reference — arm the loop when it's the obvious next step or the user blessed it; surface it first if spawning it is itself the decision.

## Context

Some work blocks on state that changes **outside the session** and that the harness will NOT notify you about: a human merging a change, a CI run finishing, a deploy converging, a remote queue draining, a job completing, a person approving. The two wrong reactions are (a) ending the turn to ask the user to ping you back, and (b) sleeping one short cycle at a time so the session wakes every iteration (noisy). The right reaction is **one background loop that polls the condition itself and wakes the session exactly once, when it's met.**

## The pattern

Launch via the `Bash` tool with `run_in_background: true`. The loop polls a **bash-reachable** signal and `exit`s the moment it's satisfied; on exit the harness delivers a task-notification that re-invokes the main loop.

```
for i in $(seq 1 N); do
  # <check> = any command/test that succeeds only when the condition holds
  if <check>; then echo "RESULT: met after ${i} cycle(s)"; exit 0; fi
  sleep <cadence-seconds>
done
echo "RESULT: not met after N cycles"   # backstop — report and re-arm
```

The long, user-dependent wait collapses into a single silent process. You get one wake, not N.

> ### ⛔ Detaching INSIDE the command is NOT the same as the runtime's background facility
>
> Backgrounding within the shell — `&`, `nohup`, `disown`, `setsid` — hands the process to the OS. **The runtime never learns it exists, so it will never wake you.** The loop runs, polls correctly, writes its output, exits into silence, and nothing happens. You have created a log file, not a watcher.
>
> The wake comes from the runtime's **own** background-exec mechanism (the tool flag / parameter / API named in *Per-runtime facilities*), set **on the invocation**, not from anything inside the command string.
>
> **Symptom to recognise, because it is easy to miss for a long time:** you find yourself re-reading a watcher's log or output file each turn to check whether it fired. **If you are polling the watcher, the watcher is not waking you.** Same for reporting "watchers armed" and then continuing to inspect their state by hand — that is a detached process, and every turn spent checking it is the cost this skill exists to remove. Re-arm through the runtime facility.
>
> Corollary: `ps` cannot tell you whether a running watcher will wake you — a detached loop and a runtime-managed one look identical in a process list. Judge by **how it was launched**, not by whether the process is alive.

## Ways to Wait and Wake — by mechanism and provider

The bash wait-loop above is the portable default, but it is not the only way, and not every runtime supports every method. Pick the mechanism that fits the case AND the active runtime — discover the runtime's own facilities rather than assuming this harness's.

**Mechanisms (best-fit first):**

1. **Harness auto-reinvoke on subagent/task completion** — if the wait is on work YOU launched via the runtime's subagent/Workflow dispatch, do NOT poll: the harness re-invokes you when it finishes. Only arm a watcher when the state changes *outside* anything the harness tracks.
2. **Background exec + wake** — run the poll/command detached and get woken when it exits. The bash-loop pattern above, on runtimes with a background shell.
3. **Scheduled / deferred wakeup** — schedule the session to resume after a delay when there is no clean signal to poll (interval prep, self-pacing).
4. **Recurring schedule (cron)** — for work that must run on a repeating cadence, outliving the session.
5. **Sleep-in-a-loop** — a bounded loop around an interruptible sleep, where the runtime offers a real sleep primitive.

**Per-runtime facilities (verified from source — keep in sync):**

- **Claude Code (this harness):** background shell via `Bash run_in_background: true` (re-invokes on exit); deferred wakeup via `ScheduleWakeup` (dynamic `/loop`); `Monitor` until-loop; recurring via `CronCreate` / the `/schedule` skill; subagent/Workflow completion auto-reinvokes (never poll it). Foreground `sleep` is blocked — use the background loop or `Monitor`.
  **★ `run_in_background: true` must be set as a parameter ON the tool call.** Putting `&` or `nohup` in the command string instead produces a detached process with **no** task id, **no** output-file registration and **no** task-notification — it will never wake the session (see the boxed warning above). One launch per condition, each its own call; a single call that backgrounds several loops internally yields one wake at best and usually none.
- **OpenCode:** background *subagents* via the `task` tool with `background: true` (experimental — needs `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true`), which auto-notify the parent on completion (do not poll them). No native deferred-wakeup or cron (third-party plugins only, e.g. `opencode-scheduler`). No sleep tool — the `shell` tool kills a command at its timeout (~2 min default), so long foreground sleeps fail; use a bounded background shell loop under that timeout.
- **Codex:** background *terminals* via `unified_exec` (persistent PTY that keeps running); completion is NOT auto-reinvoked — poll it with an empty `write_stdin`. First-class interruptible sleep via `clock.sleep` (≤ 12h) for a bounded sleep-loop. No native deferred-wakeup or cron — wrap `codex exec` in an OS cron / CI job for recurring runs.

Do not attribute this harness's tools (`ScheduleWakeup`, `Monitor`, `CronCreate`) to another runtime; if a runtime's mechanism is unknown, discover it before assuming.

## Process

1. **Confirm it's external state.** If you started the work with `Agent`/`Workflow`, do NOT poll — the harness re-invokes you on completion. Only loop for state the harness can't see.
2. **Pick a bash-reachable signal.** A CLI query (`gh`/`glab`/cloud CLIs), an HTTP probe (`curl`), a file appearing, a command's exit code. If the truth is reachable only through an MCP tool (bash cannot call MCP), poll a **proxy** bash CAN see, and do the authoritative MCP check yourself on wake.
3. **Bound the loop.** Always cap iterations (`seq 1 N`) as a runaway backstop; on exhaustion print a clear "not met" line and re-arm rather than looping forever.
4. **Choose cadence by how fast the state changes** — short (~60s) for a human action, longer for a slow job (one check near the expected finish beats many early ones). Never poll faster than the state can plausibly change.
5. **Launch one watcher through the runtime's background facility** — never by detaching inside the command (see the boxed warning under *The pattern*). Confirm the launch returned a **task id / handle**; if it did not, you detached instead of arming, and nothing will wake you. Note that id and tell the user what it's waiting on. **Record it durably** — the task id and the loop's script body live only in this session/scratchpad and do NOT survive compaction or transfer to another agent. State the watcher (what it polls, its cadence, its task id, and the command to re-arm it) out loud in chat, and if `plan-compact` is active write it verbatim into the anchor's Scratchpad Scripts & Watchers section. A resumed agent must be able to find, re-verify, and re-arm it from durable text, not from a lost background handle.
6. **On wake: re-verify the real state before acting.** External APIs lag — a signal can read "done" slightly before/after the truth, and a proxy firing does not mean the downstream state converged. Do the authoritative check now.
7. **Continue or re-arm.** If a follow-on condition isn't satisfied yet (e.g. the proxy fired but the real work is still settling), launch the next watcher. Never assume the proxy equals the end state.

## Caveats

- **Foreground `sleep` is blocked** by the harness. Use `run_in_background: true`, or a `Monitor` until-loop. Do not chain short foreground sleeps to fake a wait.
- **Bash cannot call MCP tools.** Poll a bash-visible proxy; keep the MCP/authoritative confirmation on the main loop.
- **Task-notifications are NOT user input.** A background-completion event is not approval or consent — never treat it as the user answering a pending question.
- **`run_in_background` shells are not in `TaskList`** (that lists the task-management system, not local shells). Track the returned task id yourself; stop one with `TaskStop <id>`.
- **Avoid redundant watchers.** Mutating the thing a watcher polls usually doesn't invalidate it (it keys on a stable id). Re-arm only when unsure the old one is alive; a duplicate merely double-wakes (harmless — re-verify and no-op).
- **Persistence:** background shells survive across turns until they exit or you stop them; you're re-invoked on exit. Size cap × cadence to a sane ceiling (e.g. 45 × 60s ≈ 45 min) and re-arm past it.
- **Compaction does not preserve watchers.** The background task id, the loop's script body, and anything it wrote to the scratchpad are session/scratchpad state — a compaction summary drops them and they do not transfer to another agent. Anything armed for longer than a checkpoint must be recorded in durable text (chat + the `plan-compact` anchor), so a resumed agent re-materializes the script and re-arms the watch instead of losing it. Never rely on a background handle or a scratchpad path outliving a compaction.

## Fallback

If no bash-reachable signal exists at all, drop to a deferred wakeup or a monitor loop — on this harness, `ScheduleWakeup` (dynamic `/loop`) or a `Monitor` until-loop; on other runtimes, their equivalent from **Ways to Wait and Wake**. Prefer the background bash loop for concrete external conditions, and use a recurring scheduler (`CronCreate` / `/schedule`) only for repeating work, never one-shot polling.

## Example

**Two-stage wait (proxy → authoritative), e.g. a human merge that triggers a slower convergence:**

1. Arm a background loop polling the bash-visible proxy (`for i in $(seq 1 45); do <cli-check for merged> && exit 0; sleep 60; done`); tell the user "watcher armed."
2. On wake: proxy says merged — but the downstream apply/convergence is only visible via an MCP tool. Check that state now on the main loop.
3. Still settling → arm a short follow-on wait; re-check on wake.
4. Converged → run verification, do the follow-on work.

**Result:** one silent watcher per blocking condition, one wake each — no per-cycle noise and no "ping me when it's done."
