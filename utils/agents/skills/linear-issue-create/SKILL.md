---
name: linear-issue-create
description: Create new Linear issues with comprehensive analysis and research. Use when user says "create an issue", "file a bug", "add a task to Linear", or "create a ticket". Requires a workspace skill (linear-kilic or linear-laravel). ALWAYS set state explicitly — do NOT let issues go to Triage (API default). Do NOT use for updating existing issues (linear-issue-update), commenting (linear-issue-comment), or picking up issues (linear-issue-implement).
interaction: chat
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-mandatory-fields.md
  - ../references/linear-issue-states.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
  - ../references/plan-mode.md
  - ../references/output-diff.md
---

## system

### Linear Issue Creation

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives This is a research and issue creation workflow ONLY — do NOT implement or write code unless the user EXPLICITLY asks.
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`.
> - Conduct thorough research using web search and Context7.

### Core Requirements

> Read the `linear-mandatory-fields` reference for team, state, labels, estimate, priority, and relations rules.

> Read the `linear-issue-states` reference for state meanings, transition rules, and when to use which state.

Additional rules for issue creation:

- Always assign issues to the current user.
- When creating multiple related issues, batch create them in a single response using parallel tool calls.
- Use project names directly when creating issues — Linear MCP will resolve them, unless prompted to specifically search for it.
- Keep issue titles concise and replicate the styling of encountered issues in the same project.
- If the user creates an issue and also asks for a non-default status, create with the best matching explicit state or compose with `linear-issue-status` immediately after creation.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

> Read the `linear-project-documents` reference for packaging local/file reference context into Linear documents or comments when an issue points an implementation agent at files, screenshots, examples, or other context that may not be available from the issue text alone.

> Read the `linear-scm-discovery` reference when the user explicitly asks to enrich the issue from GitHub/GitLab or repository context. Use `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available. Use discovered facts to make the issue easier to implement, but do not run broad SCM discovery by default.

### Issue Structure

**Standard issue format:**

1. Brief overview paragraph (1-2 sentences explaining the issue/task).
2. Checklist immediately after overview (NO `## Checklist` header - just start checkboxes directly).
   - Use `- [ ]` for pending items.
   - Use `- [X]` for completed items.
3. Additional sections as needed (Requirements, Configuration Examples, etc.).
4. Analysis section (for research-heavy issues).
5. Notes section (optional - for important caveats or context).
6. Appendix (for research-heavy issues with documentation links).

**Markdown formatting:**

- Use `##` and smaller headings to break sections when issues are large or involve extensive research.
- Keep descriptions clean and scannable.

### Research & Documentation

**For technical issues requiring research:**

1. **Research Process:**
   - Use web search with sequential thinking to explore the problem space.
   - Use Context7 to analyze relevant framework/library documentation for implementation guidance.
   - When explicitly requested, use Sourcebot first when available to discover relevant repositories and existing patterns, then use the active workspace's SCM MCP (GitLab or GitHub) for related PRs/MRs, implementation boundaries, live metadata, and verification expectations.

2. **Analysis Section:**
   - Add an `## Analysis` section before the Appendix.
   - Synthesize research findings into actionable guidance.
   - Focus on "what we learned" and "how it fits together" rather than specific implementation details.
   - Explain the approach and key decision points that inform the checklist items.
   - Keep it concise (2-4 paragraphs) - this is guidance, not a detailed implementation plan.

3. **Appendix Section:**
   - Add an `## Appendix` section at the end for research-heavy issues.
   - Group links by category (e.g., "Official Documentation", "Related Tools", "Design Documents").
   - Write documentation links as **plain text** in the description (NOT using Linear's links feature).
   - For each link, provide:
     - Bold title/name.
     - The URL on its own line.
     - Brief 1-2 sentence explanation of why it's useful and what knowledge it contains.

### Link Management

**Repository and MR/PR links:**

- Use Linear's `links` parameter to attach repository URLs and merge request/pull request URLs as proper attachments.
- Keep issue descriptions clean by using attachments instead of inline repository URLs.

**Documentation links:**

- Write documentation URLs directly in the Appendix section of the description.
- Do NOT use Linear's links feature for documentation/external resources.
- This keeps research materials embedded in the issue for easy reference.

### Cross-referencing

- Use `relatedTo` field to link related issues (same or different projects).
- Use `blocks` / `blockedBy` fields for dependency relationships.
- Use `parentId` field for sub-issues.
- NEVER put dependency chains, sub-issue tables, or "## Dependencies" sections in issue descriptions — Linear shows these natively.
- Link to merge requests/pull requests and repositories as attachments for easy navigation.

### Related Skills

- **`linear-issue-status`** — lightweight status changes after creation or when the user verbally specifies a target state.
- **`linear-issue-checklist`** — checklist updates for created issues when the user immediately provides completion criteria changes.

### Examples

**User says:** "Create an issue for adding cert-manager to cluster-rubik"

1. Auto-invoke `linear-kilic` (GitLab context detected).
2. Enter plan mode.
3. Research cert-manager deployment patterns via web search and Context7.
4. Fetch labels and team from Linear workspace.
5. Draft issue with checklist, analysis, and appendix links.
6. Present draft to user for review.

**Result:** Linear issue created in backlog with labels, estimate, priority, and research appendix.

---

**User says:** "File a bug — the webhook handler returns 500 on empty payloads"

1. Auto-invoke workspace skill based on repo context.
2. Enter plan mode.
3. Research the webhook handler in the codebase.
4. Draft bug issue with reproduction steps and checklist.
5. Present draft to user.

**Result:** Bug issue created in backlog with clear reproduction steps and fix checklist.
