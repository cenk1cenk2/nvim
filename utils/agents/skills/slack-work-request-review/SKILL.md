---
name: slack-work-request-review
description: "Post a PR review request in #cloud-infra on the Laravel enterprise Slack. Use when user says 'request review', 'post review request', or 'ask for review'. Can be composed with github-pr-create skill after PR creation. Always manually invoked."
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
   - Use `github__pull_request_read` (method: `get_comments`) to fetch PR comments.
   - Use `github__pull_request_read` (method: `get_review_comments`) to fetch review threads.

3. **Analyze PR context.**
   - **PR description** — extract the core intent (what changed and why).
   - **Infrastructure impact** — scan PR comments for Spacelift reports or infrastructure analysis (look for headings like "Spacelift Infrastructure Impact Report", "Overview", stack tables, or resource change summaries). Extract: number of stacks affected, total resource counts (+/~/−), and the 1-2 sentence overview.
   - **Review threads** — scan review comments for unresolved threads or threads with unresolved decisions. Summarize any blocking or open items (e.g., "1 unresolved thread: security concern on IAM policy scope").
   - If no comments or reviews exist, skip these sections.

4. **Compose the summary.**
   - Write a short summary (1-3 sentences) of the PR description.
   - Focus on **what** changed and **why** — not implementation details.
   - If the PR description is empty, summarize from the title and commit messages.
   - If infrastructure impact was found, append a one-line summary (e.g., "Spacelift: 5 stacks, +35 ~41 −10, all finished.").
   - If unresolved review threads exist, append a one-line note (e.g., "1 unresolved review thread.").
   - **Composing with `*-pr-comment`** — if this skill is being used alongside `github-pr-comment` or `gitlab-pr-comment`, also output a `## Review Request` section containing the formatted Slack review request message (from Step 5). This section will be included in the PR/MR comment by the `*-pr-comment` skill. The Slack message is still posted separately to Slack — the `## Review Request` section is additional output for the PR/MR comment, not a replacement.

5. **Format the message.**
   - Use Slack mrkdwn syntax (NOT standard markdown).
   - Template:
     ```
     :review: {pr_url}

     {short_summary}

     {infrastructure_line}

     {review_notes_line}
     ```
   - Omit the infrastructure and review lines if not applicable.
   - Example:
     ```
     :review: https://github.com/laravel/cloud-infrastructure/pull/3797

     Cuts over Cloudflare tunnel traffic to envoy-gateway for 5 euc1 enterprise clusters. Bumps dedicated-cluster module to 3.4.0.

     _Spacelift: 5 stacks, +35 ~41 −10, all finished._
     ```

6. **Present for approval.**
   - Show the formatted message to the user in chat.
   - Wait for explicit approval before posting.

7. **Post to Slack.**
   - Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
   - Use `mcp__claude_ai_Slack__slack_send_message` to post to channel `C073JL6GDMF`.

### Composing with Other Skills

- **`github-pr-create`** — after creating a PR with the `github-pr-create` skill, this skill can be invoked to post the review request. The PR URL from the `github-pr-create` output can be passed directly — no need to re-detect from git state.
- **`github-pr-comment` / `gitlab-pr-comment`** — when composed with a `*-pr-comment` skill, the Slack review request message is included as a `## Review Request` section in the PR/MR comment. The `*-pr-comment` skill handles drafting, approval, and posting. The Slack message is still posted separately to Slack — the `## Review Request` section is additive output for the PR/MR comment, not a replacement for the Slack post.
- **`slack-work`** — workspace prerequisite, must be loaded first.

### Key Principles

- **Always present before posting.** Never send without user approval.
- **Use Slack mrkdwn.** Use plain URLs for links (Slack auto-unfurls GitHub PRs). No markdown bold (`**`), use `*text*` instead.
- **Keep the summary concise.** 1-3 sentences, focused on what and why.
