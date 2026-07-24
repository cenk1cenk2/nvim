---
name: linear-laravel
description: 'linear-laravel Initialize a Linear session for the Laravel workspace with GitHub as SCM. Auto-invoked on Laravel context: CLOUD-xxx issue IDs, Laravel workspace URLs, GitHub Laravel org repos.'
references:
  - ../references/present-first.md
---

## Linear Workspace: Laravel

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Session Initialization

**FIRST ACTION** when this skill is invoked:

1. Call `linear-laravel__get_user` with `query: "me"` to identify the current user.
2. Note the user's **team(s)** from the response — this is your default team for issue creation.
3. Store the user ID for assigning issues.
4. Call `linear-laravel__list_issue_labels` to fetch **all available labels** for the workspace.
   - Store the label list for the session.
   - **NEVER fabricate or guess label names** — only use labels that exist in this list.
   - If no label fits the issue, ASK the user which label to use rather than inventing one.

## Default Team

The current user is on multiple teams (`Infrastructure Foundations`, `Infrastructure`). For this workspace, override the generic multi-team rule in `linear-mandatory-fields`:

- **Default:** `Infrastructure Foundations`. Use for all create flows (issues, projects, initiatives) unless the user explicitly opts out.
- **Opt-in:** `Infrastructure`. Use ONLY when the user explicitly signals it, e.g.:
  - Says "Infra team", "Infrastructure team", "on Infra", or similar.
  - References an `INFRA-xxx` issue or asks to create something in the Infra scope.
  - Works in a project/scope that lives on the Infrastructure team (e.g., Nginx replacement, envoy-gateway cutover).
- **Do not ask** when these two are the only candidates — the default above resolves it. Still ASK if the user lists a third team or the request genuinely spans both.

## Workspace Context

- **Linear MCP:** `linear-laravel` — ALWAYS use `linear-laravel__*` tools unless prompted otherwise.
- **SCM MCP:** `github` — ALWAYS use `github__*` tools for repository operations.
- **Repository link format:** `{"url": "https://github.com/laravel/...", "title": "repo-name"}`.
- **PR link format:** `{"url": "https://github.com/laravel/.../pull/123", "title": "PR #123"}`.
- **Cross-reference style:** Use Linear issue identifiers (e.g., "See CLOUD-123 for related work").

## After Initialization

Once context is established, proceed with the user's request. If the user wants to create issues, follow the `linear-issue-create` skill workflow.
