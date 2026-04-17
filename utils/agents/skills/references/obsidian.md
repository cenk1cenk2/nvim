# Obsidian Vault Conventions

## Vault Location

The Obsidian vault is at `~/notes`.

## Tool Access

> **THIS IS NON-NEGOTIABLE. FILESYSTEM IS THE DEFAULT WHEN THE VAULT IS ACCESSIBLE.**

### When the vault (`~/notes`) is accessible on disk (default case)

**Use built-in tools for all file operations, with absolute paths.** You do not need to be inside the vault — CWD is irrelevant as long as `~/notes` exists and is readable.

| Operation | Tool | Example |
|---|---|---|
| Read note | `Read` (built-in) | `Read("~/notes/Todo/20260310T143022.md")` |
| Create note | `Write` (built-in) | `Write("~/notes/Todo/20260310T143022.md", content)` |
| Edit note | `Edit` (built-in) | `Edit("~/notes/Todo/20260310T143022.md", old, new)` |
| Delete note | `Bash` | `rm ~/notes/Todo/20260310T143022.md` |
| Move/rename note | `Bash` | `mv ~/notes/Todo/old.md ~/notes/Work/new.md` |
| Find files | `Glob` (built-in) | `Glob("~/notes/Todo/*.md")` |

**Availability check:** the vault is considered accessible if `~/notes` exists and is readable. On the local machine this is almost always true — filesystem is the default path.

**Fallback:** if a built-in tool is unavailable or the operation fails because the vault is not mounted, fall back to the equivalent `obsidian__*` MCP tool.

### When the vault is not accessible on disk (fallback)

Use `obsidian__*` MCP tools for all file operations:

| Operation | Tool |
|---|---|
| Read note | `obsidian__obsidian_read_note` |
| Create/write note | `obsidian__obsidian_update_note` |
| Delete note | `obsidian__obsidian_delete_note` |
| Move/rename note | `filesystem__move_file` |

### Always use MCP regardless of vault availability

These obsidian MCP tools expose capabilities that built-in tools cannot replicate — they are the **default**, not fallbacks:

| Operation | Tool | Why |
|---|---|---|
| List notes | `obsidian__obsidian_list_notes` | Structured tree with filtering, recursion control, and Obsidian metadata. |
| Search vault | `obsidian__obsidian_global_search` | Uses Obsidian's index — understands backlinks, tags, and frontmatter. |

## File Naming

- **Reference notes:** Kebab-case descriptive names — `wireplumber-source-selection.md`, `gitlab-ci-token-configuration.md`.
- **Todo notes:** Timestamp format — `YYYYMMDDThhmmss.md` (e.g., `20260310T143022.md`).

## Frontmatter

**Standard pattern (most notes):**

```yaml
---
aliases:
  - [Descriptive Title]
---
```

**With optional fields:**

```yaml
---
aliases:
  - [Descriptive Title]
tags:
  - tag1
bookmarks:
  - https://reference-url.com
---
```

## Writing Style

- **Concise and action-oriented** — focus on "how to do X", not explanations.
- **Practical examples** — include commands, code blocks with language identifiers.
- **Flat structure** — `##` headers for sections, no deep nesting.
- **Markdown links** — use `[text](url)` for external references. Do NOT use wikilinks `[[page]]`.
- **`bookmarks:` frontmatter** — for important reference URLs.
- **Minimal prose** — this vault is a reference system, not a knowledge base.
- **Match the category** — different categories have different conventions. Follow what you find, not a fixed template.

## Vault Exploration

Before creating or moving notes:

1. List directories to understand the current vault structure.
2. Identify which category the note belongs in.
3. Read 2-3 existing notes in the target category to learn its patterns (frontmatter fields, heading structure, level of detail, formatting).
4. Check `Templates/` for applicable templates before writing from scratch.
