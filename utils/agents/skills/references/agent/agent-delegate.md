# Agent Delegation

Shared logic for creating and dispatching subagents via the active runtime's dispatch mechanism. Used by all `agent-*` skills.

**This file is runtime-agnostic on purpose.** It covers what every dispatch needs — parameters, prompt shape, reaping discipline. Every mechanic that varies per runtime (permission handling, background defaults, how a result reaches you, limits) lives in `agent-delegate-harness-<provider>` and is authoritative there. When the two disagree, the harness reference wins.

## Dispatch mechanisms

- **Claude Code** — the built-in `Agent` tool; parameters per `agent-delegate-harness-claude`.
- **OpenCode** — the `task` tool (subagent dispatch, allowed in `opencode.jsonc`). Set the subagent's model to the resolved `kilic/*` slug.
- **Codex** — its own task/subagent spawning. Set the resolved `gpt-*` model.
- **Other / custom** — Claude API SDK, OpenAI SDK, or a custom dispatch; the `model` value is whatever that mechanism expects.

Whatever the mechanism, the flow is the same: pick a tier from task complexity, resolve it to a concrete model via the active harness's list, build a self-contained prompt, dispatch.

## FIRST: settle the permission context

**How a subagent gets its permissions is a runtime property, and getting it wrong is the most expensive dispatch mistake.** Read the active `agent-delegate-harness-<provider>` reference before the first dispatch. Two shapes exist in the wild:

- **Inherited** — the subagent runs with the parent session's permission mode (current Claude Code). You therefore **cannot grant an agent more autonomy than the session has**; a task needing more is a conversation with the user about the session, not a dispatch parameter. Attempting to pass a permission mode on the dispatch is a no-op.
- **Independent** — the subagent has its own permission context and a gate it hits may not surface to the parent, so it can wait forever with no error, no timeout, and no tool calls. Older Claude Code builds behaved this way; assume any unfamiliar runtime might.

Rules that hold either way:

- **Granting autonomous access is a security decision, not a default.** Get the user's explicit opt-in, scope the prompt to exact paths with a do-not-touch list, and keep irreversible steps on the main loop.
- **Cross-repo and cross-directory dispatch is the riskiest case** on any runtime — settings and isolation are usually scoped to a filesystem path.
- **Diagnose by inspecting the artifact, never the notification.** Work present but no report means the work happened and only the delivery failed — verify it and move on, do **not** re-run. **Silence is neither success nor failure.**
- **An ABSENT artifact proves nothing.** It does not mean the agent never ran, never worked, or is broken. Most agents write once near the end, so one that has read twenty files and formed its entire answer looks **identical on disk** to one that never started. Treating an empty disk as "it never ran" and reaping on that basis **destroys real work**, and reaping is terminal. When there is nothing to inspect you have learned nothing — steer it (below) rather than concluding.

## An agent that is quiet, thin, or finished — COLLECT, never redo

**You have control over your agents.** One that has gone quiet, looks stuck, or handed back a vague summary is a thing you can **talk to**, and that is nearly always the cheapest fix.

An agent that finishes and returns "I made the changes" with no detail **has almost certainly done the work** — its transcript holds the specifics and the changes are on disk. What failed is the last step, and it is the cheapest one to retry. **Taking the work in-house discards a completed run, pays for it twice, and loses everything it learned that you did not think to ask about.** It also feels like progress, which is why it happens.

### 1. Establish the agent's state — it decides the branch

- **Reachable, and this is the usual answer.** **Finishing does not put an agent out of reach.** Where the runtime supports resuming, a completed agent — and often a stopped one — takes a message and picks up from its own transcript. Running and idle agents are reachable too.
- **Genuinely gone** — the spawning session no longer exists, the runtime cannot resume at all, or the name now resolves to a **different** agent. Only then is there nobody to ask.

**Do not treat "it already finished" as gone.** That mistake sends you reconstructing from the diff while the agent sits holding the report. Which states are reachable, and whether a name can drift onto another agent, are runtime properties: `agent-delegate-harness-<provider>`.

### 2. Nudge — the only step that recovers the reasoning

A message is cheaper than reading a large diff, and it is the only thing that recovers what the artifact cannot show: why something was done, what was deviated from, what was found and deliberately left alone. Reconstructing that yourself is the in-house failure in miniature.

**Check that delivery was ever possible before blaming the agent.** On some runtimes an agent's plain text does not reach the lead at all and the report must be sent explicitly — one that "returned nothing" may have written a perfect report into the void. That is a brief bug, fixed by a delivery instruction, not a re-dispatch.

**Name the exact artifact, one at a time.** A specific ask retrieves it in one round; "can you give more detail" returns another summary, and a nudge listing five requests returns a summary of five things.

- "Give me the unified diff of every file you changed."
- "You said you verified it — paste the command and its output."
- "Which of the four files did you not change, and why?"

### 3. Debug the cause, if steering gets nothing

Look for something concrete: an auth failure, a tool erroring, a path it cannot reach, a permission gate the runtime is not surfacing, a scope too large to finish. A named cause is what makes the next step a fix rather than a guess.

### 4. Discover how far it got, before replacing anything

A lost agent still leaves evidence — the working tree, a branch, the output path, an MR it opened, its transcript. **Establish how far it actually got**, because the answer is usually not "run the whole thing again":

| What you find | Do |
|---|---|
| **Complete** | Verify and move on. Only the report was missing. |
| **Partial and coherent** | Re-dispatch **scoped to the remainder**, naming what already exists so it neither redoes nor clobbers it. |
| **Partial and half-applied** | Decide deliberately between finishing and resetting. This is the dangerous one — it looks done. |
| **Nothing** | Re-dispatch in full, and fix the brief first if the brief was the cause. |

**Re-dispatching without this discovery is how work gets destroyed.** A fresh agent aimed at a half-done task duplicates or overwrites it, and neither agent reports the collision. **Reap before re-dispatching.**

### 5. Ask the user

If steering produced nothing, you cannot name a cause, and your brief looks sound, **stop and surface it.** Do not loop re-dispatching, and never quietly take the work in-house without saying so — an unexplained agent failure is information the user needs.

### Collecting and verifying are different jobs

Collect from the agent; verify against the artifact — `git status`, `git diff`, the output path. **Do both.** A correct diff under a useless summary still needs the summary, because the reasoning is not in the diff. And never let an unusable report pass silently: reporting a task done on an agent's word, with no evidence, is the same failure wearing a better outfit.

Say which state you found. "Re-ran it" and "finished the remaining four files because six were already correct" are different events, and only one is a repeat cost.

## Reaping — terminal for the run, so COLLECT FIRST

> **Stopping an agent ends its run.** Reap only when you are finished with it: you have what you need, you have no further question, and the work has moved on.
>
> **A quiet agent is a candidate for COLLECTION, not for reaping.** Quiet usually means the work is done and only the delivery is pending. Collect first — read its result, or message it. On runtimes where a completed agent can be resumed by message (Claude Code), killing it is the one move that forecloses that. Steering is reversible; reaping is not.

**Order, always:** collect → confirm you have what you need → *then* reap.

Genuinely safe to reap:

- it delivered, you acted on the result, and the task is closed,
- you obtained the answer another way **and verified it**, so its report is redundant,
- its task was superseded, re-scoped, or abandoned,
- **you are about to replace it** — reap before re-dispatching, so two agents never write the same target,
- it is demonstrably stale: guarding work that no longer exists, or polling a signal now known to be wrong.

**Do NOT reap** because it went quiet, because you are unsure whether it finished, or to tidy up mid-flow. Uncertainty means collect.

**The concrete hazard is two concurrent writers.** Re-dispatching over the same files, document, or resource without reaping the first lets the later write silently clobber the earlier one — and neither agent reports the collision.

**Completion does not self-clean.** A finished agent, and a background task whose command already exited, can linger in the runtime's task list. Stop them explicitly per `agent-delegate-harness-<provider>` once you are done.

**Reap checkpoint:** before declaring the work done, enumerate everything you spawned and confirm each is stopped, or state that one is *deliberately* still running and what it waits on.

## Dispatch Mode — background by default, where the runtime supports it

> **Background is the preferred posture where the runtime delivers results reliably** (Claude Code: background is the tool default, and a finished agent's result arrives as a completion notification in a later turn). The lead stays free, the user keeps talking, you keep working.
>
> **Block when you need the result to continue** — the next step depends on it and you would otherwise sit idle. Blocking costs no parallelism: several dispatches in ONE message run concurrently and land together.
>
> **On a runtime that does NOT wake you on completion (Codex today), background is a trap** — the work finishes into silence and nobody re-invokes you. There, block, or poll explicitly, or have the agent write its result to a file you read afterwards.

**Decide with two questions:**

1. **Does this runtime deliver a detached result?** If no, block or poll. `agent-delegate-harness-<provider>` answers this.
2. **What will you inspect when it finishes?** A side effect you can verify yourself (files changed, resources written) is safe to background — you confirm it directly. If the agent's prose is the entire deliverable and the runtime's delivery is unreliable, block.

**Never treat silence as a verdict.** A quiet verification agent has not passed anything. Equally, do not assume delivery is broken on a runtime where it works — check the harness reference before concluding an agent failed.

**Consequences of blocking:** no mid-execution message exchange (the lead is paused), and user guidance only arrives on the next turn.

## Model Selection

Delegation picks a **tier** from task complexity, then resolves it to a **concrete model** for the active runtime. The tier system, user-wording mapping, and per-harness model lists live in the **`agent-harness`** skill and its references (`agent-delegate-harness-claude`, `agent-delegate-harness-opencode`, `agent-delegate-harness-codex`).

- **Tiers:** `cheap` (mechanical), `default` (integration), `smart` (architecture/review), `max` (absolute ceiling — use sparingly).
- **Explicit model names override tiers** — use verbatim.
- **Ask on mismatch** — if the chosen tier/model looks wrong for the task, state it and propose an alternative before dispatching.

## Self-Contained Prompt Structure

Agents start with a fresh context window — no conversation history, no files you already read, no skills you already loaded. Every dispatch prompt must include:

1. **Role and scope** — one-sentence framing of what the agent is responsible for.
2. **Task** — concrete description, detailed enough that another engineer could execute it.
3. **Files** — exact paths the agent owns (reads anywhere, writes only within scope).
4. **Context** — relevant architecture, patterns, conventions, adjacent work.
5. **Boundaries** — what NOT to touch (other agents' scope, read-only files), and **do not open anything in the captain's browser or editor unless this prompt says to**. Opening is the lead's call and the lead's timing, per `open-artifact` — say so explicitly when you do want the agent to open its result.
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
6. Does the dispatch mode match the runtime's delivery behavior (per `agent-delegate-harness-<provider>`), and does the agent have the tools it needs in that mode?
7. Does the session's own permission posture actually allow the work you are asking for?

## Key Principles

- **Self-contained prompts.** Agents share no context — everything must be in the prompt.
- **Tiers, not model names.** Think cheap/default/smart/max; resolve at dispatch time via `agent-harness`.
- **`max` is the ceiling — use sparingly.** `smart` covers most heavy work.
- **The harness reference owns the mechanics.** Permission handling, background defaults, delivery, and limits are runtime properties — never carry one runtime's behavior to another.
- **Match tier to task**, and **ask on mismatch** rather than silently complying.
- **Verify results.** Agent summaries describe intent, not outcomes. Check the artifact — and for code, check that it matches the house style, not just that it works (`agent-conventions`).
- **A thin report means nudge, not redo.** The work is on disk and the specifics are in its transcript; taking the task in-house discards a finished run and pays for it twice.
- **When collection fails, discover how far it got before re-dispatching.** Scope the replacement to what remains — a fresh agent pointed at half-finished work duplicates or clobbers it, and neither reports the collision.
