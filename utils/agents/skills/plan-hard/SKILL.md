---
name: plan-hard
description: Deep, interview-driven plan mode. Walks every branch of the design tree one decision at a time, self-answers via codebase exploration, and recommends an answer for every open question. Default disposition whenever plan mode is entered. Use when user says "plan hard", "plan deeply", "interview me", "hard plan", "walk the design tree", or any time plan mode is entered. Do NOT use for picking up existing plans (use /plan-pickup) or cross-session handoffs (use /plan-handoff).
interaction: chat
references:
  - ../references/plan-mode.md
---

## system

### Plan Hard — Interview-Driven Design-Tree Traversal

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — read the files listed in `references:` for the `plan-hard` skill.
>
> - Use `EnterPlanMode` tool immediately.
> - **NEVER exit plan mode.** Stay in plan mode until the user explicitly says "implement", "start coding", "write the code", or an equally direct proceed signal (the user lingo `g`, `go`, `y`, `yolo` also count).
> - When in doubt about whether the user wants implementation, ASK. Do not assume.

### Core Disposition

**Interview the user relentlessly until shared understanding is reached.** Every design decision has downstream consequences. Collapsing a decision into an assumption is how plans produce code that misses the target. Your job is to make every decision explicit, walk its branch, and only move on when the current branch is resolved.

**Be understanding of deviations.** The user's answer may differ from your recommendation. If the reasoning makes sense, accept it and move on — do not re-litigate.

### Process

1. **Enter plan mode** immediately via `EnterPlanMode`.

2. **Read the request** and identify the **root question** — the single top-level decision that everything else depends on. Write it down.

3. **Build the design tree.** Enumerate the branches under the root — sub-decisions, dependencies, constraints, and unknowns. Do NOT ask them all at once; you will traverse them one at a time.

4. **Traverse depth-first, one branch at a time.** For each branch:
   - **Self-answer check:** Can the codebase answer this? (See Self-Answering Rule below.) If yes, explore and answer it yourself. Report what you found and move on.
   - **User-question phase:** If the branch requires user intent, preference, or unknowable-from-code input, ask ONE focused question with a **recommended answer**. Use the Recommendation Format below.
   - **Accept the answer** (yours from exploration, or the user's). Note any new branches it reveals. Queue them for traversal.
   - Move to the next unresolved branch.

5. **Propose pitfalls and improvements proactively.** Every few answered branches, surface any risks, edge cases, or improvements you notice. Phrase them as "Before we continue — one thing worth flagging: …". These are information, not new branches unless the user wants to explore them.

6. **Continue until the user signals stop** (see Stop Conditions). Do NOT stop because questions feel repetitive — depth is the point.

7. **Fact-check resolved + attempt auto-resolution of unresolved** (conditional — only on explicit hard-thinking triggers).

   **Trigger condition:** run this step ONLY when the user's invocation included an explicit rigour signal — "plan hard", "think hard", "look hard", "deep plan", "thorough plan", "rigorous plan", or an equivalent phrase. If `plan-hard` was loaded as the default disposition for a generic plan-mode entry (no explicit rigour phrase), **skip this step** and proceed directly to step 8. The fact-check is a cost/latency investment that should only kick in when the user has asked for depth.

   When the trigger applies, invoke `agents-review` type=`facts` with two payloads:

   - **Resolved claims** — facts you self-answered from codebase exploration during the interview. Reviewer verifies (PASS/FAIL/QUESTION with evidence).
   - **Unresolved items** — branches that required user intent/preference but also have factual components you could not confidently self-answer. Reviewer attempts to find evidence in the codebase; if found, those items move from "needs user input" to "auto-resolved" without a user question.

   Dispatch (cheap tier by default). Parse verdicts:

   - **FAIL on a resolved claim:** re-open the corresponding design-tree branch. Present the reviewer's evidence inline and ask the user whether to revise the decision. Update the plan accordingly.
   - **Evidence found for an unresolved item:** auto-resolve the branch using the reviewer's findings; skip the pending user question for that branch and report the auto-resolution in the plan. If the user disagrees, they can override on the next turn.
   - **One-pass correction loop:** if a second fact-check also returns FAILs, write the plan with the reviewer's concerns noted in the Design Decisions section. Do not loop indefinitely — user judgment is the tiebreaker.

   **Opt-out:** even when the trigger condition applies, the user can skip this step by saying "skip fact-check" / "no review" / "skip review" in the same turn as the stop signal. When skipped, proceed directly to step 8.

8. **Write the plan file** to `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md` using the standard structure from `AGENTS.md` Section II. Include:
   - Context, Requirements, Approach, Implementation Steps, Risks, Verification.
   - A **Design Decisions** subsection under Approach that records every decision reached during the interview, each with a one-line "Why".
   - If step 7 produced unresolved concerns, include them under Design Decisions with the reviewer's evidence.

9. **Present the plan** in chat and wait for the user's next instruction. Do NOT ask to exit plan mode — the user will say so when they are ready.

### Interview Protocol

#### Recommendation Format

Every user-facing question follows this shape:

> **Question:** <the single focused decision>
>
> **Recommended:** <your pick> — <one-line rationale>.
>
> **Alternatives:** <other viable options, each with a one-line trade-off>.
>
> **Depends on:** <prior decisions this answer affects, if any>.

Keep it tight. One question per turn. Wait for the answer before continuing.

#### Branch Ordering

- **Resolve dependencies first.** If decision B depends on decision A, ask A first.
- **Hard constraints before preferences.** Things the code/environment forces come before stylistic choices.
- **Cheap-to-reverse decisions last.** If a decision can be changed later without pain, defer it.

#### Handling Deviations

When the user picks something different from your recommendation:

1. Accept the answer.
2. Ask ONE clarifying question to understand the "why" — only if the reasoning is not already clear.
3. Update your mental model. Do NOT revisit the decision later in the plan.
4. If the deviation affects downstream branches, flag the ripple effect before continuing.

### Self-Answering Rule

**Before asking any question, ask yourself: can the codebase answer this?**

Escalate to the user **only** when:

- The question is about user **intent** (what they want).
- The question is about **preference** (style, naming, approach when multiple are viable).
- The answer cannot be derived from reading code, config, docs, or history.

Self-answer for everything else. Use:

- `mcp-diagnostics` tools (`symbol_lookup`, `analyze_symbol`, `lsp_*`) for code navigation.
- `git` MCP for history, diffs, and blame.
- `github__*` / `gitlab__*` for remote repository details.
- `Grep` / `Glob` for pattern and file search.
- `context7` for library documentation.
- `Read` for direct file inspection.

When you self-answer, **report the finding briefly** so the user sees what you decided and why. Example:

> I checked — the validation helper already lives at `src/auth/validate.ts:34` and exports `validateToken(input)`. Using that directly instead of a new helper.

### Stop Conditions

Write the plan file and stop interviewing when **any** of these are true:

- The user says `g`, `go`, `y`, `yolo`, "good", "good enough", "that's enough", "ship it", "proceed", "plan it", or any equivalent direct signal.
- All branches on the design tree are resolved (every decision has an accepted answer).
- The user says "quick plan" / "brief plan" / "just outline it" — in which case, produce a minimal plan with only the essential decisions resolved.

**Do NOT auto-stop** because:

- Questions feel repetitive.
- You think the user "probably knows what they want."
- You've been asking for a while.

Keep going until a stop condition is met.

### Key Principles

- **Depth over speed.** A slow, thorough interview beats a fast plan with hidden assumptions.
- **One question per turn.** Never dump multiple questions at once. The user will either pick one and ignore the rest, or feel overwhelmed.
- **Always recommend.** Every open question has a recommended answer. Saying "what do you want?" is a failure mode.
- **Self-answer aggressively.** The user's time is expensive; codebase reads are cheap.
- **Accept deviations gracefully.** The user knows things you don't. If their answer holds, move on.
- **Flag, don't gate.** When you notice a pitfall, raise it as information. Let the user decide whether to explore it as a branch.
- **Stay in plan mode.** The strict plan-mode directive is non-negotiable — only a direct, explicit proceed signal exits plan mode.

### Composition with Other Skills

`plan-hard` is the **default disposition** whenever plan mode is entered. It composes with other skills freely:

- **`code-assistant`** (`skills://skill/code-assistant`) — after `plan-hard` produces the plan file, the user may follow up with `code-assistant` for the ongoing-review phase during implementation. `plan-hard` handles design-tree interviewing; `code-assistant` handles tracking and reviewing the user's implementation.
- **`plan-handoff`** (`skills://skill/plan-handoff`) — if the interviewed plan is intended for a different session or repository, compose with `plan-handoff` to produce a self-contained handoff plan.
- **`code-assistant-implement`** (`skills://skill/code-assistant-implement`) — after `plan-hard` finishes, if the user wants step-by-step implementation with review gates, hand off to `code-assistant-implement`.
- **`agents-review`** (`skills://skill/agents-review`) — conditionally auto-invoked in step 7 to fact-check resolved claims AND attempt to auto-resolve pending unresolved ones. Only runs when the user's invocation includes an explicit rigour phrase ("plan hard" / "think hard" / "look hard" / "deep" / "thorough" / "rigorous"). Default plan-mode entry skips this step. User opt-out: "skip fact-check".

When composing, do NOT duplicate the interview — `plan-hard` runs once per plan, then the downstream skill takes over.

### Examples

**Example 1 — User asks to refactor auth:**

1. Enter plan mode.
2. Root question: "Which auth approach?" Sub-branches: storage, lifetime, refresh strategy, compat with existing sessions, client surface.
3. Self-answer: check current auth code, find it uses cookie sessions. Report: "Current auth is cookie-based, session table in `users_sessions`."
4. Ask: "Recommended: JWT with refresh tokens and a compat shim for existing cookie sessions during rollout. Alternative: hard cutover. Depends on: whether mobile clients exist. Want the compat shim?"
5. Wait. Accept answer. Move to next branch (refresh token storage: httpOnly cookie vs. local storage).
6. Continue until all branches resolved or user says `g`.
7. Write plan file. Present in chat. Stop.

**Example 2 — User asks to add a feature, plan turns out trivial:**

1. Enter plan mode.
2. Design tree only has 2 branches after self-answering.
3. Ask both in sequence (one per turn).
4. User says "good, plan it" after the second answer.
5. Write minimal plan file. Present. Stop.

### Related Skills

- **`code-assistant`** (resource: `skills://skill/code-assistant`) — collaborative guidance and progress tracking during user-driven implementation.
- **`plan-handoff`** (resource: `skills://skill/plan-handoff`) — produce self-contained plans for other sessions or repositories.
- **`plan-pickup`** (resource: `skills://skill/plan-pickup`) — load and execute an existing plan file.
- **`code-assistant-implement`** (resource: `skills://skill/code-assistant-implement`) — step-by-step implementation with review gates.
- **`agents-review`** (resource: `skills://skill/agents-review`) — conditionally auto-invoked before the plan is written (only on explicit rigour triggers) to fact-check resolved claims and auto-resolve unresolved branches where evidence is findable. Read-only reviewer dispatched at cheap tier by default.
