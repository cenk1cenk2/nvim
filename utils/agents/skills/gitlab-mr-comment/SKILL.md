---
name: gitlab-mr-comment
description: Post a companion skill's output as a comment on the current GitLab MR. Use when user says "comment on the MR", "post this to the MR", or invokes alongside another skill to comment its output on GitLab. Do NOT use for MR descriptions (gitlab-mr), GitHub PR comments (github-pr-comment), or issue comments (use GitLab MCP directly).
interaction: chat
disable-model-invocation: true
argument-hint: "[companion-skill] [MR number or URL]"
references:
  - ../references/scm-gitlab.md
  - ../references/output-diff.md
---

## system

### GitLab MR Comment Poster

> **DO NOT enter plan mode.** This is an interactive draft-and-post workflow.

> Read the `scm-gitlab` reference for GitLab MCP tools, git MCP tools, and platform detection.
> Read the `output-diff` reference for presenting the comment before posting.

This skill is a **modifier**. It intercepts the final output of a companion skill and posts it as a comment on the current GitLab merge request instead of performing the skill's original write action.

### Process

1. **Identify the companion skill.**
   - If exactly one other skill is active or invoked alongside this skill — use it.
   - If multiple skills are invoked — ask the user which skill's output to post.
   - If no companion skill is identifiable — ask the user what they want commented.

2. **Identify the MR.**
   - If the user provides a GitLab MR URL or number, use it directly.
   - If not provided, detect from the current branch:
     - Use `git__git_status` to get the current branch.
     - Extract the project path from the remote URL.
     - Use `gitlab__list_merge_requests` with `source_branch` filter and `state: opened` to find the open MR.
   - If no open MR is found, inform the user and stop.

3. **Run the companion skill** — follow its full process (research, analysis, drafting) but **stop before the write/execute step**.

4. **Draft the comment.**
   - Take the companion skill's final drafted content as the comment body.
   - Present the full comment to the user in chat using `output-diff` conventions.
   - Include which MR it will be posted to (number, title, URL).

5. **Post (only after approval).**
   - When the user explicitly approves, post via `gitlab__mr_discussions` with the project path, MR IID, and comment body.
   - Confirm the comment was posted.

### Key Principles

- **Always present before posting.** Never comment without user approval.
- **Never execute the companion skill's write action.** The output becomes a comment, not its original target.
- **Ask when ambiguous.** Multiple skills or unclear target → ask before doing anything.
