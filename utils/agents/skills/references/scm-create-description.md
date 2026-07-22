# SCM Create Description

Shared description/title drafting workflow for opening or updating a pull/merge request. Used by `github-pr-create` (GitHub) and `gitlab-mr-create` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) and each skill's "Platform specifics" supply the exact detect/create/update tools; this reference covers only the parts that are identical across platforms.

## Branch reuse

Branches may have previously merged or closed PRs/MRs — this is normal. Only open PRs/MRs matter. If no open PR/MR is found but `git log main..HEAD` shows commits ahead of the base branch, the branch needs a new one. Do NOT search for or get confused by prior closed/merged PRs/MRs on the same branch.

## Draft the description

- If a template exists — in the existing PR/MR body, or discovered in the repo (see the skill's "Platform specifics") — fill in its sections with analyzed content. Preserve the template's structure, headings, and any HTML comments (`<!-- -->`) — only replace the placeholder content inside them. Do NOT remove sections the template defines, even if empty; leave them with a minimal placeholder or the template's own guidance.
- If no template exists, write a fresh description following the format below.
- Analyze the diff for **logical changes only** — what behavior was added, removed, or changed.
- Do NOT list changed files, line counts, or mechanical details.
- If the PR/MR links Linear issues, add or preserve body trailers using `commit-trailers`: `closes <ID>` only for issues this PR/MR fully resolves, `refs <ID>` for partial or related work.

## Draft the title

- If the existing title is already descriptive and clear, keep it.
- If the title is a branch name, ticket number, or otherwise non-descriptive, generate a new one.
- **The title is a semantic (conventional) commit — this matters:** `<type>(<scope>): <brief description>`. On a squash-merge repo it becomes the commit, so it must be a valid conventional-commit subject.
- Types: feat, fix, docs, style, refactor, test, chore, perf, build, ci, revert.
- **Keep it concise** — one line, well within the platform's title limit (aim ≤ ~100 chars, hard ~120); tighter than the description, no fluff.
- **Pure ASCII, no special chars** — no em/en dashes (`—`, `–`), smart quotes, or ellipsis (`…`); use a plain hyphen `-`. Same subject rules as the `commit-style` reference.
- If the repo has release automation (release-please, semantic-release, …), the title must satisfy it — see the `release-convention` reference. Mark breaking changes with `type(scope)!:` and a `BREAKING CHANGE:` footer.

## Description Format (When No Template Exists)

**Standard PRs/MRs:**

```markdown
<1-3 sentence summary of what this PR/MR does and why>

- <logical change 1>
- <logical change 2>
- <logical change 3>
```

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
- **`agents-pickup`** — when this skill is composed from a pickup workflow, keep PR/MR text focused on logical changes; the caller records broader deviations/findings on Linear issues or project documents.
