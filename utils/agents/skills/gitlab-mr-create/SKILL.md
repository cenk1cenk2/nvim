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
  - ../references/scm/scm-linear-follow-up.md
  - ../references/output-diff.md
  - ../references/scm/release-convention.md
  - ../references/scm/scm-change-kind.md
  - ../references/delivery-decisions.md
  - ../references/identifier-legibility.md
  - ../references/open-artifact.md
  - ../references/agent-owned.md
argumentHint: '[optional: MR number or URL]'
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`.

## GitLab MR Description Workflow

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
> **Open when ready.** Default communication is opening the MR in the browser once it's ready to look at — skip only on explicit opt-out ("just the link", "don't open").

Description/title workflow, format templates, and writing style per `scm-create-description`. GitLab tooling, local git, CLI fallback, and platform detection per `scm-detect` and `scm-gitlab`.

Check every linked issue's `statusType` first, per `scm-linear-follow-up`. For open work, issue trailers per `commit-trailers` — **if this MR closes the issue, write `closes`**; `References` (or `Part of`) only for genuinely partial work. Linear's GitLab keywords and multi-issue form per `commit-trailers-linear`; a native GitLab issue (`#NUMBER`) closes on the same default with GitLab's keyword list and cross-project syntax per `commit-trailers-gitlab`. **Linear on GitLab ignores commit messages entirely**, so the title, description, and branch are the only things carrying the link.

## Platform specifics

- **An owned PR/MR may be retargeted or closed when superseded without asking**, per `agent-owned`; opening it, its title and description, and draft or ready status still wait for approval of the draft.
- **Find the MR** (when not given): get the current branch via `git status`, extract the GitLab project path from the remote, then `gitlab__list_merge_requests` with a `source_branch` filter and `state: opened`. See "Branch reuse" in `scm-create-description`. If no open MR exists, ask the user before creating one, then create it with `gitlab__create_merge_request`.
- Load `command-glab` for stacks; it falls back to the target-branch route below.
- **Cascading MRs — target the prerequisite branch, not trunk.** When the branch was cut from another branch whose MR is still open (per `git-branch`), pass `--target-branch <prerequisite>` on create. The MR then shows only its own diff instead of re-reviewing the prerequisite. **GitLab retargets on merge**, and the docs are explicit that deletion is not the trigger: *"Selecting Remove source branch after merging does not retarget open merge requests"* — so the `--remove-source-branch` default below neither helps nor hurts here. **The limit is four open MRs** updated per merge; beyond that, retarget the rest by hand. State the target and the prerequisite in your report; an MR whose target looks like an accident gets merged into the wrong place.
- **Merge defaults (on create):** always pass `--remove-source-branch` to delete the source branch on merge. For squash, decide by commit count: if the branch is a single logical commit, pass `--squash-before-merge`; if it carries multiple meaningful commits (e.g. grouped by task), keep squash OFF so the separate commits survive the merge. A fast second opinion on single versus multiple per `delivery-decisions`. `gitlab__create_merge_request` takes both: set `remove_source_branch: true` and `squash` per the same rule. These are team defaults — do not prompt to confirm them each run; skip only if the user explicitly opts out in the same message that requests MR creation. **Inside a stack, squash is OFF on every MR in it, the top included**, whatever its commit count: a squash rewrites the commits the dependent branch carries (recovery per `git-branch`). Only a project that enforces squash overrides this, and each MR description says so. `--remove-source-branch` stays on; GitLab retargets on merge regardless.
- **Match the release automation.** Detect the repo's release method per `release-convention` — **semantic-release is the default here** (release-please, changesets and commitlint are the alternates). It runs from `.gitlab-ci.yml`, via the `devops/pipelines` `semantic-release/publish.gitlab-ci.yml` component or the `cenk1cenk2/pipe-semantic-release` image — when present, the branch's commits (or, when the MR squashes, the MR title) must be valid Conventional Commits so the pipeline computes the right version; breaking changes need `type(scope)!:` plus a `BREAKING CHANGE:` footer. A fast second opinion on the type and on breaking per `scm-change-kind`. If the repo uses changesets, ensure the branch includes a changeset file before merge (offer to add one).
- **Analyze the MR:** read details via `gitlab__get_merge_request`, the full diff via `gitlab__get_merge_request_diffs`, and commit history via `gitlab__list_commits` filtered to the MR branch. Note the existing title and description.
- **Update the MR** (only after approval): update `title` (if changed) and the description via GitLab MCP tools, then confirm success. Once the MR is created/updated and ready to look at, open its web URL per `open-artifact`, unless the user said not to ("just give me the link", "don't open it", "no browser").
- **Linear state rides on the trailers.** The `closes` / contributing trailers in the approved description link the issues, and Linear's own integration moves them per the workspace's workflow; make no separate `save_issue` call.
