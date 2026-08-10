# Harness: OpenCode — agent-delegate

Runtime mechanics for delegation on OpenCode — how subagent dispatch behaves, plus the tier → model mapping. Read this before the first dispatch of a session running on OpenCode. For waiting and waking, see `harness-opencode-agent-background`.

**Dispatch:** the OpenCode `task` tool (subagent dispatch, allowed in `opencode.jsonc`). Set the subagent's model to the resolved `kilic/*` slug.

## Tier → model

| Tier | Model |
|------|-------|
| cheap | `kilic/gemma4:31b-cloud` (opencode `small_model`) |
| default | `kilic/glm-5.2:cloud` (opencode `model`, reasoningEffort `max`) |
| smart | `kilic/deepseek-v4-pro:cloud` |
| max | `kilic/deepseek-v4-pro:cloud` (no distinct ceiling above smart) |

Off-ladder alternates in the `kilic` provider: `kilic/deepseek-v4-flash:cloud` (faster), `kilic/kimi-k2.7-code:cloud` (coding), `kilic/minimax-m3:cloud`.

Mirrors `~/.config/opencode/opencode.jsonc` (`model`, `small_model`) and the `personal/kilic/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

## Dispatch semantics

**The `task` tool is blocking.** A dispatch occupies the turn until the subagent returns; its result is the tool result. Plan around that: OpenCode has no first-class detached-subagent posture equivalent to Claude Code's background default, so "dispatch and keep working" is not available the same way.

**No timeout parameter.** `task` exposes no deadline, and long subagent runs have been reported hanging with no structured error and no recovery path short of aborting (`anomalyco/opencode` #15072, #20096, #6792). Consequences for how you dispatch:

- **Keep delegated tasks small enough to finish well inside a turn.** A subagent asked to do an hour of work is a subagent you may have to abandon.
- **Prefer several small dispatches over one large one** — a hang costs you the whole task, so smaller tasks lose less.
- **Have the subagent write its findings to a file** when the result matters. A file survives an aborted dispatch; a stranded tool result does not.

**Shell timeout is short.** The bash/shell tool kills a command at its timeout — **120000 ms (2 min) by default**, raisable with `OPENCODE_EXPERIMENTAL_BASH_DEFAULT_TIMEOUT_MS`. A long foreground wait or test suite fails against that ceiling, so bound any wait-loop under it (see `agent-background`).

> **⚠ Unverified — confirm before relying on it.** A `background: true` parameter on `task`, gated by `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`, was previously recorded here but could not be confirmed against current OpenCode documentation. What *is* documented publicly is a third-party plugin (`opencode-background-agents`) adding `delegate` / `delegation_read` / `delegation_list`, restricted to **read-only** subagents (write-capable ones must use native `task`) with a **15-minute** delegation timeout. Check the installed OpenCode version's own tool list before assuming either exists.

## Waiting and waking

- **No native deferred-wakeup and no cron** — third-party plugins only (e.g. `opencode-scheduler`). Do not assume a `ScheduleWakeup`/`CronCreate` equivalent.
- **No sleep tool.** Use a bounded background shell loop kept under the shell timeout above.
- If a background-subagent mechanism is present in the running build, it notifies the parent on completion — do not poll it.
