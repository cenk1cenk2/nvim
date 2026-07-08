---
name: obsidian-repository
description: Document repository knowledge in Obsidian — key findings, architecture, conventions, and gotchas. Use when user says "document this repo", "update the repo note", "capture architecture in Obsidian", or "add a detailed note about X in this repo" — OR when the assistant detects that the Obsidian repo note has drifted from the actual repo state (architecture, conventions, components, gotchas) during a session (see AGENTS.md §VII "Knowledge Base Updates (Proactive)"); ALWAYS propose, never auto-apply regardless of session mode. Do NOT use for general notes (obsidian-note), quick todos (obsidian-todo), or triaging notes (obsidian-triage).
disable-model-invocation: true
argument-hint: "[repository name or path] [optional: what to document]"
references:
  - ../references/present-first.md
  - ../references/obsidian.md
  - ../references/output-diff.md
---

## Obsidian Repository: Repository Knowledge Base

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Context

You maintain structured reference notes about development repositories in the vault's `Repositories/` folder (`~/notes/Repositories/` on disk). These notes capture architecture, conventions, key decisions, and gotchas — the knowledge that's hard to rediscover. They are living documents that get updated as repositories evolve.

## File Paths

Repositories live in `~/development/`. The note path mirrors the repository path relative to `~/development/`:

Each repository gets a **folder**. The main overview note is `README.md` inside that folder. Detailed sub-topics get their own notes alongside it.

| Repository path                             | Vault-relative note path                               |
| ------------------------------------------- | ------------------------------------------------------ |
| `~/development/ansible-playbooks/`          | `Repositories/ansible-playbooks/README.md`             |
| `~/development/laravel/cloud-app-operator/` | `Repositories/laravel/cloud-app-operator/README.md`    |
| `~/development/kilic-dev/my-tool/`          | `Repositories/kilic-dev/my-tool/README.md`             |

**Sub-notes** live in the same folder:

```
Repositories/laravel/cloud-app-operator/
├── README.md                          # overview, stack, structure, conventions
├── envoy-gateway-analysis.md          # detailed migration analysis
└── deployment-topology.md             # cluster deployment details
```

If the current working directory is under `~/development/`, derive the folder path automatically. Otherwise, ask the user which repository.

## Tools

> **Tool access:** Use the embedded `obsidian` MCP tools from the `obsidian` reference for all vault operations. Paths are vault-relative; filesystem is fallback only.
>
> Read the `obsidian` reference for vault location and full tool access conventions — read the files listed in `references:` for the `obsidian-repository` skill.

- Use codebase exploration tools (treesitter, Grep, Glob, git MCP) to analyze the repository.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

### Create (note does not exist)

1. **Explore the repository.**
   - Read key files: README, CONTRIBUTING, Makefile/Taskfile, CI config, main entrypoints.
   - Analyze project structure (directory layout, module organization).
   - Identify language, framework, build system, and dependency management.
   - Check git history for recent activity and major contributors.

2. **Draft the note.**
   - Follow the note structure below for `README.md`.
   - Present the draft in chat for approval.
   - After approval, create the repository folder and `README.md`.

3. **Identify sub-note candidates (optional).**
   - If exploration revealed detailed standalone topics (migration analyses, architecture decisions, research findings), propose creating sub-notes.
   - Each sub-note should have its own context — if it needs the README for context, it belongs in the README instead.
   - Draft sub-notes and present for approval alongside or after the README.

### Update (note already exists)

1. **Read the existing note.**
2. **List existing sub-notes** in the repository folder via `obsidian__vault_list`.
3. **Explore the repository** for current state.
4. **Compare** the note against the repository:
   - Identify outdated information (changed structure, removed components, new patterns).
   - Identify missing information (new components, changed conventions).
   - Identify oversized sections that could be extracted to sub-notes (standalone topics with their own context, references, or findings).
5. **Present deviations to the user.**
   - For each outdated section, show what changed and ask: "Is this still relevant, or should I update it?"
   - For oversized sections, propose extracting to a sub-note and replacing with a brief summary + link in the README.
   - Wait for the user to confirm which updates to apply.
6. **Apply approved updates** and present the final note.

## Sub-Notes

Sub-notes are detailed reference documents for standalone topics within a repository. They live alongside `README.md` in the repository folder.

**When to create a sub-note** (vs keeping in README):

- The topic has its own context, findings, references, or action items.
- The section would exceed ~50 lines in the README.
- The topic is self-contained — someone could read it without the README.

**When to keep in README:**

- Brief conventions, stack info, or structural overview.
- Content that only makes sense in the context of the full repository note.

**Conventions:**

- **Naming:** kebab-case descriptive names matching the topic (e.g., `envoy-gateway-analysis.md`, `deployment-topology.md`).
- **Frontmatter:** same pattern as README — `aliases`, `tags: [repository]`, and `origin` field pointing to the repository path.
- **Linking:** README should link to sub-notes where relevant — inline in the appropriate section or in a dedicated section.
- **Structure:** flat `##` headers, same style as README. No fixed template — structure fits the topic.

## Note Structure (README.md)

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

## Plan Sections

When a repository note tracks an ongoing plan (multi-phase work, migrations, rollouts), use this structure per phase so the plan reflects both the intent and what was actually done.

**Each plan phase has:**

- A short 1–2 sentence main body — brief, scannable description of what the phase accomplishes and why. Keep it concise; details go in sub-sections.

**When a phase is completed, add these sub-sections under the phase (use `####`):**

- **`#### Implementation`** — what was actually done. Files changed, PRs/commits, verification steps. Brief but specific.
- **`#### Caveats`** — surprising behaviors, gotchas, or things that didn't match original assumptions. Omit if none.
- **`#### Deviations`** — where actual implementation differed from the original plan and why. Omit if none.

Omit any sub-section that has no content — don't write empty headers.

**Example:**

```markdown
### Phase 1 — Converge use2 to karpenter-v0.5.0

Bump the 5 remaining enterprise clusters (ent-cmsmax, davidsons, diagonal, foundry, govai) from `v0.3.6` to `v0.5.0` to match the rest of the use2 fleet.

#### Implementation

- PR #3909 (ent-foundry canary) and #3913 (remaining 4).
- Single-line change per cluster: `karpenter-version: karpenter-v0.3.6` → `v0.5.0`.
- Verified via `kubectl` on all 5 clusters: ArgoCD synced, controller pods healthy, NodePools on 300Gi disks, no errors.

#### Caveats

- Green/blue was already enabled on all 5 enterprise clusters — the earlier fleet audit incorrectly reported it as disabled.
```

## Key Principles

- **Explore before writing.** Read the repository thoroughly. Do not guess about structure or conventions.
- **Ask before overwriting.** When updating, always present deviations and let the user decide what to change.
- **Concise and practical.** These are reference notes, not documentation. Focus on what helps someone navigate and contribute.
- **Extract when it grows.** If a README section becomes a standalone topic with its own references and context, extract it to a sub-note.
- **Match the obsidian-note style.** Flat structure (`##` headers), kebab-case filenames, minimal prose, action-oriented.

## Related Skills

- **`obsidian-note`** — general-purpose note creation. This skill specializes the obsidian-note pattern for repository documentation. Do not auto-invoke.
