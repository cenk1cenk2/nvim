# Obsidian Vault Conventions

## Vault Location

The Obsidian vault is at `~/notes`.

## Tool Access

> **THIS IS NON-NEGOTIABLE. THE EMBEDDED OBSIDIAN MCP SERVER IS THE DEFAULT.**

Use the embedded `obsidian` MCP tools for vault operations. Tool names below use the stable short form; the runtime may surface them with a longer prefix such as `mcp__obsidian__vault_read`.

### Path Rules

- MCP tools take **vault-relative paths** such as `Todo/20260310T143022.md`, `Repositories/example/README.md`, or `Drawings/system.excalidraw.md`.
- Do not pass absolute `~/notes/...` paths to embedded Obsidian tools.
- CWD is irrelevant for MCP operations; the server owns the vault root.
- If a note path is ambiguous, list or search first and use the exact returned path.

### Core Vault Operations

| Operation | Tool | Notes |
|---|---|---|
| Read note | `obsidian__vault_read` | Reads full content and metadata, or a targeted heading/block/frontmatter field. |
| Create/overwrite note | `obsidian__vault_write` | Creates parent directories and overwrites existing files. Present changes first when overwriting. |
| Append note | `obsidian__vault_append` | Creates the file if it does not exist. |
| Patch note section | `obsidian__vault_patch` | Target a heading, block, or frontmatter key. Use idempotency guards for repeated appends. |
| Move/rename note | `obsidian__vault_move` | Preserves Obsidian links and file history. |
| Delete note | `obsidian__vault_delete` | Only delete after explicit confirmation unless the invoking skill says otherwise. |
| List directory | `obsidian__vault_list` | Use for top-level folders and known directories like `Todo/` or `Drawings/`. |
| Inspect note structure | `obsidian__vault_get_document_map` | Use before targeted reads or patches. |
| Open note in Obsidian | `obsidian__open_file` | UI operation only; not needed for normal reads/writes. |

### Search and Metadata

| Operation | Tool | Notes |
|---|---|---|
| Search by text | `obsidian__search_simple` | Use for content search and fuzzy user descriptions. |
| Search by metadata/path | `obsidian__search_query` | Use JsonLogic for tags, frontmatter, backlinks, or path globs. |
| List tags | `obsidian__tag_list` | Read-only tag inventory. |
| Get active file | `obsidian__active_file_get_path` | Use only when the user references the currently open Obsidian note. |
| Get periodic note | `obsidian__periodic_note_get_path` | Use for daily/weekly/monthly/quarterly/yearly notes. |

### Command Execution

| Operation | Tool | Notes |
|---|---|---|
| List commands | `obsidian__command_list` | Read-only inventory of every registered command id (core + plugins). |
| Run a command | `obsidian__command_execute` | Runs a command by id against the **currently active file/pane**. `open_file` the target first to focus it. Not auto-accepted — it can mutate the vault, so expect a prompt. |

Use this to drive plugin actions that have no dedicated tool. Example — the Excalidraw plugin's `obsidian-excalidraw-plugin:excalidraw-unzip-file` ("Decompress current Excalidraw file") converts a legacy `compressed-json` drawing to plain `json` in place so it can be parsed.

### Filesystem Fallback

If the embedded Obsidian MCP server is unavailable or a vault operation fails because the server cannot reach the vault, fall back to local filesystem operations under `~/notes` with absolute paths. Keep filesystem fallback secondary and report when it is used.

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
