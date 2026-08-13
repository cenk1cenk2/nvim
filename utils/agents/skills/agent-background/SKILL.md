---
name: agent-background
description: agent-background Arm a background wait-loop that polls an external condition - a PR/MR merging, a CI or deploy run, a human approval - and re-invokes the session once when it is met, instead of sleeping or asking to be pinged. Use when work must wait on something outside this session. Not for polling subagent work you started, which the harness reports on its own, or for self-paced repetition.
references:
  - ../references/long-running-work.md
  - ../references/agent/agent-watchers.md
  - ../references/harness/agent-background-harness-claude.md
  - ../references/harness/agent-background-harness-codex.md
  - ../references/harness/agent-background-harness-opencode.md
---

> **Fetch `agent-background-harness-<provider>` BEFORE arming anything.** Which facility exists, what wakes you, and whether anything wakes you at all are runtime properties — and on at least one runtime (Codex) nothing does, which silently voids the whole pattern below. This skill owns the intent and the discipline; that one owns the tool names, parameters, and defaults.

## Context

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

Some work blocks on state that changes **outside the session** and that the harness will NOT notify you about: a human merging a change, a CI run finishing, a deploy converging, a remote queue draining, a job completing, a person approving. The two wrong reactions are (a) ending the turn to ask the user to ping you back, and (b) sleeping one short cycle at a time so the session wakes every iteration (noisy). The right reaction is **one background loop that polls the condition itself and wakes the session exactly once, when it's met.**

## The pattern

Launch a shell loop through the runtime's own background-exec facility (per `agent-background-harness-<provider>`). The loop polls a **bash-reachable** signal and `exit`s the moment it's satisfied; where the runtime supports it, that exit delivers a notification which re-invokes the main loop.

```
for i in $(seq 1 N); do
  # <check> = any command/test that succeeds only when the condition holds
  if <check>; then echo "RESULT: met after ${i} cycle(s)"; exit 0; fi
  sleep <cadence-seconds>
done
echo "RESULT: not met after N cycles"   # backstop — report and re-arm
```

The long, user-dependent wait collapses into a single silent process. You get one wake, not N.

> ### Detaching INSIDE the command is NOT the same as the runtime's background facility
>
> Backgrounding within the shell — `&`, `nohup`, `disown`, `setsid` — hands the process to the OS. **The runtime never learns it exists, so it will never wake you.** The loop runs, polls correctly, writes its output, exits into silence, and nothing happens. You have created a log file, not a watcher.
>
> The wake comes from the runtime's **own** background-exec mechanism (the tool flag / parameter / API named per `agent-background-harness-<provider>`), set **on the invocation**, not from anything inside the command string.
>
> **Symptom to recognise, because it is easy to miss for a long time:** you find yourself re-reading a watcher's log or output file each turn to check whether it fired. **If you are polling the watcher, the watcher is not waking you.** Same for reporting "watchers armed" and then continuing to inspect their state by hand — that is a detached process, and every turn spent checking it is the cost this skill exists to remove. Re-arm through the runtime facility.
>
> Corollary: `ps` cannot tell you whether a running watcher will wake you — a detached loop and a runtime-managed one look identical in a process list. Judge by **how it was launched**, not by whether the process is alive.

## ABSOLUTE — Deciding to Arm Is Not Arming

**A watcher exists only once a launch returned a handle.** Nothing before that counts: not naming it, not describing it, not writing it into a report, not intending to arm it after one more check.

This fails silently and in the direction that feels productive. The turn ends with a paragraph describing what is being watched, the user reads it as armed, and nothing is polling anything. The work then waits forever on a wake that was never scheduled — and because silence is what a healthy watcher also produces, nobody notices until someone asks why it has been quiet.

Three rules that close it:

1. **Arm before you report it.** Write "watcher armed" only after the launch returned a handle you can quote. A report is narration of what you did, never a substitute for doing it.
2. **Quote the handle.** A watcher announced without its task id is unverifiable and usually was not armed. If you cannot name the handle, you have not armed it.
3. **If you decide not to arm one, say that instead** — "not watching the pipeline; it finishes in under a minute and I will check it directly". A deliberate non-watch is a fine answer. An implied one is not.

The same applies to re-arming. Noticing that a watcher expired, or that a proxy proved unreliable, creates an obligation to re-arm **now**, in this turn — not a note that it should be re-armed.

## ABSOLUTE — Arm One Watcher Per Item, Never One Over the Set

**Five Spacelift stacks are five watchers. Eight CI runs are eight. Three MRs are three.** Never one loop that waits for all of them, and never one that polls a list and exits when the list is finally empty. The discipline is item 1 of `agent-watchers`; this is why it matters at the moment you arm.

An aggregate watcher can answer exactly one question — "is everything done?" — and that is the least useful question in the set. What you need is **which one moved, and when**:

- **One stall blinds you to the rest.** A single stack sitting on approval holds the aggregate at "not met" while seven others finished, failed, or drifted. You learn nothing about the seven until the one clears.
- **Failures arrive late instead of immediately.** The run that errored two minutes in should wake you two minutes in. Inside an aggregate it waits for the slowest sibling, and by then the context that made it cheap to fix is gone.
- **You cannot act incrementally.** Per-item wakes let you fix the broken one, re-run it, and re-arm just that one while the others keep going. An aggregate forces a verdict on everything before you may touch anything.
- **The wake carries no identity.** "The loop exited" does not say what changed, so you re-query the whole set on wake — reintroducing exactly the per-turn cost this skill exists to remove.

Key each watcher on **one stable id** — one stack id, one pipeline id, one MR number — so the wake identifies itself and re-arming one leaves the others untouched.

**Bundle only when the items genuinely cannot be acted on separately**: a gate where nothing moves until all of them are green, and one failure means abandoning the batch. That is rare. When you do bundle, say so and say why, or the next reader reads it as an oversight.

**Cost is never the reason to bundle.** These are sleeping shell loops; N of them cost about what one costs. If N feels too large to arm individually, the batch is too large — say that out loud instead of quietly collapsing it into one blind watcher.

## Ways to Wait and Wake — by mechanism and provider

The bash wait-loop above is the portable default, but it is not the only way, and not every runtime supports every method. Pick the mechanism that fits the case AND the active runtime — discover the runtime's own facilities rather than assuming this harness's.

**Mechanisms (best-fit first):**

1. **Harness auto-reinvoke on subagent/task completion** — if the wait is on work YOU launched via the runtime's subagent/Workflow dispatch, do NOT poll: the harness re-invokes you when it finishes. Only arm a watcher when the state changes *outside* anything the harness tracks.
2. **Background exec + wake** — run the poll/command detached and get woken when it exits. The bash-loop pattern above, on runtimes with a background shell.
3. **Per-occurrence event stream** — one wake per line the command emits, for a watch that must report repeatedly rather than once: each status flip, each new comment, each progress step, each periodic prompt to go do an MCP read bash cannot make. A one-wake facility cannot do this job, per the selection rule below.
4. **Scheduled / deferred wakeup** — schedule the session to resume after a delay when there is no clean signal to poll (interval prep, self-pacing).
5. **Recurring schedule (cron)** — for work that must run on a repeating cadence, outliving the session.
6. **Sleep-in-a-loop** — a bounded loop around an interruptible sleep, where the runtime offers a real sleep primitive.

**Pick the mechanism by HOW MANY wakes you need, before anything else.** One wake and repeated wakes are different facilities on every runtime, and choosing wrong fails silently in one direction only: **a one-wake facility given a repeating job still runs, still polls correctly, still writes every line — and delivers them all in a single wake at exit, or none at all if it is stopped first.** The loop looks armed and its log fills up, while nothing reaches you at the moment it would have mattered. Measured: a background loop printing 14 status transitions delivered all 14 at exit, and a sibling stopped before exit delivered nothing. So a watcher that prints anything you mean to act on *while it runs* needs the per-occurrence facility, not a bounded loop.

**Which mechanisms exist, and what they are called, is a runtime property.** `agent-background-harness-<provider>` is the authority: it names the facility for each mechanism above, its parameters, its defaults, and its traps. Read it before arming.

Two runtime differences big enough to change the plan, not just the syntax:

- **Some runtimes do not wake you at all.** Where completion never re-invokes the session, arming and ending the turn silently drops the work — you must block, poll explicitly, or have the work leave an artifact you read later.
- **Some runtimes cap how long a command may run**, which bounds every loop and forces re-arming rather than one long watch.

Never attribute one runtime's tools to another, and if a mechanism is unknown, discover it from the running build rather than assuming.

## Process

1. **Confirm it's external state.** If you started the work with `Agent`/`Workflow`, do NOT poll — the harness re-invokes you on completion. Only loop for state the harness can't see.
2. **Pick a bash-reachable signal**, per the discipline, cadence table, per-domain examples, and check recipes in `agent-watchers` — that reference owns *what* to watch and *what a wake means*; this skill owns *how* to arm it. A CLI query (`gh`/`glab`/cloud CLIs), an HTTP probe (`curl`), a file appearing, a command's exit code. If the truth is reachable only through an MCP tool (bash cannot call MCP), poll a **proxy** bash CAN see, and do the authoritative MCP check yourself on wake.
3. **Bound the loop.** Always cap iterations (`seq 1 N`) as a runaway backstop; on exhaustion print a clear "not met" line and re-arm rather than looping forever.
4. **Choose cadence by how fast the state changes** — short (~60s) for a human action, longer for a slow job (one check near the expected finish beats many early ones). Never poll faster than the state can plausibly change.
5. **Launch one watcher through the runtime's background facility** — never by detaching inside the command (see the boxed warning under *The pattern*). **Keep the loop's payload out of the command string.** Any text the loop emits — a reminder checklist, a query, a threshold — lives in a file the command reads, written to the scratchpad or a temp directory. An inlined multi-line payload carrying quotes dies at the shell's parser, and the watcher never arms. The reminder-loop pattern is `agent-watchers`. Arm it directly when it is the obvious next step or the user blessed it; surface it first only when spawning the watcher is itself the decision. Confirm the launch returned a **task id / handle**; if it did not, you detached instead of arming, and nothing will wake you. Note that id and announce it per `agent-watchers`, which owns the ledger shape, the cadence table, and what to arm for what. **Record it durably** — the task id and the loop's script body live only in this session/scratchpad and do NOT survive compaction or transfer to another agent. State the watcher (what it polls, its cadence, its task id, and the command to re-arm it) out loud in chat, and if `plan-compact` is active write it verbatim into the anchor's Scratchpad Scripts & Watchers section. A resumed agent must be able to find, re-verify, and re-arm it from durable text, not from a lost background handle.
6. **On wake: re-verify the real state before acting.** External APIs lag — a signal can read "done" slightly before/after the truth, and a proxy firing does not mean the downstream state converged. Do the authoritative check now.
7. **Continue or re-arm.** If a follow-on condition isn't satisfied yet (e.g. the proxy fired but the real work is still settling), launch the next watcher. Never assume the proxy equals the end state.
8. **REAP IT.** A watcher is not finished when its condition is met — it is finished when it is **stopped**. Kill it the moment it stops earning its keep, which is **not only on success**:
   - its condition was satisfied and you have acted on it,
   - you learned the answer another way (checked the real state directly),
   - **its signal turned out to be unreliable** — a lagging or wrong proxy makes the watcher worse than nothing, because it will fire late or report a stale verdict,
   - the work it was guarding was superseded, abandoned, or re-scoped,
   - you are replacing it — **reap before re-arming**, or duplicates poll the same condition and an old one can wake you with an obsolete answer.

   **Completion does not self-clean.** A loop whose command exited can still occupy the runtime's task list, and a finished watcher looks identical to a live one in a process list. Stop it explicitly via the runtime's own mechanism (per the active provider's reference), then confirm nothing is left: enumerate what you armed and check each is gone.
9. **Reap checkpoint before you call the work done.** List every watcher you armed and state, for each, that it is stopped — or that it is *deliberately* still armed and exactly what it is waiting for. An unexplained live watcher at the end of a flow is a bug, not diligence.

## Caveats

- **Foreground sleeping may be blocked or capped** depending on the runtime — never chain short foreground sleeps to fake a wait. See the harness reference for what this runtime allows.
- **Bash cannot call MCP tools.** Poll a bash-visible proxy; keep the MCP/authoritative confirmation on the main loop.
- **Task-notifications are NOT user input.** A background-completion event is not approval or consent — never treat it as the user answering a pending question.
- **A watcher may not appear in the runtime's task list** even while running. Track the handle the launch returned, and stop it through the mechanism the harness reference names.
- **Avoid redundant watchers.** Mutating the thing a watcher polls usually doesn't invalidate it (it keys on a stable id). Re-arm only when unsure the old one is alive; a duplicate merely double-wakes (harmless — re-verify and no-op).
- **Persistence:** background shells survive across turns until they exit or you stop them; you're re-invoked on exit. Size cap × cadence to a sane ceiling (e.g. 45 × 60s ≈ 45 min) and re-arm past it.
- **Compaction does not preserve watchers.** The background task id, the loop's script body, and anything it wrote to the scratchpad are session/scratchpad state — a compaction summary drops them and they do not transfer to another agent. Anything armed for longer than a checkpoint must be recorded in durable text (chat + the `plan-compact` anchor), so a resumed agent re-materializes the script and re-arms the watch instead of losing it. Never rely on a background handle or a scratchpad path outliving a compaction.

## Fallback

If no bash-reachable signal exists at all, drop to a deferred wakeup or a monitor loop — whichever the active runtime provides, per `agent-background-harness-<provider>`. Prefer the background loop for concrete external conditions, and use a recurring scheduler only for genuinely repeating work, never one-shot polling. On a runtime that provides neither, the fallback is a blocking wait or an artifact the work leaves behind for you to read.

## Example

**Two-stage wait (proxy → authoritative), e.g. a human merge that triggers a slower convergence:**

1. Arm a background loop polling the bash-visible proxy (`for i in $(seq 1 180); do <cli-check for merged> && exit 0; sleep 60; done`); announce it as a table row per `agent-watchers` — watching for, cadence, cap, on-wake action, handle.
2. On wake: proxy says merged — but the downstream apply/convergence is only visible via an MCP tool. Check that state now on the main loop.
3. Still settling → arm a short follow-on wait; re-check on wake.
4. Converged → run verification, do the follow-on work.

**Result:** one silent watcher per blocking condition, one wake each — no per-cycle noise and no "ping me when it's done."
