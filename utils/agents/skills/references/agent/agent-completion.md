# Agent Completion Handoff

After all tasks are done, review passes, and verification succeeds, present the user with options for what to do with the work. Do not just stop — the user needs a clear handoff.

## Process

1. **Summarize what was done.**
   - Number of tasks completed.
   - Files changed (brief list or count).
   - Verification results (all passing).

2. **Present options.**

   ```
   All tasks complete. Verification passing.

   What would you like to do?
   1. Commit (locally, no push)
   2. Commit and push
   3. Create a PR/MR (invokes github-pr-create or gitlab-mr-create)
   4. Leave uncommitted (for manual review)
   ```

   - Detect the SCM platform (GitHub vs GitLab) and present the correct PR/MR option.
   - If changes are already committed (e.g., subagents committed per task), adjust options — skip "commit" and offer push/PR/leave as-is.
   - If in a worktree, mention that the worktree branch needs to be merged to the original branch first (or offer to do it).

3. **Execute the user's choice.**
   - **Commit:** Load `git-commit` — it owns staging, the message format, issue trailers, and the approval step. Pass it any issue ID or URL known from the task context.
   - **Push:** Commit (as above), then load `git-push`.
   - **PR/MR:** Load `github-pr-create` or `gitlab-mr-create`, which owns the description and the draft-or-ready decision.
   - **Leave uncommitted:** Confirm and stop. Note that changes are in the working tree.

4. **Confirm completion.**
   - State what was done: "Committed on branch `feature-x` with message: ..."
   - If PR created, include the PR URL.
