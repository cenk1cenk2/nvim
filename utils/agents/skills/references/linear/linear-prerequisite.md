# Linear Prerequisite

What must be true before any Linear tool call: the workspace skill is active and its session initialised, and the parent parameter is spelled the way that particular tool spells it.

## Workspace

A Linear workspace skill **MUST** be active before any Linear issue/project/initiative skill runs.

If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:

- **kilic-dev workspace:** Load `linear-kilic`.
- **Laravel workspace:** Load `linear-laravel`.

**One workspace per session.** Never load both `linear-kilic` and `linear-laravel`; once one is active, use it for the whole session. Switching workspace means dismissing the other first, and only when the user explicitly switches.

## Transport

The workspace's standalone server (`linear-kilic`, `linear-laravel`) and the harness Linear connector are the same Linear server behind two names. Use whichever is present; neither outranks the other, and tool names map one to one (`linear-kilic__get_issue` is the connector's `get_issue`). The one check before the first write: the surface you picked is authorized against this session's workspace. Confirm with `get_user "me"` or the team keys (`K-` is kilic-dev, `CLOUD-` is Laravel). A surface bound to the other workspace is not an option for this one.

## Session Initialization

The workspace skill's **first action**, against that workspace's own server:

1. Call `get_user` with `query: "me"` to identify the current user.
2. Note the user's **team(s)** from the response — the default team for issue creation.
3. Store the user ID for assigning issues.
4. Call `list_issue_labels` to fetch **all available labels** for the workspace.
   - Store the label list for the session.
   - **NEVER fabricate or guess label names** — only use labels that exist in this list.
   - If no label fits the issue, ASK the user which label to use rather than inventing one.

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

## The write tools disagree with each other on parameter names

**The Linear MCP server does not spell the parent parameter the same way across its own write tools.** Carrying one tool's spelling to the next fails, and the server rejects it with a bare `Invalid input` that names no field — so the error says nothing about which parameter was wrong. Read the schema for the specific tool rather than pattern-matching from a sibling.

| Tool | Parent parameter | Form |
|---|---|---|
| `save_comment` | `issueId`, `projectId`, `initiativeId`, `documentId`, `milestoneId`, `statusUpdateId` | `Id`-suffixed |
| `save_document` | `issue`, `project`, `initiative`, `cycle`, `team` | bare, **no** `Id` suffix |

Both take `id` to update an existing object instead of creating one, and both accept identifiers (`INFFND-528`) as well as UUIDs where the schema says so.

**Verify the parameter against the tool's own schema before the first write of a session.** The names are not derivable from the tool name, and the failure is a validation error that identifies nothing.
