---
name: hyprpilot-reload
description: hyprpilot-reload Re-read the skills and references you already hold once they change on disk, so you stop following a pre-edit copy. Use when a change notification arrives, when a `modified` stamp is newer than your read, or after writing a SKILL.md or reference yourself. Not for editing skills, guidelines, or MCP config.
disableModelInvocation: true
---

## Hyprpilot Reload

The skills sidecar watches every root. An edit to a `SKILL.md` or a `references/*.md` is rescanned within a debounce window and announced as `resources/updated` (per affected skill) plus `resources/list_changed`. The catalog keeps itself current with nothing asked of you.

Your context does not. That is the whole subject of this skill.

## What refreshes, and what does not

A rescan rebuilds the **sidecar's** catalog. It cannot rewrite anything already in this conversation. A skill you read earlier — via `read_skill`, via an attached `hyprpilot://skills/<slug>` resource, via a palette pick or auto-injection — is a **snapshot taken before the edit**, and it stays authoritative-looking in context while being wrong.

hyprpilot never pushes a changed body into your context, deliberately. So a notification is a signal to act on, not the act.

**The rule: when a skill or reference you hold changes on disk, re-read it.**

## Triggers

Any one of these means something you hold may be stale:

- A `resources/updated` or `resources/list_changed` notification arrives.
- A `modified` stamp in a `list_skills`, `read_skill`, or `list_skill_references` result is newer than when you read that path.
- You wrote or edited a `SKILL.md` or a `references/*.md` earlier in this session.
- The captain says they changed something.

This is a mandatory trigger, not a judgment call — `AGENTS.md` §I, "A Changed Guidance File Re-Grounds You".

## Process

1. **Re-read the changed skill.** `mcp__hyprpilot-skills__read_skill { slug }`. Treat the newly returned body as authoritative and the earlier copy as void.
2. **Re-fetch changed references.** A change invalidates your loaded-path set too — reference bodies you hold are snapshots. Compare each file's `modified` in the current manifest against when you fetched it, drop those paths from the set, and re-fetch with `mcp__hyprpilot-skills__read_skill_references { references: [path] }`. The set is keyed on path, so a body that changed under the same path is exactly the case it cannot notice on its own.
3. **Re-read an attached resource rather than trusting it.** This is the riskiest case: it reads as current and carries no marker saying when it was fetched.
4. **Re-read the catalogue when its shape moved** — a skill added, renamed, or deleted — so routing is decided against the new names. `hyprpilot://skills` is the whole index in one read; `mcp__hyprpilot-skills__list_skills` returns the same set as a tool call.
5. **Report** what you re-read, and anything that failed to resolve.

Skip nothing on the grounds that "the edit was small". The point of re-reading is that you cannot tell from context which copy you are holding.

## Boundaries

- **Skills only.** This covers the skill catalog. It does **not** re-inject the system-prompt files (`AGENTS.md`) — those propagate on the next session.
- **Context only.** Nothing here touches the sidecar; the sidecar looks after itself.
- **Non-destructive.** Reading only. Never edits or deletes skill files.
