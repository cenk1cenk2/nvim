---
name: editor-open
description: editor-open Open a repo root, worktree, or branch in a new nvim window in the captain's tmux session, launched through zsh. Use on "open this in the editor", "show me this branch", "open the worktree in nvim". Not for reading a file yourself, which the editor MCP already serves.
disableModelInvocation: true
argumentHint: "[branch | path | file]"
references:
  - ../references/tmux.md
  - ../references/agent/agent-worktrees.md
---

## Context

Window creation is a `tmux` CLI job through `Bash` — the tmux MCP's write tools are disabled, and `tmux__*` stays read-only inspection per `tmux`.

The captain's editor is the destination, not a second one of yours. Reading a file, finding a symbol, or showing a set of locations belongs to `hyprpilot-nvim`; this skill is for putting a whole tree in front of them in its own window.

## Process

1. **Resolve the session from your own pane.**

   ```
   session=$(tmux display-message -t "$TMUX_PANE" -p '#S')
   session=${session%%/*}
   ```

   > **ABSOLUTE — pass `-t "$TMUX_PANE"`.** With no target, `display-message` answers for the attached client's *active* window, which is whatever the captain is looking at, not where you are running. The `%%/*` strip sends the window to the main session when you are inside a popup session (`root/nvim//path/nvim`), per the naming map in `tmux`.

2. **Resolve the directory.** First match wins, and it must be absolute:

   - An explicit path in the request — use it.
   - Nothing named — `git rev-parse --show-toplevel` from the working directory.
   - A branch named — `wt list --format=json`, match `items[].branch`, take that item's `worktree.path`. The main worktree carries `"main": true`; a branch checked out there opens the repo root.
   - A branch with no worktree — create one per `agent-worktrees`: `wt switch <branch> --no-cd` for a branch that already exists, `wt switch --create <branch> --base @ --no-cd` for one that does not. Confirm before creating a **new** branch; an existing branch just gets its tree. Re-read `wt list --format=json` for the resulting path.

   Verify the directory exists before opening. A path that does not resolve is a stop, not a guess.

3. **Reuse before creating.**

   ```
   tmux list-windows -t "$session:" -F '#I #{pane_current_path} #{pane_current_command}'
   ```

   A window already at the target path running `nvim` gets `tmux select-window -t "$session:<index>"`. Two editors on one tree fight over swap files.

4. **Open it.**

   ```
   tmux new-window -t "$session:" -c "<dir>" 'zsh -ic nvim'
   ```

   - **Through zsh, never `nvim` directly.** The rc files supply the mise shims and the captain's environment. tmux builds the new window from the server environment, so nothing from your own session leaks into it.
   - **No `-n`.** The editor renames its window to `nvim@<dir>` on `VimEnter`, matching every other window; passing a name turns `automatic-rename` off and breaks that.
   - **Foreground — no `-d`.** The captain asked to be taken there, and the new window being current is what keeps the editor's own rename on target.
   - A file instead of a tree: `'zsh -ic "nvim <file>"'`, or `'zsh -ic "nvim +<line> <file>"'` for a position.

5. **Report one line** — window index, name, and the path it opened, plus the worktree you created if you created one. Removing it later is `wt remove <branch>`, and it is the captain's call, not yours.

## Key Principles

- **Their terminal.** One window per request, in the foreground, and nothing killed or renamed that you did not create.
- **Resolve, never assume.** The session comes from your own pane and the path from `wt` or `git`, both read before anything is opened.
- **`wt` owns worktree placement** — never hand `tmux` a path you computed yourself.
