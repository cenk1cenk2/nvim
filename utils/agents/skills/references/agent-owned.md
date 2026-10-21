# Agent-Owned

A standing exception the captain scoped: an agent manages and cleans up what it created **in this session** without asking. It is the per-scope exception the central destructive-action gate allows, and it covers nothing outside the scope below.

## Proof of ownership — absolute

**Ownership is proven by your own record, never inferred.** Every agent acts under the captain's identity, so an author, assignee, label, branch name or timestamp proves nothing — the captain looks exactly like you.

A thing is owned only when all of these hold:

- **Created in this session** — by you, or by a subagent this session dispatched whose collected report handed the identifier back.
- **Recorded at creation** — you hold the id, URL or SHA the create call returned, from that call's own output, in this session's context.
- **Untouched by anyone else since** — re-read it before acting, in the same turn. Someone else's commit, review, reply, comment, edit or state change ends ownership.
- **Not protected or shared** — never the default branch, `main`, `master`, `rolling`, `develop` or `trunk`; never something you only edited, commented on or were assigned.

Ownership does not survive the session. A resumed, handed-off or later session treats everything as the captain's until it creates it anew.

Any condition fails, or you cannot prove one, and it is not owned — the normal gate applies. Doubt is a no.

## Free, no confirmation

| Owned thing | Free |
|---|---|
| Branch | Rebase, `rebase --onto` to repair a stack, amend, squash fixups; resolve the conflicts the rebase raises, then run the project's checks; push with `--force-with-lease=<branch>:<last SHA you pushed>` and report the old and new head. |
| PR/MR | Retarget its base after a stack moves, close it when a replacement supersedes it. Opening one, its title and description, and draft or ready status always wait for the user's approval of the draft — an explicit skill invocation does not clear it; a completion skill such as `agent-bohrhammer` that the user invoked does. |
| CI on an owned branch | Retry a failed job or pipeline, cancel pipelines a newer push made obsolete, stop or delete its review-app environment. |
| Comment (PR/MR, Linear, Slack) | Edit it; delete it while it has no replies. |
| Stash entry | Pop or drop it. |
| Linear issue | Fix its fields, relink it, cancel it as a duplicate you made. |
| Worktree, scratch file, plan | Remove it, once the cleanup rule below holds. |
| tmux window, watcher | Stop it. |
| Artifact, Obsidian note, Notion page | Edit it; delete it while nobody else has opened, edited or commented on it. |

**Cleanup waits for merged and finished.** Delete a branch (`-D` included, since a squash merge looks unmerged to git), its worktree, its plan and its scratch data only once its PR/MR merged and its agent delivered and was collected.

## Still gated

- **Plain `--force`.** Never.
- **A conflict whose resolution is a design choice** — stop and present both sides.
- **Discarding uncommitted work** — a dirty-tree force-remove, `reset --hard` over local changes.
- **Merging a PR/MR.** Local merges of the run's own branches, as in a plan layer, are free.
- **Linear project and initiative writes** follow `linear-absolute-approval`.
- **Deleting an owned thing before its work merged** — branch, worktree or data of work still open, closed unmerged, or never opened.
- **A bulk operation that also reaches what is not owned** — present the dry-run.
- **Live clusters** — Kubernetes and ArgoCD resources gate per their own skills, owned or not.
