---
name: notion-push
description: "Push the current markdown file to a Notion page. Use when user says 'push to Notion', 'update Notion page', 'sync to Notion', or wants to update a Notion document from local markdown. Converts # heading to title and frontmatter to metadata. Do NOT use for pulling (notion-pull) or session init (notion-work)."
interaction: chat
disable-model-invocation: true
argument-hint: "[notion-url or search description]"
references:
  - ../references/output-diff.md
---

## system

### Notion Push: Markdown to Page

> **DO NOT enter plan mode.** This is an interactive, quick-turnaround skill.

> **PREREQUISITE:** The `notion-work` skill MUST be active before this skill runs. If no Notion workspace context exists in the current session, auto-invoke `notion-work` first.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Process

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

**Step 1: Read the current file.**

- Use `vim__vim_status` to identify the current buffer.
- Read the file content via `neovim__read_file`.
- If the buffer is empty or has no content, inform the user and stop.

**Step 2: Parse the markdown.**

Extract the three components:

1. **Title** — the first `# heading` in the document becomes the Notion page title.
2. **Frontmatter** — YAML frontmatter between `---` delimiters becomes page properties/metadata.
   - Map YAML keys back to Notion property names.
   - Convert dates, people references, tags, and relations to their Notion property types.
   - The `notion-url` field (if present) is used to resolve the target page — do NOT push it as a property.
3. **Body** — everything after the `# heading` becomes the page body content.
   - Convert markdown formatting to Notion block equivalents.

**Step 3: Resolve the target page.**

Determine the Notion page to update, using this priority:

1. **Explicit argument** — if the user provided a URL or description with the command, use that.
2. **Frontmatter `notion-url`** — if the file has a `notion-url` in frontmatter, use it as the target.
3. **Ask the user** — if neither is available, ask for a URL or description.

- **If URL or page ID:** Target that page directly.
- **If description:** Use `notion_laravel__notion-search` with the query. Present results as a numbered list. **Wait for the user to select a result.** Do NOT proceed without explicit approval.

**Step 4: Confirm before pushing.**

Present a summary to the user before updating:

- Target page title and URL.
- Properties that will be updated (from frontmatter).
- Content length (approximate).
- Ask for explicit confirmation to proceed.

**Step 5: Push the content.**

- Use `notion_laravel__notion-update-page` to update the page with:
  - Page title from the `# heading`.
  - Properties from frontmatter.
  - Body content from the markdown.
- Confirm success to the user with the page URL.

### Key Principles

- **Always confirm before pushing** — show what will be updated and wait for approval.
- **Prefer `notion-url` from frontmatter** — enables seamless round-trip with `notion-pull`.
- **Search requires approval** — never auto-select a search result.
- **Preserve the local file** — pushing does not modify the local markdown file.
- **Report failures clearly** — if the update fails (permissions, page not found), explain the error and suggest next steps.
