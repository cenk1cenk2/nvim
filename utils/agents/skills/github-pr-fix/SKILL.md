---
name: github-pr-fix
description: Fix all open review conversations on a GitHub PR by reading each thread, understanding the requested change, and applying fixes to the code. Use when user says "fix the PR comments", "resolve the review", "address PR feedback", or "fix review threads". Do NOT use for reviewing PRs (github-pr-review), writing PR descriptions (github-pr), or GitLab MR fixes (gitlab-pr-fix).
interaction: chat
disable-model-invocation: true
argument-hint: "[PR number or URL]"
references:
  - ../references/scm-github.md
  - ../references/scm-detect.md
---

## system

### GitHub PR Fix

> **DO NOT enter plan mode.** This is an autonomous fix workflow — read threads, analyze, fix, and resolve.

> Read the `scm-github` reference for GitHub MCP tools and git MCP tools.
> Read the `scm-detect` reference for platform detection and local git operations.

This skill reads all open review conversations on a GitHub pull request, interprets each reviewer comment as a prompt, and applies the requested code fixes using local editing tools. After fixing, it replies to each thread confirming the fix.

### Process

#### Step 1: Identify the PR

- If the user provides a GitHub PR URL or number, use it directly.
- If not provided, detect from the current branch:
  - Use `git__git_status` to get the current branch.
  - Extract owner/repo from the remote URL.
  - Use `github__list_pull_requests` with `head: "owner:branch"` and `state: open` to find the open PR.
- If no open PR is found, inform the user and stop.
- Read PR metadata via `github__pull_request_read` (method: `get`).

#### Step 2: Collect Open Conversations

- Read all review comments and conversation threads on the PR.
- Filter to **unresolved/open** threads only — skip resolved conversations.
- For each thread, collect:
  - The file path and line range the comment targets.
  - The full conversation history (all replies in the thread).
  - Any pending suggestions (GitHub `suggestion` blocks).

#### Step 3: Analyze Each Thread

Process threads one at a time. For each open thread:

1. **Read the full thread** — every message, not just the first comment. Later replies may refine, contradict, or supersede earlier ones. The latest message in the thread is the most current intent.
2. **Understand the request** — treat the reviewer's words as a prompt. What are they asking to change? Categories:
   - **Suggestion block exists** — the reviewer provided an exact code change. Apply it verbatim.
   - **Explicit fix request** — "change X to Y", "add a null check", "rename this". Clear action.
   - **Question or concern** — "why is this here?", "is this intentional?". These need judgment — see Step 4.
   - **Architectural/design feedback** — "this should be split into two functions", "use the factory pattern". Larger scope — see Step 4.
3. **Read the surrounding code** — open the file, read the context around the targeted lines. Understand what the code does before changing it.

#### Step 4: Triage — Always Ask When in Doubt

**Default is to ask.** Only apply a fix autonomously when the request is unambiguous AND the fix is straightforward. In every other case, present the thread to the user and ask.

- **Ambiguous wording** — the reviewer's intent is unclear or could be read multiple ways. **Ask the user.**
- **Multiple valid approaches** — you can think of more than one reasonable fix. **Ask the user** which approach they prefer, presenting the options briefly.
- **Better alternative exists** — the reviewer's suggestion works but you see a cleaner or more correct solution. **Ask the user** — present both the reviewer's request and your alternative, let them choose.
- **Questions or concerns** — "why is this here?", "is this intentional?". **Ask the user** how they want to respond. Do not guess the answer even if it seems obvious from the code — the user knows the reviewer's context better than you do.
- **Architectural/design feedback** — any change that spans multiple files, alters the design, or requires judgment about trade-offs. **Ask the user.**
- **Disagreements in the thread** — back-and-forth with no resolution. **Ask the user** which direction to take.
- **Stale threads** — the code has already been changed and the concern may no longer apply. **Ask the user** to confirm before replying or resolving.

#### Step 5: Apply Fixes

For each thread with a clear action:

1. **Read the target file** using the built-in Read tool.
2. **Apply the fix** using the built-in Edit tool.
3. **Verify** — read the edited area to confirm the change is correct and doesn't break surrounding code.
4. **Track the fix** — note which thread was addressed and what was changed.

Apply fixes file by file to minimize context switching. If multiple threads target the same file, batch them.

#### Step 6: Reply to Threads

After applying fixes:

- For each fixed thread, reply via `github__add_reply_to_pull_request_comment`:
  - If a suggestion was applied verbatim: `Applied.`
  - If a custom fix was made: one-line description of what was changed. Example: `Added null guard before accessing \`user.email\`.`
- For threads answered with an explanation (no code change): post the explanation.
- For threads deferred to the user: skip — the user will handle these after you report them.

#### Step 7: Report

After processing all threads, report to the user in chat:

```
**Fixed:** N threads resolved.
**Skipped:** M threads need your input.

<For each skipped thread: one-liner explaining why it was skipped and what decision is needed.>
```

If all threads were fixed, just confirm the count.

### Key Principles

- **Thread history is the prompt.** Read every message in a thread — the last reply is the most current intent. Do not fix based on the first comment alone if later replies refine it.
- **Suggestions are sacred.** When a reviewer provides a `suggestion` block, apply it exactly as written. Do not improve, refactor, or deviate from it.
- **Ask early, ask often.** When anything is ambiguous, unclear, or could be done better — ask the user. Do not guess. The cost of one question is low; the cost of a wrong fix is high.
- **Present alternatives.** When you see a better approach than what was requested, show both options and let the user decide.
- **Minimal fixes.** Change only what the thread asks for. Do not refactor surrounding code, add comments, or "improve" nearby lines.
- **Batch by file.** Process all threads targeting the same file together to avoid redundant reads and conflicting edits.
