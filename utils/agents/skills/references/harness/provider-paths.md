# Provider Paths

Where each agent runtime keeps its state and plans, and where its native worktrees land. Skills speak generically ("your internal plans directory"); resolve the concrete path for the active runtime here. Values are researched from each tool's source — keep in sync if upstream changes.

| Runtime | State / home dir | Internal plans directory | Native worktree location (not used) |
|---------|------------------|--------------------------|--------------------------------------|
| Claude Code | `~/.claude/` | `~/.claude/plans/` | `<project>/.claude/worktrees/<name>/`, or wherever a `WorktreeCreate` hook puts it |
| OpenCode | `~/.local/share/opencode/` (data), `~/.config/opencode/` (config) | `~/.local/share/opencode/plans/` | `~/.local/share/opencode/worktree/<projectID>/<name>` (branch `opencode/<name>`) |
| Codex | `~/.codex/` | `~/.codex/plans/` | `$CODEX_HOME/worktrees/` (`--worktree`, detached `HEAD`) |
| Other | the runtime's own state dir | `<state-dir>/plans/` | none |

## Notes

- **Plans folders are this setup's convention.** Only Claude Code ships a native plans directory. OpenCode persists session state as JSON under `data/storage/` and Codex under `~/.codex/sessions/`, but neither has a dedicated on-disk "plans" folder — the plans paths above are chosen so plan files stay durable and discoverable per runtime.
- **Filename default:** `YYYY-MM-DD-<project>-<name>.md`. Whatever the runtime actually writes is fine; the date-project-name shape is just the default.
- **Worktrees:** every agent worktree is placed by `wt` per `agent-worktrees`, on every runtime. The native column is for recognising a tree something else created; the fallback location when `wt` is unavailable is `command-wt`'s.
