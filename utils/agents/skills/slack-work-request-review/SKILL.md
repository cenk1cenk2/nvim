---
name: slack-work-request-review
description: "Post a PR review request in #cloud-infra on the Laravel enterprise Slack. Use when user says 'request review', 'post review request', or 'ask for review'. Can be composed with github-pr skill after PR creation. Always manually invoked."
interaction: chat
disable-model-invocation: true
argument-hint: "[github-pr-url or PR number]"
references:
  - ../references/claude-ai-connectors.md
  - ../references/slack.md
  - ../references/slack-prerequisite.md
  - ../references/scm-github.md
  - ../references/output-diff.md
---

## system

### Slack Review Request Poster

> **DO NOT enter plan mode.** This skill fetches PR details and posts a message.

> **PREREQUISITE:** The `slack-work` workspace skill MUST be active before this skill runs.
> Load it via `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/slack-work" })` if not already loaded.

> Read the `slack` reference for Slack mrkdwn formatting rules.
> Read the `scm-github` reference for GitHub MCP tools.
> Read the `output-diff` reference for presenting the message before posting.

### Context

- **Channel:** `#cloud-infra` (ID: `C073JL6GDMF`).
- **Slack workspace:** Laravel enterprise (`slack-work`).
- **Slack tools:** Deferred claude.ai connector tools (`mcp__claude_ai_Slack__*`) — load via `ToolSearch` before use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })
  ```

### Process

1. **Identify the PR.**
   - If the user provides a GitHub PR URL or number, use it directly.
   - If not provided, detect from the current branch:
     - Use `git__git_status` to get the current branch.
     - Use `github__list_pull_requests` with `head: "owner:branch"` to find the open PR.
   - If no PR is found, ask the user.

2. **Fetch PR details.**
   - Use `github__pull_request_read` (method: `get`) to fetch the PR metadata.
   - Extract: title, URL, description/body.

3. **Compose the summary.**
   - Write a short summary (1-3 sentences) of the PR description.
   - Focus on **what** changed and **why** — not implementation details.
   - If the PR description is empty, summarize from the title and commit messages.

4. **Format the message.**
   - Use Slack mrkdwn syntax (NOT standard markdown).
   - Template:
     ```
     :review: {pr_url}

     {short_summary}
     ```
   - Example:
     ```
     :review: https://github.com/laravel/cloud-app-operator/pull/42

     Adds health check endpoint for the operator pod and configures liveness/readiness probes in the Helm chart.
     ```

5. **Present for approval.**
   - Show the formatted message to the user in chat.
   - Wait for explicit approval before posting.

6. **Post to Slack.**
   - Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
   - Use `mcp__claude_ai_Slack__slack_send_message` to post to channel `C073JL6GDMF`.

### Composing with Other Skills

- **`github-pr`** — after creating a PR with the `github-pr` skill, this skill can be invoked to post the review request. The PR URL from the `github-pr` output can be passed directly — no need to re-detect from git state.
- **`slack-work`** — workspace prerequisite, must be loaded first.

### Key Principles

- **Always present before posting.** Never send without user approval.
- **Use Slack mrkdwn.** Use plain URLs for links (Slack auto-unfurls GitHub PRs). No markdown bold (`**`), use `*text*` instead.
- **Keep the summary concise.** 1-3 sentences, focused on what and why.
