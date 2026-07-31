# Scoped Commit & Push

Handoff for any skill that edits files in a repository and then commits them: commit
and push **only what this run touched**, gated on the user's word. Read it after the
edits are written and any post-write verification (reload, format, lint) succeeded.

The calling skill decides the target branch and the commit scope, and states both in
its own directive. This reference decides the gate, the staging scope, and how the
protected-branch ack is resolved.

## Gate

- **Default — ask once.** After reporting what changed, ask a single line:
  "Commit and push to `<branch>`?" Do not commit unprompted.
- **Upfront blessing — skip the ask.** When the request already authorized it
  ("adjust this and push", "change it and push", "... and push it", or `g` / `go` /
  `y` / `yolo` on a request that included pushing), commit and push directly, then
  report.
- **Blessing is scoped to this run.** It covers the files this run touched and
  nothing else; it does not carry to a later, separate change.
- If the user declines, leave the edits uncommitted in the working tree and say so.

## Staging — only what this run touched

⛔ **Never `git add .` here.** The edited files usually share a repository with
unrelated work, and staging everything sweeps up changes that are not yours.

- Stage explicit paths only — every file this run created or edited, and no other.
- Run `git status --short` before staging; confirm the staged set after with
  `git diff --staged --name-only`. It must equal your touched-file list exactly.
- Never `git add -A`, `git add -u`, or `git commit -a`. Never stash, checkout, reset,
  or revert changes you did not make.
- Untouched dirty files stay dirty. Mention them in the report, do not act on them.

## Flow

1. Compose with `git-commit`, handing it the explicit touched paths so it skips its
   default `.` staging, and the commit scope the calling skill named. Match the
   repo's history for type and subject style.
2. Compose with `git-push`. Target the branch the calling skill named; default to the
   current branch when it named none.
3. **Protected-branch ack.** `git-push` stops on protected branches (`main`,
   `master`, `rolling`, `develop`, `trunk`). The user's push blessing — or their
   answer to the default ask above — **is** that ack. Do not ask a second time.
4. Report the commit subject, the short sha, and the push result. If any unrelated
   file was left uncommitted, say so.
