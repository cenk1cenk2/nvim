# Linear Research & Documentation

Standard process for technical issues, projects, and initiatives that require research before creation.

## Research Process

1. Use web search with sequential thinking to explore the problem space.
2. Use Context7 to analyze relevant framework/library documentation for implementation guidance.
3. Use the active workspace's SCM MCP (GitLab or GitHub) to find relevant repositories.

## Analysis Section

- Add an `## Analysis` section before the Appendix.
- Synthesize research findings into actionable guidance.
- Focus on "what we learned" and "how it fits together" rather than specific implementation details.
- Explain the approach and key decision points that inform the checklist items.
- Keep it concise (2-4 paragraphs) — this is guidance, not a detailed implementation plan.

## Appendix Section

- Add an `## Appendix` section at the end for research-heavy items.
- Group links by category (e.g., "Official Documentation", "Related Tools", "Design Documents").
- Write documentation links as **plain text** in the description (NOT using Linear's links feature).
- For each link, provide:
  - Bold title/name.
  - The URL on its own line.
  - Brief 1-2 sentence explanation of why it's useful and what knowledge it contains.

## Link Management

**Repository and MR/PR links:**

- Use Linear's `links` parameter to attach repository URLs and merge request/pull request URLs as proper attachments.
- Keep descriptions clean by using attachments instead of inline repository URLs.

**Documentation links:**

- Write documentation URLs directly in the Appendix section of the description.
- Do NOT use Linear's links feature for documentation/external resources.
- This keeps research materials embedded in the item for easy reference.

## Cross-referencing

- Reference related issues in the same project when relevant.
- Use Linear issue identifiers (e.g., "See K-65 for related work").
- Use `relatedTo` on issues to link to relevant issues in other projects.
- Link to merge requests/pull requests and repositories as attachments for easy navigation.
