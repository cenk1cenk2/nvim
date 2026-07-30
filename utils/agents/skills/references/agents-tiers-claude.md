# Agent Tiers — Claude / Anthropic

Tier → model mapping for delegation running on Claude. Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

**Dispatch:** the built-in `Agent` tool. Its `model` parameter accepts `haiku`, `sonnet`, `opus`, `fable`.

## Dispatch semantics — Claude Code

> **★ BACKGROUND IS THE DEFAULT AND THE PREFERRED WAY — standing operator preference.** Omit `run_in_background` and let the agent run detached. The lead stays free, so the user can keep talking and you keep working. **Blocking is the exception, not the norm.**

Claude Code's `Agent` tool already runs subagents in the background unless you pass `run_in_background: false`, so the preferred posture is also the tool's own default — just leave the flag off.

**Use blocking (`run_in_background: false`) ONLY when you are essentially just waiting on that result** — the next step depends on it and you would otherwise sit idle with nothing else to push. Then it lands as a normal tool result in the same turn.

- **Parallel blocking:** several `Agent` calls **in one message**, each with `run_in_background: false` — they run concurrently and all results arrive when the slowest finishes. For a fan-out you must have complete before proceeding.
- **Do not block a long-running agent just to be sure of getting its report.** Run it in the background and collect the result properly (below) — that is the whole point of the default.

**★ Collecting a background agent's result — this is where it goes wrong.** A background agent's final text is not automatically pushed into the lead's turn. What you may see instead is a `{"type":"idle_notification","idleReason":"available"}` teammate message, which reads exactly like an agent that silently gave up. **It usually is not.** Before concluding anything failed:

- **Check `run_in_background` and how you expected the result to arrive** — misreading an idle notification as failure is the common error, not agent flakiness.
- **Read the agent's own output** rather than waiting to be told: background work writes to the task output file reported at dispatch.
- **`SendMessage` to the agent's `name`** resumes it from its transcript and asks it to deliver. Ask for the partial result explicitly and tell it not to start new work.
- **Diagnose BEFORE you re-dispatch — then re-dispatch freely.** Re-dispatching is the right move once you know the cause and have fixed it (wrong flag, bad prompt, genuinely dead agent). What wastes work is re-dispatching *blind*, on the assumption the agent did nothing: this has burned a whole run of consecutive delegates that all looked failed while every one had actually completed its task. Collect first, fix the cause, then fire again.

**Worktrees:** `isolation: "worktree"` creates them under `<project>/.claude/worktrees/` — the harness default and the required location per `agents-worktrees`.

| Tier | Model |
|------|-------|
| cheap | `haiku` |
| default | `sonnet` |
| smart | `opus` |
| max | `fable` (`claude-fable-5`) |

`max`/`fable` is the ceiling — reserve it for the single hardest problems; `smart`/`opus` covers most heavy work.
