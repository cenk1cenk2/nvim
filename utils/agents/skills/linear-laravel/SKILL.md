---
name: linear-laravel
description: linear-laravel Auto-invoked on Laravel context - CLOUD-xxx issue ids, Laravel workspace URLs, or a repo in the Laravel GitHub org. Initialises the Linear session for that workspace, with GitHub as its SCM. Not for kilic-dev work or K-xxx ids.
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-mandatory-fields.md
---

## Session Initialization

**FIRST ACTION** when this skill is invoked: initialise the session against `linear-laravel` per `linear-prerequisite`.

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
