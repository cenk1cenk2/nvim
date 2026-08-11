# Agent Delegation

Shared logic for creating and dispatching subagents via the active runtime's dispatch mechanism. Used by all `agent-*` skills.

**This file is runtime-agnostic on purpose.** It covers what every dispatch needs — parameters, prompt shape, reaping discipline. Every mechanic that varies per runtime (permission handling, background defaults, how a result reaches you, limits) lives in `harness-<provider>-agent-delegate` and is authoritative there. When the two disagree, the harness reference wins.

## Dispatch mechanisms

- **Claude Code** — the built-in `Agent` tool. The parameter table below describes it.
- **OpenCode** — the `task` tool (subagent dispatch, allowed in `opencode.jsonc`). Set the subagent's model to the resolved `kilic/*` slug.
- **Codex** — its own task/subagent spawning. Set the resolved `gpt-*` model.
- **Other / custom** — Claude API SDK, OpenAI SDK, or a custom dispatch; the `model` value is whatever that mechanism expects.

Whatever the mechanism, the flow is the same: pick a tier from task complexity, resolve it to a concrete model via the active harness's list, build a self-contained prompt, dispatch.

## Agent Tool Parameters (Claude Code)

| Param | Required | Purpose |
|-------|----------|---------|
| `description` | yes | Short (3-5 word) task summary. Shown in telemetry and to the user. |
| `prompt` | yes | Full self-contained task prompt. Agents do not share context with you or each other. |
| `subagent_type` | no | `general-purpose` (default), `Explore` for research-heavy work, or a specialized agent type. |
| `model` | no | `haiku`, `sonnet`, `opus`, `fable`, a full model ID, or `inherit`. See Model Selection below. |
| `effort` | no | Reasoning effort for this agent (`low`…`max`); overrides the session level. |
| `isolation` | no | `worktree` runs the agent in a temporary git worktree branched from the **default branch**, auto-removed if it changes nothing. Costs disk and setup time — use it only when parallel writers would collide. See `agent-worktrees`. |
| `name` | no | Agent name for `SendMessage` routing and for resuming it later. |
| `run_in_background` | no | Detached execution. **Default is background on Claude Code**; other runtimes differ — check `harness-<provider>-agent-delegate`. |
| `mode` | — | **Deprecated and ignored** on current Claude Code. See the permission section below. |

## FIRST: settle the permission context

**How a subagent gets its permissions is a runtime property, and getting it wrong is the most expensive dispatch mistake.** Read the active `harness-<provider>-agent-delegate` reference before the first dispatch. Two shapes exist in the wild:

- **Inherited** — the subagent runs with the parent session's permission mode (current Claude Code). You therefore **cannot grant an agent more autonomy than the session has**; a task needing more is a conversation with the user about the session, not a dispatch parameter. Attempting to pass a permission mode on the dispatch is a no-op.
- **Independent** — the subagent has its own permission context and a gate it hits may not surface to the parent, so it can wait forever with no error, no timeout, and no tool calls. Older Claude Code builds behaved this way; assume any unfamiliar runtime might.

Rules that hold either way:

- **Granting autonomous access is a security decision, not a default.** Get the user's explicit opt-in, scope the prompt to exact paths with a do-not-touch list, and keep irreversible steps on the main loop.
- **Cross-repo and cross-directory dispatch is the riskiest case** on any runtime — settings and isolation are usually scoped to a filesystem path.
- **Diagnose by inspecting the artifact, never the notification.** Work present but no report means the work happened and only the delivery failed — verify it and move on, do **not** re-run. **Silence is neither success nor failure.**
- **An ABSENT artifact proves nothing.** It does not mean the agent never ran, never worked, or is broken. Most agents write once near the end, so one that has read twenty files and formed its entire answer looks **identical on disk** to one that never started. Treating an empty disk as "it never ran" and reaping on that basis **destroys real work**, and reaping is terminal. When there is nothing to inspect you have learned nothing — steer it (below) rather than concluding.

## A quiet or stuck agent — STEER FIRST, escalate in this order

**You have control over your agents.** An agent that has gone quiet, looks stuck, or has produced nothing is a thing you can **talk to**, and that is nearly always the cheapest fix. Work the ladder in order and do not skip a rung — each later rung costs more and destroys more.

1. **Steer it.** Message it. Ask for whatever it has right now, even partial. Nudge it, narrow its scope, tell it to write incrementally to disk, remind it of the output path, or redirect it if it has wandered. **This resolves most cases**, and it costs one message and no work.
2. **Debug the cause.** If steering gets nothing, look for a concrete reason: an auth or credential failure, a tool erroring, a path it cannot reach, a permission gate the runtime is not surfacing, a scope so large it cannot finish. Inspect what it *can* see. A named cause is what makes the next rung a fix rather than a guess.
3. **Re-dispatch — only when the cause was YOURS.** If your brief was the problem — missing context, a wrong path, an impossible or unbounded scope, a tool it was never going to have — fix the brief and dispatch again. **Reap before re-dispatching** so two agents never write the same target. Re-dispatching without a diagnosed cause just repeats the failure with fresh tokens.
4. **Ask the user.** If steering produced nothing, you cannot name a cause, and your brief looks sound, **stop and surface it.** Do not loop re-dispatching, and do not quietly take the work in-house without saying so — an unexplained agent failure is information the user needs.

**Reaping is never the first response to silence.** It is terminal: it destroys the report, and on runtimes where a finished agent can be resumed by message it also forecloses that. Steering is reversible; reaping is not.

## ABSOLUTE — A thin report is a DELIVERY failure, not a work failure

An agent that finishes and hands back a vague summary, a paragraph where you asked for a diff, or "I made the changes" with no detail **has almost certainly done the work**. Its transcript holds the specifics. What failed is the last step, and the last step is the cheapest one to retry.

**The wrong response is to take the work in-house.** Redoing it locally discards a completed run, pays for it a second time, and loses everything it learned that you did not think to ask about. It also feels like progress, which is why it happens.

### Check the artifact before you judge the report

**Work lands on disk, not in the message.** Before concluding anything, look at what actually changed:

- `git status` and `git diff --stat` in the target repository.
- The output path you asked it to write.
- Whether the run made many tool calls or ran a long time — both mean it did something, whatever it said.

A correct diff under a useless summary is a **formatting problem**. Read the diff and move on; do not ask it to redo work that is already sitting in the working tree.

### Then nudge, and be specific

A finished agent can be resumed by message and answers from its existing transcript, so it still has everything. **Name the exact artifact you are missing.** A specific ask retrieves it in one round; a vague "can you give more detail" returns another summary.

- "Give me the unified diff of every file you changed."
- "List each file you touched with a count of replacements."
- "You said you verified it — paste the command you ran and its output."
- "Which of the four files did you not change, and why?"

**Ask for one thing at a time.** A nudge listing five requests tends to come back as a summary of five things rather than the five artifacts.

### The ladder for a bad report

1. **Inspect the artifact.** Often the answer is already there and no message is needed.
2. **Nudge for the specific missing piece.** One artifact, named exactly.
3. **Nudge again, narrower**, if the reply is still a summary — ask for a single file, a single command's output.
4. **Read its transcript or output file** where the runtime exposes one.
5. **Only then reconstruct**, and say plainly that you did and why the collection failed.

Rungs 1 through 3 resolve nearly everything and cost one message each. Rung 5 costs the whole task again.

**Never let an unusable report pass silently either.** Accepting a summary you cannot verify, and reporting the task as done on its word, is the same failure wearing a better outfit — you have no evidence, and neither does the user.

## Dispatch Mode — background by default, where the runtime supports it

> **Background is the preferred posture where the runtime delivers results reliably** (Claude Code: background is the tool default, and a finished agent's result arrives as a completion notification in a later turn). The lead stays free, the user keeps talking, you keep working.
>
> **Block when you need the result to continue** — the next step depends on it and you would otherwise sit idle. Blocking costs no parallelism: several dispatches in ONE message run concurrently and land together.
>
> **On a runtime that does NOT wake you on completion (Codex today), background is a trap** — the work finishes into silence and nobody re-invokes you. There, block, or poll explicitly, or have the agent write its result to a file you read afterwards.

**Decide with two questions:**

1. **Does this runtime deliver a detached result?** If no, block or poll. `harness-<provider>-agent-delegate` answers this.
2. **What will you inspect when it finishes?** A side effect you can verify yourself (files changed, resources written) is safe to background — you confirm it directly. If the agent's prose is the entire deliverable and the runtime's delivery is unreliable, block.

**Never treat silence as a verdict.** A quiet verification agent has not passed anything. Equally, do not assume delivery is broken on a runtime where it works — check the harness reference before concluding an agent failed.

**Consequences of blocking:** no mid-execution message exchange (the lead is paused), and user guidance only arrives on the next turn.

## Reaping — terminal for the run, so COLLECT FIRST

> **Stopping an agent ends its run.** Reap only when you are finished with it: you have what you need, you have no further question, and the work has moved on.
>
> **A quiet agent is a candidate for COLLECTION, not for reaping.** Quiet usually means the work is done and only the delivery is pending. Collect first — read its result, or message it. On runtimes where a completed agent can be resumed by message (Claude Code), killing it is the one move that forecloses that.

**Order, always:** collect → confirm you have what you need → *then* reap.

Genuinely safe to reap:

- it delivered, you acted on the result, and the task is closed,
- you obtained the answer another way **and verified it**, so its report is redundant,
- its task was superseded, re-scoped, or abandoned,
- **you are about to replace it** — reap before re-dispatching, so two agents never write the same target,
- it is demonstrably stale: guarding work that no longer exists, or polling a signal now known to be wrong.

**Do NOT reap** because it went quiet, because you are unsure whether it finished, or to tidy up mid-flow. Uncertainty means collect.

**Completion does not self-clean.** A finished agent, and a background task whose command already exited, can linger in the runtime's task list. Stop them explicitly via the runtime's own mechanism (per `harness-<provider>-agent-delegate`) once you are done.

**The concrete hazard is two concurrent writers.** Re-dispatching over the same files, document, or resource without reaping the first lets the later write silently clobber the earlier one — and neither agent reports the collision.

**Reap checkpoint:** before declaring the work done, enumerate everything you spawned and confirm each is stopped, or state that one is *deliberately* still running and what it waits on.

## Model Selection

Delegation picks a **tier** from task complexity, then resolves it to a **concrete model** for the active runtime. The tier system, user-wording mapping, and per-harness model lists live in the **`agent-harness`** skill and its references (`harness-claude-agent-delegate`, `harness-opencode-agent-delegate`, `harness-codex-agent-delegate`).

- **Tiers:** `cheap` (mechanical), `default` (integration), `smart` (architecture/review), `max` (absolute ceiling — use sparingly).
- **Explicit model names override tiers** — use verbatim.
- **Ask on mismatch** — if the chosen tier/model looks wrong for the task, state it and propose an alternative before dispatching.

## Self-Contained Prompt Structure

Agents start with a fresh context window — no conversation history, no files you already read, no skills you already loaded. Every dispatch prompt must include:

1. **Role and scope** — one-sentence framing of what the agent is responsible for.
2. **Task** — concrete description, detailed enough that another engineer could execute it.
3. **Files** — exact paths the agent owns (reads anywhere, writes only within scope).
4. **Context** — relevant architecture, patterns, conventions, adjacent work.
5. **Boundaries** — what NOT to touch (other agents' scope, read-only files).
6. **Verification** — commands to run after implementation (from `project-tooling` discovery).
7. **Conventions** — **mandatory for any prompt that writes code.** Paste the filled-in block from `agent-conventions`: study the neighbouring files first, copy the local naming/structure/error idiom, match comment density (usually none), stay in scope, and self-check the diff before reporting. An agent given no conventions writes its own dialect, and the result reads as foreign even when it works.
8. **Report** — expected status format (DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED) and its length bound. For code work, also require: which files it used as its pattern reference, and anything it had to invent for lack of local precedent.

Point at skills and tools by name rather than inlining them when the target shares your access — see `agent-target-capability`.

## Dispatch Checklist

1. Is the prompt self-contained? Could someone execute it with no other context?
2. Is the tier right for the task, and resolved to a concrete model for the active runtime?
3. Are file boundaries explicit? No "and related files."
4. Are verification commands included when the task modifies code?
4b. Does the prompt carry the `agent-conventions` block — prior-art study, naming, comment discipline, scope limits, and the pre-report self-check?
5. Is isolation right? Worktree for parallel writers; omit for read-only work.
6. Does the dispatch mode match the runtime's delivery behavior (per `harness-<provider>-agent-delegate`), and does the agent have the tools it needs in that mode?
7. Does the session's own permission posture actually allow the work you are asking for?

## Key Principles

- **Self-contained prompts.** Agents share no context — everything must be in the prompt.
- **Tiers, not model names.** Think cheap/default/smart/max; resolve at dispatch time via `agent-harness`.
- **`max` is the ceiling — use sparingly.** `smart` covers most heavy work.
- **The harness reference owns the mechanics.** Permission handling, background defaults, delivery, and limits are runtime properties — never carry one runtime's behavior to another.
- **Match tier to task**, and **ask on mismatch** rather than silently complying.
- **Verify results.** Agent summaries describe intent, not outcomes. Check the artifact — and for code, check that it matches the house style, not just that it works (`agent-conventions`).
- **A thin report means nudge, not redo.** The work is on disk and the specifics are in its transcript; taking the task in-house discards a finished run and pays for it twice.
