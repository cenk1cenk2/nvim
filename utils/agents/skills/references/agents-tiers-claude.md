# Agent Tiers — Claude / Anthropic

Tier → model mapping for delegation running on Claude. Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

**Dispatch:** the built-in `Agent` tool. Its `model` parameter accepts `haiku`, `sonnet`, `opus`, `fable`.

## Dispatch semantics — Claude Code

> **★ BACKGROUND IS THE DEFAULT AND THE PREFERRED WAY — standing operator preference.** Omit `run_in_background` and let the agent run detached. The lead stays free, so the user can keep talking and you keep working. **Blocking is the exception, not the norm.**

Claude Code's `Agent` tool already runs subagents in the background unless you pass `run_in_background: false`, so the preferred posture is also the tool's own default — just leave the flag off.

**Use blocking (`run_in_background: false`) ONLY when you are essentially just waiting on that result** — the next step depends on it and you would otherwise sit idle with nothing else to push. Then it lands as a normal tool result in the same turn.

- **Parallel blocking:** several `Agent` calls **in one message**, each with `run_in_background: false` — they run concurrently and all results arrive when the slowest finishes. For a fan-out you must have complete before proceeding.
- **Do not block a long-running agent just to be sure of getting its report.** Run it in the background and collect the result properly (below) — that is the whole point of the default.

### ⛔ Choose the mode by WHOSE OUTPUT IS THE DELIVERABLE

Background-by-default holds for work whose product is a **side effect you can verify yourself** — files edited, resources written, a branch pushed. You confirm it with `git diff --stat` or a targeted re-fetch, so the agent's prose is a bonus and losing it costs nothing.

**It does NOT hold when the agent's REPORT is the entire deliverable.** Research, verification, audits, plan-delta extraction, log digging, "go and find out X" — if there is no artifact to inspect afterwards and the text is the whole point, **dispatch blocking (`run_in_background: false`)**.

Why this is a rule and not a preference: **collection of a detached agent's final text is unreliable in practice.** In one observed session, six consecutive detached agents each completed their work and *none* delivered a report; `SendMessage` asking one to deliver produced another idle notification rather than the report, and the documented fallbacks did not recover it either. Blocking dispatch has not exhibited this. So:

- **Report is the deliverable → blocking.** Non-negotiable, however long it runs. Several such agents in ONE message run concurrently and all land together, so blocking costs parallelism nothing.
- **Side effect is the deliverable → background**, and verify the side effect yourself rather than waiting to be told.
- **Never dispatch a verification agent detached and then treat its silence as a verdict.** No report means no verdict — it does not mean pass.

**★ Collecting a background agent's result — this is where it goes wrong.** A background agent's final text is not automatically pushed into the lead's turn. What you may see instead is a `{"type":"idle_notification","idleReason":"available"}` teammate message, which reads exactly like an agent that silently gave up. **It usually is not** — the work is typically done, only the report is stranded. Before concluding anything failed:

- **Check `run_in_background` and how you expected the result to arrive** — misreading an idle notification as failure is the common error, not agent flakiness.
- **Read the agent's own output** rather than waiting to be told: background work writes to the task output file reported at dispatch.
- **`SendMessage` to the agent's `name`** resumes it from its transcript and asks it to deliver. Ask for the partial result explicitly and tell it not to start new work.
- **`TaskOutput` is NOT a fallback for a local agent** — its output file is a symlink to the full subagent transcript (JSONL) and reading it overflows the lead's context. Reserve it for background *shell* tasks.
- **If two collection attempts fail, stop trying.** Either verify the underlying artifact yourself, or re-dispatch **blocking** — do not spend a third turn negotiating with a stranded report.
- **Diagnose BEFORE you re-dispatch — then re-dispatch freely.** Re-dispatching is the right move once you know the cause and have fixed it (wrong flag, bad prompt, genuinely dead agent). What wastes work is re-dispatching *blind*, on the assumption the agent did nothing: this has burned a whole run of consecutive delegates that all looked failed while every one had actually completed its task. Collect first, fix the cause, then fire again.

**Worktrees:** `isolation: "worktree"` creates them under `<project>/.claude/worktrees/` — the harness default and the required location per `agents-worktrees`.

| Tier | Model |
|------|-------|
| cheap | `haiku` |
| default | `sonnet` |
| smart | `opus` |
| max | `fable` (`claude-fable-5`) |

`max`/`fable` is the ceiling — reserve it for the single hardest problems; `smart`/`opus` covers most heavy work.
