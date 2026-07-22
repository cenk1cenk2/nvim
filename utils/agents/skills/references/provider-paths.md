# Provider Paths

Where each agent runtime keeps its state, plans, and git worktrees. Skills speak generically ("your internal plans directory", "the agent worktrees directory"); resolve the concrete path for the active runtime here. Values are researched from each tool's source — keep in sync if upstream changes.

| Runtime | State / home dir | Internal plans directory | Agent worktrees directory |
|---------|------------------|--------------------------|----------------------------|
| Claude Code | `~/.claude/` | `~/.claude/plans/` | `<project>/.claude/worktrees/<name>/` (harness default) |
| OpenCode | `~/.local/share/opencode/` (data), `~/.config/opencode/` (config) | `~/.local/share/opencode/plans/` | native worktree isolation places these under `~/.local/share/opencode/worktree/<projectID>/<name>` (branch `opencode/<name>`) |
| Codex | `~/.codex/` | `~/.codex/plans/` | no native worktree feature — create manually under `<project>/.agents/worktrees/<name>/` |
| Other | the runtime's own state dir | `<state-dir>/plans/` | `<project>/.agents/worktrees/<name>/` |

## Notes

- **Plans folders are this setup's convention.** Only Claude Code ships a native plans directory. OpenCode persists session state as JSON under `data/storage/` and Codex under `~/.codex/sessions/`, but neither has a dedicated on-disk "plans" folder — the plans paths above are chosen so plan files stay durable and discoverable per runtime.
- **Filename default:** `YYYY-MM-DD-<project>-<name>.md`. Whatever the runtime actually writes is fine; the date-project-name shape is just the default.
- **Worktrees:** if the runtime has native worktree isolation (Claude Code, OpenCode), use its default location and verify the path the dispatch tool returns. Otherwise create worktrees manually under `<project>/.agents/worktrees/`. Ensure the worktrees directory is gitignored.
