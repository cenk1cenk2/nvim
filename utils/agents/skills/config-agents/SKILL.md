---
name: config-agents
description: config-agents Update or review the central agent guidelines that load into every session. Use when a rule there is wrong, drifted, or a new durable convention should apply everywhere. Suggest it on rule drift; the user triggers it. Not for a repository's own knowledge base, for skills, or for MCP server config.
disableModelInvocation: true
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/config-targets.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/scm/commit-push-scoped.md
argumentHint: '[what to change or review]'
---

## Agents Guidelines Management

Posture: `present-first`.
> **Editor MCP.** When the `hyprpilot-nvim` server is in the session, load the `hyprpilot-nvim` skill and work through it — read `AGENTS.md` with `editor_read` so the captain's unsaved edits are visible, and let that skill own every editor-tool rule you are tempted to write into this document.

## Target File

`~/.config/nvim/utils/agents/AGENTS.md` — the central guidelines document loaded into every hyprpilot agent session.

> **ABSOLUTE — discover the target before drafting, per `config-targets`.** This file is the procedure; the target is `AGENTS.md` and whatever skills own the behaviour alongside it. A rule a skill already governs belongs in that skill, not here. Editing this file needs the captain naming it **and** blessing the change — otherwise propose and stop.

It is injected by an **unscoped root `[[patches]]` entry** in `~/.config/hyprpilot/config.yaml` — a `system_prompt: [{ file: ... }]` overlay with no `$match`, so it folds onto whichever profile resolves. Individual profiles do NOT declare it. Changing which file is loaded is a patch edit, not a per-profile edit.

## Process

1. **Read the current AGENTS.md.** Understand the full structure, existing sections, and conventions before proposing any changes.
2. **Understand the request.** Determine what needs to change. Ask the user if the intent is ambiguous.
3. **Check for conflicts.** Verify that the proposed change does not contradict existing rules elsewhere in the document. AGENTS.md has a Rule Priority section — ensure new rules fit within or update that hierarchy.
4. **Check skill ownership before growing the file.** If a skill already governs the behaviour, edit that skill through `config-skills` and leave AGENTS.md a pointer plus the rule that loads it. §III's `hyprpilot-nvim` entry is the shape: the server's presence triggers the skill, and the whole editor-tool playbook lives there rather than in every session's context window. Only rules with no owning skill — or the load rules themselves — belong in this document.
5. **Draft the changes.** Present the exact additions, modifications, or removals per `output-diff`, with surrounding context so the user can see where changes fit. Keep real private specifics out of the guidelines and their examples per `redact-private-data`.
6. **Validate.** Run the `current-state-only` check — no deprecation notes, no record of what a rule replaced. Then conciseness: AGENTS.md is loaded into every session's context window. Every line must earn its place. Remove redundancy, prefer tables over prose, and avoid restating what's already implied by other rules.
7. **Iterate.** Refine based on user feedback until approved.
8. **Apply changes.** After explicit approval, edit the file.
9. **Commit and push.** Per `commit-push-scoped`, stage ONLY `AGENTS.md` and nothing else in the repo, then compose with `git-commit` (scope `agents`, e.g. `fix(agents): ...`) and `git-push` targeting `rolling`. Ask before committing unless the request already blessed the push.

## Key Principles

- **Every change is high-impact.** AGENTS.md governs all future sessions. A bad rule propagates everywhere.
- **No contradictions.** If a new rule conflicts with an existing one, resolve the conflict explicitly — don't leave both in place.
- **Keep it scannable.** Agents read this under token pressure. Use tables, bullet points, and bold sparingly but effectively.
- **Write rules as instructions, not prohibitions.** Say what to do; an **ABSOLUTE** marker earns its place when the captain asked for one, or when the wrong move destroys work. Every session pays for an invented forbidden case, and a reader told what the rule *is* deduces the rest.
- **Rule Priority must stay in sync.** If you add rules that affect priority ordering, update the Rule Priority section.
- **AGENTS.md points, skills carry.** A rule that only matters when a particular tool, server, or workspace is present belongs in the skill that surface loads, with a load rule here. Every line kept in this file is paid for by sessions that will never use it.
