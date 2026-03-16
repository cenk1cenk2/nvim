---
name: config-repository
description: Create or revise repository knowledge base files (CLAUDE.md, AGENTS.md, or .local variants). Use when user says "update CLAUDE.md", "create AGENTS.md", "write repo knowledge base", "document decisions", or "snapshot this session". Do NOT use for the central AGENTS.md guidelines (/config-agents), skills (/config-skills), or MCP server configs (/config-mcp).
interaction: chat
disable-model-invocation: true
references:
  - ../references/mcp-output-transparency.md
argument-hint: "[local] [optional: what changed or focus area]"
---

## system

### Repository Knowledge Base

> **DO NOT enter plan mode.** This skill explores the repository and session context, then writes directly.

> Read the `mcp-output-transparency` reference for chunked change presentation — show reasoning + content blocks for each proposed section change before writing.

### Purpose

Maintain a structured knowledge base file in the repository root that helps future agent sessions understand the repo, avoid dead ends, and use the right tools. The file is not documentation for humans — it is context for agents.

### File Detection

1. **Check the repo root** for existing files in this order: `CLAUDE.md`, `AGENTS.md`.
2. **If the user says "local"** — target the `.local.md` variant instead (`CLAUDE.local.md` or `AGENTS.local.md`).
3. **If a file exists** — enter revise mode.
4. **If no file exists** — ask the user which to create (`CLAUDE.md` or `AGENTS.md`). Default suggestion: `CLAUDE.md`.
5. **Respect the existing filename** — if the repo has `AGENTS.md`, do not create a parallel `CLAUDE.md`. Work with what exists.

### Create Mode

When no knowledge base file exists yet:

1. **Explore the repository.**
   - Read: README, CONTRIBUTING, Makefile/Taskfile, CI config, main entrypoints, package manifests.
   - Analyze directory structure and module organization.
   - Check `git log` for recent activity, branching patterns, and commit style.
   - Identify language, framework, build system, and key dependencies.

2. **Review the current session** for context.
   - What was the user working on? What decisions were made?
   - What approaches were tried and failed?
   - What tools (MCP or otherwise) were used and how?

3. **Draft the full document** following the Document Structure below.
4. **Present the draft** in chat for approval.
5. **Iterate** based on user feedback.
6. **After approval**, create the file.

### Revise Mode

When the knowledge base file already exists:

1. **Read the existing file.**
2. **Review the current session** for new information:
   - New decisions or fork points.
   - Approaches that were tried and failed (or succeeded).
   - New conventions discovered or established.
   - Tools used in new ways.
   - Gotchas encountered.
   - Information that has become outdated.

3. **Compare** the session learnings against the existing file:
   - Identify sections that need updating.
   - Identify information that is now outdated or wrong — **mark for deletion**.
   - Identify new information that should be added.

4. **Present proposed changes** to the user:
   - For each change, show what exists and what you propose.
   - Explicitly call out deletions — explain why the content is outdated.
   - Group changes by section.

5. **Iterate** based on user feedback.
6. **After approval**, apply the changes. Delete outdated content without hesitation — this file must stay accurate and lean.

### Document Structure

The knowledge base file should contain these sections. All sections are optional — use only what the repository warrants. Order matters: general context first, decision history in the middle, tooling at the bottom.

```markdown
## Overview

What this repository does, why it exists, and how it is structured at a high level.
Keep it to 3-5 sentences. An agent reading this should immediately understand the repo's purpose.

## Stack & Structure

- **Language:** Go 1.22 / TypeScript 5.x / etc.
- **Framework:** Laravel / Next.js / etc.
- **Build:** Make / Taskfile / npm scripts / etc.
- **CI:** GitHub Actions / GitLab CI / etc.
- **Key directories:** brief map of what lives where.

## Conventions

Patterns, naming conventions, commit style, branching strategy, and anything a new agent session needs to follow. One line per convention.

## Decision Log

Fork points — what was decided, why, and what was rejected. This is the most important section for preventing wasted work.

- **[Decision title]**
  - Chose: [approach taken]
  - Why: [reasoning]
  - Rejected: [alternative] — [why it was worse or failed]

## Approaches Tried

Dead ends and failed experiments. Future sessions MUST read this before proposing solutions.

- [What was tried] → [why it failed or was abandoned]
- [What was tried] → [outcome and reason for stopping]

## Tools & MCP Usage

Which tools (MCP servers, CLI tools, scripts) are used in this repo, what for, and any quirks.

- `tool_name` — what it does in this repo, how to use it, gotchas.

## Gotchas

Non-obvious things that trip up agents or developers. Things that look like they should work but don't.
```

### Writing Rules

- **Always write how and why** — not just what. "We use X" is useless. "We use X because Y, and Z didn't work because W" is useful.
- **Be concise** — this file is loaded into agent context windows. Every line must earn its place.
- **Delete aggressively** — outdated information is worse than no information. If something changed, remove the old version entirely.
- **Decision Log is sacred** — never delete entries from the Decision Log unless the decision was reversed. Add new entries, update outcomes, but preserve the history of why choices were made.
- **Approaches Tried is append-mostly** — failed approaches stay forever so no one tries them again. Only remove if the underlying constraint changed (e.g., a library bug was fixed).
- **No fluff** — no "this file was last updated on...", no meta-commentary, no TODOs about what to document later. If you know it, write it. If you don't, skip the section.
- **Match existing style** — if the file already exists with a different structure, adapt to it rather than forcing the template. The sections above are a starting point, not a rigid schema.

### Key Principles

- **Session-aware.** The primary input for revisions is the current conversation — what was learned, what was decided, what failed. Read the session carefully before proposing changes.
- **Destructive updates are fine.** This is not a changelog. If a section is wrong, rewrite it. If a convention changed, update it. If an approach that "failed" now works, move it out of Approaches Tried.
- **Fork points matter most.** The Decision Log and Approaches Tried sections save the most time for future sessions. Prioritize these over everything else.
- **Tools section prevents tool misuse.** Documenting which MCP tools work well (and which don't) in this repo prevents future sessions from fumbling with wrong tools or missing useful ones.
