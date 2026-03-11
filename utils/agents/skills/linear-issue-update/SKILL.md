---
name: linear-issue-update
description: Update a Linear issue's description to reflect deviations and refinements from the conversation. Use when user says "update the issue", "the issue description is outdated", or "sync the issue with what we agreed". Do NOT use for commenting (/linear-issue-comment), checklist updates (/linear-issue-checklist), or creating new issues (/linear-issue-create).
interaction: chat
argument-hint: "[issue-id or Linear URL]"
---

## system

### Linear Issue Update

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Review conversation deviations before modifying the issue.
> - Present proposed changes to the user and get approval before applying.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

### Core Principle

> **THE ISSUE IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.**
>
> Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). The user's session knowledge and the current conversation context hold the most recent version of the issue's intent. The goal of this skill is to apply deviations from the conversation back to the issue in Linear. When the issue's `updatedAt` is older than the current conversation context, **treat the conversation as the source of truth** and update the issue to match — always confirming with the user before applying.

### Process

1. **Fetch the issue** using the appropriate Linear MCP tools.
2. **Check the `updatedAt` timestamp** — if the description is older than the current session context, ask the user what has changed before assuming the stored content is current.
3. **Review the conversation** for deviations from the original issue — changed requirements, rejected approaches, new decisions, corrected assumptions.
4. **Flag outdated or irrelevant sections** — warn the user about parts of the issue that are stale, no longer applicable, or contradicted by the conversation. Get explicit approval before modifying or removing these.
5. **Draft the updated description** and present it to the user, highlighting what changed and why.
6. **Iterate** based on user feedback. This is a refining process — work with the user to get the issue into a state that accurately reflects the current understanding.
7. **Apply changes** only after user approval.

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
