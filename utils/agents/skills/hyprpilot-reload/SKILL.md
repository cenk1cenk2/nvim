---
name: hyprpilot-reload
description: Reload and refresh the hyprpilot skill catalog after skill or reference files change on disk. Use when user says "reload skills", "refresh skills", "hyprpilot-reload", "pick up the new skill", or after creating/editing/moving/deleting a SKILL.md or a shared reference. Do NOT use to edit a skill (/config-skills), the central guidelines (/config-agents), or MCP server config (/config-mcp).
disable-model-invocation: true
---

## Hyprpilot Reload

Refresh the daemon's view of skills after the files on disk change. The catalog is cached at session start, so edits to `SKILL.md` or `references/*.md` are **not** visible until a reload.

## Tools

All on the in-tree `hyprpilot` MCP server (surfaced as `mcp__hyprpilot__*`):

| Tool | Purpose |
|------|---------|
| `reload` | Rescan every skill directory from disk and rebuild the catalog. The one you almost always want. |
| `list_skills` | Enumerate the current (profile-filtered) catalog — names, descriptions, invocation flags. |
| `read_skill` | Fetch a single skill body by slug. |
| `load_skill_references` | Bundle the references a skill declares in frontmatter. |

## Process

1. **Reload.** Call `mcp__hyprpilot__reload`. It returns the reloaded skill count.
2. **Verify.** Confirm the count is what you expect (e.g. `+1` after adding a skill) and the call reported no errors.
3. **Spot-check when practical.** For a skill you just changed, re-read it with `mcp__hyprpilot__read_skill { slug }` to confirm the daemon sees the latest body; if references changed, `mcp__hyprpilot__load_skill_references { slug }` to confirm they resolve.
4. **Report** the reload result to the user (count, and anything that failed to resolve).

## When to Use

- After creating, editing, renaming (`git mv`), or deleting a `SKILL.md`.
- After adding or editing a shared `references/*.md` file that skills depend on.
- When `list_skills` doesn't show a skill you know exists on disk — the catalog is stale; reload.

## Boundaries

- **Skills only.** `reload` refreshes the skill catalog. It does **not** re-inject the system-prompt files (`AGENTS.md`) — those propagate on the next session, not via reload.
- **Non-destructive.** Reloading only rescans disk; it never edits or deletes skill files.
