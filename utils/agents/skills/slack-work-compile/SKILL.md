---
name: slack-work-compile
description: "Compile a concise Slack message from the user's input, enriched with links and references from MCP tools. Use when user says 'compile this for Slack', 'write this up for the team', 'post this finding', or 'share this on Slack'. Enriches the user's question or finding with PR links, Spacelift run links, code line references, and other relevant links. Always drafts and presents for approval before posting."
interaction: chat
disable-model-invocation: true
argument-hint: "[what to compile — a question, finding, or topic]"
references:
  - ../references/claude-ai-connectors.md
  - ../references/slack.md
  - ../references/slack-prerequisite.md
  - ../references/scm-github.md
  - ../references/scm-gitlab.md
  - ../references/scm-detect.md
  - ../references/output-diff.md
---

## system

### Slack Compile

> **DO NOT enter plan mode.** This is a draft-and-post workflow.

> **PREREQUISITE:** The `slack-work` workspace skill MUST be active before this skill runs.
> Load it via `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/slack-work" })` if not already loaded.

> Read the `slack` reference for Slack mrkdwn formatting rules.
> Read the `scm-github` and `scm-gitlab` references for SCM MCP tools.
> Read the `output-diff` reference for presenting the draft before posting.

This skill takes the user's input — a question, finding, or topic — and compiles it into a concise Slack message enriched with real links and references. The goal is to make the message self-contained so others can understand it and reach the relevant resources without asking follow-up questions.

### Context

- **Slack workspace:** Laravel enterprise (`slack-work`).
- **Slack tools:** Deferred claude.ai connector tools (`mcp__claude_ai_Slack__*`) — load via `ToolSearch` before use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })
  ```
- **Target channel:** Ask the user which channel to post to. If already clear from context (e.g., combined with another skill that specifies a channel), use that.

### Process

#### Step 1: Understand the User's Input

Read the user's message carefully. Identify:

- **The core message** — what they want to communicate (a question, a finding, a status update, a concern).
- **Entities mentioned** — PRs, MRs, Spacelift runs/stacks, code files, functions, branches, commits, issues.
- **Companion skill output** — if used alongside another skill (e.g., `slack-work-request-review`, `github-pr-fix`), incorporate that skill's output as additional context.

**Stay within the user's input.** Do not add information the user did not mention or imply. Do not bring in unrelated topics.

#### Step 2: Enrich with Links and References

For each entity the user mentioned, fetch the real link using the appropriate MCP tools:

- **GitHub PR** — use `github__pull_request_read` (method: `get`) to get the PR URL. Include as a plain URL (Slack auto-unfurls).
- **GitLab MR** — use `gitlab__get_merge_request` to get the MR web URL. Include as a plain URL.
- **Spacelift run** — use `spacelift_laravel__get_stack_run` or `spacelift_laravel__list_stack_runs` to get the run URL. Format: `<run_url|stack-name run #N>`.
- **Spacelift stack** — use `spacelift_laravel__list_stacks` to find the stack. Link to the stack page.
- **Code references** — use `github__get_file_contents` or `gitlab__get_file_contents` to verify the file and line exist. Build a permalink to the specific line(s):
  - GitHub: `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<line>-L<end_line>`
  - GitLab: `https://gitlab.com/<project_path>/-/blob/<sha>/<path>#L<line>-<end_line>`
- **Commits** — use `github__get_commit` or `gitlab__get_commit` to get the commit URL.
- **Issues** — use `github__issue_read` or `gitlab__get_issue` to get the issue URL.

Only enrich entities that the user actually mentioned. Do not go looking for extra things to link.

#### Step 3: Compose the Message

Structure:

```
<core message — the user's question or finding, rewritten concisely in Slack mrkdwn>

<inline links to relevant entities, woven naturally into the text>
```

If companion skill output is present, include it as a separate section:

```
<core message>

## <Companion Section Title>
<companion skill output — e.g., Review Request, Fix Summary, etc.>
```

Rules:
- **Concise.** Say enough so others understand and can reach the resources. No more.
- **Slack mrkdwn.** Use `*bold*`, `_italic_`, `\`code\``, plain URLs for auto-unfurl, `<url|label>` for non-unfurling links.
- **No markdown.** No `**bold**`, no `[text](url)`, no `###` headings. Use Slack conventions.
- **Stick to what the user said.** Enrich with links and details, but do not add opinions, analysis, or information the user did not ask to share.

#### Step 4: Add Appendix (if needed)

If there are additional details that help but would clutter the main message, add an `## Appendix` section:

```
<core message>

## Appendix
<extra details — stack lists, full file paths, commit SHAs, config snippets, etc.>
```

Use the appendix for:
- Lists of affected stacks or resources.
- Full error messages or log snippets.
- Detailed code paths or file references.
- Anything that adds context without being essential to the main point.

Skip the appendix if the message is already self-contained.

#### Step 5: Present Draft

Show the complete message to the user in chat using `output-diff` conventions.

- Include which channel it will be posted to.
- Wait for explicit approval before posting.
- If the user wants changes, revise and re-present.

#### Step 6: Post to Slack

Only after user approval:

- Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
- Post to the specified channel.
- Confirm the message was posted.

### Composing with Other Skills

This skill can be combined with any skill that produces output the user wants to share:

- **`slack-work-request-review`** — the review request message becomes the companion output.
- **`github-pr-fix` / `gitlab-pr-fix`** — the fix summary becomes the companion output.
- **`github-pr-read` / `gitlab-pr-read`** — the PR/MR summary becomes the companion output.
- Any other skill — whatever the skill produced that the user wants to share.

When composed, the companion skill's output is included under its own `##` section heading in the message.

### Key Principles

- **Always draft first.** Never post without presenting to the user and getting approval.
- **Stay within scope.** Only compile what the user asked about. Do not add unrelated information.
- **Enrich, don't editorialize.** Add links, references, and details — not opinions or analysis.
- **Use Slack mrkdwn.** Plain URLs for GitHub/GitLab (auto-unfurl). `<url|label>` for everything else.
- **Concise with reach.** Short enough to read quickly, detailed enough to act on.
