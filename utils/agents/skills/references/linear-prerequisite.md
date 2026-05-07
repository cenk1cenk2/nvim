# Linear Workspace Prerequisite

A Linear workspace skill **MUST** be active before any Linear issue/project/initiative skill runs.

If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:

- **kilic-dev workspace:** Load skill `linear-kilic` via the `linear-kilic` skill (load it as defined in `load-skills`)
- **Laravel workspace:** Load skill `linear-laravel` via the `linear-laravel` skill (load it as defined in `load-skills`)

## Deduction Rules

| Signal | Workspace | Skill |
|--------|-----------|-------|
| Issue ID prefix `K-xxx` | kilic-dev | `linear-kilic` |
| Issue ID prefix `CLOUD-xxx` | Laravel | `linear-laravel` |
| Linear URL containing `kilic-dev` | kilic-dev | `linear-kilic` |
| Linear URL containing `laravel` | Laravel | `linear-laravel` |
| GitLab repository (`gitlab.kilic.dev`) | kilic-dev | `linear-kilic` |
| GitHub repository (Laravel org) | Laravel | `linear-laravel` |
| User says "work" or "laravel" | Laravel | `linear-laravel` |
| User says "personal" or "kilic" | kilic-dev | `linear-kilic` |
| No signal available | — | Ask the user |

If a full Linear URL is provided, deduce the workspace from the URL directly.
