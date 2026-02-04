## Linear Issue Management Guidelines

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`
> - Use plan file to organize research findings before creating Linear issues
> - Conduct thorough research using web search and Context7
>
> **CRITICAL: This is a research and issue creation workflow ONLY.**
>
> - Do NOT implement or write code unless explicitly requested by the user
> - Do NOT exit plan mode and start implementation automatically
> - After creating the Linear issue(s), present the results and wait for user direction
> - The goal is to research, plan, and document - NOT to implement

### Core Requirements

- **IMPORTANT!!! ALWAYS use `linear/kilic.dev` MCP and `gitlab` MCP unless PROMPTED OTHERWISE!**
- **IMPORTANT!!! When updating issues, preserve existing checked items and context.**
- Always assign issues to the current user
- When creating multiple related issues, batch create them in a single response using parallel tool calls
- Use project names directly when creating issues - Linear MCP will resolve them, unless prompted to specifically search for it
- Keep issue titles concise and replicate the styling of encountered issues in the same project
- ALWAYS!!! create issue in `backlog` state unless prompted otherwise, for things that is prompted as undecided work can be in `triage` state. You ALWAYS have to send `{"state": "backlog"}` to make this happen since default is triage.

### Issue Structure

**Standard issue format:**

1. Brief overview paragraph (1-2 sentences explaining the issue/task)
2. Checklist immediately after overview (NO `## Checklist` header - just start checkboxes directly)
   - Use `- [ ]` for pending items
   - Use `- [X]` for completed items
3. Additional sections as needed (Requirements, Configuration Examples, etc.)
4. Analysis section (for research-heavy issues)
5. Notes section (optional - for important caveats or context)
6. Appendix (for research-heavy issues with documentation links)

**Markdown formatting:**

- Use `##` and smaller headings to break sections when issues are large or involve extensive research
- Keep descriptions clean and scannable

### Research & Documentation

**For technical issues requiring research:**

1. **Research Process:**
   - Use web search with sequential thinking to explore the problem space
   - Use Context7 to analyze relevant framework/library documentation for implementation guidance
   - Use GitLab MCP to find relevant repositories of the discussed code

2. **Analysis Section:**
   - Add an `## Analysis` section before the Appendix
   - Synthesize research findings into actionable guidance
   - Focus on "what we learned" and "how it fits together" rather than specific implementation details
   - Explain the approach and key decision points that inform the checklist items
   - Keep it concise (2-4 paragraphs) - this is guidance, not a detailed implementation plan

3. **Appendix Section:**
   - Add an `## Appendix` section at the end for research-heavy issues
   - Group links by category (e.g., "Official Documentation", "Related Tools", "Design Documents")
   - Write documentation links as **plain text** in the description (NOT using Linear's links feature)
   - For each link, provide:
     - Bold title/name
     - The URL on its own line
     - Brief 1-2 sentence explanation of why it's useful and what knowledge it contains

### Link Management

**Repository and MR links:**

- Use Linear's `links` parameter to attach GitLab repository URLs and merge request URLs as proper attachments
- Format repository links: `{"url": "https://gitlab.kilic.dev/...", "title": "repo-name"}`
- Format MR links: `{"url": "https://gitlab.kilic.dev/.../merge_requests/123", "title": "MR !123"}`
- Keep issue descriptions clean by using attachments instead of inline repository URLs

**Documentation links:**

- Write documentation URLs directly in the Appendix section of the description
- Do NOT use Linear's links feature for documentation/external resources
- This keeps research materials embedded in the issue for easy reference

### Cross-referencing

- Reference related issues in the same project when relevant
- Use Linear issue identifiers (e.g., "See K-65 for similar work on nailbed cluster")
- Link to merge requests and repositories as attachments for easy navigation
