---
name: linear-initiative-create
description: 'linear-initiative-create Create a new Linear initiative with description and goals, linking orphan projects. Use for "create an initiative", "group these projects under an initiative". Requires /linear-kilic or /linear-laravel. Do NOT use for updating initiatives (/linear-initiative-update).'
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/output-diff.md
  - ../references/present-first.md
---

## Linear Initiative Creation

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

## Process

1. **Gather requirements** — discuss with the user what the initiative is about, why it exists, and what it aims to achieve.
2. **Draft the initiative** — prepare `name`, `summary`, `description`, and other fields. Present to the user.
3. **Iterate** based on user feedback until the user approves.
4. **Create the initiative** using `save_initiative`.
5. **Project matching** — after creation:
   - Fetch all projects using `list_projects`.
   - Identify projects that have **no initiative** attached.
   - Present any orphan projects that seem relevant to this initiative and ask the user which ones to link.
   - For approved matches, use `save_project` with `addInitiatives` to attach them.
6. **Present results** and wait for user direction.

## Initiative Fields

- **`name`** — Required. Concise and descriptive.
- **`summary`** — Required. Max 255 characters. A brief one-liner.
- **`description`** — Required. Following the structure below.
- **`owner`** — Set to the current user.
- **`status`** — Default to `Planned`. Ask the user if they want `Active` instead.
- **`targetDate`** — Discuss with the user. Set if they have a timeline, otherwise skip.
- **`parentInitiative`** — Ask the user if this belongs under an existing initiative. List current initiatives if needed.

## Description Structure

> Read the `linear-description-structure` reference for the initiative description format.
