---
name: git-manual
description: 'git-manual Session-persistent "skip the ceremony" mode - implement inline on the current branch and leave all version control to the user; overrides prior instructions to branch/commit/push/PR. Triggers: "manual mode", "no branch", "no commit", "I''ll handle git". Do NOT use to create a branch (git-branch), commit (git-commit), or draft a PR/MR (github-pr-create, gitlab-mr-create).'
disableModelInvocation: true
---

## Git Manual

## What This Mode Does

When active, the agent:

- Implements requested changes by editing files directly (Edit / Write / `hyprpilot-nvim__editor_format`).
- Stays on the **currently checked-out branch**. Does not propose, create, or switch branches.
- Does **not** stage or commit changes. Leaves the working tree dirty for the user to review and commit themselves.
- Does **not** push. Does **not** open or update PRs/MRs.
- **Ignores prior instructions** to branch / commit / push / open PRs that came from `AGENTS.md`, an earlier turn in the conversation, a loaded plan, or another skill's description.

The user owns version control while this mode is active — the agent only edits.

## Suppressed Skills

While this mode is active, the agent does **not** auto-invoke any of:

- `git-branch` (no new branches).
- `git-commit` (no commits, no staging unless the user explicitly stages).
- `git-push` (no pushes).
- `github-pr-create` (no GitHub PR drafts).
- `gitlab-mr-create` (no GitLab MR drafts).

Composite phrases route the same way:

- "implement X and commit" → implement X, **drop the commit step**.
- "fix this and open a PR" → fix it, **drop the PR step**.
- "make a branch and add Y" → add Y on the current branch, **drop the branch step**.

## Explicit User Requests Win

If the user explicitly asks for one of the suppressed actions while the mode is active — by skill name (`/git-commit`, `/github-pr`) or by unambiguous direct command ("commit this now", "push this", "open the PR for me") — comply, but report briefly: _"Manual mode is active — committing because you asked explicitly."_ The mode stays on for subsequent turns.

## What This Mode Does NOT Affect

- File edits, refactors, deletions, formatting, renames (`hyprpilot-nvim__lsp_rename`), and tests run normally.
- Reading code, running builds and test suites, querying diagnostics, exploring the codebase.
- Memory updates, knowledge-base updates, Linear / Obsidian / Slack / GitHub-issue interactions unrelated to PR/MR creation.
- Replying to existing PR/MR review comments via `github-pr-fix`, `gitlab-mr-fix`, `github-pr-comment`, `gitlab-mr-comment`. These are not suppressed — but if their workflow needs a commit or push, the agent asks the user first instead of acting.
- Conflict resolution (`git-conflict`), CI fixes (`github-ci-fix`, `gitlab-ci-fix`) — same rule: do the work, stop before any write to remote.

## Activation

When invoked, announce the mode briefly:

> _"Manual mode active. Edits will be inline on `<current-branch>`. No branches, commits, or PR drafts unless you explicitly ask."_

Then continue with whatever the user asked next. Do not require additional confirmation.

## Exit

User says any of: "exit manual", "stop manual", "manual off", "normal mode", "back to normal" → mode off, default behavior resumes.

The mode otherwise persists until the session ends.

## Boundaries

- This mode does not delete branches, drop commits, reset history, or undo previous actions. It only changes what the agent does **going forward**.
- It does not silence safety prompts. Destructive operations (force-push, branch deletion, `git reset --hard`, etc.) still require confirmation.
- It does not override the rule against `Co-authored-by:` trailers, AI-attribution lines, or any other hard rule from `git-commit`'s commit-style reference — those apply if the user explicitly asks for a commit while the mode is active.
