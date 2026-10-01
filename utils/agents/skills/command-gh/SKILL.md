---
name: command-gh
description: command-gh When to run the gh CLI rather than the GitHub MCP server, and how to build and maintain native PR stacks with the gh-stack extension. Load before running `gh`, or before opening a stack of PRs. Not for PR or issue work the GitHub MCP server already does.
references:
  - ../references/scm/scm-github.md
---

## Route

- **The GitHub MCP server first** for PRs, issues, reviews, branches and file reads; tool surface per `scm-github`.
- **`gh` for what the server cannot do**: workflow runs and their logs, a stack, an output the server cannot return, a bulk job that would cost dozens of calls. Say in one line what the server was missing.
- **Writes gate like any external write**: summarize the change and wait unless the user already cleared that class of write. Reads never gate.

## Stacks — `gh stack`

Native stacks come from the official extension `github/gh-stack`. Load `github-pr-create` before opening any stacked PR; its title, description and merge conventions apply to every layer.

1. **Check presence** with `gh extension list`; `gh stack --help` printing an install hint also means it is missing.
2. **Missing**: never install it. Say it is unavailable and stack with plain PRs whose `base` is the layer below.
3. **Present**:
   - Build layers with `gh stack init [-b <base>]` then `gh stack add [-A|-u] [-m <msg>] [<branch>]`, or adopt existing branches with `gh stack init <branches...>`.
   - Push and open the PRs as a linked stack with `gh stack submit --auto` (non-interactive). Titles are auto-generated, so afterwards bring every PR's title and description up to those conventions with `github__update_pull_request`.
   - Link branches made outside gh-stack with `gh stack link <branches-or-PRs...>`.
   - Keep it current with `gh stack rebase [--downstack|--upstack]`, `gh stack push`, `gh stack sync [--prune]`.
   - Read it with `gh stack view --json`.
4. **Never run `gh stack merge`**: merging is the user's. Never pass a squash method to any merge of a stack layer.

`submit`, `link`, `push` and `sync` write to the remote, so each gates as an external write.

## Exit Codes

| Code | Meaning | Action |
|---|---|---|
| 0 | Success. | Continue. |
| 2 | Not in a stack. | Check out a stack branch, or `gh stack init` to start or adopt one. |
| 3 | Rebase conflict. | Resolve the conflicted files, then `gh stack rebase --continue`; `--abort` when the user would rather back out. |
| 4 | API failure. | Check `gh auth status`, retry once, then report the error. |
| 5 | Bad arguments. | Fix the invocation against `--help`; do not retry it unchanged. |
| 6 | Disambiguation needed. | Re-run naming the branch or PR explicitly. |
| 7 | Rebase in progress. | Finish it with `--continue` or `--abort` before any other stack command. |
| 8 | Locked. | Another `gh stack` operation holds the stack; wait for it, then retry once. |

## Failure Modes

- **`gh` not authenticated** — `gh auth status` names the host; report it rather than switching accounts.
- **`gh` not on `PATH`** — resolve it per `AGENTS.md` §IV mise.
