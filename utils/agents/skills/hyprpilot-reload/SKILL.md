---
name: hyprpilot-reload
description: hyprpilot-reload Reload the skill catalog after skill or reference files change on disk. Use on "reload skills", "refresh the catalog", or after writing a SKILL.md or reference. Not for editing skills, guidelines, or MCP config.
disableModelInvocation: true
---

## Hyprpilot Reload

Refresh the skills sidecar's view after the files on disk change. The catalog is cached at session start, so edits to `SKILL.md` or `references/*.md` are **not** visible until a reload.

## Tools

All on the in-tree skills MCP server (surfaced as `mcp__hyprpilot-skills__*`):

| Tool | Purpose |
|------|---------|
| `reload` | Rescan every skill directory from disk and rebuild the catalog. The one you almost always want. |
| `list_skills` | Enumerate the current (profile-filtered) catalog — names, descriptions, invocation flags. |
| `read_skill` | Fetch a single skill body by slug. |
| `list_skill_references` | The manifest of references a skill declares — paths, sizes, `modified`, no bodies. |
| `read_skill_references` | Fetch reference bodies by canonical path. |

## Reload fixes the sidecar, not your context

`reload` rescans disk and rebuilds the **sidecar's** catalog. (There is no daemon — `hyprpilot mcp skills` is a per-session child the vendor spawns and owns.) It does **not** rewrite anything already in this conversation. A skill you read earlier — via `read_skill`, via an attached `hyprpilot://skills/<slug>` resource, via a palette pick or auto-injection — is a **snapshot taken before the edit**, and it stays authoritative-looking in context while being wrong.

That is the failure this skill exists to prevent: reloading, seeing the count go up, and then continuing to follow the pre-edit copy of the very skill you just fixed.

**So a reload is two steps, always: rescan, then re-read everything this session has already loaded.**

## Process

1. **Reload.** Call `mcp__hyprpilot-skills__reload`. It returns `reloaded` (the skill count), `membershipChanged` (whether any skill was added or removed), and `updated` — **the slugs whose content actually changed**.
2. **Verify.** Confirm `reloaded` is what you expect (e.g. `+1` after adding a skill) and the call reported no errors.
3. **Re-read what is already loaded.** `updated` names exactly which skills changed, so start there: fetch each with `mcp__hyprpilot-skills__read_skill { slug }` and treat the newly returned body as authoritative and the earlier copy as void. Then cover anything else in this conversation whose source you touched — `updated` tracks skill bodies, so a reference edit shows up in the manifests rather than in that list.
   - **A reload also invalidates your loaded-path set.** Reference bodies you already hold are snapshots too. Compare each edited file's `modified` in the new manifest against when you fetched it, drop those paths from the set, and re-fetch them with `mcp__hyprpilot-skills__read_skill_references { references: [path] }`. The set is keyed on path, so a body that changed under the same path is exactly the case the set cannot notice on its own.
   - **A resource attached earlier is the riskiest case**, because it reads as current and there is no marker saying when it was fetched. Re-fetch it rather than trusting it.
   - If the catalog itself may have changed shape — a skill added, renamed, or deleted — re-read the catalogue too, so routing decisions are made against the new names rather than the old ones. The `hyprpilot://skills` resource is the whole index in one read; `mcp__hyprpilot-skills__list_skills` returns the same set as a tool call.
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
