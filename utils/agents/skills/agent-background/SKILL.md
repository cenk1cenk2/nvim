---
name: agent-background
description: agent-background Arm a background wait-loop that polls an external condition - a PR/MR merging, a CI or deploy run, a human approval - and re-invokes the session once when it is met, instead of sleeping or asking to be pinged. Use when work must wait on something outside this session. Not for polling subagent work you started, which the harness reports on its own, or for self-paced repetition.
references:
  - ../references/long-running-work.md
  - ../references/agent-watchers.md
---

> **⛔ Read the active runtime's mechanics from `~/.config/nvim/utils/agents/skills/references/harness-<provider>-agent-background.md` BEFORE arming anything.** Which facility exists, what wakes you, and whether anything wakes you at all are runtime properties — and on at least one runtime (Codex) nothing does, which silently voids the whole pattern below. This skill owns the intent and the discipline; that file owns the tool names, parameters, and defaults.

## Context

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

Some work blocks on state that changes **outside the session** and that the harness will NOT notify you about: a human merging a change, a CI run finishing, a deploy converging, a remote queue draining, a job completing, a person approving. The two wrong reactions are (a) ending the turn to ask the user to ping you back, and (b) sleeping one short cycle at a time so the session wakes every iteration (noisy). The right reaction is **one background loop that polls the condition itself and wakes the session exactly once, when it's met.**

## The pattern

Launch a shell loop through the runtime's own background-exec facility (named in the active `harness-<provider>-agent-background` reference). The loop polls a **bash-reachable** signal and `exit`s the moment it's satisfied; where the runtime supports it, that exit delivers a notification which re-invokes the main loop.

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
> The wake comes from the runtime's **own** background-exec mechanism (the tool flag / parameter / API named in its `harness-<provider>-agent-background` reference), set **on the invocation**, not from anything inside the command string.
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

**Which mechanisms exist, and what they are called, is a runtime property.** The active runtime's `harness-<provider>-agent-background` reference is the authority: it names the facility for each mechanism above, its parameters, its defaults, and its traps. Read it before arming.

Two runtime differences big enough to change the plan, not just the syntax:

- **Some runtimes do not wake you at all.** Where completion never re-invokes the session, arming and ending the turn silently drops the work — you must block, poll explicitly, or have the work leave an artifact you read later.
- **Some runtimes cap how long a command may run**, which bounds every loop and forces re-arming rather than one long watch.

Never attribute one runtime's tools to another, and if a mechanism is unknown, discover it from the running build rather than assuming.

## Process

1. **Confirm it's external state.** If you started the work with `Agent`/`Workflow`, do NOT poll — the harness re-invokes you on completion. Only loop for state the harness can't see.
2. **Pick a bash-reachable signal**, per the watching discipline, cadence table, and check recipes in `agent-watchers`. A CLI query (`gh`/`glab`/cloud CLIs), an HTTP probe (`curl`), a file appearing, a command's exit code. If the truth is reachable only through an MCP tool (bash cannot call MCP), poll a **proxy** bash CAN see, and do the authoritative MCP check yourself on wake.
3. **Bound the loop.** Always cap iterations (`seq 1 N`) as a runaway backstop; on exhaustion print a clear "not met" line and re-arm rather than looping forever.
4. **Choose cadence by how fast the state changes** — short (~60s) for a human action, longer for a slow job (one check near the expected finish beats many early ones). Never poll faster than the state can plausibly change.
5. **Launch one watcher through the runtime's background facility** — never by detaching inside the command (see the boxed warning under *The pattern*). Arm it directly when it is the obvious next step or the user blessed it; surface it first only when spawning the watcher is itself the decision. Confirm the launch returned a **task id / handle**; if it did not, you detached instead of arming, and nothing will wake you. Note that id and **announce the watcher as a row in the table above**. **Record it durably** — the task id and the loop's script body live only in this session/scratchpad and do NOT survive compaction or transfer to another agent. State the watcher (what it polls, its cadence, its task id, and the command to re-arm it) out loud in chat, and if `plan-compact` is active write it verbatim into the anchor's Scratchpad Scripts & Watchers section. A resumed agent must be able to find, re-verify, and re-arm it from durable text, not from a lost background handle.
6. **On wake: re-verify the real state before acting.** External APIs lag — a signal can read "done" slightly before/after the truth, and a proxy firing does not mean the downstream state converged. Do the authoritative check now.
7. **Continue or re-arm.** If a follow-on condition isn't satisfied yet (e.g. the proxy fired but the real work is still settling), launch the next watcher. Never assume the proxy equals the end state.
8. **⛔ REAP IT.** A watcher is not finished when its condition is met — it is finished when it is **stopped**. Kill it the moment it stops earning its keep, which is **not only on success**:
   - its condition was satisfied and you have acted on it,
   - you learned the answer another way (checked the real state directly),
   - **its signal turned out to be unreliable** — a lagging or wrong proxy makes the watcher worse than nothing, because it will fire late or report a stale verdict,
   - the work it was guarding was superseded, abandoned, or re-scoped,
   - you are replacing it — **reap before re-arming**, or duplicates poll the same condition and an old one can wake you with an obsolete answer.

   **Completion does not self-clean.** A loop whose command exited can still occupy the runtime's task list, and a finished watcher looks identical to a live one in a process list. Stop it explicitly via the runtime's own mechanism (per the active provider's reference), then confirm nothing is left: enumerate what you armed and check each is gone.
9. **Reap checkpoint before you call the work done.** List every watcher you armed and state, for each, that it is stopped — or that it is *deliberately* still armed and exactly what it is waiting for. An unexplained live watcher at the end of a flow is a bug, not diligence.

## Announce every armed watcher as a table

**Arming without announcing is the same failure as not arming** — the user cannot see a background loop, so an unannounced watcher is indistinguishable from a session that quietly stopped waiting. State it the moment it is armed, again when it is re-armed, and whenever asked what is running:

| Watcher | Watching for | Cadence | Cap | On wake | Handle |
|---|---|---|---|---|---|
| `pr-4821` | PR 4821 merged to `main` | 60s | 45 cycles (~45m), then report and re-arm | resume the rollout, post the Linear update | `task_01H…` |
| `deploy-prod` | all 8 prod pipeline jobs FINISHED | 5m | 24 cycles (2h), then surface as stalled | verify, then open the follow-up MR | `task_01H…` |

Column rules:

- **Watching for** is the *done-condition as it will be tested*, not the topic. "PR merged" is a topic; "`gh pr view 4821 --json state` returns MERGED" is a condition. If you cannot write it as a testable line, the watcher is not ready to arm.
- **Cadence** matches how fast the signal actually changes — see the cadence table in `agent-watchers`. A 5-minute deploy does not need a 30-second poll.
- **Cap** always states what happens when it is hit, because a watcher that expires silently is worse than one that never armed.
- **On wake** is the action the watcher exists to trigger. A watcher with no stated action is an alarm nobody answers.
- **Handle** is the task id the runtime returned. **No handle means you detached instead of arming** — nothing will wake you.

When `plan-compact` is active, these columns are exactly what its anchor records, so copy the row across rather than writing it twice.

## Announce every watcher that ends, the same way

A watcher that stops is a decision point, not a cleanup detail. Report it the moment it fires, expires, or is reaped:

| Watcher | Outcome | What the condition actually said | Re-arm? | Next / deviation |
|---|---|---|---|---|
| `pr-4821` | fired | merged at 14:02, CI green | no - done | resumed the rollout; moved the issue to In Review |
| `deploy-prod` | expired at cap | 6 of 8 jobs FINISHED, 2 still queued | yes, cadence 10m | runner capacity looks like the holdup - check that first |
| `ci-lint` | reaped | superseded, branch was force-pushed | replaced | new watcher armed on the new head |

- **Fired means the condition was met and verified** — not merely that the loop exited. A loop can exit on its own backstop; check the artifact before writing "fired".
- **Expired is never silently dropped.** Every expiry ends in an explicit choice: re-arm with a longer cadence or cap, escalate to the user, or abandon the wait and say so. Leaving it off the table reads as "it completed".
- **Deviation is the valuable column** — the condition met late, partially, or in a way you did not predict. That is what changes the next step, and it is the first thing lost when a watcher is reported as a bare "done".
- **Reaped needs its reason** — superseded, moot, or replaced — because a reaped watcher and a fired one look identical afterwards.

⛔ Never reap a watcher to tidy up before its outcome is in the table. Collect the outcome first; reaping is terminal.

## Caveats

- **Foreground sleeping may be blocked or capped** depending on the runtime — never chain short foreground sleeps to fake a wait. See the harness reference for what this runtime allows.
- **Bash cannot call MCP tools.** Poll a bash-visible proxy; keep the MCP/authoritative confirmation on the main loop.
- **Task-notifications are NOT user input.** A background-completion event is not approval or consent — never treat it as the user answering a pending question.
- **A watcher may not appear in the runtime's task list** even while running. Track the handle the launch returned, and stop it through the mechanism the harness reference names.
- **Avoid redundant watchers.** Mutating the thing a watcher polls usually doesn't invalidate it (it keys on a stable id). Re-arm only when unsure the old one is alive; a duplicate merely double-wakes (harmless — re-verify and no-op).
- **Persistence:** background shells survive across turns until they exit or you stop them; you're re-invoked on exit. Size cap × cadence to a sane ceiling (e.g. 45 × 60s ≈ 45 min) and re-arm past it.
- **Compaction does not preserve watchers.** The background task id, the loop's script body, and anything it wrote to the scratchpad are session/scratchpad state — a compaction summary drops them and they do not transfer to another agent. Anything armed for longer than a checkpoint must be recorded in durable text (chat + the `plan-compact` anchor), so a resumed agent re-materializes the script and re-arms the watch instead of losing it. Never rely on a background handle or a scratchpad path outliving a compaction.

## Fallback

If no bash-reachable signal exists at all, drop to a deferred wakeup or a monitor loop — whichever the active runtime provides, per its `harness-<provider>-agent-background` reference. Prefer the background loop for concrete external conditions, and use a recurring scheduler only for genuinely repeating work, never one-shot polling. On a runtime that provides neither, the fallback is a blocking wait or an artifact the work leaves behind for you to read.

## Example

**Two-stage wait (proxy → authoritative), e.g. a human merge that triggers a slower convergence:**

1. Arm a background loop polling the bash-visible proxy (`for i in $(seq 1 45); do <cli-check for merged> && exit 0; sleep 60; done`); announce it as a table row — watching for, cadence, cap, on-wake action, handle.
2. On wake: proxy says merged — but the downstream apply/convergence is only visible via an MCP tool. Check that state now on the main loop.
3. Still settling → arm a short follow-on wait; re-check on wake.
4. Converged → run verification, do the follow-on work.

**Result:** one silent watcher per blocking condition, one wake each — no per-cycle noise and no "ping me when it's done."
