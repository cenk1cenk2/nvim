---
name: output-summary
description: output-summary Summarize the scope the user names - work done, an MR, a thread, a doc, a topic - as one report under headers, a lede first and loose ends last. Use on "summarize X", "recap X", "sum up what we did on X". Not for the live state of in-flight work, and not for presenting a write for approval.
disableModelInvocation: true
argumentHint: '[scope to summarize]'
references:
  - ../references/output-status.md
  - ../references/identifier-legibility.md
  - ../references/output-diff.md
---

## Summary On Demand

A one-shot presentation skill, not a mode. One invocation gives one report on **the scope the user names**, and the skill then stands down. Nothing turns on, nothing persists, and nothing is written.

## Scope

Summarize exactly what the user pointed at and nothing around it. The scope can be anything: a stretch of work done in this session, a PR/MR, an issue, a Slack thread, a document, a discussion, a topic. Name the scope in the lede so the reader knows the boundary.

When no scope is given and the conversation does not make it obvious, ask one short question naming the likely candidates. Never default to summarizing the whole session.

Read the scope's source live before writing: the repository state for work done, the PR/MR or issue as it stands now, the thread or document itself. A summary built from memory of an earlier read reads as verified and is worse than none.

## Shape

```
<lede — the scope named, and what it comes down to, no header>

## <Part of the scope>
<bullets>

## <Another part>
...

## Open
<bullets>

## Waiting on you
<bullets, only when the scope implies a user action>
```

### The lede

What the scope comes down to, in one or two sentences, with the scope named. For work done, the outcome. For an MR, what it changes and where it stands. For a thread or discussion, what was concluded.

### One `##` per part of the scope

Pick the grouping that fits the scope: areas of work, components of an MR, topics of a thread, sections of a document. Name each header after its subject, never after time order. Each header holds bullets stating results or conclusions, not the steps that led there.

When the scope is **work done**, each header also carries:

- **Landed:** commits, branches, PR/MR links, issue links, file paths, each a titled link per `identifier-legibility`. Several items get a short table instead.
- **Checked:** how it was verified, or **unverified** stated plainly.

Decisions that shaped the result get a bullet starting with **Decided:** under the header they shaped.

Split a header with `###` when it holds several unrelated things. Merge two headers when one has a single bullet.

### `## Open`

What the scope leaves unresolved: not done, deferred, disputed, unanswered. Always include it, and write "nothing open" when it is empty.

### `## Waiting on you`

Only when the scope implies a user action, one bullet per concrete action. Prerequisite marker per `output-status`. Omit it when the scope is purely informational.

## Rules

- **Results, not narration.** "Added `output-summary` skill" rather than "First I read the other modes, then I drafted…". The steps belong in the transcript.
- **Synthesize, never relay.** No pasted tool output or subagent reports.
- **Any active voice mode still governs.** Under `caveman` the headers stay, filled tersely.
- **Scannable over complete.** When a part outgrows a screen, point at the durable artifact (the MR description, the plan file, the note) and keep a summary of it here.

## Boundaries

- **The live picture of in-flight work is `output-status`**, not this. A summary looks back over a settled scope; anything in the scope still moving is named under `Open`.
- **Presenting a write is `output-diff`.** A summary may say a write is pending; its content is presented per `output-diff` before it runs.

## Examples

**User says:** "summarize what we did on the output modes"

1. Scope is the output-mode skill work only; the Lua fix from the same session stays out.
2. Re-run `git log` for the skills commits.
3. Lede: `output-summary` added and pushed.
4. `## Skills: output-summary`: changed, landed (commit link), checked (re-read via the skills server).
5. `## Open`: nothing open.

**Result:** only the named work, grouped by area, with where it landed and how it was checked.

---

**User says:** "sum up this slack thread"

1. Read the thread live.
2. Lede: what was concluded.
3. One header per topic the thread covered, conclusions as bullets.
4. `## Open`: questions nobody answered.
5. No `Waiting on you`, since nothing in the thread asks the user to act.

**Result:** the thread's conclusions by topic, with the unanswered parts called out.
