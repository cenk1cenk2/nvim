---
name: linear-comment
description: Record critical findings, deviations, and decisions as concise comments on Linear issues. Use when documenting outcomes of research, debugging, or implementation sessions.
interaction: chat
disable-model-invocation: true
argument-hint: "[issue-id or Linear URL] [what to comment]"
---

## system

### Linear Comment: Issue Documentation

> **DO NOT enter plan mode for this prompt.**
>
> - These are quick documentation captures — comment immediately.
> - Keep comments short and factual.

### Prerequisite

A Linear workspace skill (`/linear-kilic` or `/linear-work`) MUST be invoked before this skill, unless a full Linear URL is provided — in that case, deduce the workspace from the URL and use the corresponding MCP tools.

### Context

You record critical findings and deviations as comments on Linear issues. Comments are **not summaries or status updates** — they document specific things that changed from the original plan: decisions made, approaches rejected, blockers discovered, or assumptions corrected.

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

Use the appendix when the comment would otherwise lose important context that future readers need to understand *why* decisions were made.
