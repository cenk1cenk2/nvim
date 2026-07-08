---
name: config-agents
description: Update, refine, or review the central AGENTS.md guidelines file at ~/.config/nvim/utils/agents/AGENTS.md. Always manually invoked — the assistant should SUGGEST this skill when detecting rule drift or new durable conventions that belong in the central guidelines (see AGENTS.md §VII "Knowledge Base Updates (Proactive)"), but never self-invoke. Do NOT use for per-repo CLAUDE.md/AGENTS.md (/config-repository), skills (/config-skills), or MCP server configs (/config-mcp).
disable-model-invocation: true
references:
  - ../references/present-first.md
  - ../references/output-diff.md
argument-hint: "[what to change or review in AGENTS.md]"
---

## Agents Guidelines Management

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chunked change presentation — show reasoning + content blocks for each proposed change before asking for approval.

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

## Key Principles

- **Every change is high-impact.** AGENTS.md governs all future sessions. A bad rule propagates everywhere.
- **No contradictions.** If a new rule conflicts with an existing one, resolve the conflict explicitly — don't leave both in place.
- **Keep it scannable.** Agents read this under token pressure. Use tables, bullet points, and bold sparingly but effectively.
- **Quick Reference must stay in sync.** If you change behavior in a main section, update the Quick Reference section to match.
- **Rule Priority must stay in sync.** If you add rules that affect priority ordering, update the Rule Priority section.
