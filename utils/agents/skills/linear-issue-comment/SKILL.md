---
name: linear-issue-comment
description: linear-issue-comment Record findings, deviations, and decisions as a concise comment on a Linear issue. Use on "comment on the issue", "log this to Linear". Not for rewriting the description, or for checklist items.
argumentHint: '[issue id or URL] [what to record]'
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-comment-style.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
  - ../references/agent-owned.md
---

Issues, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Comment: Issue Documentation

A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Context

You record critical findings and deviations as comments on Linear issues. Comments are **not summaries or status updates** — they document specific things that changed from the original plan: decisions made, approaches rejected, blockers discovered, or assumptions corrected.

The current conversation context holds the most recent version of the issue's intent. The goal is to capture deviations from the conversation back into Linear so future readers understand what changed and why. The issue description may be stale — the conversation is the source of truth for what to document.

## Process

1. **Identify the issue:**
   - If given an issue ID (e.g., `K-123`), use the active workspace's Linear MCP tools.
   - If given a full Linear URL, deduce the workspace from the URL and use the corresponding MCP tools.

2. **Distill the comment:**
   - Extract only critical findings and deviations from the conversation context.
   - Distill per `linear-comment-style`.

3. **Post the comment:**
   - Write it with the Linear MCP `save_comment` tool from the appropriate workspace, then report it with its link. Markdown normaliser traps per `linear-description-structure`.

4. **Close out:** when the comment is a delivery or close-out note — it announces or links a merged MR/PR, or the user says "close K-xxx", "mark K-xxx done", "K-xxx is merged" — Load `linear-status` to move the issue to `Done`, only when the merged MR/PR carried a closing keyword for this issue or the work it delivers is finished.

## Comment Style

Comment shape, ownership, and the findings appendix per `linear-comment-style`.
