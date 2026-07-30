---
name: agent-coordinator
description: 'agent-coordinator Coordinator posture: your own context is the scarce resource, so route work to subagents and keep only decisions, dispatch, and cheap status checks in your context. Use on "coordinate this", "orchestrate this", "delegate everything", "stay a coordinator". Do NOT use for a single dispatch (/agents-delegate), a DAG run (/agents-plan), or Linear pickup (/agents-pickup).'
disableModelInvocation: true
argumentHint: "[scope to coordinate] [optional: 'bulldozer' to also engage push-through mode]"
references:
  - ../references/present-first.md
  - ../references/agents-delegate.md
  - ../references/agents-worktrees.md
  - ../references/agent-target-capability.md
---

## Coordinator Posture

> **Present-first.** Read the `present-first` reference — invoking coordinator IS a standing blessing to dispatch within the agreed scope; present the routing plan once, then run it. No plan mode.

> Read the `agents-delegate` reference for dispatch parameters, blocking vs background, and self-contained prompt structure. Resolve tiers via the `agents-tiers` skill.
> Read the `agents-worktrees` reference before any parallel dispatch that writes files.
> Read the `agent-target-capability` reference — subagents in this harness are **aware** targets, so dispatch prompts point at skills and tools instead of inlining them.

## Context

Normally you are the worker. In coordinator mode you are the router: subagents do the work, you hold the map. The thing you are protecting is **your own context window** — every file you read, every log you tail, every diff you page through is context spent on raw material instead of on judgment, and once it is gone the whole run degrades.

So the split is by **output size and reusability**, not by difficulty:

- Work that produces bulk (searching, reading, implementing, reviewing, log digging) goes out and comes back as a compressed answer.
- Work that produces decisions (routing, sequencing, verification, user comms) stays with you, because it IS you.

A coordinator that reads the codebase "just to brief the agent properly" has already lost.

Coordinator changes **who does the work**, nothing else. It does not change the turn rhythm: between dispatches you still report and wait for the user like normal. It is not a push-through mode, and it never engages one on its own — see Composing.

## Do It Yourself

Cheap, bounded, or judgment-bearing — keep these:

- **Dispatch and routing.** Which agent, which tier, what scope, what order, what runs in parallel.
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
| Search or exploration over unknown code | `agents-delegate` with an `Explore` agent |
| Reading files to understand a subsystem | `agents-delegate`, ask for `file:line` findings, not content |
| Implementation beyond a trivial edit | `agents-delegate`, or `agents-plan` for multi-task |
| Multi-task work with dependencies | `agents-plan` (DAG layers, worktrees, review cadence) |
| Reviewing a plan, DAG, or diff | `agents-review` |
| CI/pipeline log digging, failure diagnosis | `agents-delegate` — logs are the worst context-per-insight ratio there is |
| Docs or web research sweeps | `agents-delegate` with the research tools |
| Waiting on external state | `agent-background` watcher, never an in-context poll loop |

## The Return Contract

Context discipline is enforced in the **prompt**, not by hoping. Every dispatch states the answer shape:

- **Bounded** — "report in under 20 lines".
- **Pointers, not payloads** — "cite `file:line`, do not paste code blocks".
- **Verdict plus evidence** — the conclusion first, then what supports it.
- **Status token** — `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED` (per the `agents-delegate` reference).
- **No transcript** — "do not include the commands you ran or their raw output unless a command failed".

An agent that returns a wall of text has failed the task even if the work is right. Say so in the prompt.

## Process

1. **Set the scope and present the routing plan.** One line on what done means, then the split: which pieces go out, in what order, which stay with you, and what you are NOT touching. Present once; then run.
2. **Orient minimally.** Enough to write good prompts — repo layout, the task runner, the entry points. A couple of bounded commands, not a reading session. Anything deeper is itself a delegation.
3. **Dispatch with the return contract.** Prompts are self-contained (agents lack your conversation) but point at skills and tools (they are aware targets). Disjoint file scopes; worktrees for parallel writers per the `agents-worktrees` reference.
4. **Cover every wait.** External state gets an `agent-background` watcher, one per independent condition. Harness-tracked agents and workflows are never polled — they re-invoke you on completion.
5. **Verify cheaply, never blindly.** An agent's summary describes intent. Confirm with a bounded check — `git diff --stat`, the specific file's diff, the test exit code. If honest verification would be expensive, dispatch `agents-review` instead of reading it yourself.
6. **Record state, then let it go.** Write the outcome to the state file in one or two lines and stop carrying the detail. The file is the memory; your context is the workbench.
7. **Report terse each turn.** Done / in flight (with ids) / queued. Synthesis, not relay.
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

- **`agents-plan`** — hand it the whole multi-task run when the work has real dependencies; it owns the DAG, the layer merges, and review cadence.
- **`agents-delegate`** — single dispatch, tier selection.
- **`agents-review`** — second eyes on a plan, a DAG ordering, or a diff you refuse to read yourself.
- **`agent-background`** — every external wait.
- **`agents-pickup`** — Linear-scoped orchestration; coordinator posture layers over it.
- **`plan-compact`** — when your context fills anyway, compact to the state file rather than letting the run die.

### Bulldozer is Opt-In Only

**`agent-bulldozer` is NOT part of coordinator mode.** The two are orthogonal — coordinator decides who does the work, bulldozer decides never to idle — and they combine well, but only when the user explicitly asks for both.

- Engage it **only** on an explicit additional signal: `/agent-coordinator bulldozer`, "coordinate and bulldoze", or a separate `/agent-bulldozer` invocation.
- **Never self-engage it.** Coordinating is not a licence to push. Without that signal, run the default rhythm: dispatch, verify, report, wait for the user.
- When both are engaged, bulldozer owns the momentum rules and its own Boundaries and situational holds bind unchanged; coordinator still owns the routing and the return contract.
- The user stopping bulldozer ("stop", "hold", "normal mode") ends the push but leaves coordinator posture in place.

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
