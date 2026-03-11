# Obsidian Vault Conventions

## Vault Location

The Obsidian vault is at `~/notes`.

## Tool Access

> **THIS IS NON-NEGOTIABLE. CHECK YOUR CWD BEFORE EVERY FILE OPERATION.**

### When CWD is `~/notes` (you are inside the vault)

**Use built-in tools for all file operations.** You are already in the vault — obsidian MCP tools add unnecessary indirection.

| Operation | Tool | Example |
|---|---|---|
| Read note | `Read` (built-in) | `Read("Todo/20260310T143022.md")` |
| Create note | `Write` (built-in) | `Write("Todo/20260310T143022.md", content)` |
| Edit note | `Edit` (built-in) | `Edit("Todo/20260310T143022.md", old, new)` |
| Delete note | `Bash` | `rm Todo/20260310T143022.md` |
| Move/rename note | `Bash` | `mv Todo/old.md Work/new.md` |
| Find files | `Glob` (built-in) | `Glob("Todo/*.md")` |

**Fallback:** If a built-in tool is unavailable or fails, fall back to the equivalent `obsidian__*` MCP tool.

### When CWD is NOT `~/notes` (you are outside the vault)

Use `obsidian__*` MCP tools for all operations:

| Operation | Tool |
|---|---|
| Read note | `obsidian__obsidian_read_note` |
| Create/write note | `obsidian__obsidian_update_note` |
| Delete note | `obsidian__obsidian_delete_note` |
| Move/rename note | `filesystem__move_file` |

### Always use regardless of CWD

These obsidian MCP tools are **always preferred** because they are better than their built-in equivalents:

| Operation | Tool | Why |
|---|---|---|
| List notes | `obsidian__obsidian_list_notes` | Returns structured tree with filtering and recursion control. |
| Search vault | `obsidian__obsidian_global_search` | Searches across the entire vault with Obsidian's index. |

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
