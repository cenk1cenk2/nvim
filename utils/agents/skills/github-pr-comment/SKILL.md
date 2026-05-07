---
name: github-pr-comment
description: Post a companion skill's output as a comment on the current GitHub PR. Use when user says "comment on the PR", "post this to the PR", or invokes alongside another skill to comment its output on GitHub. Do NOT use for PR descriptions (github-pr-create), GitLab MR comments (gitlab-mr-comment), or issue comments (use GitHub MCP directly).
interaction: chat
disable-model-invocation: true
argument-hint: "[companion-skill] [PR number or URL]"
references:
  - ../references/scm-github.md
  - ../references/output-diff.md
---

## system

### GitHub PR Comment Poster

> **DO NOT enter plan mode.** This is an interactive draft-and-post workflow.

> Read the `scm-github` reference for GitHub MCP tools, git MCP tools, and platform detection.
> Read the `output-diff` reference for presenting the comment before posting.

This skill is a **modifier**. It intercepts the final output of a companion skill and posts it as a comment on the current GitHub pull request instead of performing the skill's original write action.

### Process

1. **Identify the companion skill.**
   - If exactly one other skill is active or invoked alongside this skill — use it.
   - If multiple skills are invoked — ask the user which skill's output to post.
   - If no companion skill is identifiable — ask the user what they want commented.

2. **Identify the PR.**
   - If the user provides a GitHub PR URL or number, use it directly.
   - If not provided, detect from the current branch:
     - Use `git status` to get the current branch.
     - Extract owner/repo from the remote URL.
     - Use `github__list_pull_requests` with `head: "owner:branch"` and `state: open` to find the open PR.
   - If no open PR is found, inform the user and stop.

3. **Run the companion skill** — follow its full process (research, analysis, drafting) but **stop before the write/execute step**.

4. **Draft the comment.**
   - Take the companion skill's final drafted content as the comment body.
   - Present the full comment to the user in chat using `output-diff` conventions.
   - Include which PR it will be posted to (number, title, URL).

5. **Post (only after approval).**
   - When the user explicitly approves, post via `github__add_issue_comment` with `owner`, `repo`, `issue_number` (the PR number), and `body`.
   - Confirm the comment was posted.

### Key Principles

- **Always present before posting.** Never comment without user approval.
- **Never execute the companion skill's write action.** The output becomes a comment, not its original target.
- **Ask when ambiguous.** Multiple skills or unclear target → ask before doing anything.
