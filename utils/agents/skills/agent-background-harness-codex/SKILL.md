---
name: agent-background-harness-codex
description: agent-background-harness-codex Codex waiting and waking mechanics - background work never re-invokes the session, so every wait is a blocking call or an explicit poll. Load before arming anything on Codex. Not for the runtime-agnostic watcher discipline, or for dispatching subagents.
---

# Harness: Codex — agent-background

Runtime mechanics for the `agent-background` skill on Codex. Read this before arming anything: the core assumption behind background waiting does not hold here.

## Nothing wakes you

**Background subprocesses and subagents complete without informing the calling agent** — no notification, no re-invocation (`openai/codex` #15723, open, filed against codex-cli 0.116.0). The caller either polls, or waits for the user to ask.

This inverts the whole skill. On a runtime that wakes you, arming a watcher and ending the turn is correct. Here it silently drops the work.

## Facilities

| Need | Mechanism | Notes |
|------|-----------|-------|
| Wait for a condition | Blocking call, or an explicit poll of a background terminal | Polling means writing an empty string to the terminal's stdin and reading what comes back. |
| Bounded sleep | Codex's first-class interruptible sleep primitive | Unlike harnesses that block foreground sleeping, a real sleep-loop is viable here. |
| Deferred wakeup | **none** | No `ScheduleWakeup` equivalent. |
| Recurring cadence | OS cron / CI job wrapping `codex exec` | Nothing in-session. |

## How to wait here

1. **Prefer blocking** whenever the result matters — it is the only delivery you can count on.
2. **Write results to a file** for anything long, so an un-collected result is recoverable by reading the artifact instead of re-running the work.
3. **If you must background it, schedule your own poll** in the same turn plan — never end the turn expecting a wake.
4. **Re-verify on poll.** As everywhere, a proxy signal firing does not mean the downstream state converged.

> **Unverified.** The exact tool names for background terminals and for sleep are unconfirmed against current documentation; upstream issue text uses `exec_command` for that capability. Codex ships very fast — check the running build's tool list rather than trusting a name from this file.
