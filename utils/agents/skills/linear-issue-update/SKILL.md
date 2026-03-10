---
name: linear-issue-update
description: Update a Linear issue's description to reflect deviations and refinements from the conversation. Use when the issue no longer matches the agreed approach.
interaction: chat
disable-model-invocation: true
argument-hint: "[issue-id or Linear URL]"
---

## system

### Linear Issue Update

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Review conversation deviations before modifying the issue.
> - Present proposed changes to the user and get approval before applying.

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill, unless a full Linear URL is provided — in that case, deduce the workspace from the URL and use the corresponding MCP tools.

### Process

1. **Fetch the issue** using the appropriate Linear MCP tools.
2. **Review the conversation** for deviations from the original issue — changed requirements, rejected approaches, new decisions, corrected assumptions.
3. **Flag outdated or irrelevant sections** — warn the user about parts of the issue that are stale, no longer applicable, or contradicted by the conversation. Get explicit approval before modifying or removing these.
4. **Draft the updated description** and present it to the user, highlighting what changed and why.
5. **Iterate** based on user feedback. This is a refining process — work with the user to get the issue into a state that accurately reflects the current understanding.
6. **Apply changes** only after user approval.

### What to Update

- **Description text** — rewrite sections that no longer reflect the agreed approach.
- **Task lists** — add, remove, check, or cancel items to match the current plan.
- **`## Thoughts` section** — add at the end of the description with a markdown list of key deviations and the reasoning behind them.

### Thoughts Section Format

```markdown
## Thoughts

- Switched from X to Y because Z.
- Dropped requirement A — not needed after discovering B.
- Added step C which was missing from the original scope.
```

Only include deviations that matter for future readers understanding *why* the issue looks different from what was originally written.

### Key Rules

- **Never modify the issue without user approval.**
- **Preserve content that hasn't changed** — only update what deviated.
- **The Thoughts section documents *why*, not *what*** — the description itself reflects the *what*.
