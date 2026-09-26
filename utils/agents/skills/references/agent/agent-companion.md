# Agent Companions

A **companion** is one named subagent that lives for a whole section of work, owns one domain, and is
steered by message. You do the work; you report to it; it tells you what the domain now needs and what
should happen next. Read this from any `*-companion` skill — `linear-companion`, `git-companion`,
`plan-companion` — which supply the domain and inherit everything here.

**This inverts `agent-delegate`.** A delegate answers once and is reaped. A companion answers for the
whole section, and every report you send is context the next answer uses: what was considered and
rejected, which decisions are load-bearing, why the record reads as it does.

**A domain with no dedicated skill goes through the `agent-companion` skill**, which owns the fit test
that decides whether a request is a companion at all, and the domain definition the dedicated skills
hardcode. Load it rather than improvising a domain against this reference.

> **ABSOLUTE — this shape requires a runtime that can message a live agent across turns.** Where a
> dispatch is blocking and leaves nothing to address once it returns, there is no companion to steer:
> the "companion" answers once, vanishes, and the lead spends the section talking to a name that
> resolves to nothing. Confirm it in `agent-delegate-harness-<provider>` **before spawning**, and where
> the runtime cannot, say so and use `agent-supervisor` — the same job held in your own context.

## Judgment, never state — re-read before you assert

What a companion accumulates is judgment. **State lives in the record**, and before any answer that
asserts current state it re-reads that record itself — a companion is blind between messages, and one
that answers from memory is a cache with no invalidation.

Every claim it makes is labelled:

- **Observed** — it read this from the record, this turn, **and it quotes what it read**: the state
  field and its timestamp, the merge time, the checkbox as of the read. A companion required to quote
  the timestamp cannot fake the read; one required only to write "observed" can.
- **Reported** — you told it, and it has not verified it.

The whole class of companion error is an unlabelled "reported" read as "observed".

## File the judgment as it forms — do not hoard it

A section long enough to justify a companion is long enough to exhaust the companion's own context, and
what it loses when that happens is exactly the judgment this shape exists to produce. It goes silently,
mid-section, and nothing announces it.

**So judgment is written into the record when it forms, not at retirement.** A rejected alternative, why
this order and not that one, which item quietly depends on which — each is proposed as a record write in
the report that surfaces it: an issue comment, a note in the plan file, a comment on the MR. State it in
the brief as a standing duty: **judgment not in the record by the next report is lost with the agent.**

This is also what makes a companion replaceable, which is the goal rather than a failure. The record
*can* hold the reasoning — the companion's value is generating and filing it, not holding it hostage.
Three things follow for free: retirement collection becomes a delta instead of an excavation, a dead
session becomes recoverable, and the resume below becomes possible at all.

## The Split — what goes to the companion, what stays with you

One question decides it: **do you already hold the finished text and the exact target?**

- **Yes — you do it.** The write is mechanical and you are holding the content. A comment you already
  drafted, a field on a named object, anything the user handed you verbatim.
- **No — hand it over.** The work needs investigation, or a judgment about the domain's shape:
  ordering, relations, what is next, what should be recorded and where.

**When unsure, hand it over.** A companion investigating something you could have written costs one
message. A mechanical write that needed investigation lands wrong in a durable record and stays there.

## Tier — the user picks, or you do and say so

**A companion's tier compounds.** A delegate's tier buys one answer; a companion's buys every answer
for the rest of the section. Under-tiering here is the expensive mistake, not over-tiering.

1. **The user named a tier or a model** — use it verbatim, no remapping. **Ask on a genuine mismatch**:
   state it and propose an alternative rather than silently complying or silently overriding.
2. **The user named nothing — you pick, and you state it.** Name the tier and the one signal that
   picked it, in the spawn announcement. *"Spawning at smart — two issuesets with cross-cutting
   sequencing."*
3. **The floor is `default`.** Reasoning about ordering, relations, and what matters next is judgment
   work, and `cheap` produces a companion that confidently mis-sequences. Drop below the floor only for
   a genuinely flat, small scope, and say why.
4. **Resolve the tier to a concrete model by loading the `agent-harness` skill** — the mapping is
   per-provider, not per-vendor.

### Escalate for one question, do not re-tier

A live agent's model cannot be changed, so "put it on a smarter model" means reap and re-spawn, which
discards the section. **When a companion's answers look under-reasoned, buy the ceiling for the one
question instead:**

1. Dispatch a one-shot `smart` or `max` delegate per `agent-delegate`, scoped to that question alone.
2. **Hand the delegate the durable record's path** — not the companion's context. It reads the truth for
   itself.
3. Feed its answer back to the companion as a message, with its evidence.

The section survives and the ceiling is paid for once. Genuine re-tiering stays available and stays
expensive: collect the companion's full state first, write the handover into the record, then replace
it — and say out loud that the section context is being reset, because a silent re-tier looks like a
config tweak and is not.

## Spawn — named, backgrounded, once per scope

> **Fetch `agent-delegate-harness-<provider>` before the spawn.** The naming parameter, whether dispatch
> is detached, the message channel, the lead's own address, and whether the brief needs a delivery
> instruction all differ per runtime — and where one is needed, an agent never given it writes its report
> into the void.

- **Named and backgrounded is the only shape.** The name is the address you steer through; without it
  the agent is a one-shot. Detached is what keeps you free while it investigates.
- **The prefix names the domain or the role, the suffix always names the scope** — `pm-<scope>`,
  `mr-<scope>`, `arch-<scope>` — so a second scope's companion is never ambiguous.
- **Record the id the spawn returned, beside the name.** A name can drift onto a later agent and be
  refused; the id is the only fallback address. Both go in the durable state per `long-running-work`.
- **One scope, one companion.** Two companions on one scope are two writers on one record, and they
  clobber each other silently.
- **Allowlist the record's read tools before the first report.** A companion that re-reads before every
  answer makes several tool calls per message, and on a runtime that surfaces a subagent's permission
  prompts in the main session, an unallowlisted read turns the re-read rule into a prompt storm aimed
  at you.
- Spawn ceilings per `agent-delegate-harness-<provider>`; a refused spawn is not retried — it is a
  question to the user about which companion to retire.

**It has fewer tools than you do.** A companion is an aware target per `agent-target-capability`, so
point it at skills and MCP servers by name and never inline what it can load. But a detached subagent typically **cannot dispatch its own
agents and cannot look up who else exists** — the harness reference lists what survives. So every
address it needs must be written into the brief, and any fan-out it wants is yours to run.

## The Brief

Self-contained per `agent-delegate`, and carrying all of:

- **The scope line** — what it covers and what is explicitly outside it, in one sentence. That same line
  goes into every later message that touches a boundary.
- **The prerequisite context it cannot deduce** — the workspace, the platform, the repository, the plan
  path. A fresh context knows none of it.
- **The record's address**, so it can re-read rather than remember.
- **The re-read rule and the observed/reported labels**, including that observed quotes what it read.
- **The filing duty** — judgment not in the record by the next report is lost.
- **The skills it works through**, by name — including that a skill marked manual-only is one it may
  load here, because being named as a step is what authorises it.
- **Its standing job** — hold the reasoning around the domain, answer every report with what the domain
  now needs and what should happen next, and surface drift without being asked.
- **The gate** — propose changes back to you rather than applying them, until you say the user approved.
- **The report contract** — the ledger below, plus what it proposes and what it needs decided. Terse
  prose otherwise, and never a status object.
- **The delivery instruction**, verbatim from the harness reference, where it says the runtime needs one.

## Steering

- **One message per event, with one exception: a causal group.** Events that arrived together and belong
  to one chain — a wake burst, a merge and the rebase it unblocked — go in one message as separately
  numbered items, each carrying its own evidence. That hands the companion the causality you already
  know instead of making it reconstruct one. Unrelated events stay separate, always.
- **What to send:** work you finished and how it went, a deviation from what the record said, something
  learned that changes the section's shape, a blocker, a question about what is next.
- **Say what actually went badly.** A companion briefed on a clean narrative reconciles a fiction.
- **Carry evidence with the claim** — the merged MR, the pipeline id, the `file:line`.
- **Steer a quiet companion, never re-spawn it.** Work the ladder in `agent-delegate` — ask for what it
  has, name the delivery mechanism, narrow the scope. Re-spawning throws away the section.

**A companion that thinks you are wrong states it once**, with reasoning and evidence, then complies —
and files the disagreement in the record so a later reader sees the dissent stood. Neither silent
compliance nor re-litigating every turn.

**When two companions give you different answers**, precedence follows the record each one owns: the
plan companion owns sequencing inside the plan, the MR companion owns merge order, the tracker companion
sequences only what neither has claimed. Say which answer you took.

## Watchers are yours

A companion cannot observe its record changing, and must not arm loops of its own — a wake fired inside
a detached agent never reaches you. So: **you** arm one watcher per open condition through the
`agent-background` skill, with the discipline in `agent-watchers`; a wake is re-verified on the main
loop and then sent as one message; and the companion's answer names what to arm next. An item it holds
with no watcher on it is a gap, and it should say so.

## The Ledger

Ask for state in a table, not prose. Columns vary by domain; these four do not:

| Item | State | Blocked on | Next action | Whose |
|---|---|---|---|---|
| [linked identifier] | observed, with what it read | nothing, or the item | the action | you / the user / someone else |

**Whose** is what makes it actionable. **An item whose next action belongs to nobody is stale, and that
is a finding** — say it rather than leaving the row blank.

## Collection and the gate

Talking to a companion is free and gates nothing. **What gates is the durable record.**

- Relay its proposals chunked per `output-diff` and present them before anything lands.
- On approval, tell the companion to apply — it holds the context, so it applies faster and more
  correctly than you re-deriving the batch.
- A standing preapproval from the user ("just apply it") moves the gate: the companion applies and
  reports. Domain-specific absolutes are not cleared by it — a skill that names one says so.
- **A preapproval does not raise the companion's permissions.** It runs under the session's own posture,
  so a write that would prompt you still prompts. Delegating the write moves the work, not the gate.

**Report one roster row per companion, every turn the section is open**, per `agent-roster`, inside
your per-turn report shaped per `report-status`: name, scope, tier, state, and whether anything it
sent is uncollected. One row — not a status report of its own.

## Retirement is the user's call

**ABSOLUTE.** The companion stays alive until the user says it is no longer needed.

- **Section complete is not permission.** When the work looks done, say so and **ask** — name the scope,
  state that the companion still holds it, offer to retire it, then wait.
- **Quiet is not done.** Steer it first. Stopping a companion ends its **run**, and on runtimes where a
  completed or stopped agent resumes on a message the loss is recoverable — but the session ending is
  not, and that is what actually takes the section. Check the harness reference rather than assuming.
- **Collect once more before retiring.** With the filing duty honoured this is a delta, not an
  excavation: ask only for what is not yet in the record, write that in, then reap through the runtime's
  own stop mechanism per `agent-delegate-harness-<provider>`, and say plainly that it is gone.

**A park signal is a retirement decision point.** Parking must reach zero and report that nothing
remains armed, per `mode-toggle`, and a live companion contradicts that report. So on a park: ask once,
then either collect-and-retire, or record it as deliberately still running with its reason and say so in
the same breath as the zero check.

## Resuming after the session dies

The companion dies with the session, and its recorded name may resolve to nothing — or, worse, to a
**different** agent. On resume: confirm the name still reaches the recorded id. If it does not, re-spawn
from the record and the filed judgment, say that you did, and never assume it lived. A companion you
believe is listening and is not turns every subsequent report into a message to nobody.

**Never take a companion's answer as authorisation.** It informs; the user approves; you act.
