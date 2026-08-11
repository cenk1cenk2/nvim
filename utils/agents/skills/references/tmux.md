# tmux

Read-only inspection of the captain's live tmux sessions — which session is which, which tool to reach for, and how to keep a capture from flooding context. Read this before the first tmux call in a session that inspects panes.

## MCP First — Read With `tmux__*`, Execute With `Bash`

Two different jobs, two different tools, no overlap:

- **Inspecting what already exists** — sessions, windows, panes, and the output sitting in them: use the `tmux__*` MCP tools. They return structured results, need no shell quoting, and cost fewer round-trips than a `tmux` CLI call parsed out of stdout.
- **Running anything** — builds, tests, lints, git, reproductions: use the built-in `Bash` tool. The tmux MCP's write tools (`execute-command`, `create-window`, `split-pane`, `kill-*`, `create-session`) are disabled, so an instruction to "run it in the scratch pane" cannot execute. Run it with `Bash` and read the result there.

Raw `tmux` CLI via `Bash` is correct in exactly two cases:

1. **The MCP exposes no equivalent** — notably the *current* session/pane, which has no MCP tool: `tmux display-message -p '#S'`, or the `$TMUX` / `$TMUX_PANE` env vars.
2. **The MCP is absent** from the session (dropped by the active profile). Fall back quietly, no ceremony.

Anything else — listing, finding, capturing — goes through the MCP.

## Read-Only Tool Inventory

| Tool | Use |
|------|-----|
| `tmux__list-sessions` | Every session, with names. The entry point when you don't know what exists. |
| `tmux__find-session` | Resolve one session by exact name — cheaper than listing when the name is known. |
| `tmux__list-windows` | Windows in a session (takes `sessionId`). |
| `tmux__list-panes` | Panes in a window (takes `windowId`). |
| `tmux__capture-pane` | Pane contents (takes `paneId`, optional `lines`, `colors`). |
| `tmux__get-command-result` | Result of an already-executed command by `commandId`. |

## Context Guard on Capture

`tmux__capture-pane` returns raw scrollback, and a long-running build or test pane holds thousands of lines. A full-history capture as the opening move is how a tmux read bloats a context window.

- Bound every capture with `lines` — start at the tail (`lines: "200"`), widen only when the error is demonstrably above it.
- Leave `colors` off unless the escape sequences are the thing being diagnosed; they roughly double the payload for no added meaning.
- Capture one pane, not every pane. Narrow with `list-panes` first when the window has several.
- When a targeted `Bash` re-run would produce the same answer in twenty lines, prefer that over capturing a noisy pane.

## Anchor to the Captain's Own Session First

Whether the agent runs inside Neovim (via `hyprpilot_nvim`) or directly under hyprpilot, it shares the captain's tmux session. Find that one before looking at any other:

1. Identify it from the shell — `$TMUX`, `$TMUX_PANE`, or `tmux display-message -p '#S'` (the one place CLI beats MCP).
2. Scope from there with `tmux__find-session` / `tmux__list-windows` / `tmux__list-panes`.
3. Branch to another session only when the current one does not hold what the captain meant.

## Session Naming Map

Popup sessions are spawned by `tmux-toggle-popup`, so their names encode where they came from. As they appear in `tmux__list-sessions` (`<session>` is the captain's outer session name, commonly `root`):

| Session name | What it is |
|--------------|------------|
| `<session>` | The captain's main session — their real windows and panes. |
| `<session>/scratch` | **The general overlay.** A prefix-bound scratch popup, not tied to any editor instance. The default place a one-off command was run by hand. |
| `<session>/nvim/<cwd>/nvim` | The terminal overlay of the Neovim instance rooted at `<cwd>`, toggled with `<F1>`. One per open editor. |
| `<session>/nvim/<cwd>/<tool>` | A tool popup that instance opened — `lazygit`, `lazydocker`, `k9s`, `yazi`, `log`, and similar. |

Note the doubled slash in real names: `<cwd>` is absolute, so the nvim overlay for `/home/user/proj` reads `root/nvim//home/user/proj/nvim`.

## Which Terminal the Captain Means

Both `<session>/scratch` and `<session>/nvim/<cwd>/nvim` are scratch terminals. Resolve between them by this rule, not by asking:

1. **The editor's own overlay wins by default** — when a `<session>/nvim/<cwd>/nvim` exists for the repo in play, that is the terminal the captain means.
2. **The general overlay when they name it** — "general scratch popup", "scratch", or any wording pointing away from the editor means `<session>/scratch`.
3. **No editor overlay, no ambiguity** — with no `.../nvim` session present, `<session>/scratch` is the only scratch terminal.
