---
name: linear-kilic
description: linear-kilic Auto-invoked on kilic-dev context - K-xxx issue ids, kilic-dev workspace URLs, or a gitlab.kilic.dev repo. Initialises the Linear session for that workspace, with GitLab as its SCM. Not for Laravel-workspace work or CLOUD-xxx ids.
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-mandatory-fields.md
---

## Session Initialization

**FIRST ACTION** when this skill is invoked: initialise the session against `linear-kilic` per `linear-prerequisite`.

## Workspace Context

- **Linear MCP:** `linear-kilic`, or the harness Linear connector when it is authorized for kilic-dev. Use whichever is present, per `linear-prerequisite`.
- **Code discovery MCP:** `sourcebot-kilic` — prefer for fast organization-wide repository/code discovery and prior-art search when available.
- **SCM MCP:** `gitlab` — use `gitlab__*` tools for authoritative GitLab metadata, MRs, pipelines, issues, project settings, permissions, live branch state, and writes.
- **Repository link format:** `{"url": "https://gitlab.kilic.dev/...", "title": "repo-name"}`.
- **MR link format:** `{"url": "https://gitlab.kilic.dev/.../merge_requests/123", "title": "MR !123"}`.
- **Cross-reference style:** Use Linear issue identifiers (e.g., "See K-65 for similar work on nailbed cluster").

## After Initialization

Once context is established, proceed with the user's request.

**Issue-creation invariant:** every `linear-kilic__save_issue` call — including ad-hoc creates made WITHOUT the `linear-issue-create` skill — sends an explicit `state` and the required fields per `linear-mandatory-fields`.

If the user wants to create issues, follow the `linear-issue-create` skill workflow.
