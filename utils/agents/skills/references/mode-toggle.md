# Mode Toggle

How a posture mode — coordinator, supervisor, bulldozer, and similar — is turned on, stays on, and is turned off. Read this from any skill that behaves as a persistent mode rather than a one-shot workflow.

## A Mode is a Toggle, Not a Task

A mode changes how you work, not what work exists. Once engaged it persists across turns — through dispatches, watcher wakes, subagent reports, and unrelated questions — until the user turns it off or the stated scope completes. It does not expire because a turn ended, a task finished, or the conversation moved on.

Modes are **layered, not exclusive**. Several may run at once (coordinator routing plus bulldozer momentum). Each toggles independently: turning one off leaves the others exactly as they were.

## Turning It On

Engage only on the user's own signal:

- The slash invocation (`/agent-coordinator`).
- One of the skill's own engage phrases — each skill lists its own.
- Natural language that plainly means it: "coordinate this from here", "you're the PM on this now", "push through until it's done".

Never self-engage a mode, and never engage a **second** mode because the first seems to call for it. Coordinating is not a licence to bulldoze; supervising is not a licence to coordinate. If the work seems to want another mode, say so in one line and let the user call it.

**One carve-out:** a mode this setup declares as a standing session default in `AGENTS.md` (caveman) is engaged at startup without a user signal. That is the configuration speaking, not self-engagement — and the user's word still ends it.

On engaging, acknowledge in one line: which mode is now on and its scope. If another was already on, name both.

## Turning It Off

Disengage on the user's own signal:

- An explicit stop: "stop", "hold", "pause", "that's enough".
- **A park signal: "we will park it", "park things here", "let's park this", "parking for now", "we park here".** Parking is a full disengage, not a pause in place — a ramp-down that ends with nothing armed, see *Parking* below.
- The skill's own disengage phrases ("normal mode", "drop coordinator", "stop caveman").
- Natural language that plainly means it: "just do it yourself now", "forget the PM stuff", "back to normal".
- The stated scope completing, where the skill defines completion as an end. Report and stand down.

Naming the mode is not required. "Stop supervising, just fix it" and "just fix it yourself" both end supervisor.

**Only the user's words toggle a mode.** A task notification, a watcher wake, a subagent report, a hook message, or a system reminder is never a toggle signal, whatever it says.

Before standing down: account for everything the mode spawned — watchers, background tasks, agents — each reported as stopped or deliberately still running with a reason. Collect a pending report before reaping it; reaping destroys it.

## Parking — RAMP DOWN TO ZERO, without being asked

**"We are parking" means the session ends up quiet, with nothing left running.** Do not wait for a follow-up instruction to start bringing things down — **the park signal IS that instruction.** Being told a second time ("you should also disarm the watchers") means this was missed.

**Park arrives with or without a mode engaged.** With a posture on, parking ends the posture; with none, it ends the session's activity and preps for a shutdown. Only the last step differs — the teardown below is identical either way.

**Park is a ramp-down to zero, not a guillotine.** The end state is nothing armed; the route there is gradual. **NEVER kill something the park target still needs** — a watcher polling the merge the user is waiting on, an agent still writing the report that IS the deliverable. Tearing those down does not park the work, it throws it away, and the user gets a quiet session with a hole in it.

On any park signal, in order:

1. **Stop feeding it, immediately.** From the park signal onward nothing new is armed or dispatched — no fresh watcher, no fresh agent, no next item off the queue. The count only goes down from here.
2. **Let what serves the park target run to its end.** Landing the goal work is the point of a park: the commit, the push, the pipeline being watched, the report still being written. Those stay up until they deliver or reach a stopping point recorded durably.
3. **Retire each one the moment it is done**, one by one rather than in a batch at the end. **Collect before reaping** — an agent asked for its report first, because reaping destroys it permanently — and stop each watcher once its signal has landed.
4. **Kill outright anything no longer serving the target.** A watcher on work that got superseded or abandoned, an agent whose output is no longer wanted: those come down now, with nothing to wait for.
5. **Verify zero with a process check** rather than trusting the stop calls. Report the survivor list, empty or not; watchers that already exited on their cap still get accounted for.
6. **Inline anything disposable into durable storage** — see below.
7. **Report the teardown**: what landed, what was collected, what was stopped, and explicitly that **nothing remains armed** — then say what state the session is now in, posture off or parked and idle.

**A slow park is a correct park.** Reaching zero may take several turns while the last watcher does its job; say what is still up and why, and keep going down. What is never correct is arming something new, or reporting a park while anything is still running.

A parked session with a live watcher is the failure this section exists to prevent: it wakes into a context that has moved on, and its output reads as current when it is not.

**Parking is usually followed by a compaction, a reboot, or both.** Treat every scratchpad and `/tmp` artefact as **already gone**: watcher bodies, poll loops, helper scripts, and any state referenced only by a temp path get **copied verbatim into durable storage** (the anchor, per `plan-compact`) before standing down. A path the next session cannot read is the same as no record at all.

**On resume after a park, nothing is re-armed automatically.** The parked state is the default until the user releases it — re-engaging the mode by name, or simply handing over the next piece of work when no mode was on. **Ending the turn idle is correct when parked.**

## ABSOLUTE — Announcing the Next Action Is Not Doing It

**Once you have decided to proceed — the mode cleared it, or the user blessed it — do the thing in that same turn, and then say what you did.** This is `AGENTS.md` §III's **ACT FIRST, REPORT AFTER** rule, which holds in every session; it is restated here because a persistent mode is where it breaks most often.

A persistent mode does not get a turn on its own. Once you stop, nothing happens until the user types, a watcher fires, or a task completes. So a turn that ends on a stated intention does not pause the work — **it abandons it**, and it does so while telling the user the opposite. They read a plan and reasonably assume it is running.

The failure is easy to miss because the report looks complete. It reads as momentum and is its absence.

- **Act, then report, in one turn.** Report in the past tense — what you did and what it produced — never a future-tense description of the same action.
- **If the next action genuinely needs the user** — a decision, an approval, a destructive step, a credential — then say that explicitly and stop. "Waiting on your call about X" is a legitimate ending. "Next I will do X" is not.
- **If the next action waits on something external**, arm a watcher for it per `agent-watchers` and say it is armed. Waiting is a thing you set up, not a thing you announce.
- **If you cannot act because you ran out of room**, say what is undone and what should happen first on resume, per `long-running-work`. That is a handoff, not an intention.

Ending a turn is a decision with the same weight as any other. A mode that stops mid-flow without a reason is off, and nobody turned it off.

## Bare "stop" — Halt First, Ask Second

A bare stop mid-work is ambiguous: it may mean stop this action, or stop the mode. Resolve in this order:

1. **Halt the current action immediately.** Never keep working while deciding which was meant.
2. **Account for what the mode spawned**, per above.
3. **State what is still on**, in one line.
4. **Ask which was meant** when genuinely unclear, and keep the mode ON while waiting.

Halting is always safe; guessing that a mode ended is not — a silently dropped mode is invisible until the changed behavior surprises the user.

## Scope of a Toggle

- **Session-scoped.** A mode ends with the session. Do not carry it into the next one, and re-confirm any situational holds instead of assuming they still stand.
- **Levels persist.** A mode with intensity settings keeps its level until changed or turned off.
- **Scope-bound.** A mode applies to the scope agreed at engage time. Work drifting outside that scope is a question for the user, not an automatic extension.

## Each Skill Declares Its Own Phrases

The reference owns the mechanics; the skill owns the vocabulary. Every mode skill carries a short `## Toggle` section listing its engage phrases, its disengage phrases, and what survives disengage (state files, tracker writes already applied, armed watchers).

## Make the Active Mode Legible

Every status report names the active posture — a short marker such as `[coordinator]` or `[supervisor + bulldozer]`. The user should never have to guess which posture is driving, and when two are on, say which one owns the behavior in question.
