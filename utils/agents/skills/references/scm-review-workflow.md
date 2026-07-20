# SCM Review Workflow

Shared workflow for an autonomous code review of the current PR/MR with inline code annotations and a summary comment. Used by `github-pr-review` (GitHub) and `gitlab-mr-review` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact PR/MR-detection, diff, annotation, and comment tools; each skill lists the platform-specific pieces — the review marker, PR/MR identification, inline-annotation targeting, and thread-resolution mechanism — under its own "Platform specifics".

This workflow is **autonomous**: it does NOT draft findings for user approval. It reviews the code and posts annotations and a summary directly.

The full run is: identify the PR/MR → detect previous reviews → determine scope → resolve previous threads → analyze → post inline annotations → post summary. Identifying the PR/MR and posting inline annotations are platform-specific (see the skill's "Platform specifics"); the steps below are shared.

## Detect previous reviews

- Read existing PR/MR comments to find prior summary comments from this skill (see the skill's "Platform specifics" for the read tool).
- Summary comments are identified by this skill's review marker at the top of the comment (see the skill's "Platform specifics" for the exact marker string).
- If a previous summary exists, extract the **reviewed commit SHA** from it.
- If no previous review exists, this is a **first run**.

## Determine review scope

**First run:**
- Get the full PR/MR diff via the platform's diff tool (see the skill's "Platform specifics").
- Record the current HEAD commit SHA as the review baseline.

**Consecutive run:**
- Get the diff between the previously reviewed commit SHA and current HEAD via `git diff`.
- If no new changes exist since the last review, inform the user and stop.
- Also re-read the full PR/MR diff for context on existing annotations.

## Resolve previous threads (consecutive runs only)

- Read existing review threads/discussions on the PR/MR (see the skill's "Platform specifics" for the read tool).
- For each open review thread from a previous run:
  - Check if the flagged code has been changed in the new commits.
  - If **fixed** — reply to the thread: `Fixed in <short-sha>.` No further commentary. Resolve the thread if the platform supports it (see the skill's "Platform specifics").
  - If **still present and unchanged** — leave it. Do not repeat the same finding.
  - If **changed but not fixed** — reply with an updated observation.
- Post thread replies via the platform's reply mechanism (see the skill's "Platform specifics").

## Analyze the changes

Apply the review methodology from `code-review-branch` and `code-review-changes`:

- **Read surrounding code** — the diff alone is never enough. Trace call sites, check types, read related files.
- **Work through the diff methodically** — reason through each change in sequence rather than skimming.
- **Cross-PR/MR consistency** — if the user provides a reference PR/MR (URL or number), fetch its diff via the platform's diff tool and compare both for structural consistency: same variable ordering, same formatting patterns, same parameter additions/removals across analogous files. Flag deviations as `**nit:**` inline annotations on the specific lines that diverge.
- **What to look for:**
  - **Silent failures** — errors caught and ignored, missing error propagation, fallback values hiding problems.
  - **Logic errors** — off-by-one, wrong operator, inverted conditions, missing null/undefined checks.
  - **Security** — injection, auth bypass, secret exposure, unsanitized input at boundaries.
  - **Edge cases** — empty input, large data, concurrent access, failure paths.
  - **Error handling** — swallowed errors, missing rollback.
  - **Inconsistency** — new code deviating from existing codebase patterns or from a reference PR/MR when provided.
  - **Unnecessary complexity** — over-engineering, premature abstraction, dead code.
- **No noise** — only flag real issues. Silence means approval.
- **Be specific** — concrete problem and fix, not vague suggestions.

## Summary comment

After posting inline annotations, post a top-level summary comment (see the skill's "Platform specifics" for the tool) with this structure:

```markdown
<!-- review-marker -->
**Review — `<short-sha>`**

<1-3 sentence summary of review findings and overall assessment.>

| Severity | Count |
|----------|-------|
| bug      | N     |
| risk     | N     |
| nit      | N     |

<If consecutive run: brief note on resolved threads and new findings.>
```

Replace `<!-- review-marker -->` with this skill's exact review marker (see the skill's "Platform specifics"). The marker and commit SHA are required — they enable consecutive run detection.

## Review Tone

Follow the `review-findings` reference tone:

- No hedging, no filler praise, no throat-clearing.
- Terse and specific. One finding per annotation.
- Include the *why* only when the fix isn't obvious.
- Security findings and architectural concerns get full paragraphs.

## Key Principles

- **Autonomous.** No drafts, no approval prompts. Review and post directly.
- **Suggestions over descriptions.** When the fix is clear, use a `suggestion` block so the author can apply it in one click. Do not describe the fix in prose when a suggestion block conveys it better.
- **Incremental.** Consecutive runs only review new changes and resolve old threads.
- **Native annotations.** Use the platform's native review/discussion API for inline comments, not chat output.
- **Commit-tracked.** Every summary records the reviewed commit SHA for future delta detection.
- **No noise.** If the code is clean, say so in one sentence. Do not invent findings.
