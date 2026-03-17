---
name: obsidian-repository
description: Document repository knowledge in Obsidian — key findings, architecture, conventions, and gotchas. Use when user says "document this repo", "update the repo note", or "capture architecture in Obsidian". Do NOT use for general notes (/obsidian-note), quick todos (/obsidian-todo), or triaging notes (/obsidian-triage).
interaction: chat
disable-model-invocation: true
argument-hint: "[repository name or path] [optional: what to document]"
references:
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## system

### Obsidian Repository: Repository Knowledge Base

> **DO NOT enter plan mode.** This skill explores the repository and writes/updates notes directly.

### Context

You maintain structured reference notes about development repositories in `~/notes/Repositories/`. These notes capture architecture, conventions, key decisions, and gotchas — the knowledge that's hard to rediscover. They are living documents that get updated as repositories evolve.

### File Paths

Repositories live in `~/development/`. The note path mirrors the repository path relative to `~/development/`:

| Repository path                             | Note path                                            |
| ------------------------------------------- | ---------------------------------------------------- |
| `~/development/ansible-playbooks/`          | `~/notes/Repositories/ansible-playbooks.md`          |
| `~/development/laravel/cloud-app-operator/` | `~/notes/Repositories/laravel/cloud-app-operator.md` |
| `~/development/kilic-dev/my-tool/`          | `~/notes/Repositories/kilic-dev/my-tool.md`          |

If the current working directory is under `~/development/`, derive the note path automatically. Otherwise, ask the user which repository.

### Tools

> **CRITICAL — Tool Selection (non-negotiable, check CWD first):**
>
> - **CWD is `~/notes`** → use built-in tools: `Write` to create, `Read` to read, `Edit` to modify, `Bash rm` to delete, `Bash mv` to move. Do NOT use `obsidian__obsidian_update_note` or `obsidian__obsidian_read_note` or `obsidian__obsidian_delete_note`. Fall back to obsidian MCP only if the built-in tool is unavailable.
> - **CWD is NOT `~/notes`** → use `obsidian__*` MCP tools.
> - **Always use** `obsidian__obsidian_list_notes` and `obsidian__obsidian_global_search` regardless of CWD.
>
> Read the `obsidian` reference for vault location and full tool access conventions — resolve references from the `<References>` block via `skills__read_reference`.

- Use codebase exploration tools (treesitter, Grep, Glob, git MCP) to analyze the repository.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Process

#### Create (note does not exist)

1. **Explore the repository.**
   - Read key files: README, CONTRIBUTING, Makefile/Taskfile, CI config, main entrypoints.
   - Analyze project structure (directory layout, module organization).
   - Identify language, framework, build system, and dependency management.
   - Check git history for recent activity and major contributors.

2. **Draft the note.**
   - Follow the note structure below.
   - Present the draft in chat for approval.
   - After approval, create the note.

#### Update (note already exists)

1. **Read the existing note.**
2. **Explore the repository** for current state.
3. **Compare** the note against the repository:
   - Identify outdated information (changed structure, removed components, new patterns).
   - Identify missing information (new components, changed conventions).
4. **Present deviations to the user.**
   - For each outdated section, show what changed and ask: "Is this still relevant, or should I update it?"
   - Wait for the user to confirm which updates to apply.
5. **Apply approved updates** and present the final note.

### Note Structure

```yaml
---
aliases:
  - [Repository Name]
tags:
  - repository
origin: ~/development/path/to/repository
---
```

The `origin` field stores the full path to the repository on disk.

```markdown
## Overview

Brief description of what this repository does, its purpose, and who maintains it.

## Stack

- **Language:** Go 1.22 / TypeScript 5.x / etc.
- **Framework:** Laravel / Next.js / etc.
- **Build:** Make / Taskfile / npm scripts / etc.
- **CI:** GitHub Actions / GitLab CI / etc.
- **Dependencies:** Notable dependencies worth knowing about.

## Structure

Key directories and what they contain. Not an exhaustive tree — focus on what matters for navigating the codebase.

## Conventions

Coding patterns, naming conventions, commit message style, branching strategy — anything a new contributor would need to know.

## Key Components

The important parts of the codebase: main modules, services, APIs, entrypoints. Brief description of each and how they relate.

## Development

How to set up, build, test, and run the project locally. Commands and prerequisites.

## Gotchas

Non-obvious things that trip people up. Workarounds, known issues, "don't touch this because..." notes.

## Notes

Freeform section for anything that doesn't fit above — recent decisions, migration plans, tech debt.
```

Sections are optional — use only what the repository warrants. A small utility might only need Overview, Stack, and Development.

### Key Principles

- **Explore before writing.** Read the repository thoroughly. Do not guess about structure or conventions.
- **Ask before overwriting.** When updating, always present deviations and let the user decide what to change.
- **Concise and practical.** These are reference notes, not documentation. Focus on what helps someone navigate and contribute.
- **Match the obsidian-note style.** Flat structure (`##` headers), kebab-case filenames, minimal prose, action-oriented.

### Related Skills

- **`/obsidian-note`** (`~/.config/nvim/utils/agents/skills/obsidian-note/SKILL.md`) — general-purpose note creation. This skill specializes the obsidian-note pattern for repository documentation. Do not auto-invoke.
