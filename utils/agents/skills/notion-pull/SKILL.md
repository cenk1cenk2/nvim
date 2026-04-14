---
name: notion-pull
description: "Pull a Notion page into the current editor as markdown. Use when user says 'pull from Notion', 'fetch Notion page', 'import from Notion', or provides a Notion URL to pull. Converts title to # heading and metadata to frontmatter. Do NOT use for pushing (notion-push) or session init (notion-work)."
interaction: chat
disable-model-invocation: true
argument-hint: "[notion-url or search description]"
references:
  - ../references/claude-ai-connectors.md
---

## system

### Notion Pull: Page to Markdown

> **DO NOT enter plan mode.** This is an interactive, quick-turnaround skill.

> **PREREQUISITE:** The `notion-work` skill MUST be active before this skill runs.
> If no Notion workspace context exists in the current session, auto-invoke `notion-work` first.

> **Deferred tools:** Notion tools are claude.ai connector tools (`mcp__claude_ai_Notion__*`) — load via `ToolSearch` before use:
> `ToolSearch({ query: "select:mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-search" })`

### Process

**Step 1: Resolve the page.**

- **If the user provides a Notion URL or page ID:**
  - Use `notion-fetch` to retrieve the page directly.

- **If the user provides a description or query:**
  - Use `notion-search` with the query.
  - Present the search results to the user as a numbered list (title, URL, last edited).
  - **Wait for the user to select a result.** Do NOT proceed without explicit approval.
  - Fetch the selected page via `notion-fetch`.

**Step 2: Convert to markdown.**

Parse the fetched page content into markdown format:

1. **Title** — the page title becomes the first `# heading` in the document.
2. **Frontmatter** — page metadata and properties become YAML frontmatter:
   - Include all page properties (status, tags, dates, people, relations, etc.).
   - Use the property name as the YAML key (lowercase, hyphens for spaces).
   - Format dates as ISO 8601.
   - Format people as display names.
   - Format relations as page titles or IDs.
   - Include the Notion page URL as `notion-url` in frontmatter for round-trip support.
3. **Body** — the page body content becomes markdown below the heading.
   - Preserve Notion's markdown formatting (bold, italic, code, lists, toggles, callouts).
   - Convert Notion-specific blocks to closest markdown equivalents.

**Step 3: Determine the target.**

- Use `vim__vim_status` to check the current buffer.
- If the buffer is empty or unnamed, write the markdown content there.
- If the buffer has existing content, ask the user: write to current buffer (replacing content) or create a new file?

**Step 4: Write the file.**

- Use `neovim__edit_file` to write the converted markdown to the target buffer.
- Confirm to the user: page title, number of properties converted, and where the file was written.

### Markdown Format

```markdown
---
notion-url: https://www.notion.so/page-id
status: In Progress
tags:
  - engineering
  - api
created: 2026-01-15
last-edited: 2026-03-10
author: Jane Doe
---

# Page Title

Body content here...
```

### Key Principles

- **Always include `notion-url` in frontmatter** — enables round-trip with `notion-push`.
- **Search requires approval** — never auto-select a search result.
- **Preserve fidelity** — convert as much Notion formatting as possible to markdown equivalents.
- **Ask before overwriting** — if the target buffer has content, confirm with the user.
