# Reconcile State

For skills that own a **durable artifact** — a Linear issue or project, a PR/MR title and description, a plan file, a repo knowledge base, an Obsidian note. These outlive the turn that wrote them, and reality moves on without them.

⛔ **An artifact you own must describe what is actually true.** Deviating is normal — scope grows, an approach is dropped, an issue splits, a delegated agent solves it another way. The failure is leaving the artifact claiming the original plan.

**A confidently wrong artifact is worse than a thin one.** A stale issue gets implemented; a stale plan gets picked up; a stale PR body gets squash-merged into permanent history.

| Situation | Do |
|---|---|
| Artifact contradicts what is now true | **Update it** — a correction, not a new decision. No prompt. |
| Unclear whether it should follow the deviation | **Ask in one line:** "scope changed to X — update the issue?" |
| Only the conversation moved | Leave it. Not every turn earns a write. |

In doubt, ask rather than skip. Batch it: one pass covering everything that drifted, not a write per realization.

**Delegation is the main source** — a subagent's result differs from its brief, and the agent that did the work usually cannot fix the tracker. Whoever owns the item reconciles it. Long multi-turn flows are next: the state written at the start is the one most likely wrong at the end.

**On by default.** The user opts out for the turn — "don't touch the issue", "leave the tracker alone", "I'll fix it myself" — and you report that: `Reconciliation suppressed by user.` An opt-out suppresses the write, never the question when something is genuinely ambiguous.

**Report each one:** `Reconciled K-219 — description now reflects the split into K-244/K-245.` A silent correction is indistinguishable from drift nobody caught.
