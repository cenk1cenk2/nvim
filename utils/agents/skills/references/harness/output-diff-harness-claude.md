# Harness: Claude Code — output-diff

How to put a change or a decision in front of the user on Claude Code. The runtime has native surfaces for both, and they beat printed proposals: the user reviews in the harness's own UI and answers there. Read with `output-diff`, which owns what a chunk contains. Facts are from v2.1.306.

## Decisions go through `AskUserQuestion`

Any question whose answer changes what you do next — a decision list, a fork in the approach, a fact only the user knows, a "which of these" — is asked with `AskUserQuestion`, not printed as a table or a trailing question.

- **Up to 4 questions per call, 2-4 options each.** The UI adds "Other" for free text, so never add one yourself.
- **Recommended option first**, with `(Recommended)` at the end of its label.
- **`header`** is a chip of at most 12 characters; **`description`** carries the trade-off in one line.
- **`multiSelect: true`** when the choices are not exclusive, such as "which of these items to apply".
- **`preview`** on single-select options shows a mockup, snippet or diff beside the list; use it when the user must compare concrete content.
- A longer decision list is several calls, ranked, the most consequential first. Never ask whether a plan is ready or whether to proceed; that is the approval itself.

## File changes go through `Edit` diffs

A change to a local file that needs the user's eyes — a present-first write, a gate change, a meaning change in guidance — is made as the `Edit` call itself, one call per logical chunk, instead of printing the diff. The harness renders each call as a reviewable diff.

- **Put the reasoning in one line before the calls.** The diffs are the content blocks `output-diff` asks for.
- **In a permission mode that prompts for edits, the prompt is the approval.** A denied call is a rejected chunk; handle it per `code-deviations`, never retry it verbatim.
- **In `auto` or `acceptEdits` mode the edit lands at once.** Use this route for changes already approved, or for act-then-report writes, and the user still sees each diff. A change that still needs approval in those modes is asked first with `AskUserQuestion`, with the diff in its `preview`.
- **Never batch a reviewable change into a shell script** (`sed -i`, a Python rewrite). It lands with no diff in the UI, which is exactly what this route exists to avoid. Scripted edits are for mechanical sweeps already approved as a whole.

## Subagents

A background subagent's `Edit` that needs permission surfaces its prompt in the main session, naming the subagent. So a subagent applying approved changes makes them with `Edit`, not a script, and the user reviews them the same way. A subagent never asks the user directly; its questions travel to the lead, and the lead asks them with `AskUserQuestion`.

## External resources

`Edit` covers local files only. A draft for an external resource (a PR/MR description, a Linear issue, a Slack message) still follows `output-diff`'s chunk format, and the approve-or-change decision goes through `AskUserQuestion` with the draft in `preview` when it fits.
