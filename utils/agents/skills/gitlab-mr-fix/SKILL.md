---
name: gitlab-mr-fix
description: gitlab-mr-fix Work through the open discussions on a GitLab MR, applying the requested changes and replying to each thread. Use on "fix the MR comments", "address the feedback". Not for producing a review, for the MR description, or for GitHub pull requests.
disableModelInvocation: true
argumentHint: '[MR number or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/scm/scm-fix-threads.md
  - ../references/scm/scm-gitlab.md
  - ../references/scm/scm-detect.md
---

## GitLab MR Fix

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Thread-fixing workflow per `scm-fix-threads`. GitLab tooling and local git per `scm-gitlab`; platform detection per `scm-detect`.

## Report the threads as a ledger

One row per open thread, so it is checkable whether every reviewer got an answer — the part prose reliably drops:

| Thread | Asked for | Outcome | Replied | Resolved |
|---|---|---|---|---|
| `auth.ts:42` | use the shared validator | applied | yes | yes |
| `api.ts:88` | two possible approaches | asked the user | yes | no - awaiting choice |
| `old.ts:12` | concern about removed code | skipped, stale | yes | yes |

**Outcome** is one of: applied, asked the user, skipped as stale, or could not — never blank. **Replied** and **Resolved** are the only things the reviewer sees on the other end, so an unreplied row is unfinished work no matter what changed in the code.

## Platform specifics

- **Identify the MR** (when not given): use `git status` for the current branch, extract the project path from the remote URL, then `gitlab__list_merge_requests` with `source_branch` filter and `state: opened`. If none is open, inform the user and stop. Read MR metadata via `gitlab__get_merge_request`.
- **List open threads:** read all discussion threads on the MR via `gitlab__mr_discussions`, filtering to **unresolved** threads only. The file path and line range come from the diff position. Pending suggestions are GitLab `suggestion` blocks.
- **Reply to a thread:** add a note to the discussion via `gitlab__mr_discussions`.
- **Resolve a thread:** use `gitlab__mr_discussions` with the `resolved: true` parameter on the discussion.
