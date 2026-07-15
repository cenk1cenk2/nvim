---
name: agent-background
description: Run a background wait-loop that polls an external condition and re-invokes the session once, when the condition is met — instead of ending the turn to ask the user to ping, or sleeping one cycle at a time. Use when waiting on async state the harness cannot notify you about — a PR/MR merge, a CI or pipeline run, a deploy, a remote queue, a job, or a human approval/apply. Do NOT use to poll background Agent/Workflow work you started (the harness re-invokes you automatically), and do NOT use for self-paced loop iteration (use /loop with ScheduleWakeup).
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

## Process

1. **Confirm it's external state.** If you started the work with `Agent`/`Workflow`, do NOT poll — the harness re-invokes you on completion. Only loop for state the harness can't see.
2. **Pick a bash-reachable signal.** A CLI query (`gh`/`glab`/cloud CLIs), an HTTP probe (`curl`), a file appearing, a command's exit code. If the truth is reachable only through an MCP tool (bash cannot call MCP), poll a **proxy** bash CAN see, and do the authoritative MCP check yourself on wake.
3. **Bound the loop.** Always cap iterations (`seq 1 N`) as a runaway backstop; on exhaustion print a clear "not met" line and re-arm rather than looping forever.
4. **Choose cadence by how fast the state changes** — short (~60s) for a human action, longer for a slow job (one check near the expected finish beats many early ones). Never poll faster than the state can plausibly change.
5. **Launch one watcher**, note its task id, and tell the user what it's waiting on.
6. **On wake: re-verify the real state before acting.** External APIs lag — a signal can read "done" slightly before/after the truth, and a proxy firing does not mean the downstream state converged. Do the authoritative check now.
7. **Continue or re-arm.** If a follow-on condition isn't satisfied yet (e.g. the proxy fired but the real work is still settling), launch the next watcher. Never assume the proxy equals the end state.

## Caveats

- **Foreground `sleep` is blocked** by the harness. Use `run_in_background: true`, or a `Monitor` until-loop. Do not chain short foreground sleeps to fake a wait.
- **Bash cannot call MCP tools.** Poll a bash-visible proxy; keep the MCP/authoritative confirmation on the main loop.
- **Task-notifications are NOT user input.** A background-completion event is not approval or consent — never treat it as the user answering a pending question.
- **`run_in_background` shells are not in `TaskList`** (that lists the task-management system, not local shells). Track the returned task id yourself; stop one with `TaskStop <id>`.
- **Avoid redundant watchers.** Mutating the thing a watcher polls usually doesn't invalidate it (it keys on a stable id). Re-arm only when unsure the old one is alive; a duplicate merely double-wakes (harmless — re-verify and no-op).
- **Persistence:** background shells survive across turns until they exit or you stop them; you're re-invoked on exit. Size cap × cadence to a sane ceiling (e.g. 45 × 60s ≈ 45 min) and re-arm past it.

## Fallback

If no bash-reachable signal exists at all, use `ScheduleWakeup` (dynamic `/loop`) or a `Monitor` until-loop — but prefer the background bash loop for concrete external conditions. `CronCreate` is for recurring scheduled work, not one-shot polling.

## Example

**Two-stage wait (proxy → authoritative), e.g. a human merge that triggers a slower convergence:**

1. Arm a background loop polling the bash-visible proxy (`for i in $(seq 1 45); do <cli-check for merged> && exit 0; sleep 60; done`); tell the user "watcher armed."
2. On wake: proxy says merged — but the downstream apply/convergence is only visible via an MCP tool. Check that state now on the main loop.
3. Still settling → arm a short follow-on wait; re-check on wake.
4. Converged → run verification, do the follow-on work.

**Result:** one silent watcher per blocking condition, one wake each — no per-cycle noise and no "ping me when it's done."
