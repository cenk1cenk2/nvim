---
name: slack-laravel-review
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

> **PREREQUISITE:** The `slack-laravel` workspace skill MUST be active before this skill runs.
> Load it via the `slack-laravel` skill (load it as defined in `load-skills`) if not already loaded.

> Read the `slack` reference for Slack mrkdwn formatting rules.
> Read the `scm-github` reference for GitHub MCP tools.
> Read the `output-diff` reference for presenting the message before posting.

### Context

- **Channel:** `#cloud-infra` (ID: `C073JL6GDMF`).
- **Slack workspace:** Laravel enterprise (`slack-laravel`).
- **Slack tools:** Deferred claude.ai connector tools (`mcp__claude_ai_Slack__*`) — load via `ToolSearch` before use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })
  ```

### Process

1. **Identify the PR.**
   - If the user provides a GitHub PR URL or number, use it directly.
   - If not provided, detect from the current branch:
     - Use `git status` to get the current branch.
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
   - **Full Spacelift narrative (when requested)** — if the user says "include spacelift report", "include the spacelift analysis", or similar, replace the one-line infrastructure summary with a full narrative:
     - Start with the one-line delta summary in italics (e.g., `_Spacelift: 1 stack, +5 ~5 ♻2, finished._`).
     - Follow with a paragraph explaining the core intended change and its effect (e.g., what the tunnel cutover does, what service replaces what).
     - Then a paragraph covering module-bump or incidental side effects — new resources added, secrets recreated, addon version bumps, AMI refreshes. Name specific resources, versions, and values so the reviewer understands the blast radius without opening the PR.
     - Use Slack mrkdwn: backticks for resource names, service URLs, versions, and AMIs. Italics (`_text_`) for the delta line.
   - If unresolved review threads exist, append a one-line note (e.g., "1 unresolved review thread.").
   - **Composing with `*-pr-comment`** — if this skill is being used alongside `github-pr-comment` or `gitlab-mr-comment`, also output a `## Review Request` section containing the formatted Slack review request message (from Step 5). This section will be included in the PR/MR comment by the `*-pr-comment` skill. The Slack message is still posted separately to Slack — the `## Review Request` section is additional output for the PR/MR comment, not a replacement.

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
   - Example (with full Spacelift narrative):
     ```
     :review: https://github.com/laravel/cloud-infrastructure/pull/3847

     Cuts over Cloudflare tunnel traffic to envoy-gateway for enterprise-portwest-dev in eu-west-1. Bumps dedicated-cluster module from 3.0.0 to 3.4.0, adding SQS queue management IAM, CloudWatch quota alarms, and updated Karpenter annotations.

     _Spacelift: 1 stack (`cloud-prd-eu-west-1-enterprise-portwest`), +5 ~5 ♻2, finished._

     The core change switches the Cloudflare tunnel backend from nginx-ingress (`http://ingress-nginx-controller.ingress-nginx.svc.cluster.local:80`) to envoy-gateway (`https://app-operator-gateway.envoy-gateway-system.svc:443`).

     The module bump from 3.0.0 → 3.4.0 brings in three new IAM resources for web app SQS queue management (cross-account role assumed by `277707137550`), two CloudWatch alarms monitoring EIP and vCPU quota usage at 80% via GrafanaOnCall, and rotates the ArgoCD cluster registration secret with new Karpenter consolidation annotations (`karpenter-flex-consolidate-after: 24h`, `karpenter-pro-consolidate-after: 24h`). Incidentally picks up EKS addon bumps (EBS CSI driver `v1.57.1` → `v1.58.0`, Pod Identity Agent `eksbuild.2` → `eksbuild.3`) and a Tailscale subnet router AMI refresh (`ami-0476c6b26004a1760` → `ami-0f8493690c875fd2d`).
     ```

6. **Present for approval.**
   - Show the formatted message to the user in chat.
   - Wait for explicit approval before posting.

7. **Post to Slack.**
   - Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
   - Use `mcp__claude_ai_Slack__slack_send_message` to post to channel `C073JL6GDMF`.

### Composing with Other Skills

- **`github-pr-create`** — after creating a PR with the `github-pr-create` skill, this skill can be invoked to post the review request. The PR URL from the `github-pr-create` output can be passed directly — no need to re-detect from git state.
- **`github-pr-comment` / `gitlab-mr-comment`** — when composed with a `*-pr-comment` skill, the Slack review request message is included as a `## Review Request` section in the PR/MR comment. The `*-pr-comment` skill handles drafting, approval, and posting. The Slack message is still posted separately to Slack — the `## Review Request` section is additive output for the PR/MR comment, not a replacement for the Slack post.
- **`slack-laravel`** — workspace prerequisite, must be loaded first.

### Key Principles

- **Always present before posting.** Never send without user approval.
- **Use Slack mrkdwn.** Use plain URLs for links (Slack auto-unfurls GitHub PRs). No markdown bold (`**`), use `*text*` instead.
- **Keep the summary concise.** 1-3 sentences, focused on what and why.
