# Long-Running Work

Work that spans many turns, survives a compaction, or hands off to another session. The risk is not the work — it is that **state living only in the conversation disappears without announcing itself**, and the next agent proceeds confidently without it.

## Three things must survive

| | What is lost | Consequence |
|---|---|---|
| **Posture** | which mode is on, its scope, its re-engage phrase | a delegating session silently becomes hands-on; a parked one resumes pushing |
| **Armed state** | watchers, background agents, queued next actions | a watcher never re-arms, or a second one is armed over a live one |
| **Artifact truth** | what the tracker, plan, or PR body actually claims now | the next agent executes a stale plan and cannot tell |

Anything held only in the transcript, a scratchpad file, or `/tmp` counts as already gone. Write it somewhere durable at each checkpoint, not once at the end — the checkpoint you skip is the one before the compaction.

## On resume

1. **Adopt the recorded posture — do not pick one.** Reading a transcript that looks like ordinary work is not evidence the mode was off.
2. **Re-arm only what is recorded as live.** Arming is a write. Nothing recorded means ask, never infer. Parked means re-arm nothing at all.
3. **Do not re-run delivered work.** Check what each spawned agent returned before dispatching over it, and never read silence as failure.
4. **Reconcile what you own** per `reconcile-state`, and surface what you do not.

## Never end quietly

Close every turn of long-running work by saying what is **live**, what is **queued**, and what is **waiting on the user**. A turn that ends without that is indistinguishable from one where everything finished — which is how armed watchers get orphaned and blocked work gets forgotten.

The same applies at a hard stop: on a park, a handoff, or a compaction, account for everything spawned as stopped or deliberately still running, and say which.
