---
name: slack-laravel-review
description: "Post a PR/MR review request in #cloud-infra-pr on the Laravel enterprise Slack, one PR per message. Use when user says 'request review', 'post review request', 'ask for review', 'post this/these to slack'. Can be composed with github-pr-create skill after PR creation. Always manually invoked."
disable-model-invocation: true
argument-hint: "[github-pr-url or PR number]"
references:
  - ../references/present-first.md
  - ../references/claude-ai-connectors.md
  - ../references/slack.md
  - ../references/slack-prerequisite.md
  - ../references/scm-github.md
  - ../references/output-diff.md
---

## Slack Review Request Poster

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **PREREQUISITE:** Read the `slack-prerequisite` reference for workspace detection and activation. This skill operates on the Laravel enterprise workspace (`slack-laravel`), which MUST be active before it runs.

> Read the `slack` reference for Slack mrkdwn formatting rules.
> Read the `scm-github` reference for GitHub MCP tools.
> Read the `output-diff` reference for presenting the message before posting.

## Context

- **Channel:** `#cloud-infra-pr` (ID: `C0B0XMD0HS4`).
- **Slack workspace:** Laravel enterprise (`slack-laravel`).
- **Slack tools:** Deferred claude.ai connector tools (`mcp__claude_ai_Slack__*`) — load via `ToolSearch` before use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })
  ```

## Process

1. **Identify the PR.**
   - If the user provides a GitHub PR URL or number, use it directly.
   - If not provided, detect from the current branch:
     - Use `git status` to get the current branch.
     - Use `github__list_pull_requests` with `head: "owner:branch"` to find the open PR.
   - If no PR is found, ask the user.
   - **Multiple PRs:** if the user provides several PRs (e.g., a wave rollout), process each independently and post a SEPARATE message per PR — repeat Steps 2-7 once per PR. Never combine multiple PRs into one message.

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

4. **Compose the summary (default).**
   - **Default: title + description.** Every post carries a short title stating what was done, followed by an extended description of the goal.
   - **Title (what was done):** one short bold line summarizing the change. Combine the PR title with contextual detail — when the conversation, commits, or PR body give you a clearer picture of what is being done, fold that in so the title is more descriptive than the raw PR title alone. Keep it to one line.
   - **Extended description (the goal):** 1-2 direct sentences stating what this change accomplishes and why, framed by its role in the rollout (e.g. "Phase 0 (converge): normalize the stacks to the latest module version to clear drift ahead of the Karpenter swap in the next phase").
   - **State the goal, not a changelog.** Do NOT itemize incidental resource changes in the prose (addon/AMI/policy tweaks, a single SQS ARN variant, etc.) — the Spacelift delta line and the PR diff already carry those. Reviewers want the intent, not a per-resource list.
   - **Avoid listing sibling PRs.** Do NOT paste links to related/prior PRs of the same wave, environment, or cluster-type. If continuity genuinely helps the reviewer, mention *where* the change is being applied in prose (e.g. "same change as the earlier prod waves") — without the PR URLs. Prefer omitting even that unless it adds real context.
   - If the PR description is empty, derive the title and goal from the PR title, commit messages, and rollout context.
   - If infrastructure impact was found, append a one-line summary (e.g., "Spacelift: 5 stacks, +35 ~41 −10, all finished.").
   - **Full Spacelift narrative (when requested)** — if the user says "include spacelift report", "include the spacelift analysis", or similar, replace the one-line infrastructure summary with a full narrative:
     - Start with the one-line delta summary in italics (e.g., `_Spacelift: 1 stack, +5 ~5 ♻2, finished._`).
     - Follow with a paragraph explaining the core intended change and its effect (e.g., what the tunnel cutover does, what service replaces what).
     - Then a paragraph covering module-bump or incidental side effects — new resources added, secrets recreated, addon version bumps, AMI refreshes. Name specific resources, versions, and values so the reviewer understands the blast radius without opening the PR.
     - Use Slack mrkdwn: backticks for resource names, service URLs, versions, and AMIs. Italics (`_text_`) for the delta line.
   - If unresolved review threads exist, append a one-line note (e.g., "1 unresolved review thread.").
   - **Title-only (very rare, on request).** Only when the user explicitly asks for just the link (e.g. "title only", "no summary", or a bulk wave rollout where they want minimal noise), post the bare title line `{pr_url} :review:` and skip the summary. This is the exception, not the default.
   - **Composing with `*-pr-comment`** — if this skill is being used alongside `github-pr-comment` or `gitlab-mr-comment`, also output a `## Review Request` section containing the formatted Slack review request message (from Step 5). This section will be included in the PR/MR comment by the `*-pr-comment` skill. The Slack message is still posted separately to Slack — the `## Review Request` section is additional output for the PR/MR comment, not a replacement.

5. **Format the message.**
   - Use Slack mrkdwn syntax (NOT standard markdown).
   - **Review line (always, exact):** `{pr_url} :review:` — the URL first, then the `:review:` emoji.
   - **Default — title + description.** Leave ONE blank line after the review line, then the bold what-was-done title, then the extended description:
     ```
     {pr_url} :review:

     *{what_was_done_title}*

     {extended_description}

     {infrastructure_line}

     {review_notes_line}
     ```
   - Omit the infrastructure and review lines if not applicable.
   - **Title-only (very rare, on request):** the entire message is just the review line `{pr_url} :review:`.
   - Example (default — title + description; note: title blends the PR title with contextual detail, description states the goal, no sibling PR links, does NOT itemize the incidental resource changes):
     ```
     https://github.com/<owner>/<repo>/pull/<number> :review:

     *<what was done — PR title enriched with context>*

     <Phase / goal>: <what this change accomplishes and why, framed by its role in the rollout>. Same change as the earlier <cluster-type> waves.

     _Spacelift: <N> stacks, +<a> ~<c> −<d> each, finished._
     ```
   - Example (title-only — very rare):
     ```
     https://github.com/<owner>/<repo>/pull/<number> :review:
     ```
   - Example (with full Spacelift narrative):
     ```
     https://github.com/<owner>/<repo>/pull/<number> :review:

     <One-line goal: what this change accomplishes and why>.

     _Spacelift: <N> stack(s) (`<stack-name>`), +<a> ~<c> ♻<r>, finished._

     <Paragraph explaining the core intended change and its effect — e.g. what a cutover does, what service replaces what. Use backticks for service URLs and resource names.>

     <Paragraph covering module-bump / incidental side effects — new resources, recreated secrets, addon/AMI version bumps. Name the specific resources, versions, and values so the reviewer sees the blast radius, e.g. `<module> <old-version> → <new-version>`, `<addon> <old> → <new>`, `<old-ami> → <new-ami>`.>
     ```

6. **Present for approval — unless the user already told you to post.**
   - **If the user explicitly instructed the message(s) be posted** (e.g., "post this", "post these", "this has to be posted", "go ahead and post"), skip approval and post directly (Step 7).
   - Otherwise, show the formatted message(s) in chat and wait for explicit approval before posting.

7. **Post to Slack.**
   - Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
   - Use `mcp__claude_ai_Slack__slack_send_message` to post to channel `C0B0XMD0HS4` (`#cloud-infra-pr`).
   - **One message per PR/MR** — when posting multiple, send each as its own separate message (one `slack_send_message` call per PR).

## Composing with Other Skills

- **`github-pr-create`** — after creating a PR with the `github-pr-create` skill, this skill can be invoked to post the review request. The PR URL from the `github-pr-create` output can be passed directly — no need to re-detect from git state.
- **`github-pr-comment` / `gitlab-mr-comment`** — when composed with a `*-pr-comment` skill, the Slack review request message is included as a `## Review Request` section in the PR/MR comment. The `*-pr-comment` skill handles drafting, approval, and posting. The Slack message is still posted separately to Slack — the `## Review Request` section is additive output for the PR/MR comment, not a replacement for the Slack post.
- **`slack-laravel`** — workspace prerequisite, must be loaded first.

## Key Principles

- **Present before posting — unless told to post.** Default to presenting for approval; when the user has explicitly said to post (e.g., "post this/these", "this has to be posted"), post directly without re-asking.
- **One PR/MR per message.** Always exactly one PR/MR per Slack message. When posting multiple (e.g., a wave rollout), send a separate message per PR — never bundle.
- **Review line is exact:** `{pr_url} :review:` — URL first, then the `:review:` emoji.
- **Default carries title + description.** Every post leads with the review line, then a bold one-line title of what was done (PR title blended with contextual detail), then a 1-2 sentence extended description of the goal. Title-only is a very rare opt-out (bulk waves, "just the link").
- **Use Slack mrkdwn.** Use plain URLs for links (Slack auto-unfurls GitHub PRs). No markdown bold (`**`), use `*text*` instead.
- **Summary states the GOAL, not a changelog.** 1-2 direct sentences on what the change accomplishes and why (its role/phase in the rollout). Do NOT itemize incidental resource changes in the prose — the Spacelift delta line carries the impact. Do NOT paste sibling PR links; at most mention where the change is applied in prose when it genuinely aids continuity.
