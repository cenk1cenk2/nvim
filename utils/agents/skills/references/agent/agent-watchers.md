# Agent Watchers

What to watch, how often, what a wake means, and how to keep the set legible. Read this whenever you
arm a watcher — from `agent-background` (which owns the launch mechanics), `agent-bulldozer` (never
idle), `agent-supervisor` (never drift), or `agent-coordinator` (covering a wait).

The runtime facility and its parameters live in `agent-background-harness-<provider>`. Subagents are
tracked separately, per `agent-roster`.

## Discipline

1. **One watcher per independent condition.** Five MRs are five watchers. Bundle only when a gate
   genuinely cannot move until all of them clear together — otherwise one stalling blinds you to the
   rest.
2. **Arm it the moment the condition opens**, not when you next remember it. The gap between "the MR is
   open" and "did it merge?" is where both momentum and tracker accuracy are lost.
   **Arming is never gated on a decision.** A prep is held at a gate because firing early corrupts
   state; a watcher only reads, so there is no such thing as arming one too early. Holding one back
   pending an ordering call, an approval, or a preference leaves the event it guarded unobserved — and
   the thing you were deciding about happens while you decide.
3. **Bound every loop.** A cap is a runaway backstop, not a deadline: on exhaustion, report "not met"
   and re-arm rather than looping forever.
4. **Size cap × cadence to the real wait, not to your impatience.** A human action you expect
   overnight needs hours of cap; a 60-cycle 60-second watch on it expires long before the merge and the
   silence then reads as "nothing happened". Estimate how long the thing genuinely takes, then add
   margin.
5. **Cadence follows how fast the signal can actually change** (table below). Never poll faster than the
   state can move; never leave a fast signal unchecked for minutes.
6. **On wake, re-verify authoritatively.** The signal may be a proxy, and proxies lag — a merge can read
   done before the downstream apply has converged. Do the real check on the main loop before acting.
7. **A dead watcher is not an answer.** If it exits without the condition met — cap exhausted, signal
   broke, process killed — diagnose which, fix that, and re-arm. Never let a lapsed watch silently
   become "no news".
8. **Reap what you armed**, and reap *before* re-arming a replacement, or duplicates double-wake and can
   contradict each other. Reap when: the condition fired and you acted, you learned the answer another
   way, the signal proved unreliable, or the work was superseded.
9. **Account for every live watcher in each report** — what it polls, its cadence, its handle. An
   unexplained live watcher at the end of a flow is a bug, not diligence.

**One wake or many is a mechanism choice, not a cadence choice.** A watcher that must report each time
something changes needs the runtime's per-occurrence facility. Give that job to a one-wake background loop
and it still runs and still polls correctly, but every line it prints is withheld until the process exits and
lost entirely if it is reaped first. If you find yourself reading a watcher's log to see what it has said,
the mechanism is wrong, not slow.

**Bash cannot call MCP tools.** When the truth is only reachable via MCP (Linear state, ArgoCD, Grafana,
Spacelift where no CLI exists), poll a bash-visible **proxy** and do the authoritative MCP check
yourself on wake.

## Fire on the actionable transition, not only the terminal state

**A watcher keyed to the end state is silent through every intermediate state, including the ones you
need to act on.** Ask what the *earliest* state is that changes what you do, and wake on that.

A job reaching a terminal state and a job merely *appearing* are different events with different
actions. When a pre-condition window opens as the work starts — a baseline to capture, a snapshot to
take, a value to record before it is overwritten — a terminal-only watcher delivers its wake after that
window has already closed.

So watch the state field for **any change**, report each transition, and exit on terminal. A job that
appears and then sits queued becomes visible that way too, where a terminal-only watch makes it
indistinguishable from nothing having happened at all.

**Carry the wake's own reference values in its message, and replace the watcher when they turn out
wrong.** A threshold or band written from an earlier measurement is the thing a wake gets judged
against, so a stale one produces a confident false positive. On learning the real figure, stop the
watcher and re-arm with the corrected value rather than remembering to mentally adjust — a wake read
against a wrong band is worse than no wake.

## A watcher can watch nothing and still earn its keep — the reminder loop

Not every watcher polls external state. A **reminder watcher** emits a fixed checklist on a cadence
during a long wait, so the standing procedure stays in front of you instead of decaying across turns:
the queries to re-run, the discriminator that separates progress from a stall, the person to prompt,
the trap to avoid. It watches you, not the system.

Arm one whenever a wait is long enough that the *procedure* will drift before the condition fires — a
multi-stage rollout, a convergence with a manual step in the middle, anything whose next action depends
on a rule established hours earlier. It is the per-occurrence mechanism by definition: a one-wake loop
delivers the whole checklist once, at exit, which is the single moment it is useless.

**The payload is a file. The command is `cat <path>`.** Never inline the reminder text into the
command string.

- **Quoting kills it.** Real payloads carry quoted selectors, JSON, and regex. Nested quotes inside a
  command string fail at the shell's parser, and that failure arrives as an *unarmed* watcher, not a
  bad wake — indistinguishable from a quiet one.
- **A file is editable.** A reminder goes stale the moment a rule is superseded — a retired window, a
  corrected discriminator. Correcting a file is an edit; correcting an inlined string is a reap and a
  re-arm, which is how a wrong reminder outlives the rule it carried.
- **A file outlives the handle.** The command string exists only in the runtime's task record and dies
  with a compaction. The file is on disk and the anchor names its path.

Write it to the session scratchpad or a temp directory — it is scaffolding, not a deliverable, and it
does not belong in a repository. Durability comes from the `plan-compact` anchor recording the path and
the payload per `long-running-work`, never from where the file sits.

## Which wake is this? — routing by posture

The mechanics are identical across modes. **What the wake is *for* is not**, and you decide that before
arming, because it determines whether the wake fires work.

| | **Momentum** — `agent-bulldozer` | **Routing** — `agent-coordinator` | **Awareness** — `agent-supervisor` |
|---|---|---|---|
| Purpose | Unblock the next action | Decide what gets dispatched next | Keep the record true |
| Cadence bias | Tight — idle time after the blocker cleared is pure waste | Tight enough not to stall the queue | Matched to the signal; late costs accuracy, not speed |
| On wake | Re-verify, fire the already-staged next step, arm the follow-on | Re-verify, then choose the next dispatch; delegate the bulk of it | Re-verify, reconcile the tracker and the report, arm the follow-on |
| Does it act? | Yes — that is the point | It routes: the acting is a subagent's | No. It corrects and reports; pushing work needs the user's ask |
| Cost of not arming | You sit idle while the blocker cleared long ago | The queue drains and nothing is dispatched | Your next report is confidently wrong |

**The same condition serves any of the three** — an open MR is a blocker to a bulldozer, a routing
trigger to a coordinator, and a pending fact to a supervisor. Decide which you are arming and say so
when you report it, because "MR merged" means *fire the next stage* to one, *dispatch the next agent* to
another, and *move the issue to Done* to the third.

## What to arm, and how to check it

Per-domain signals — merge gates, CI runs, terraform and Spacelift, deploy convergence, chaining, tracker reconciliation — and the shell recipes that poll them, live in `agent-watcher-recipes`. **Read the entry for the domain you are about to watch before arming**, since a signal chosen from memory is how a watcher ends up polling something that never changes.

## Cadence by signal

| Signal | Cadence | Why |
|--------|---------|-----|
| CI run, pipeline job, merge, apply finishing | 15–30 s | Fast, and the whole point is catching it immediately. |
| Deploy or operator convergence (ArgoCD, rollout) | 30–60 s | Reconcile loops run on their own interval. |
| Human action — review, approval, manual gate | 60–300 s | Bounded by a person, not a machine — and cap for hours, not minutes. |
| Long batch job with a known runtime | one check near the expected finish, then tighten | Early checks are pure waste. |
| Remote API with rate limits | ≥ 30 s | A tight loop gets you throttled, not informed. |

## Announce every armed watcher as a table

**Arming without announcing is the same failure as not arming** — the user cannot see a background loop,
so an unannounced watcher is indistinguishable from a session that quietly stopped waiting. State it
when armed, again when re-armed, and whenever asked what is running:

| Watcher | Watching for | Cadence | Cap | On wake | Handle |
|---|---|---|---|---|---|
| `pr-4821` | `gh pr view 4821 --json state` returns `MERGED` | 60s | 180 (~3h), then report and re-arm | verify the merge, arm the apply watcher | `task_01H…` |
| `deploy-prod` | all 8 prod pipeline jobs settled | 5m | 24 (2h), then surface as stalled | verify, then open the follow-up MR | `task_01H…` |

- **Watching for** is the done-condition *as it will be tested*, not the topic. "PR merged" is a topic;
  the command and its expected value is a condition. If you cannot write it as a testable line, the
  watcher is not ready to arm.
- **Cadence** matches how fast the signal actually changes. A 5-minute deploy does not need a
  30-second poll.
- **Cap** always states what happens when it is hit, because a watcher that expires silently is worse
  than one that never armed.
- **On wake** is the action it exists to trigger. A watcher with no stated action is an alarm nobody
  answers.
- **Handle** is the task id the runtime returned. **No handle means you detached instead of arming** —
  nothing will wake you.
- **A reminder watcher's *Watching for* cell is its payload path**, since it tests no condition. Without
  it the row reads as a watcher with no purpose.

When `plan-compact` is active, these columns are exactly what its anchor records — copy the row across
rather than writing it twice.

## Announce every watcher that ends, the same way

A watcher that stops is a decision point, not a cleanup detail. Report it the moment it fires, expires,
or is reaped:

| Watcher | Outcome | What the condition actually said | Re-arm? | Next / deviation |
|---|---|---|---|---|
| `pr-4821` | fired | merged at 14:02, CI green | no - done | resumed the rollout; moved the issue to In Review |
| `deploy-prod` | expired at cap | 6 of 8 jobs settled, 2 still queued | yes, cadence 10m | runner capacity looks like the holdup |
| `ci-lint` | reaped | superseded, branch was force-pushed | replaced | new watcher armed on the new head |

- **Fired means the condition was met and verified** — not merely that the loop exited. A loop can exit
  on its own backstop, or on a broken filter; check the artifact before writing "fired".
- **Expired is never silently dropped.** Every expiry ends in an explicit choice: re-arm with a longer
  cadence or cap, escalate, or abandon the wait and say so. Leaving it off the table reads as
  "it completed".
- **Deviation is the valuable column** — the condition met late, partially, or in a way you did not
  predict. That is what changes the next step, and the first thing lost when a watcher is reported as a
  bare "done".
- **Reaped needs its reason** — superseded, moot, or replaced — because a reaped watcher and a fired one
  look identical afterwards.

Never reap a watcher to tidy up before its outcome is in the table. Collect the outcome first;
reaping is terminal.

## Audit the ledger against reality, not against your notes

**What you believe is armed and what is actually running drift apart**, and every mechanism that
causes it is silent. A watcher exits on its cap. A process dies. One was described in a report but
never launched. A replacement was armed without reaping its predecessor, so two now poll the same
condition and can wake you with contradicting answers. None of these announce themselves — the
symptom of all of them is quiet, which is also what a healthy watcher produces.

So **verify, do not recall**. Enumerate what the runtime says is running and compare it against your
ledger, rather than re-reading your own last report and trusting it.

Run the audit:

- **Every time you report armed state.** A table row claiming a watcher is live is a factual claim;
  check it before writing it.
- **On every wake**, before acting on what woke you — including that the waker itself is now spent.
- **Before standing down, parking, or handing off**, per `mode-toggle`. An unexplained live watcher
  at the end of a flow is a bug.

Each row resolves to exactly one of: **live** and still earning its keep, **fired** with its outcome
recorded, **expired** and needing a diagnosis before re-arming, or **deliberately not armed** with
the reason stated. Anything that resolves to none of those is drift, and the fix happens in the same
turn that finds it — re-arm it, reap it, or say why neither.

**A discrepancy is a finding, not a bookkeeping error.** A watcher you thought was live and was not
means the thing it guarded has been unobserved for however long, and whatever you concluded from its
silence was unfounded. Say so plainly rather than quietly re-arming and moving on.

## Anti-patterns

- **Detaching inside the command** (`&`, `nohup`, `disown`) instead of using the runtime's facility —
  the process runs, exits into silence, and nothing wakes you. You made a log file, not a watcher.
- **Re-reading a watcher's output each turn** to see whether it fired. If you are polling the watcher,
  the watcher is not waking you.
- **Reporting a watcher you have not launched.** Describing one, naming what it would poll, or
  intending to arm it after one more check are all "no watcher". It exists when a launch returned a
  handle you can quote, and not before.
- **One watcher over a set of items** — a single loop across five stacks, eight pipelines, or three MRs.
  It can only report "all done", so one stall hides the rest and a failure waits for the slowest sibling.
  One item, one stable id, one watcher.
- **An in-context poll loop** — burning turns on checks a background loop does for free.
- **Arming the whole chain up front** — the later ids do not exist yet, so those watchers key on a guess.
- **Treating a wake as user input.** A notification is never approval, consent, or an answer to a
  pending question.
- **Treating silence as a verdict.** No wake means no information, never a pass.
- **Watching something the harness already tracks.** Work you dispatched (subagents, workflows) reports
  its own completion where the runtime supports it — check the harness reference before arming.
