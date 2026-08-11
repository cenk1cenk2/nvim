---
name: hyprpilot-reload
description: hyprpilot-reload Reload the skill catalog after skill or reference files change on disk. Use on "reload skills", "refresh the catalog", or after writing a SKILL.md or reference. Not for editing skills, guidelines, or MCP config.
disableModelInvocation: true
---

## Hyprpilot Reload

Refresh the skills sidecar's view after the files on disk change. The catalog is cached at session start, so edits to `SKILL.md` or `references/*.md` are **not** visible until a reload.

## Tools

All on the in-tree skills MCP server (surfaced as `mcp__hyprpilot_skills__*`):

| Tool | Purpose |
|------|---------|
| `reload` | Rescan every skill directory from disk and rebuild the catalog. The one you almost always want. |
| `list_skills` | Enumerate the current (profile-filtered) catalog — names, descriptions, invocation flags. |
| `read_skill` | Fetch a single skill body by slug. |
| `load_skill_references` | Bundle the references a skill declares in frontmatter. |

## Reload fixes the sidecar, not your context

`reload` rescans disk and rebuilds the **sidecar's** catalog. (There is no daemon — `hyprpilot mcp skills` is a per-session child the vendor spawns and owns.) It does **not** rewrite anything already in this conversation. A skill you read earlier — via `read_skill`, via an attached `hyprpilot://skills/<slug>` resource, via a palette pick or auto-injection — is a **snapshot taken before the edit**, and it stays authoritative-looking in context while being wrong.

That is the failure this skill exists to prevent: reloading, seeing the count go up, and then continuing to follow the pre-edit copy of the very skill you just fixed.

**So a reload is two steps, always: rescan, then re-read everything this session has already loaded.**

## Process

1. **Reload.** Call `mcp__hyprpilot_skills__reload`. It returns the reloaded skill count.
2. **Verify.** Confirm the count is what you expect (e.g. `+1` after adding a skill) and the call reported no errors.
3. **Re-read what is already loaded.** Enumerate every skill whose content is in this conversation — the ones you edited, and any others loaded earlier this session — and fetch each again with `mcp__hyprpilot_skills__read_skill { slug }`. Do the same with `mcp__hyprpilot_skills__load_skill_references { slug }` for any skill whose references changed. Treat the newly returned body as authoritative and the earlier copy as void.
   - **A resource attached earlier is the riskiest case**, because it reads as current and there is no marker saying when it was fetched. Re-fetch it rather than trusting it.
   - If the catalog itself may have changed shape — a skill added, renamed, or deleted — re-read the catalogue too, so routing decisions are made against the new names rather than the old ones. The `hyprpilot://skills` resource is the whole index in one read; `mcp__hyprpilot_skills__list_skills` returns the same set as a tool call.
   - Skip nothing on the grounds that "the edit was small". The whole point of re-reading is that you cannot tell from context which copy you are holding.
4. **Report** the reload result to the user: the count, which skills were re-read, and anything that failed to resolve.

## When to Use

- After creating, editing, renaming (`git mv`), or deleting a `SKILL.md`.
- After adding or editing a shared `references/*.md` file that skills depend on.
- When `list_skills` doesn't show a skill you know exists on disk — the catalog is stale; reload.
- Before acting on a skill you edited earlier in this session, even if you already reloaded once — re-read it first (step 3), because a later edit invalidates the copy again.

## Boundaries

- **Skills only.** `reload` refreshes the skill catalog. It does **not** re-inject the system-prompt files (`AGENTS.md`) — those propagate on the next session, not via reload.
- **Daemon-side only.** It cannot reach into this conversation and update a body you already loaded — that is what step 3 is for. Anything read before the reload is stale until re-read.
- **Non-destructive.** Reloading only rescans disk; it never edits or deletes skill files.
