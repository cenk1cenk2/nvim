---
name: gitlab-mr-create
description: gitlab-mr-create Analyse a GitLab MR and write its title and description, keeping them current as the branch changes. Use on "write an MR description", "create an MR", "improve the MR". Not for GitHub pull requests, or for CI pipelines and failures.
references:
  - ../references/reconcile-state.md
  - ../references/scm/scm-detect.md
  - ../references/present-first.md
  - ../references/scm/scm-create-description.md
  - ../references/scm/scm-gitlab.md
  - ../references/scm/commit-trailers.md
  - ../references/scm/commit-trailers-gitlab.md
  - ../references/scm/commit-trailers-linear.md
  - ../references/output-diff.md
  - ../references/linear/linear-state-transitions.md
  - ../references/scm/release-convention.md
  - ../references/identifier-legibility.md
  - ../references/open-artifact.md
argumentHint: '[optional: MR number or URL]'
---

Never hand back a bare identifier: issues, MRs and PRs carry their title and a markdown link to their URL, plus the repository or parent scope when more than one is in play, per `identifier-legibility`.

## GitLab MR Description Workflow

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
> **Open when ready.** Default communication is opening the MR in the browser once it's ready to look at — skip only on explicit opt-out ("just the link", "don't open").

Description/title workflow, format templates, and writing style per `scm-create-description`. GitLab tooling, local git, CLI fallback, and platform detection per `scm-detect` and `scm-gitlab`. Present reasoning and content in logical chunks for user approval per `output-diff` before writing to external systems.

Issue trailer selection per `commit-trailers`: use `closes <Linear-id>` for the single/final MR that should close a Linear issue; use `refs <Linear-id>` **only** when the work is genuinely partial - another MR is still pending on the same issue. Unclear is not a reason to hedge to `refs`: if this MR closes it, write `closes`. **Several issues in one MR:** one keyword, comma-separated — `Closes K-879, K-881` — never one trailer per issue, and carry the ids in the title too: `fix(scope): subject (K-879, K-881)`. Give each issue its own description section per `scm-create-description`. **Linear ignores commit messages entirely**, so the title and description are the only things carrying the link.

## Platform specifics

- **Find the MR** (when not given): get the current branch via `git status`, extract the GitLab project path from the remote, then `gitlab__list_merge_requests` with a `source_branch` filter and `state: opened`. See "Branch reuse" in `scm-create-description`. If no open MR exists, ask the user before creating one. GitLab MCP has no creation tool today, so fall back to `glab mr create`.
- **Merge defaults (on create):** always pass `--remove-source-branch` to delete the source branch on merge. For squash, decide by commit count: if the branch is a single logical commit, pass `--squash-before-merge`; if it carries multiple meaningful commits (e.g. grouped by task), keep squash OFF so the separate commits survive the merge. If a GitLab MCP creation tool becomes available and accepts `squash` / `remove_source_branch`, set `remove_source_branch: true` and `squash` per the same rule. These are team defaults — do not prompt to confirm them each run; skip only if the user explicitly opts out in the same message that requests MR creation.
- **Match the release automation.** Detect the repo's release method (release-please, semantic-release, changesets, commitlint) per `release-convention`. semantic-release frequently runs from `.gitlab-ci.yml` — when present, the branch's commits (or, when the MR squashes, the MR title) must be valid Conventional Commits so the pipeline computes the right version; breaking changes need `type(scope)!:` plus a `BREAKING CHANGE:` footer. If the repo uses changesets, ensure the branch includes a changeset file before merge (offer to add one).
- **Analyze the MR:** read details via `gitlab__get_merge_request`, the full diff via `gitlab__get_merge_request_diffs`, and commit history via `gitlab__list_commits` filtered to the MR branch. Note the existing title and description.
- **Update the MR** (only after approval): update `title` (if changed) and the description via GitLab MCP tools, then confirm success. Once the MR is created/updated and ready to look at, by default open its web URL in the browser (e.g. via `hyprpilot__open`), timing per `open-artifact` — skip only if the user explicitly said not to ("just give me the link", "don't open it", "no browser").
- **Transition linked Linear issues to `In Review`:** after the MR create/update succeeds, apply the auto-advance rules per `linear-state-transitions` — extract Linear ids from the MR body (`refs K-xxx` / `closes K-xxx` trailers) and the branch's commit messages, fetch each id's current `statusType`, and call `save_issue` with `state: "In Review"` (skip when already `Done` / `Canceled` or already `In Review`; never downgrade). Report one line per issue touched: `Linear state: moved K-xxx → In Review (was Todo).` Silent-with-report — no prompt; the user opts out by saying "don't move the Linear state" in the MR-create request. Skip entirely when zero Linear ids are found — not every branch is tied to an issue.
