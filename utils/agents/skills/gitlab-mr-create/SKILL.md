---
name: gitlab-mr-create
description: gitlab-mr-create Analyze and write GitLab merge request titles and descriptions. Use when user says "write an MR description", "create an MR", "improve the MR", or "describe what this branch does". Do NOT use for GitHub PRs (github-pr-create), CI pipelines (gitlab-ci-create), or CI failures (gitlab-ci-fix).
references:
  - ../references/present-first.md
  - ../references/scm-create-description.md
  - ../references/scm-gitlab.md
  - ../references/commit-trailers.md
  - ../references/output-diff.md
  - ../references/linear-state-transitions.md
  - ../references/release-convention.md
---

## GitLab MR Description Workflow

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **Open when ready.** Default communication is opening the MR in the browser once it's ready to look at — skip only on explicit opt-out ("just the link", "don't open").

> Read the `scm-create-description` reference for the shared description/title workflow, format templates, and writing style.
> Read the `scm-gitlab` reference for GitLab MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection.
> Read the `commit-trailers` reference for Linear/GitLab issue trailer selection. Use `closes <Linear-id>` for the single/final MR that should close a Linear issue; use `refs <Linear-id>` for partial, related, multi-MR, or unclear completion work.
> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.
> Read the `linear-state-transitions` reference for the auto-advance rules (target state, never-downgrade guard, id extraction, silent-with-report contract). Applied after the MR create/update succeeds.
> Read the `release-convention` reference to detect the repo's release automation (release-please, semantic-release, changesets, commitlint) and match the title/commits. semantic-release commonly runs from `.gitlab-ci.yml`; on a squash MR the title becomes the release commit, and breaking changes need `type(scope)!:` plus a `BREAKING CHANGE:` footer.

## Platform specifics

- **Find the MR** (when not given): get the current branch via `git status`, extract the GitLab project path from the remote, then `gitlab__list_merge_requests` with a `source_branch` filter and `state: opened`. See "Branch reuse" in the `scm-create-description` reference. If no open MR exists, ask the user before creating one. GitLab MCP has no creation tool today, so fall back to `glab mr create`.
- **Merge defaults (on create):** always pass `--remove-source-branch` to delete the source branch on merge. For squash, decide by commit count: if the branch is a single logical commit, pass `--squash-before-merge`; if it carries multiple meaningful commits (e.g. grouped by task), keep squash OFF so the separate commits survive the merge. If a GitLab MCP creation tool becomes available and accepts `squash` / `remove_source_branch`, set `remove_source_branch: true` and `squash` per the same rule. These are team defaults — do not prompt to confirm them each run; skip only if the user explicitly opts out in the same message that requests MR creation.
- **Match the release automation.** Detect the repo's release method per `release-convention`. semantic-release frequently runs from `.gitlab-ci.yml` — when present, the branch's commits (or, when the MR squashes, the MR title) must be valid Conventional Commits so the pipeline computes the right version; breaking changes need `type(scope)!:` plus a `BREAKING CHANGE:` footer. If the repo uses changesets, ensure the branch includes a changeset file before merge (offer to add one).
- **Analyze the MR:** read details via `gitlab__get_merge_request`, the full diff via `gitlab__get_merge_request_diffs`, and commit history via `gitlab__list_commits` filtered to the MR branch. Note the existing title and description.
- **Update the MR** (only after approval): update `title` (if changed) and the description via GitLab MCP tools, then confirm success. Once the MR is created/updated and ready to look at, by default open its web URL in the browser (e.g. via `hyprpilot__open`) — skip only if the user explicitly said not to ("just give me the link", "don't open it", "no browser").
- **Transition linked Linear issues to `In Review`:** after the MR create/update succeeds, follow the `linear-state-transitions` reference — extract Linear ids from the MR body (`refs K-xxx` / `closes K-xxx` trailers) and the branch's commit messages, fetch each id's current `statusType`, and call `save_issue` with `state: "In Review"` (skip when already `Done` / `Canceled` or already `In Review`; never downgrade). Report one line per issue touched: `Linear state: moved K-xxx → In Review (was Todo).` Silent-with-report — no prompt; the user opts out by saying "don't move the Linear state" in the MR-create request. Skip entirely when zero Linear ids are found — not every branch is tied to an issue.
