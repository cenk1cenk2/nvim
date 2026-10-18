---
name: labrat-pickup
description: labrat-pickup Take a labrat session back to finish it here - ground on the original ask, the agent's posture, what it built, what is waiting and every deviation, verify it live, then lay out how to proceed. Use on "pick up the labrat session", "take this back from labrat", "finish what labrat started". Not for a quick status read or following a live session.
disableModelInvocation: true
argumentHint: '[Slack thread permalink, session key, or what the session was about]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/identifier-legibility.md
---

## Context

labrat works in Slack threads and leaves its record in a Hermes session; this skill moves that work back into the local session. The session transcript is the agent's own account. Everything it claims — a green pipeline, an open MR, a settled order — is a lead to verify, never a fact to relay. Load `labrat` before the first call to its server.

## Process

1. **Find the session.** A Slack permalink carries the thread ts: `p1700000000123456` is `1700000000.123456`, and searching it returns the one session. Otherwise resolve it per `labrat`; when several match, present them and ask.
2. **Read the whole record.** `messages_read` at its cap. When `total_in_session` exceeds `count`, the oldest messages are out of reach there; Load the workspace's Slack skill and read the thread itself — channel id and thread ts come from the session key — for the full history, files and the permalinks to cite. Read the gateway notifications for evidence (which watchers fired, which delegates finished) but leave them out of the narrative.
3. **Extract, in this order:**
   - **The original ask** — the first human turn, quoted in its essentials, plus every later human turn as an amendment or steer.
   - **The posture** — skills and postures the ask told it to load and the agent announced, standing grants it acted under ("full-push grant"), and the guardrails it kept repeating ("no merges, no force pushes").
   - **What it built** — every MR, branch, commit, issue and tracker change it names, with the claim attached.
   - **What is waiting** — delegates still running, watchers armed, CI pending, human reviews and gates it is blocked on.
   - **Deviations** — where the work departs from the ask: scope added or dropped, order changed, an approach swapped, a claim later retracted. Also where the last messages contradict earlier plans.
4. **Verify live.** Read every MR, pipeline, branch and issue through its platform tools: state, target, head, CI, open discussions. Mark each item verified or claimed-only, and record where the live state disagrees with the transcript. When the ask names a tracker project, Load that workspace's Linear skill to read it, and compare its issues and relations against what the agent says it reconciled.
5. **Settle who writes.** If the session's latest activity is recent, labrat is still working and holds the same branches. No tool here stops it, and a post into its thread does not reach it, so the first proceed step is the user parking it; until they do, this session stays read-only on every branch labrat touches. Two writers on one branch clobber each other.
6. **Write the summary**, human readable, every identifier a titled link per `identifier-legibility`:
   - **The ask** — what was requested, and the amendments.
   - **How the agent was working** — posture, grants, guardrails.
   - **Done** — verified items first, claimed-only items marked.
   - **In flight and waiting** — what it was blocked on and what its own last plan said comes next.
   - **Deviations** — from the ask, and between claim and live state.
   - **Open decisions** — what only the user can settle before work resumes.
7. **Lay out the way forward.** Load `output-table` and present the proceed flow as one table: parking labrat first when it is live, then the remaining work in dependency order, each row with its owner and check. Close on the next row to act on.
8. **Record and hand over.** When the user takes it on, write the pickup state durably per `long-running-work` — the session key, the verified state, the plan — and reconcile the tracker per `reconcile-state` as work lands. Implementation waits for the user's proceed signal; then route each row through the skill that owns it.

## Example

**Trigger:** "pick up https://example.slack.com/archives/C0EXAMPLE/p1700000000123456 and finish it here"

1. Thread ts `1700000000.123456` finds one session in the channel.
2. 100 of 112 messages are readable, and the Slack thread fills in the first 12; the first human turn asks it to run a project pickup on a tracker project and follow its crew charter.
3. Posture: coordinator and bulldozer, full-push grant, no merges or force pushes. Built: four stacked MRs and a notes-sink branch. Waiting: CI on the newest stack head, one review. Deviation: the planned parallel MRs were restacked after a conflict.
4. Live check: all four MRs open on the stated targets; one claimed green pipeline is still running.
5. Latest activity is minutes old, so parking labrat is row 1.
6. Summary presented, then the output-table flow: park labrat, finish the notes sink, rebase the top of the stack, request reviews, merge bottom-up.

**Result:** the user sees what was asked, what exists, what deviated and who does what next, before anything is written.

## Key Principles

- The transcript is a claim; the live platform state is the record.
- Deviations are named, never smoothed over — from the ask and between claim and reality.
- Labrat keeps writing until the user parks it; never share a branch with a live session.
- Summary and table first; implementation only on the user's go.
