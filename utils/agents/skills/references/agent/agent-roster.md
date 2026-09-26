# Agent Roster

Tracking for the subagents a mode holds. Read this from any skill that dispatches more than one agent
across a run — `agent-coordinator`, `agent-supervisor`, `agent-bulldozer`, `agent-plan`.

Watchers are tracked separately, per `agent-watchers`. Agents and watchers fail differently: a stale
watcher wakes you with an obsolete verdict, while a reaped agent loses its report forever.

## Reaping an uncollected agent destroys its report permanently

A finished agent looks exactly like a working one, and in a routing posture the report **is** the
product. The roster is what stops an accidental loss. Report it whenever you dispatch, whenever one
returns, and before any teardown:

| Agent | Doing what | Tier | State | Report |
|---|---|---|---|---|
| `audit-auth` | audit the auth module for dead paths | cheap | delivered | collected - 3 findings, folded in |
| `migrate-cfg` | move config loading to the new shape | default | running | pending |
| `review-dag` | sanity-check the layer schedule | smart | idle | **not collected** - ask before reaping |

- **State** is what the runtime says: running, idle, delivered, failed, reaped. **Idle is not done** —
  it means the agent stopped producing, which usually means the report is stranded, not absent.
- **Report** is the column that matters: pending, collected, or not collected. **Never reap a row whose
  report is not collected.**
- A row with no stated task is a dispatch whose result you cannot verify.
- **Reap before re-dispatching** the same target: two writers on one path clobber each other, and an
  old report landing after a new one is indistinguishable from the new one.

## Collect, then reap

Collect, verify the answer against the brief, then reap — in that order, per `agent-delegate`: its
collection ladder (including the two-failed-attempts rule), its diagnosis by the artifact, and its
Reaping section. The roster's job is to make the order visible: a row whose **Report** is not
`collected` is never reaped.

## Report it every turn a dispatch is live

Every momentum or status report should be able to name each live agent and why it is still alive. An
unexplained live agent at the end of a flow means you cannot say what is genuinely in flight.

Before declaring a phase done, enumerate what you spawned and state for each that it is reaped, or
deliberately still running with the reason.
