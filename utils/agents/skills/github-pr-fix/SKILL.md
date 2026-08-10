---
name: github-pr-fix
description: github-pr-fix Work through the open review conversations on a GitHub PR, applying the requested changes and replying to each thread. Use on "fix the PR comments", "address the feedback". Not for producing a review, for the PR description, or for GitLab merge requests.
disableModelInvocation: true
argumentHint: '[PR number or URL]'
references:
  - ../references/reconcile-state.md
  - ../references/scm-fix-threads.md
  - ../references/scm-github.md
  - ../references/scm-detect.md
---

## GitHub PR Fix

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Run the thread-fixing workflow per `scm-fix-threads`, with GitHub MCP tools per `scm-github` and platform detection plus local git (raw `git` CLI) per `scm-detect`.

## Report the threads as a ledger

One row per open thread, so it is checkable whether every reviewer got an answer — the part prose reliably drops:

| Thread | Asked for | Outcome | Replied | Resolved |
|---|---|---|---|---|
| `auth.ts:42` | use the shared validator | applied | yes | yes |
| `api.ts:88` | two possible approaches | asked the user | yes | no - awaiting choice |
| `old.ts:12` | concern about removed code | skipped, stale | yes | yes |

**Outcome** is one of: applied, asked the user, skipped as stale, or could not — never blank. **Replied** and **Resolved** are the only things the reviewer sees on the other end, so an unreplied row is unfinished work no matter what changed in the code.

## Platform specifics

- **Identify the PR** (when not given): use `git status` for the current branch, extract owner/repo from the remote URL, then `github__list_pull_requests` with `head: "owner:branch"` and `state: open`. If none is open, inform the user and stop. Read PR metadata via `github__pull_request_read` (method: `get`).
- **List open threads:** read all review comments and conversation threads on the PR, filtering to **unresolved/open** threads only. Pending suggestions are GitHub `suggestion` blocks.
- **Reply to a thread:** post the reply to the thread via the GitHub review-comment tools (see `scm-github`).
- **Resolve a thread — requires GraphQL** (the MCP tools do not expose this). Use `gh api graphql` as fallback:
  1. Get thread IDs: `gh api graphql -f query='query { repository(owner:"OWNER", name:"REPO") { pullRequest(number:N) { reviewThreads(first:50) { nodes { id isResolved comments(first:1) { nodes { body } } } } } } }'`
  2. Resolve each thread: `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'`

  Batch all thread IDs when collecting open threads so you only need one query, then resolve after fixes are applied.
