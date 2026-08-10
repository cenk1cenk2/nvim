# SCM Create Description

Shared description/title drafting workflow for opening or updating a pull/merge request. Used by `github-pr-create` (GitHub) and `gitlab-mr-create` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) and each skill's "Platform specifics" supply the exact detect/create/update tools; this reference covers only the parts that are identical across platforms.

## ⛔ Never open it as a draft

**Default is ready for review.** Exactly two things open a draft:

1. **The user asked for one, in those terms** — "open it as a draft", "make it a draft MR", "draft PR please".
2. **A real merge prerequisite exists** — this PR/MR cannot merge until something else does: it is stacked on another PR/MR, or waiting on a dependency release, a migration, or an approval outside this branch. Draft is the correct state there because merging early would break something, not because the work is unfinished.

**"Draft" describing the WORK is not a request for a draft PR.** These are not triggers, and treating them as one is the mistake this rule exists to stop:

- the implementation is exploratory, a first cut, a spike, or "trying things out",
- the user said "let's draft something" or "this is a draft implementation" while iterating,
- tests are failing, CI has not run, or the scope is partial,
- you want feedback before it is finished,
- you are unsure the approach is right.

By the time the user says "open a PR", the work has converged — that is what the request means. Opening a draft then hides the change from reviewers and its pipeline from the one person who asked to see it.

When the work genuinely is not ready, the answer is **not** a draft:

1. **Do not open it yet** — say what is outstanding and wait.
2. Or **open it ready** and state the outstanding items in the description.

If a request is genuinely ambiguous — the word "draft" appears but you cannot tell whether it describes the PR or the work — ask the single question before opening. Never guess toward draft.

**A draft is a state you are responsible for clearing.** Whichever reason opened it:

- **Name the reason in the description** — which PR/MR, release, or approval it waits on. A draft with no stated blocker is indistinguishable from one that was opened by mistake.
- **Reconcile it when the blocker clears.** The prerequisite merged, the dependency shipped, or the user said it is ready — mark it ready for review and say so. Do not leave it sitting in draft, and do not make the user ask twice.

## ⛔ The description is live, not write-once

**Whenever the branch changes after the PR/MR exists, bring the title and description back in line with it.** Scope grew, an approach was abandoned, a commit was added, the work deviated from what the description claims — update it. Default is update; the user opts out by saying so ("leave the description", "no need to update it").

This matters more than it looks because of the merge method:

- **Squash-merge** — the title becomes the commit subject and the body commonly becomes the commit body. A stale description is not just misleading on the PR page; it is written into history permanently and cannot be fixed by editing the PR afterwards.
- **Merge / rebase** — the commits carry the history, but the description is still what a reviewer reads first and what the tracker links from.

A description that describes work the branch no longer does is worse than a thin one: it is confidently wrong, and under squash it is wrong forever.

## Branch reuse

Branches may have previously merged or closed PRs/MRs — this is normal. Only open PRs/MRs matter. If no open PR/MR is found but `git log main..HEAD` shows commits ahead of the base branch, the branch needs a new one. Do NOT search for or get confused by prior closed/merged PRs/MRs on the same branch.

## Draft the description

- If a template exists — in the existing PR/MR body, or discovered in the repo (see the skill's "Platform specifics") — fill in its sections with analyzed content. Preserve the template's structure, headings, and any HTML comments (`<!-- -->`) — only replace the placeholder content inside them. Do NOT remove sections the template defines, even if empty; leave them with a minimal placeholder or the template's own guidance.
- If no template exists, write a fresh description following the format below.
- Analyze the diff for **logical changes only** — what behavior was added, removed, or changed.
- Do NOT list changed files, line counts, or mechanical details.
- If the PR/MR links Linear issues, add or preserve body trailers using `commit-trailers`: default to `closes <ID>` when this PR/MR resolves the issue and nothing else is pending (so it auto-closes on merge); use `refs <ID>` only for genuinely partial or related work.
- **When one PR/MR closes several issues, give each issue its own section** and list every closed ID on one trailer line — see "Multiple linked issues" below. A reviewer must be able to tell which change belongs to which issue without reading the diff.
- **Linear links only from the title, the description, and the branch name.** A Linear ID in a commit message does nothing — see `commit-trailers`. Never rely on commits to carry the link.

## Draft the title

- If the existing title is already descriptive and clear, keep it.
- If the title is a branch name, ticket number, or otherwise non-descriptive, generate a new one.
- **The title is a semantic (conventional) commit — this matters:** `<type>(<scope>): <brief description>`. On a squash-merge repo it becomes the commit, so it must be a valid conventional-commit subject.
- Types: feat, fix, docs, style, refactor, test, chore, perf, build, ci, revert.
- **Keep it concise** — one line, well within the platform's title limit (aim ≤ ~100 chars, hard ~120); tighter than the description, no fluff.
- **Pure ASCII, no special chars** — no em/en dashes (`—`, `–`), smart quotes, or ellipsis (`…`); use a plain hyphen `-`. Same subject rules as the `commit-style` reference.
- **Put the linked issue IDs in the title**, trailing and parenthesised: `fix(scope): subject (K-879)`, or `(K-879, K-881)` for several. For Linear this is a real linking surface in its own right, independent of the description trailer — keep both. Follow the repo's existing convention where it already has one.
- If the repo has release automation (release-please, semantic-release, …), the title must satisfy it — see the `release-convention` reference. Mark breaking changes with `type(scope)!:` and a `BREAKING CHANGE:` footer.

## Description Format (When No Template Exists)

**Standard PRs/MRs:**

```markdown
<1-3 sentence summary of what this PR/MR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>
```

**Multiple linked issues (one PR/MR closing several):**

```markdown
<1-3 sentence summary of what this PR/MR does and why>

## K-879 - <issue title>

- <logical change 1>
- <logical change 2>

## K-881 - <issue title>

- <logical change 1>

Closes K-879, K-881
```

One section per issue, headed by its ID and title, so the split is obvious at a glance. The trailer stays a **single line listing every closed ID** — that is Linear's documented multi-issue form, not one trailer per issue. Mixed kinds get one line each: `Closes K-879, K-881` and `Refs K-884`.

**Large PRs/MRs (judgment call — significant scope or multiple concerns):**

```markdown
<1-3 sentence summary of what this PR/MR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>

## Reasoning

<Brief explanation of approach, trade-offs, or decisions made>

## Appendix

<Additional context: migration notes, configuration changes, breaking changes, or references>
```

## Writing Style

- Be concise — every sentence must earn its place.
- Focus on **what changed logically**, not what files were touched.
- Do NOT mention file names, line counts, number of lines changed, or other mechanical details.
- Use imperative mood in bullet points: "Add retry logic" not "Added retry logic".
- Always end each bullet point with a period (`.`).
- No filler phrases: skip "This PR...", "This MR...", "This change...", "In this pull request...".
- Start the summary directly with the action or context.
- Bullet points should be self-contained and scannable.
- Group related changes into single bullets rather than listing every micro-change.

## Related Skills

- **`code-review-branch`** — for reviewing the code quality of the branch before writing the PR/MR description. Do not auto-invoke.
- **The platform's CI-create skill** (`github-ci-create` / `gitlab-ci-create`) — for creating or updating CI workflows/pipelines. Do not auto-invoke.
- **The platform's CI-fix skill** (`github-ci-fix` / `gitlab-ci-fix`) — for diagnosing failing CI on the PR/MR. Do not auto-invoke.
- **`agent-pickup`** — when this skill is composed from a pickup workflow, keep PR/MR text focused on logical changes; the caller records broader deviations/findings on Linear issues or project documents.
