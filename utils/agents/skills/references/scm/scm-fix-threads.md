# SCM Fix Threads

Shared workflow for fixing open review threads/discussions on the current PR/MR by reading each thread, interpreting the reviewer's comment as a prompt, applying the requested code fix, and then replying to and resolving the thread. Used by `github-pr-fix` (GitHub) and `gitlab-mr-fix` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact tools for identifying the PR/MR, listing open threads, replying, and resolving; each skill lists them under its own "Platform specifics".

Identify the target PR/MR and collect its open, unresolved threads first — both are platform-specific (see the skill's "Platform specifics"). For each thread, collect the file path and line range it targets, the full conversation history (all messages in the thread), and any pending suggestion blocks. Then work through the threads with the process below.

## Analyze each thread

Process threads one at a time. For each open thread:

1. **Read the full thread** — every message, not just the first comment. Later replies may refine, contradict, or supersede earlier ones. The latest message in the thread is the most current intent.
2. **Understand the request** — treat the reviewer's words as a prompt. What are they asking to change? Categories:
   - **Suggestion block exists** — the reviewer provided an exact code change. Apply it verbatim.
   - **Explicit fix request** — "change X to Y", "add a null check", "rename this". Clear action.
   - **Question or concern** — "why is this here?", "is this intentional?". These need judgment — see Triage.
   - **Architectural/design feedback** — "this should be split into two functions", "use the factory pattern". Larger scope — see Triage.
3. **Read the surrounding code** — open the file, read the context around the targeted lines. Understand what the code does before changing it.

## Triage — always ask when in doubt

**Default is to ask.** Only apply a fix autonomously when the request is unambiguous AND the fix is straightforward. In every other case, present the thread to the user and ask.

- **Ambiguous wording** — the reviewer's intent is unclear or could be read multiple ways. **Ask the user.**
- **Multiple valid approaches** — you can think of more than one reasonable fix. **Ask the user** which approach they prefer, presenting the options briefly.
- **Better alternative exists** — the reviewer's suggestion works but you see a cleaner or more correct solution. **Ask the user** — present both the reviewer's request and your alternative, let them choose.
- **Questions or concerns** — "why is this here?", "is this intentional?". **Ask the user** how they want to respond. Do not guess the answer even if it seems obvious from the code — the user knows the reviewer's context better than you do.
- **Architectural/design feedback** — any change that spans multiple files, alters the design, or requires judgment about trade-offs. **Ask the user.**
- **Disagreements in the thread** — back-and-forth with no resolution. **Ask the user** which direction to take.
- **Stale threads** — the code has already been changed and the concern may no longer apply. **Ask the user** to confirm before replying or resolving.

## Apply fixes

For each thread with a clear action:

1. **Read the target file** using the built-in Read tool.
2. **Apply the fix** using the built-in Edit tool.
3. **Verify** — read the edited area to confirm the change is correct and doesn't break surrounding code.
4. **Track the fix** — note which thread was addressed and what was changed.

Apply fixes file by file to minimize context switching. If multiple threads target the same file, batch them.

## Reply to threads and resolve

After applying fixes, update each thread on the PR/MR. See the skill's "Platform specifics" for how to reply to a thread and the resolve mechanism.

- **Fixed threads (obvious fix or suggestion applied)** — resolve silently. No reply needed when the fix speaks for itself.
- **Fixed threads (non-obvious custom fix)** — reply with a one-liner only if the fix deviates from the request or needs explanation. Then resolve.
- **Answered threads** (explanation, no code change) — post the explanation, then resolve.
- **Stale threads** (code already changed, concern no longer applies) — resolve silently.
- **Deferred threads** (awaiting user input) — leave open. Do not reply or resolve.

## Report to user

After processing all threads, present a summary in chat:

```
### PR/MR Fix Summary

**Resolved:** N threads
**Deferred:** M threads (need your input)

#### Resolved
- `path/to/file:42` — <what was fixed and why>
- `path/to/file:88` — Applied reviewer suggestion.
- `path/to/file:120` — Replied with explanation, no code change.

#### Deferred
- `path/to/file:55` — <why this was skipped and what decision is needed>
```

- List every thread with its file path, line, and a one-liner of what was done or why it was skipped.
- Group by resolved vs deferred.
- If all threads were resolved, omit the Deferred section.

**Pickup workflow note:** When this skill is composed from `agent-pickup`, report any review fix that changes scope, approach, or follow-up requirements so the caller can update the Linear issue comment/checklist or project documentation.

## Optional comment

If the user explicitly asks to post the summary on the PR/MR (e.g., "post this to the PR/MR", "comment the summary"), delegate to the platform's comment skill (`github-pr-comment` / `gitlab-mr-comment`). The fix summary from the report becomes the companion output that the comment skill drafts, presents for approval, and posts. Do not post the comment directly — let the comment skill handle the draft-approve-post workflow. **Only when explicitly requested** — do not invoke the comment skill automatically.

## Key Principles

- **Thread history is the prompt.** Read every message in a thread — the last reply is the most current intent. Do not fix based on the first message alone if later replies refine it.
- **Suggestions are sacred.** When a reviewer provides a `suggestion` block, apply it exactly as written. Do not improve, refactor, or deviate from it.
- **Ask early, ask often.** When anything is ambiguous, unclear, or could be done better — ask the user. Do not guess. The cost of one question is low; the cost of a wrong fix is high.
- **Present alternatives.** When you see a better approach than what was requested, show both options and let the user decide.
- **Minimal fixes.** Change only what the thread asks for. Do not refactor surrounding code, add comments, or "improve" nearby lines.
- **Batch by file.** Process all threads targeting the same file together to avoid redundant reads and conflicting edits.
- **Resolve after fixing.** Always resolve threads after replying — do not leave them open.
