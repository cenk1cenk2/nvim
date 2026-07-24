---
name: linear-issue-comment
description: linear-issue-comment Record critical findings, deviations, and decisions as concise comments on Linear issues. Use when user says "comment on the issue", "log this to Linear", "document this finding", or "add a note to the issue". Do NOT use for updating the issue description (/linear-issue-update) or checklist (/linear-issue-checklist).
argument-hint: "[issue-id or Linear URL] [what to comment]"
references:
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
  - ../references/linear-state-transitions.md
  - ../references/present-first.md
---

## Linear Comment: Issue Documentation

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Prerequisite

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

## Context

You record critical findings and deviations as comments on Linear issues. Comments are **not summaries or status updates** — they document specific things that changed from the original plan: decisions made, approaches rejected, blockers discovered, or assumptions corrected.

The current conversation context holds the most recent version of the issue's intent. The goal is to capture deviations from the conversation back into Linear so future readers understand what changed and why. The issue description may be stale — the conversation is the source of truth for what to document.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-state-transitions` reference — when the comment is a delivery / close-out note posted against a merged MR/PR, the skill also advances the issue to `Done` per the post-merge trigger.

## Process

1. **Identify the issue:**
   - If given an issue ID (e.g., `K-123`), use the active workspace's Linear MCP tools.
   - If given a full Linear URL, deduce the workspace from the URL and use the corresponding MCP tools.

2. **Distill the comment:**
   - Extract only critical findings and deviations from the conversation context.
   - Strip all filler — no greetings, no "just wanted to note", no restating the issue.

3. **Post the comment:**
   - Use the Linear MCP `save_comment` tool from the appropriate workspace.

4. **Transition to `Done` (when applicable):**
   - If the comment is a delivery / close-out note AND either the user explicitly says to close/mark the issue done or the linked merged MR/PR contains a Linear closing keyword for the issue, follow the `linear-state-transitions` reference: call `save_issue` with `state: "Done"`, respecting the never-downgrade guard.
   - A merged MR/PR that only has `refs K-xxx` does NOT trigger `Done`; `refs` is partial or related work until the user or a closing trailer says otherwise.
   - Detect "delivery / close-out" from the comment shape: it announces the MR merge, links the merged MR/PR, or the user prompt says "close K-xxx", "mark K-xxx done", "K-xxx is merged". A plain findings / research comment does NOT trigger this.
   - Report one line: `Linear state: moved K-xxx → Done.` Skip silently when the issue is already `Done` / `Canceled`.
   - User opts out for the turn by saying "don't move the Linear state" or "leave the state alone".

## Comment Style

- **Lead with what changed** — "Switched from X to Y because Z."
- **No filler** — no greetings, no restating the issue, no "just wanted to note".
- **Facts and decisions only.**
- **Length matches the finding** — a single deviation is one sentence. A complex research session with multiple findings gets bullets and an appendix.

## Appendix

When the session produced significant research, reasoning, or context worth preserving:

```markdown
## Findings

- [Bullet list of key deviations and decisions]

## Appendix

[Detailed context: research trail, options considered, reasoning behind decisions, links to relevant code or docs]
```

Use the appendix when the comment would otherwise lose important context that future readers need to understand _why_ decisions were made.
