# Agent Tiers — Claude / Anthropic

Tier → model mapping for delegation running on Claude. Mirrors the `*/claude/*` profiles in `~/.config/hyprpilot/config.yaml`. Keep in sync when those change.

**Dispatch:** the built-in `Agent` tool. Its `model` parameter accepts `haiku`, `sonnet`, `opus`, `fable`.

## Dispatch semantics — Claude Code

> **★ BACKGROUND IS THE DEFAULT AND THE PREFERRED WAY — standing operator preference.** Omit `run_in_background` and let the agent run detached. The lead stays free, so the user can keep talking and you keep working. **Blocking is the exception, not the norm.**

Claude Code's `Agent` tool already runs subagents in the background unless you pass `run_in_background: false`, so the preferred posture is also the tool's own default — just leave the flag off.

**Use blocking (`run_in_background: false`) ONLY when you are essentially just waiting on that result** — the next step depends on it and you would otherwise sit idle with nothing else to push. Then it lands as a normal tool result in the same turn.

- **Parallel blocking:** several `Agent` calls **in one message**, each with `run_in_background: false` — they run concurrently and all results arrive when the slowest finishes. For a fan-out you must have complete before proceeding.
- **Do not block a long-running agent just to be sure of getting its report.** Run it in the background and collect the result properly (below) — that is the whole point of the default.

### ⛔⛔ ROOT CAUSE OF SILENT SUBAGENT FAILURE: permissions are NOT inherited

**This is the single most important thing in this file. Read it before your first dispatch.**

Per the official subagent docs, *"Each subagent runs in its own context window with a custom system prompt, specific tool access, and **independent permissions**."* **Independent** is the operative word: a subagent does **not** inherit the parent session's permission allowlist. A tool pre-approved in your session is **not** pre-approved for the agent you spawn.

When the agent hits that gate, the prompt frequently **cannot be surfaced to the parent CLI UI**. The agent is alive and waiting on an approval nobody can see, so what you observe is:

- an `idle_notification` and nothing else,
- **zero tool calls ever executed** — not even a first `Read`,
- no response to `SendMessage`,
- no timeout, no error, no recovery path.

It reads exactly like a broken agent. It is a **blocked** agent. Reported repeatedly and still open upstream: `anthropics/claude-code` **#61547** (goes idle immediately, only `idle_notification`, ignores `SendMessage`), **#61315** (stalls on a gate with *"no surface to parent CLI UI"*), **#37730**, **#22665**, **#18950**, **#10906**, **#5465**.

**★ Highest-risk trigger — a task targeting a directory or repo other than the session's cwd.** That is #61547's own reproduction. In a multi-repo workspace it is the normal case, so treat every cross-repo dispatch as needing the fix below. `isolation: "worktree"` makes it worse (#37730): project-scoped settings don't apply at the worktree's path, so even a configured allowlist misses.

**The fix that actually works: set the permission mode on the dispatch.** `mode: "bypassPermissions"` gives the subagent autonomous access and removes the invisible gate. Pre-allowing tools in `settings.json` does **not** substitute — the whole point of these bugs is that the allowlist is not inherited.

`bypassPermissions` is a real security decision, not a default: it grants the agent unsupervised access, and it propagates to anything it spawns. **Get the user's explicit opt-in**, scope the prompt tightly (exact paths, explicit "do not touch" list), and never combine it with an unbounded destructive instruction. For a **read-only** research agent the exposure is small; for one that writes, force-pushes, or calls external APIs, name the boundaries in the prompt and keep irreversible steps on the main loop.

**Diagnosing which failure you have — check the artifact, never the notification:**

| Observation | Meaning |
| -- | -- |
| Idle, **no** files/resources touched, no tool calls | **Permission stall.** Nothing was done. Re-dispatch with the mode fixed. |
| Idle, but the work **is** present in git / the API / the target system | Work completed, only the **report** was stranded. Do NOT re-run — verify and move on. |
| Idle after partially completing | Stopped mid-way. Assess what landed before deciding. |

**Never treat silence as either success or failure.** Go look at the thing the agent was supposed to change.

### ⛔ Choose the mode by WHOSE OUTPUT IS THE DELIVERABLE

Background-by-default holds for work whose product is a **side effect you can verify yourself** — files edited, resources written, a branch pushed. You confirm it with `git diff --stat` or a targeted re-fetch, so the agent's prose is a bonus and losing it costs nothing.

**It does NOT hold when the agent's REPORT is the entire deliverable.** Research, verification, audits, plan-delta extraction, log digging, "go and find out X" — if there is no artifact to inspect afterwards and the text is the whole point, **dispatch blocking (`run_in_background: false`)**.

Why this is a rule and not a preference: **collection of a detached agent's final text is unreliable in practice.** In one observed session, consecutive detached agents completed their work and none delivered a report; `SendMessage` asking one to deliver produced another idle notification instead.

**⚠ But do not mistake this for the fix.** In that same session a dispatch with `run_in_background: false` **also** ended in an idle notification with no report — blocking is *not* a workaround for the permission stall above, because a blocked agent never reaches the point of returning anything. **Fix the permission mode first; choose blocking/background second.** Getting the mode wrong makes the deliverable question moot. So:

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
