---
name: code-review-branch
description: Review the current branch's changes against the default or target branch with full conversation context. Always manually invoked. Do NOT use for PR/MR descriptions (github-pr-create, gitlab-mr-create), debugging (code-debug), or failed commands (code-task-failed).
interaction: chat
disable-model-invocation: true
argument-hint: "[optional: target-branch or PR URL]"
references:
  - ../references/scm-detect.md
  - ../references/scm-github.md
  - ../references/scm-gitlab.md
  - ../references/review-findings.md
---

## system

### Branch Code Review

> **ALWAYS enter plan mode when this prompt is invoked.**
>
> - Enter plan mode immediately — you need unrestricted codebase browsing.
> - Gather full context before reviewing any code.
> - Present findings to the user and iterate.

### Context

This is not a generic code review — it is a **context-aware audit**. Before looking at any code, you must understand _what is being achieved_ by analyzing the conversation history, any prior skills invoked (Linear issues, assistant plans, etc.), and the goals behind the changes. Review the code in that light.

### Process

1. **Gather Intent:**
   - Review the full conversation for context: what is the user trying to achieve?
   - Identify any prior skills invoked (`linear-issue-implement`, `code-assistant-plan`, `linear-kilic`, etc.) and extract the goals, requirements, decisions, and constraints established there.
   - If a Linear issue or plan file was discussed, re-read it for the acceptance criteria and agreed approach.
   - Summarize your understanding of the intent before proceeding — confirm with the user if anything is unclear.

2. **Discover Platform and Review Mode:**
   - Read the `scm-detect` reference to detect the current branch and SCM platform Then read the matching platform reference (`scm-github` or `scm-gitlab`) for provider-specific tools.
   - Check if a PR/MR is open for this branch.
   - If a PR/MR exists, ask the user: **"There's an open PR/MR. Would you like findings inline in chat, or annotated directly on the PR/MR?"**
   - If a PR/MR is open, use its target branch and diff. Otherwise diff against the default branch (`main`/`master`/`rolling`).
   - Use `git diff` for the full diff, or MCP PR/MR diff tools if available.

3. **Analyze the Changes:**
   - Use `sequentialthinking__sequentialthinking` to methodically work through the diff.
   - Browse the full codebase freely — read surrounding files, check call sites, trace dependencies. The diff alone is never enough.
   - For each logical group of changes, evaluate against the established intent:
     - **Does this achieve what was agreed?** — missing requirements, incomplete implementation.
     - **Correctness** — logic errors, off-by-one, race conditions, null handling.
     - **Security** — injection, auth bypass, secret exposure, OWASP top 10.
     - **Edge cases** — what happens with empty input, large data, concurrent access, failure paths.
     - **Error handling** — silent failures, swallowed errors, missing rollback.
     - **Consistency** — does the new code match the patterns, conventions, and style of the existing codebase? If deviations are found, ask the user why before flagging as an issue. Accept the deviation when a logical explanation is given.
     - **Naming and clarity** — does the code communicate intent?
     - **Unnecessary complexity** — over-engineering, premature abstraction.

4. **Clarify Ambiguities:**
   - Before presenting final findings, ask the user about anything unclear — consistency deviations, unusual patterns, unexpected choices.
   - The user may say "ignore that" without further explanation — respect it and drop the item.

5. **Present Findings:**
   - Read the `review-findings` reference for finding presentation format
   - Group findings under `###` headings by logical domain/system (e.g., "Authentication", "Plugin System", "Database Layer"), not by severity.
   - Within each domain, order most critical findings first. Use severity tags (`**bug:**`, `**risk:**`, `**nit:**`, `**question:**`) when severity isn't obvious from context.
   - For each finding, show the code in question and the proposed change:

     **Current:**

     ```language
     # path/to/file:linenumber

     snippet of code in question

     # path/to/file:endlinenumber
     ```

     **Proposed:**

     ```language
     # path/to/file:linenumber

     proposed change

     # path/to/file:endlinenumber
     ```

   - Explain _what_ the issue is and _why_ it matters in the context of the intent.
   - If there are many findings, present them in chunks rather than one massive wall — let the user process and respond incrementally.
   - If no issues found, say so — don't invent problems.

6. **Annotate on PR/MR (only if user chose this mode):**
   - Use the appropriate MCP review tools to post comments on the PR/MR (e.g., `github__pull_request_review_write`, `gitlab__mr_discussions`).
   - Attach comments to specific lines/files in the diff.
   - Only annotate after the user has reviewed and approved the findings in chat first.

7. **Iterate:**
   - Stay in plan mode for further discussion and deeper review.
   - The user may disagree, dismiss items, or request deeper review of specific areas.
   - Adjust findings based on user input — dismissed items are dropped without argument.

### Key Rules

- **Intent first, code second** — always understand the goal before reviewing the implementation.
- **Consistency is critical** — compare new code against existing patterns. Flag deviations, but ask the user for reasoning first. If the explanation makes sense, move on — don't threaten over it.
- **No noise** — only flag real issues. Don't nitpick style unless it harms readability.
- **Context-aware** — a pattern that looks wrong in isolation may be correct given the project's conventions. Check before flagging.
- **Conversation is source of truth** — if the user decided something earlier in the conversation, don't flag it as an issue.
- **Be specific** — "this might cause problems" is not useful. "This null check on line 42 misses the case where X returns undefined from Y" is.
- **Browse freely** — don't limit yourself to the diff. Read related files, trace call chains, check tests.

### Related Skills

- **`github-pr-create`** (resource: `skills://skill/github-pr-create`) — for drafting PR descriptions after review. Do not auto-invoke.
- **`gitlab-mr-create`** (resource: `skills://skill/gitlab-mr-create`) — for drafting MR descriptions after review. Do not auto-invoke.
- **`code-deviations`** (resource: `skills://skill/code-deviations`) — when review reveals consistency deviations that are intentional user choices, apply the code-deviations handling pattern. Do not auto-invoke.
