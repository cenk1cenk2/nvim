# Output Table

How to present a flow: ordered steps, more than one actor, a check between steps, and steps that wait on other steps. One table the reader scans top to bottom, instead of paragraphs they have to reassemble into an order.

Typical flows: a rollout or cutover, a release chain, a merge order across prepared PRs/MRs, a run of agents whose results the user acts on, any handoff where "you do X, then I verify Y" repeats.

## Columns

One row per step, in execution order. Core columns always appear. Optional columns appear only when the flow needs them, and stay once added so successive tables compare row by row.

| Column | Kind | Holds |
|---|---|---|
| `#` | core | Step number, stable for the life of the flow. Parallel steps share a number with a letter: `3a`, `3b`. |
| `Who` | core | `you`, `me`, `you, I check`, an agent's name, or a named third party. |
| `Action` | core | The step, as an instruction. |
| `Check` | core | How done is verified: the signal, the tool, the expected value. |
| `Needs` | optional | Rows this step waits on: `2`, `2, 3a`. Blank when it waits on nothing. Add it once the order is not strictly linear. |
| `Status` | optional | `done`, `ready`, `running`, `blocked`, `waiting`. Add it once any row has moved. |
| `Blocker` | optional | The specific unmet thing behind `blocked`: a row number, an external event, a decision. |

`waiting` means its `Needs` are not done yet, the normal state of a later step. `blocked` means something outside the flow stops it, and `Blocker` names that thing.

## Rules

- **The table holds steps; bullets under it hold explanation.** Ordering reasons, risk windows and caveats go in short bullets below. A cell may carry one clause that changes how the step is executed ("plan only, needs 2 applied").
- **Every identifier is a titled link**, per `identifier-legibility`. A cell carries the short linked form; a bullet below carries more when the title is long.
- **A blocked row stays in place.** Mark it and name the blocker; never drop or reorder it out of sight.
- **Re-emit when a row moves**, same numbers, same columns, one line above it naming what moved. A turn where nothing moved does not re-emit.
- **Close with the next row to act on**: `Next: 2 (you) — merge and confirm the apply.` When several rows are ready at once, name each.
- **A markdown table, never hand-drawn box art.** The renderer draws the borders.
- **Live state only.** Re-read each row's source before re-emitting; a row copied from an earlier table is a claim, not a check.

## Inside a Status Report

When the tracked work is a flow, the flow table **is** the `## Current state` table of an `output-status` report, and every `you` row that is `ready` is a `## Waiting on you` item. The bullet list under that header then just names those rows (`2, 5 — see table`) plus anything outside the flow. The prerequisite marker becomes the row's `Needs` and `Blocker`.

Work that is not a flow — a fleet of independent items, an agent roster — keeps the plain state tables `output-status` describes.

## Examples

### A rollout with a handoff between actors

| # | Who | Action | Check | Needs | Status |
|---|---|---|---|---|---|
| 1 | you | Merge [#101 — Add the audit role to the shared module](https://example.invalid/pr/101), then the release PR it opens | Module `1.4.0` published in the registry | | done |
| 2 | you | Merge [#202 — Roll the role out to the accounts stack](https://example.invalid/pr/202) and confirm the apply | Run applied: 4 adds, 8 deletes | 1 | ready |
| 3 | me | Confirm the role exists in the target account | Role listed through the read-only profile | 2 | waiting |
| 4 | me | Open the consumer bump to `1.4.0`; plan only, needs 2 applied | Plan: one new access entry, two changed filters | 2 | waiting |
| 5 | you, I check | Merge the bump and confirm the apply | Access entry present in the expected group | 3, 4 | waiting |
| 6 | you | Log in with the new role and run the read and the denied call | Read succeeds, denied call refused, both audited under your name | 5 | waiting |

- From 3 until 5 applies, nobody can reach the cluster through the old path.
- 4 cannot plan earlier because it looks up the role 2 creates.

Next: 2 (you) — merge and confirm the apply.

### A merge order across prepared MRs

Four MRs are open and green. The table is the order they must land in.

| # | Who | Action | Check | Needs | Status | Blocker |
|---|---|---|---|---|---|---|
| 1 | you | Merge [lib!40 — Extract the retry policy](https://example.invalid/lib/-/merge_requests/40) | Tag `v2.3.0` released | | ready | |
| 2a | me | Bump [api!118 — Use the shared retry policy](https://example.invalid/api/-/merge_requests/118) to `v2.3.0`, push | Pipeline green | 1 | waiting | |
| 2b | me | Bump [worker!77 — Use the shared retry policy](https://example.invalid/worker/-/merge_requests/77) to `v2.3.0`, push | Pipeline green | 1 | waiting | |
| 3 | you | Merge api!118 and worker!77, any order | Both merged | 2a, 2b | waiting | |
| 4 | you | Merge [deploy!9 — Raise the retry budget](https://example.invalid/deploy/-/merge_requests/9) | Rollout healthy on staging | 3 | blocked | review: one open change request |

- 2a and 2b are independent; merge whichever goes green first.
- 4 merges last because it raises a budget only the new policy reads.

Next: 1 (you) — merge lib!40.

### A coordinated agent run, re-emitted after a row moved

`2a` finished and verified; `2b` failed its tests and was re-dispatched.

| # | Who | Action | Check | Needs | Status | Blocker |
|---|---|---|---|---|---|---|
| 1 | me | Split the migration into three slices | Plan approved | | done | |
| 2a | agent `slice-schema` | Migrate the schema module | Tests pass, diff reviewed | 1 | done | |
| 2b | agent `slice-handlers` | Migrate the request handlers | Tests pass, diff reviewed | 1 | running | |
| 2c | agent `slice-jobs` | Migrate the background jobs | Tests pass, diff reviewed | 1 | blocked | your call: keep or drop the legacy queue |
| 3 | me | Open one MR per slice, stacked on 2a | Pipelines green | 2a, 2b, 2c | waiting | |
| 4 | you | Review and merge the stack bottom-up | Merged in order | 3 | waiting | |

- 2b failed on a fixture that still used the old column name; the re-dispatch carries the fix.

Next: your decision on 2c — keep or drop the legacy queue.
