---
name: linear-issue-create
description: Create new Linear issues with comprehensive analysis and research. Use when user says "create an issue", "file a bug", "add a task to Linear", or "create a ticket". Requires a workspace skill (linear-kilic or linear-laravel). ALWAYS set state explicitly — do NOT let issues go to Triage (API default). Do NOT use for updating existing issues (linear-issue-update), commenting (linear-issue-comment), or picking up issues (linear-issue-pickup).
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-mandatory-fields.md
  - ../references/linear-issue-states.md
  - ../references/linear-description-structure.md
  - ../references/linear-research-documentation.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
  - ../references/present-first.md
  - ../references/output-diff.md
---

## Linear Issue Creation

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Core Requirements

> Read the `linear-mandatory-fields` reference for team, state, labels, estimate, priority, and relations rules.

> Read the `linear-issue-states` reference for state meanings, transition rules, and when to use which state.

Additional rules for issue creation:

- Always assign issues to the current user.
- When creating multiple related issues, batch create them in a single response using parallel tool calls.
- Use project names directly when creating issues — Linear MCP will resolve them, unless prompted to specifically search for it.
- Keep issue titles concise and replicate the styling of encountered issues in the same project.
- If the user creates an issue and also asks for a non-default status, create with the best matching explicit state or compose with `linear-issue-status` immediately after creation.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-project-documents` reference for packaging local/file reference context into Linear documents or comments when an issue points an implementation agent at files, screenshots, examples, or other context that may not be available from the issue text alone.

> Read the `linear-scm-discovery` reference when the user explicitly asks to enrich the issue from GitHub/GitLab or repository context. Use `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available. Use discovered facts to make the issue easier to implement, but do not run broad SCM discovery by default.

## Issue Structure

> Read the `linear-description-structure` reference for the issue description format.

## Research & Documentation

> Read the `linear-research-documentation` reference for the research process, analysis, appendix, and link conventions.

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
