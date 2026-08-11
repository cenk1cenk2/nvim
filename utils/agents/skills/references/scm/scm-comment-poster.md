# SCM Comment Poster

Shared workflow for posting a companion skill's output as a comment on the current PR/MR instead of running that skill's own write action. Used by `github-pr-comment` (GitHub) and `gitlab-mr-comment` (GitLab). The platform reference (`scm-github` / `scm-gitlab`) supplies the exact PR/MR-detection and comment tools; each skill lists them under its own "Platform specifics".

This skill is a **modifier** — it intercepts a companion skill's final output and posts it as a PR/MR comment.

## Process

1. **Identify the companion skill.**
   - Exactly one other skill active/invoked → use it.
   - Multiple skills invoked → ask the user which skill's output to post.
   - No companion skill identifiable → ask the user what they want commented.
2. **Identify the target PR/MR.**
   - If the user provides a PR/MR URL or number, use it directly.
   - Otherwise detect from the current branch via the platform reference's open-PR/MR lookup (see the skill's "Platform specifics").
   - If none is open, inform the user and stop.
3. **Run the companion skill** — follow its full process (research, analysis, drafting) but **stop before the write/execute step**.
4. **Draft the comment.**
   - Take the companion skill's final drafted content as the comment body.
   - Present the full comment in chat using `output-diff` conventions.
   - Name the target PR/MR (number, title, URL).
5. **Post (only after approval).**
   - When the user explicitly approves, post via the platform's comment tool (see the skill's "Platform specifics").
   - Confirm the comment was posted.

## Key Principles

- **Always present before posting.** Never comment without user approval.
- **Never execute the companion skill's write action.** The output becomes a comment, not its original target.
- **Ask when ambiguous.** Multiple skills or unclear target → ask before doing anything.
