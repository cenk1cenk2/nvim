# Agent Companion Offload

When to bring in a companion on your own while you are coordinating, so a busy lead hands a domain's standing judgment to a long-lived agent instead of dropping it. The companion lifecycle itself is `agent-companion`'s; this covers only the trigger and the authority to act on it.

## The trigger

You are coordinating and one domain needs standing attention you cannot give it without spending the context the routing needs. Any of these is the signal:

- **Several open PRs/MRs at once** — a stack, or parallel changes across repos, each with its own pipeline, review and merge order.
- **A tracker scope that moves while you build** — issue states, relations and recorded deviations drifting behind the work.
- **A plan under deviation** — implementation keeps departing from the approved design and each departure needs judging against it.
- **Your ledgers outgrow a turn** — the roster, watch board and open conditions no longer fit in the status you report.

## Which companion

| Domain under pressure | Companion |
|---|---|
| Open PRs/MRs, their ordering, pipelines and review threads | `git-companion` |
| A Linear project, issueset or issue tree | `linear-companion` |
| An approved plan the work keeps deviating from | `plan-companion` |
| Anything else with a durable record | `agent-companion`, proposed rather than spawned: it states its fit verdict and agrees the domain with the user first |

One companion per domain; never two on one record.

## Authority

A skill that declares this reference is authorised to load a dedicated companion skill and spawn it **without asking first**, once the trigger holds. Announce it in the same turn, in one sentence: which companion, which domain, and why now.

What stays unchanged:

- **The runtime check.** The companion shape needs a runtime that can message a live agent across turns, per `agent-companion`. Where it cannot, say so and load `agent-supervisor`, the same job held in your own context.
- **The companion's own gates.** Its boundaries and record-write approvals apply as the companion skill states them.
- **Retirement is the user's word.** You may bring a companion in; only the user retires it.
