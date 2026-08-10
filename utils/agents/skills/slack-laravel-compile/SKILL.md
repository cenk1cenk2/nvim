---
name: slack-laravel-compile
description: slack-laravel-compile Compile a concise Slack message from your input, enriched with verified links to the PRs, stacks, and code it mentions, and drafted for approval before posting. Use on "compile this for Slack", "share this on Slack". Not for reading an existing Slack link, posting a review request, or the daily check-in.
disableModelInvocation: true
argumentHint: '[what to compile - a question, finding, or topic]'
references:
  - ../references/scm-detect.md
  - ../references/present-first.md
  - ../references/slack.md
  - ../references/slack-prerequisite.md
  - ../references/scm-github.md
  - ../references/scm-gitlab.md
  - ../references/output-diff.md
  - ../references/enrich-context.md
---

## Slack Compile

Posture: `present-first`.
> **PREREQUISITE:** This skill operates on the Laravel enterprise workspace (`slack-laravel`), which MUST be active before it runs — workspace detection and activation per `slack-prerequisite`.

This skill takes the user's input — a question, finding, or topic — and compiles it into a concise Slack message enriched with real links and references. The goal is to make the message self-contained so others can understand it and reach the relevant resources without asking follow-up questions.

## Context

- **Slack workspace:** Laravel enterprise (`slack-laravel`).
- **Slack tools:** Deferred claude.ai connector tools (`mcp__claude_ai_Slack__*`) — load via `ToolSearch` before use:
  ```
  ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })
  ```
- **Target channel:** Ask the user which channel to post to. If already clear from context (e.g., combined with another skill that specifies a channel), use that.

## Process

### Step 1: Understand the User's Input

Read the user's message carefully. Identify:

- **The core message** — what they want to communicate (a question, a finding, a status update, a concern).
- **Entities mentioned** — PRs, MRs, Spacelift runs/stacks, code files, functions, branches, commits, issues.
- **Companion skill output** — if used alongside another skill (e.g., `slack-laravel-review`, `github-pr-fix`), incorporate that skill's output as additional context.

**Stay within the user's input.** Do not add information the user did not mention or imply. Do not bring in unrelated topics.

### Step 2: Enrich with Links and References

For each entity the user mentioned, fetch the real link using the entity enrichment table and code permalink format in `enrich-context`, with the SCM tools from `scm-detect` and `scm-github` / `scm-gitlab`. Only enrich entities the user actually mentioned — do not go looking for extra things to link.

For Slack output specifically: use plain URLs for GitHub/GitLab (Slack auto-unfurls them). Use `<url|label>` format for non-unfurling links (Spacelift, Linear, etc.).

### Step 3: Compose the Message

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
- **Slack mrkdwn** per `slack`. Use `*bold*`, `_italic_`, `\`code\``, plain URLs for auto-unfurl, `<url|label>` for non-unfurling links.
- **No markdown.** No `**bold**`, no `[text](url)`, no `###` headings. Use Slack conventions.
- **Stick to what the user said.** Enrich with links and details, but do not add opinions, analysis, or information the user did not ask to share.

### Step 4: Add Appendix (if needed)

Follow the appendix pattern in `enrich-context`. Add an `## Appendix` section for details that help but would clutter the main message. Skip if the message is already self-contained.

### Step 5: Present Draft

Show the complete message to the user in chat per `output-diff`.

- Include which channel it will be posted to.
- Wait for explicit approval before posting.
- If the user wants changes, revise and re-present.

### Step 6: Post to Slack

Only after user approval:

- Load the Slack send tool: `ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message" })`.
- Post to the specified channel.
- Confirm the message was posted.

## Composing with Other Skills

This skill can be combined with any skill that produces output the user wants to share:

- **`slack-laravel-review`** — the review request message becomes the companion output.
- **`github-pr-fix` / `gitlab-mr-fix`** — the fix summary becomes the companion output.
- **`github-pr-read` / `gitlab-mr-read`** — the PR/MR summary becomes the companion output.
- Any other skill — whatever the skill produced that the user wants to share.

When composed, the companion skill's output is included under its own `##` section heading in the message.

## Key Principles

- **Always draft first.** Never post without presenting to the user and getting approval.
- **Stay within scope.** Only compile what the user asked about. Do not add unrelated information.
- **Enrich, don't editorialize.** Add links, references, and details — not opinions or analysis.
- **Use Slack mrkdwn.** Plain URLs for GitHub/GitLab (auto-unfurl). `<url|label>` for everything else.
- **Concise with reach.** Short enough to read quickly, detailed enough to act on.
