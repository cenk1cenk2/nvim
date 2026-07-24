---
name: spacelift-laravel
description: 'spacelift-laravel Initialize a Spacelift session for the Laravel workspace. Auto-invoked on Spacelift context (Spacelift URLs, stack names, run references). Do NOT use for ArgoCD operations (argocd-kilic).'
references:
  - ../references/present-first.md
---

## Spacelift Workspace: Laravel

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Session Initialization

**FIRST ACTION** when this skill is invoked:

1. Call `spacelift-laravel__list_stacks` to verify connectivity and list available stacks.
2. Note the available stacks and their current states.
3. Store the workspace context for the session.

## Workspace Context

- **Spacelift MCP:** `spacelift-laravel` — ALWAYS use `spacelift-laravel__*` tools.
- **Common read operations:** `list_stacks`, `list_stack_runs`, `get_stack_run`, `get_stack_run_logs`, `get_stack_run_changes`, `list_resources`, `list_spaces`, `list_policies`, `list_modules`.
- **Write operations:** `trigger_stack_run`, `confirm_stack_run`, `discard_stack_run` — always confirm with user before executing.
- **Cross-reference style:** Reference stack names and run IDs when discussing Spacelift operations.

## After Initialization

Once context is established, proceed with the user's request. Common tasks include:

- Checking stack status and recent runs.
- Viewing run logs and resource changes.
- Triggering or approving runs (with user confirmation).
- Investigating failed runs.
- Browsing managed resources and policies.
- Exploring module registry.
