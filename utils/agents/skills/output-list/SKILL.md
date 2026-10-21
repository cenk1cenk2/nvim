---
name: output-list
description: output-list Turn the scope the user names - findings, a review, a thread, loose ends - into actionable items, one header per kind of action, each a concrete step with an owner. Use on "list it", "action items", "give me a todo list", "what do I need to do". Not for a narrative recap, the live state of in-flight work, or presenting a write for approval.
disableModelInvocation: true
argumentHint: '[scope to turn into action items]'
references:
  - ../references/output-status.md
  - ../references/identifier-legibility.md
  - ../references/output-diff.md
---

## Action List On Demand

A one-shot presentation skill, not a mode. One invocation turns **the scope the user names** into a list of things to do, and the skill then stands down. Nothing turns on, nothing persists, and nothing is written.

## Scope

List exactly what the user pointed at: review findings, an audit, a PR/MR's open threads, a Slack thread, a meeting note, the loose ends of work done this session. Name the scope in the lede.

When no scope is given and the conversation does not make it obvious, ask one short question naming the likely candidates.

Read the scope's source live before listing: the PR/MR threads as they stand now, the thread or document itself, the repository state for work done. An item already resolved at the source leaves the list.

## Shape

```
<lede — the scope named, and how many items under how many kinds, no header>

## <Kind of action>
- [ ] <owner>: <action> — <why or where, one clause>.

## <Another kind>
...
```

### The lede

The scope, the item count, and the one item to start with. One or two sentences.

### One `##` per kind of action

Group by what the reader does with the item, and name the header after that kind. Pick the kinds the scope actually holds, for example:

- **Decide** — a choice only the user can make, with the options named.
- **Fix** — a defect to correct, with the file or resource it lives in.
- **Review** — something to read, approve, or merge.
- **Follow up** — a person to ask, a ticket to file, a thread to answer.
- **Clean up** — branches, resources, scratch data to remove.
- **Verify** — a check to run before something is trusted.

A scope with a natural split of its own (per repository, per MR, per service) puts that split in `###` under the kind, or swaps it to the top level when every item shares one kind.

Order headers by urgency, most urgent first. Inside a header, order items the same way.

### Each item

- **A checkbox, an owner, and an imperative action**: `- [ ] you: merge [!118 — Use the shared retry policy](https://example.invalid/api/-/merge_requests/118) once the pipeline is green.` Owner is `you`, `me`, or a named person or agent.
- **One action per item.** An item holding "and then" is two items.
- **Concrete enough to start without rereading the source**: the file path, the command, the link, the person.
- **Every identifier a titled link**, per `identifier-legibility`.
- **Blocked items stay listed**, with the prerequisite marker from `output-status` leading the item.

## Rules

- **Actions, not observations.** "Rotate the key in `secrets/api.env`" rather than "The key is old". An observation with no action belongs out of the list or under the item it motivates.
- **Every relevant item gets a line.** Never trim to hit a number; a long list is ranked, not cut.
- **Synthesize, never relay.** No pasted tool output or subagent reports.
- **Any active voice mode still governs.** Under `caveman` the headers and checkboxes stay, items terse.

## Boundaries

- **A recap of what happened is `output-summary`**; this lists only what is left to do.
- **The live picture of in-flight work is `output-status`**, not this.
- **Presenting a write for approval is `output-diff`.** An item may name a write; the skill that performs it decides whether it is presented first.

## Examples

**User says:** "give me action items from this MR review"

1. Re-read the MR's open threads; resolved ones drop out.
2. Lede: 7 items across 3 kinds, start with the failing migration.
3. `## Fix`: four items, each with the file and the reviewer's ask.
4. `## Decide`: one item naming the two naming options a reviewer raised.
5. `## Review`: two items, re-request review from each reviewer once fixes land.

**Result:** every open thread became one checkable item, grouped by what the user does with it.

---

**User says:** "what do I need to do after this session"

1. Re-check git state, open PRs/MRs, and running watchers.
2. Lede: 4 items, start with merging the pushed branch.
3. `## Review`: merge the PR, linked with its title.
4. `## Clean up`: two scratch branches this session created.
5. `## Verify`: run the integration suite that was skipped locally.

**Result:** only what is left, owned and ordered, with nothing already done on the list.
