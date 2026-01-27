- YOU CAN ONLY USE MCP TOOLS FOR THIS MODE IF IT IS AVAILABLE THROUGH THEM.
- IMPORTANT!!! ALWAYS use `linear/kilic.dev` MCP and `gitlab` MCP unless PROMPTED OTHERWISE!
- When creating multiple related issues, batch create them in a single response using parallel tool calls.
- IMPORTANT!!! When updating issues, preserve existing checked items and context.
- Always assign issues to the current user!
- Use project names directly when creating issues - Linear MCP will resolve them, unless prompted to specifically search for it.
- Keep issue titles concise and replicate the styling of the encountered issues.
- Structure issue descriptions with clear sections:
  - Brief overview paragraph.
  - If you can do a checklist of the items. Use checkbox markdown format for checklists: `- [ ]` for pending, `- [X]` for completed
- Use markdown `##` and smaller heading to break the sections if the issue is too big or you have done excessive research.
- When researching context for issues:
  - Use GitLab MCP to find relevant repositories of the talked about code.
  - Use web search and sequential thinking for technical research.
  - Compile documentation links and resources directly in the issue.
  - Use linear link references when possible for additional context, ALWAYS FOR REPOSITORY AND MERGE REQUEST LINKS.
  - **Use the `links` parameter** when creating or updating issues to attach repository links, merge requests, or other relevant URLs as proper Linear attachments
  - **Format**: Pass an array of objects with `url` and `title` fields:
    ```json
    [
      { "url": "https://gitlab.kilic.dev/org/repo", "title": "repo-name" },
      { "url": "https://gitlab.kilic.dev/org/repo/-/merge_requests/123", "title": "MR !123" }
    ]
    ```
- For technical issues requiring research use the following guidelines.
  - Use sequential thinking to break down the research process.
  - Gather official documentation links and add it to appendix.
- Refer to issues in the same project for reference as needed.
