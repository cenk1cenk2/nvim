---
name: agent-background-harness-opencode
description: agent-background-harness-opencode OpenCode waiting and waking mechanics - no native deferred wakeup or cron, no sleep tool, and a short shell timeout that bounds every wait loop. Load before arming anything on OpenCode. Not for the runtime-agnostic watcher discipline, or for dispatching subagents.
---

# Harness: OpenCode — agent-background

Runtime mechanics for the `agent-background` skill on OpenCode: how to wait on external state and what this runtime cannot do for you.

## Facilities

| Need | Mechanism | Notes |
|------|-----------|-------|
| Wake once when a condition holds | Bounded background shell loop | Must finish inside the shell timeout — see below. |
| Deferred wakeup | **none natively** | No `ScheduleWakeup` equivalent. |
| Recurring cadence | **none natively** | Third-party plugins only (e.g. `opencode-scheduler`), or an OS cron wrapping the CLI. |
| Work you dispatched yourself | depends on the build | If a background-subagent mechanism is present it notifies the parent on completion — do not poll it. See `agent-delegate-harness-opencode`. |

## The shell timeout bounds every wait

The shell tool kills a command at its timeout — **120000 ms (2 min) by default**, raisable with `OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS`. Consequences:

- A long foreground sleep fails outright.
- A wait-loop must be sized to exit **under** the ceiling, then be re-armed. Prefer many short bounded loops over one long one.
- Raising the env var is a per-environment change, not something a skill can assume. Check before relying on a longer window.

## Traps

- **No sleep tool.** The bounded shell loop is the only wait primitive.
- **A dispatched `task` blocks the turn** (see `agent-delegate-harness-opencode`), so "arm it and keep working" is not the same posture as on Claude Code.
- **Long work should write to a file.** With no deferred wakeup and an aggressive timeout, an artifact on disk is the reliable way to recover a result you could not wait for.

> **Unverified.** Whether the running build exposes a native background-subagent flag, and what its notification behavior is, could not be confirmed against current documentation. Check the installed build's own tool list before relying on either.
