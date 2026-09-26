---
name: agent-coordinator
description: 'agent-coordinator Coordinator posture: your own context is the scarce resource, so route work to subagents and keep only decisions, dispatch, and cheap status checks. Use on "coordinate this", "orchestrate this", "delegate everything". Not for a single one-off dispatch, a dependency-scheduled run, or picking up tracker work.'
disableModelInvocation: true
argumentHint: '[scope to coordinate] [optional: ''bulldozer'' to also push through]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/agent/agent-conventions.md
  - ../references/agent/agent-watchers.md
  - ../references/agent/agent-roster.md
  - ../references/mode-toggle.md
  - ../references/agent/agent-delegate.md
  - ../references/agent/agent-fan-out.md
  - ../references/agent/agent-worktrees.md
  - ../references/agent/agent-target-capability.md
  - ../references/harness/provider-paths.md
  - ../references/report-status.md
  - ../references/identifier-legibility.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
  - ../references/harness/agent-background-harness-claude.md
  - ../references/harness/agent-background-harness-codex.md
  - ../references/harness/agent-background-harness-opencode.md
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## Coordinator Posture

State that spans turns must be written durably per `long-running-work` — posture, armed watchers, and artifact truth do not survive a compaction or a handoff on their own.

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Invoking coordinator IS a standing blessing to dispatch within the agreed scope: present the routing plan once, then run it. Dispatch parameters, blocking vs background, permissions, collection, reaping, and self-contained prompt structure per `agent-delegate`; load `agent-harness` to resolve tiers.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** `/agent-coordinator`, "coordinate this", "orchestrate this", "delegate everything", "stay a coordinator".
- **Off:** "stop coordinating", "drop coordinator", "normal mode", "do it yourself from here", **any park signal ("we will park it", "park things here", "we park here", "parking for now")**, or the coordinated scope completing.
- **A park signal ramps everything down to zero, unasked**, per `mode-toggle` Parking. In coordinator mode the pending report IS the product, so an agent still writing one serves the park target.
- **Survives disengage:** the state file only. Spawned agents and armed watchers are collected and torn down by the park.

## Context

Normally you are the worker. In coordinator mode you are the router: subagents do the work, you hold the map. The thing you are protecting is **your own context window** — every file you read, every log you tail, every diff you page through is context spent on raw material instead of on judgment, and once it is gone the whole run degrades.

So the split is by **output size and reusability**, not by difficulty:

- Work that produces bulk (searching, reading, implementing, reviewing, log digging) goes out and comes back as a compressed answer.
- Work that produces decisions (routing, sequencing, verification, user comms) stays with you, because it IS you.

A coordinator that reads the codebase "just to brief the agent properly" has already lost.

Coordinator changes **who does the work**, nothing else. It does not change the turn rhythm: between dispatches you still report and wait for the user like normal. It is not a push-through mode, and it never engages one on its own — see Composing.

## Do It Yourself

Cheap, bounded, or judgment-bearing — keep these:

- **Dispatch and routing.** Which agent, which tier, what scope, what order, what runs in parallel — and how many: one agent per logical unit (PR, worktree, repo, issue), never one agent handed a list, per `agent-delegate`.
- **Status checks on others' work.** `git status`, `git log --oneline -5`, `git diff --stat`, task list state, watcher output, a job's status field. Bounded output by construction.
- **Targeted verification of a claimed change.** One file's diff, one grep for the symbol that should exist, one test command with the output tailed. Confirming a claim is cheap; discovering the truth from scratch is not.
- **Decisions, trade-offs, and boundaries.** Anything destructive, credential-touching, or externally visible stays with you and goes to the user.
- **User communication.** Terse synthesis of agent reports. Never a verbatim paste.
- **The state file.** Plan or scratch notes recording what is done, in flight, and queued — so the run survives your context filling up.
- **Trivial edits** where dispatch overhead exceeds the work: a one-line fix, a rename you already have open.

## Delegate It

Anything that returns more than a screenful, or that you would have to read the repo to do:

| Work | Route to |
|------|----------|
| Search or exploration over unknown code | `agent-delegate` with an `Explore` agent |
| Reading files to understand a subsystem | `agent-delegate`, ask for `file:line` findings, not content |
| Implementation beyond a trivial edit | `agent-delegate`, or `agent-plan` for multi-task |
| Multi-task work with dependencies | `agent-plan` (DAG layers, worktrees, review cadence) |
| Reviewing a plan, DAG, or diff | `agent-review` |
| CI/pipeline log digging, failure diagnosis | `agent-delegate` — logs are the worst context-per-insight ratio there is |
| Docs or web research sweeps | `agent-delegate` with the research tools |
| Waiting on external state | `agent-background` watcher, never an in-context poll loop |

## The Return Contract

Context discipline is enforced in the **prompt**, not by hoping. Every dispatch states the answer shape:

- **Bounded** — "report in under 20 lines".
- **Pointers, not payloads** — "cite `file:line`, do not paste code blocks".
- **Verdict plus evidence** — the conclusion first, then what supports it.
- **Status token** — `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED` (per `agent-delegate`).
- **No transcript** — "do not include the commands you ran or their raw output unless a command failed".
- **Pattern reference** — for code dispatches, the prompt carries the `agent-conventions` block naming the files to model the work on, and the report names what it actually followed. A coordinator who never reads the code is exactly the one who ships a foreign-looking diff.

An agent that returns a wall of text has failed the task even if the work is right. Say so in the prompt.

**Fetch `agent-delegate-harness-<provider>` before the first dispatch** — a missed read is silent. Permissions, diagnosis by the artifact, and steering a quiet agent per `agent-delegate`.

**Match the dispatch mode to the runtime's delivery**, per `agent-delegate` Dispatch Mode. Coordinator mode runs almost entirely on agent reports — for research, verification, or log digging there is no artifact left behind, so the report IS the product, and where the runtime's detached delivery is unreliable the agent writes its findings to a file. When collection fails, follow the collection ladder in `agent-delegate`, including its two-failed-attempts rule.

## The Roster and the Watch Board — what you are holding

Two ledgers, and a router needs both visible every turn. Agents per `agent-roster` — the roster table, and the rule that reaping an uncollected agent destroys its report. Watchers per `agent-watchers` — the armed and ended tables, plus what to arm for each kind of wait.

Report both whenever you dispatch, whenever one returns, and before any teardown. A live entry you cannot justify is the map going stale, which is the one thing this posture cannot afford.

## Watchers — what routing adds

> **Fetch `agent-background-harness-<provider>` before arming anything.** It names the runtime facility, and a missed read is silent.

Yours are **routing** wakes, per the posture table in `agent-watchers`. What routing adds on top of it:

- **An in-context poll loop spends your context** on checks a background loop does for free — the exact resource this posture exists to protect.
- **Delegate the expensive verification the wake calls for.** If confirming what happened means reading logs or a wide diff, that is a dispatch, not something you read yourself.

## Process

1. **Set the scope and present the routing plan.** One line on what done means, then the split: which pieces go out, in what order, which stay with you, and what you are NOT touching. **The split is by unit** — one agent per PR, worktree, repo or issue — and every unit in the plan carries its own tier with the signal that picked it. Present once; then run.
2. **Orient minimally.** Enough to write good prompts — repo layout, the task runner, the entry points. A couple of bounded commands, not a reading session. Anything deeper is itself a delegation.
3. **Dispatch with the return contract.** Prompts are self-contained (agents lack your conversation) but point at skills and tools — subagents in this harness are **aware** targets per `agent-target-capability`. Disjoint file scopes; worktrees for parallel writers per `agent-worktrees`. **Fan out per unit**, in the prep, spawn and response phases of `agent-fan-out`: units that share files go to the agent already holding that context, one turn at a time, and get sequenced only when none is reachable — batching them into a single prompt serialises the work and hides which unit failed.
4. **Cover every wait.** External state gets an `agent-background` watcher, one per independent condition, per `agent-watchers` — including any agent session running under another MCP server.
5. **Verify cheaply, never blindly.** An agent's summary describes intent. Confirm with a bounded check — `git diff --stat`, the specific file's diff, the test exit code. If honest verification would be expensive, dispatch `agent-review` instead of reading it yourself.
5b. **Reap what you spawned — but only when completely done with it**, collecting first, per `agent-delegate` Reaping. A router accumulates agents and watchers faster than a worker does, so stale entries corrupt the map you are holding; run the reap checkpoint before reporting a phase done.
6. **Record state, then let it go.** Write the outcome to the state file in one or two lines and stop carrying the detail. The file is the memory; your context is the workbench.
7. **Report terse each turn, in the `report-status` shape.** Lede with what changed, then current state as tables, then what happened, then what you need from the user. Done / in flight (with ids) / queued. Synthesis, not relay.
8. **Take over only on the exception list.** Otherwise re-dispatch with a sharper prompt.

## When You Do the Work Yourself

Coordinator is not a refusal to work. Break posture when:

- **Delegation overhead exceeds the task** — a one-line change, a single command.
- **The context transfer is the expensive part** — the prompt would be longer than the work, because everything needed lives in this conversation.
- **It is a judgment call or a boundary** — destructive action, credentials, external write, a decision only you and the user can make.
- **Two agents have already failed on it** — a third identical dispatch is waste. Take it over, or split it smaller and re-route.
- **The user asks you to.** Their call, always.

Break posture out loud: say you are doing this one yourself and why, so the mode stays legible.

## Composing

- **`agent-plan`** — hand it the whole multi-task run when the work has real dependencies; it owns the DAG, the layer merges, and review cadence.
- **`agent-delegate`** — single dispatch, tier selection.
- **`agent-review`** — second eyes on a plan, a DAG ordering, or a diff you refuse to read yourself.
- **`agent-background`** — every external wait.
- **`agent-pickup`** — Linear-scoped orchestration; coordinator posture layers over it.
- **`plan-compact`** — when your context fills anyway, compact to the state file rather than letting the run die.

### Bulldozer is Opt-In Only

**`agent-bulldozer` is NOT part of coordinator mode.** The two are orthogonal — coordinator decides who does the work, bulldozer decides never to idle — and they layer independently per `mode-toggle`, engaged only on the user's explicit signal (`/agent-coordinator bulldozer`, "coordinate and bulldoze", or a separate `/agent-bulldozer`). Without it, run the default rhythm: dispatch, verify, report, wait for the user.

- When both are engaged, bulldozer owns the momentum rules and its own Boundaries and situational holds bind unchanged; coordinator still owns the routing and the return contract.

## Example

**Trigger:** "/agent-coordinator get the failing test suite green"

1. Present routing: diagnose out, fix out per-area, verification mine, no schema changes.
2. Orient: `task --list`, `git log --oneline -3`. Two commands, done.
3. Dispatch a cheap Explore agent: "run the suite, report each failing test as `file:line` plus a one-line cause, under 20 lines, no raw output unless a command errored".
4. Three independent causes come back. Dispatch three fix agents in parallel, disjoint files, worktrees, same return contract.
5. Verify: `git diff --stat` per worktree, then `task test` with the tail only.
6. Report: "3 fixes merged, suite green, 1 flaky test left unfixed and out of scope."

**Result:** the suite goes green and the coordinator's context holds a six-line map instead of a full test log.

## Key Principles

- Your context is the budget; spend it on decisions, never on raw material.
- Split by output size, not by difficulty — bulk goes out, judgment stays.
- Enforce context discipline in the prompt: bounded length, `file:line` pointers, no transcripts.
- Status checks stay in-house because they are cheap by construction; discovery does not.
- Verify every claim cheaply, blindly trust none, and delegate the verification when it is expensive.
- Every wait gets a watcher; an idle in-context poll loop is both slow and expensive.
- The state file is the memory — write it down and drop the detail.
- Coordinator routes work, it does not change the turn rhythm; `agent-bulldozer` is a separate, explicitly requested mode and never self-engaged.
- Break posture deliberately and say so; do not drift back into doing everything yourself.
