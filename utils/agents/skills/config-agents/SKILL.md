---
name: config-agents
description: 'config-agents Update or review the central AGENTS.md guidelines at ~/.config/nvim/utils/agents/AGENTS.md. Always manually invoked; suggest it on rule drift or new durable conventions but never self-invoke. Do NOT use for per-repo CLAUDE.md/AGENTS.md (config-repository), skills (config-skills), or MCP configs (config-mcp).'
disableModelInvocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
  - ../references/commit-push-scoped.md
argumentHint: "[what to change or review in AGENTS.md]"
---

## Agents Guidelines Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed change before asking for approval.

> **No private specifics.** Read the `redact-private-data` reference — never write real private/sensitive specifics (customer names, account IDs, secrets, internal hostnames, real resource IDs) into the guidelines or its examples unless the user explicitly allows it; use placeholders instead.

> **Commit and push.** Read the `commit-push-scoped` reference — after the edit lands, stage ONLY `AGENTS.md` and nothing else in the repo, then commit and push to `rolling` via `git-commit` and `git-push`. Ask first by default; skip the ask when the request already blessed the push.

## Target File

`~/.config/nvim/utils/agents/AGENTS.md` — the central guidelines document loaded into every hyprpilot agent session (injected via the `system_prompt` block on each profile in `~/.config/hyprpilot/config.yaml`).

## Process

1. **Read the current AGENTS.md.** Understand the full structure, existing sections, and conventions before proposing any changes.
2. **Understand the request.** Determine what needs to change. Ask the user if the intent is ambiguous.
3. **Check for conflicts.** Verify that the proposed change does not contradict existing rules elsewhere in the document. AGENTS.md has a Rule Priority section — ensure new rules fit within or update that hierarchy.
4. **Draft the changes.** Present the exact additions, modifications, or removals in the chat window. Show surrounding context so the user can see where changes fit.
5. **Validate conciseness.** AGENTS.md is loaded into every session's context window. Every line must earn its place. Remove redundancy, prefer tables over prose, and avoid restating what's already implied by other rules.
6. **Iterate.** Refine based on user feedback until approved.
7. **Apply changes.** After explicit approval, edit the file.
8. **Commit and push.** Follow the `commit-push-scoped` reference — stage only `AGENTS.md`, then compose with `git-commit` and `git-push` targeting `rolling`. Ask before committing unless the request already blessed the push.

## Key Principles

- **Every change is high-impact.** AGENTS.md governs all future sessions. A bad rule propagates everywhere.
- **No contradictions.** If a new rule conflicts with an existing one, resolve the conflict explicitly — don't leave both in place.
- **Keep it scannable.** Agents read this under token pressure. Use tables, bullet points, and bold sparingly but effectively.
- **Rule Priority must stay in sync.** If you add rules that affect priority ordering, update the Rule Priority section.
