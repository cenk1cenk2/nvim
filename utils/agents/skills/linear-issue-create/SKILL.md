---
name: linear-issue-create
description: linear-issue-create Create Linear issues with the analysis and research behind them, always setting the state explicitly rather than letting it fall into triage. A Linear workspace skill must be active first. Use on "create an issue", "file a bug", "open a ticket". Not for editing an existing issue, commenting on one, or preparing one for work.
references:
  - ../references/reconcile-state.md
  - ../references/present-first.md
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-mandatory-fields.md
  - ../references/linear/linear-issue-states.md
  - ../references/linear/linear-description-structure.md
  - ../references/linear/linear-research-documentation.md
  - ../references/linear/linear-project-documents.md
  - ../references/linear/linear-scm-discovery.md
  - ../references/output-diff.md
---

## Linear Issue Creation

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Core Requirements

Team, state, labels, estimate, priority, and relations per `linear-mandatory-fields`. State meanings and transition rules per `linear-issue-states`.

Additional rules for issue creation:

- Always assign issues to the current user.
- When creating multiple related issues, batch create them in a single response using parallel tool calls.
- Use project names directly when creating issues — Linear MCP will resolve them, unless prompted to specifically search for it.
- Keep issue titles concise and replicate the styling of encountered issues in the same project.
- If the user creates an issue and also asks for a non-default status, create with the best matching explicit state or compose with `linear-issue-status` immediately after creation.

Present the drafted issue in logical chunks for user approval per `output-diff` before writing to Linear.

When an issue points an implementation agent at files, screenshots, examples, or other context that may not be available from the issue text alone, package it into Linear documents or comments per `linear-project-documents`.

When the user explicitly asks to enrich the issue from GitHub/GitLab or repository context, follow `linear-scm-discovery` — its Discovery Ladder picks the tools from what the active profile carries. Use discovered facts to make the issue easier to implement, but do not run broad SCM discovery by default.

## Issue Structure

Issue description format per `linear-description-structure`.

## Research & Documentation

Research process, analysis, appendix, and link conventions per `linear-research-documentation`.

## Related Skills

- **`linear-issue-status`** — lightweight status changes after creation or when the user verbally specifies a target state.
- **`linear-issue-checklist`** — checklist updates for created issues when the user immediately provides completion criteria changes.

## Examples

**User says:** "Create an issue for adding cert-manager to cluster-rubik"

1. Auto-invoke `linear-kilic` (GitLab context detected).
2. Research cert-manager deployment patterns via web search and Context7.
3. Fetch labels and team from Linear workspace.
4. Draft the issue with checklist, analysis, and appendix links.
5. Present the draft to the user for review before writing.

**Result:** Linear issue created in backlog with labels, estimate, priority, and research appendix.

---

**User says:** "File a bug — the webhook handler returns 500 on empty payloads"

1. Auto-invoke workspace skill based on repo context.
2. Research the webhook handler in the codebase.
3. Draft the bug issue with reproduction steps and checklist.
4. Present the draft to the user before writing.

**Result:** Bug issue created in backlog with clear reproduction steps and fix checklist.
