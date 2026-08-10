---
name: config-repository
description: 'config-repository Create or revise repo knowledge base files (CLAUDE.md, AGENTS.md, .local variants). Triggers: "update CLAUDE.md", "create AGENTS.md", "document decisions", or detected durable conventions/rule drift mid-session. Do NOT use for the central AGENTS.md guidelines (config-agents), skills (config-skills), or MCP configs (config-mcp).'
disableModelInvocation: false
references:
  - ../references/current-state-only.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/redact-private-data.md
argumentHint: "[local] [optional: what changed or focus area]"
---

## Repository Knowledge Base

Posture: `present-first`.
## Purpose

Maintain a structured knowledge base file in the repository root that helps future agent sessions understand the repo, avoid dead ends, and use the right tools. The file is not documentation for humans — it is context for agents.

## Invocation Modes

The skill runs in two invocation modes. Classify before proceeding.

- **Manual invocation** (user typed `/config-repository` or asked to update the knowledge base): follow the full present-and-approve flow below.
- **Proactive invocation** (assistant self-triggered per AGENTS.md §VII "Knowledge Base Updates (Proactive)"): behavior depends on severity and session mode — see below.

**Proactive — fast-path criteria (skip present-and-approve, write directly):**

ALL of the following must hold:

1. Session is in **automatic mode** (user gave broad authorization via `go`/`y`/`yolo`/equivalent, or session runs under `/loop`/cron).
2. Change is **additive only** — pure append to a list-shaped section (`Approaches Tried`, `Gotchas`, `Tools & MCP Usage`).
3. Change does **not** touch `Decision Log`, `Overview`, `Conventions`, or `Stack & Structure`.
4. Change does **not** conflict with, reshape, or partially overlap existing content.
5. Target file is a per-repo `CLAUDE.md`/`AGENTS.md` (NOT the central `~/.config/nvim/utils/agents/AGENTS.md` — that file is always manual via `/config-agents`).

When all five hold: apply the edit, report the change in one sentence (section + summary), continue the session.

If any one fails: fall through to the full present-and-approve flow below.

## File Detection

1. **Check the repo root** for existing files in this order: `CLAUDE.md`, `AGENTS.md`.
2. **If the user says "local"** — target the `.local.md` variant instead (`CLAUDE.local.md` or `AGENTS.local.md`).
3. **If a file exists** — enter revise mode.
4. **If no file exists** — ask the user which to create (`CLAUDE.md` or `AGENTS.md`). Default suggestion: `CLAUDE.md`.
5. **Respect the existing filename** — if the repo has `AGENTS.md`, do not create a parallel `CLAUDE.md`. Work with what exists.

## Create Mode

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
4. **Present the draft** in chat per `output-diff` for approval.
5. **Iterate** based on user feedback.
6. **After approval**, create the file.

## Revise Mode

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

4. **Present proposed changes** to the user per `output-diff`:
   - For each change, show what exists and what you propose.
   - Explicitly call out deletions — explain why the content is outdated.
   - Group changes by section.

5. **Iterate** based on user feedback.
6. **After approval**, apply the changes. Delete outdated content without hesitation — this file must stay accurate and lean.

## Document Structure

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

## Constraints

Why the repo is shaped the way it is, stated as standing facts. This is where the reasoning behind a fork point belongs — as the constraint that still holds, not as an account of the decision.

- [Constraint] — [what it rules out, and why that alternative does not work here]

## Decision Log

**Opt-in — include only when the user explicitly asks for it.** Fork points as history: what was decided, why, what was rejected. Default to folding the durable half into `Constraints` instead.

- **[Decision title]**
  - Chose: [approach taken]
  - Why: [reasoning]
  - Rejected: [alternative] — [why it was worse or failed]

## Approaches Tried

**Opt-in — include only when the user explicitly asks for it.** Dead ends and failed experiments. Default to expressing the same knowledge as a `Gotchas` or `Constraints` entry phrased as current behaviour.

- [What was tried] → [why it failed or was abandoned]

## Tools & MCP Usage

Which tools (MCP servers, CLI tools, scripts) are used in this repo, what for, and any quirks.

- `tool_name` — what it does in this repo, how to use it, gotchas.

## Gotchas

Non-obvious things that trip up agents or developers. Things that look like they should work but don't.
```

## Writing Rules

> ⛔ **Present tense, current state only** — the full rule and its rewrite table are in `current-state-only`.
>
> A repo knowledge base is where this bites hardest: it is not a changelog, a migration record, or a
> postmortem. A reader must not be able to tell which parts are new.
>
> A rejected alternative is worth keeping **only as the constraint that rules it out** — the
> constraint stays true and useful, the narrative does not.
>
> When the user does explicitly ask for decision history, `Decision Log` and `Approaches Tried`
> are the sections for it, and nothing else in the file adopts that voice.

- **No private specifics** — keep customer names, account IDs, secrets, internal hostnames, and real resource IDs out of the file and its examples per `redact-private-data`; use placeholders.
- **Always write how and why** — not just what. "We use X" is useless. "We use X because Y, and Z doesn't work because W" is useful.
- **Be concise** — this file is loaded into agent context windows. Every line must earn its place.
- **Delete aggressively** — outdated information is worse than no information. If something changed, remove the old version entirely.
- **Constraints are append-mostly** — a constraint stays until the thing that causes it changes, because it is what stops the same dead end being walked again. Remove one only when it no longer holds.
- **Decision Log is sacred, when it exists** — in the opt-in case, never delete an entry unless the decision was reversed. Add entries and update outcomes, but preserve why choices were made.
- **No fluff** — no "this file was last updated on...", no meta-commentary, no TODOs about what to document later. If you know it, write it. If you don't, skip the section.
- **Match existing style** — if the file already exists with a different structure, adapt to it rather than forcing the template. The sections above are a starting point, not a rigid schema.

## Key Principles

- **Session-aware.** The primary input for revisions is the current conversation — what was learned, what was decided, what failed. Read the session carefully before proposing changes.
- **Destructive updates are fine.** This is not a changelog. If a section is wrong, rewrite it. If a convention no longer holds, replace it — do not leave the old one struck through or annotated.
- **Constraints matter most.** Knowing what does not work here, and why, saves more time than any other section. Prioritize it over everything except correctness of the current state.
- **Tools section prevents tool misuse.** Documenting which MCP tools work well (and which don't) in this repo prevents future sessions from fumbling with wrong tools or missing useful ones.
