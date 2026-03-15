---
name: linear-issue-comment
description: Record critical findings, deviations, and decisions as concise comments on Linear issues. Use when user says "comment on the issue", "log this to Linear", "document this finding", or "add a note to the issue". Do NOT use for updating the issue description (/linear-issue-update) or checklist (/linear-issue-checklist).
interaction: chat
argument-hint: "[issue-id or Linear URL] [what to comment]"
references:
  - ../references/mcp-output-transparency.md
---

## system

### Linear Comment: Issue Documentation

> **DO NOT enter plan mode for this prompt.**
>
> - These are quick documentation captures — comment immediately.
> - Keep comments short and factual.

### Prerequisite

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel). If a full Linear URL is provided, deduce the workspace from the URL directly.

### Context

You record critical findings and deviations as comments on Linear issues. Comments are **not summaries or status updates** — they document specific things that changed from the original plan: decisions made, approaches rejected, blockers discovered, or assumptions corrected.

The current conversation context holds the most recent version of the issue's intent. The goal is to capture deviations from the conversation back into Linear so future readers understand what changed and why. The issue description may be stale — the conversation is the source of truth for what to document.

> Read the `mcp-output-transparency` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Process

1. **Identify the issue:**
   - If given an issue ID (e.g., `K-123`), use the active workspace's Linear MCP tools.
   - If given a full Linear URL, deduce the workspace from the URL and use the corresponding MCP tools.

2. **Distill the comment:**
   - Extract only critical findings and deviations from the conversation context.
   - Strip all filler — no greetings, no "just wanted to note", no restating the issue.

3. **Post the comment:**
   - Use the Linear MCP `save_comment` tool from the appropriate workspace.

### Comment Style

- **Lead with what changed** — "Switched from X to Y because Z."
- **No filler** — no greetings, no restating the issue, no "just wanted to note".
- **Facts and decisions only.**
- **Length matches the finding** — a single deviation is one sentence. A complex research session with multiple findings gets bullets and an appendix.

### Appendix

When the session produced significant research, reasoning, or context worth preserving:

```markdown
## Findings

- [Bullet list of key deviations and decisions]

## Appendix

[Detailed context: research trail, options considered, reasoning behind decisions, links to relevant code or docs]
```

Use the appendix when the comment would otherwise lose important context that future readers need to understand _why_ decisions were made.
