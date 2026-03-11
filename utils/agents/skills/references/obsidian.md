# Obsidian Vault Conventions

## Vault Location

The Obsidian vault is at `~/notes`.

## Tool Access

- **If CWD is `~/notes`:** Use standard file tools directly.
- **Otherwise:** Use `obsidian__*` tools to access the vault.

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
