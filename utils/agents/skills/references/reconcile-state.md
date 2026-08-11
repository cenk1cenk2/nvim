# Reconcile State

For skills that own a **durable artifact** — a Linear issue or project, a PR/MR title and description, a Linear document, a plan file, a repo knowledge base, an Obsidian note. These outlive the turn that wrote them, and reality moves on without them.

## First: is it yours to touch?

**Reconcile only what this session created, or what the user explicitly handed you.** That is the whole permission.

| Yours — reconcile it | Not yours — do not write |
|---|---|
| The PR/MR you opened this session | A PR/MR someone else opened |
| Issues you created this session | Issues that already existed, or belong to someone else |
| A Linear document you authored | A document authored by someone else |
| A plan file you wrote | Anything outside the work you were given |

The user pointing you at an artifact and asking you to work it — "pick up K-219", "update this MR" — hands it over. Merely *reading* one does not.

**When it is not yours, say so instead of writing.** Report the drift in one line and let the user decide: `K-402 looks out of date relative to this change — not mine to edit, want me to?` Surfacing costs nothing; editing someone else's tracker item is not recoverable by them noticing later.

**In doubt, ask.** Ownership is the case where guessing is worst — assume it is not yours.

## Then: bring yours back in line

Deviating is normal — scope grows, an approach is dropped, an issue splits, a delegated agent solves it another way. The failure is leaving your own artifact claiming the original plan.

**A confidently wrong artifact is worse than a thin one.** A stale issue gets implemented; a stale plan gets picked up; a stale PR body gets squash-merged into permanent history.

| Situation | Do |
|---|---|
| Yours, and it contradicts what is now true | **Update it** — a correction, not a new decision. No prompt. |
| Yours, but unclear whether it should follow the deviation | **Ask in one line:** "scope changed to X — update the issue?" |
| Only the conversation moved | Leave it. Not every turn earns a write. |

Batch it: one pass covering everything that drifted, not a write per realization.

**Delegation is the main source** — a subagent's result differs from its brief, and the agent that did the work usually cannot fix the tracker. Whoever owns the item reconciles it. Long multi-turn flows are next: the state written at the start is the one most likely wrong at the end.

**On by default** for what is yours. The user opts out for the turn — "don't touch the issue", "leave the tracker alone", "I'll fix it myself" — and you report it: `Reconciliation suppressed by user.` An opt-out suppresses the write, never the question.

**Report each one:** `Reconciled K-219 — description now reflects the split into K-244/K-245.` A silent correction is indistinguishable from drift nobody caught.
