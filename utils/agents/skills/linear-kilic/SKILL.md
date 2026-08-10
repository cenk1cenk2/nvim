---
name: linear-kilic
description: 'linear-kilic Initialize a Linear session for the kilic-dev workspace with GitLab as SCM. Auto-invoked on kilic-dev context: K-xxx issue IDs, kilic-dev workspace URLs, gitlab.kilic.dev repos.'
references:
  - ../references/linear-mandatory-fields.md
---

## Session Initialization

**FIRST ACTION** when this skill is invoked:

1. Call `linear-kilic__get_user` with `query: "me"` to identify the current user.
2. Note the user's **team(s)** from the response — this is your default team for issue creation.
3. Store the user ID for assigning issues.
4. Call `linear-kilic__list_issue_labels` to fetch **all available labels** for the workspace.
   - Store the label list for the session.
   - **NEVER fabricate or guess label names** — only use labels that exist in this list.
   - If no label fits the issue, ASK the user which label to use rather than inventing one.

## Workspace Context

- **Linear MCP:** `linear-kilic` — ALWAYS use `linear-kilic__*` tools unless prompted otherwise.
- **Code discovery MCP:** `sourcebot-kilic` — prefer for fast organization-wide repository/code discovery and prior-art search when available.
- **SCM MCP:** `gitlab` — use `gitlab__*` tools for authoritative GitLab metadata, MRs, pipelines, issues, project settings, permissions, live branch state, and writes.
- **Repository link format:** `{"url": "https://gitlab.kilic.dev/...", "title": "repo-name"}`.
- **MR link format:** `{"url": "https://gitlab.kilic.dev/.../merge_requests/123", "title": "MR !123"}`.
- **Cross-reference style:** Use Linear issue identifiers (e.g., "See K-65 for similar work on nailbed cluster").

## After Initialization

Once context is established, proceed with the user's request.

**Issue-creation invariant:** every `linear-kilic__save_issue` call — including ad-hoc creates made WITHOUT the `linear-issue-create` skill — MUST send an explicit `state`. The Linear API defaults to `Triage`, which is WRONG. Default to `state: "Backlog"`; set `Triage` ONLY when the user explicitly asks for it. Required issue fields per `linear-mandatory-fields`.

If the user wants to create issues, follow the `linear-issue-create` skill workflow.
