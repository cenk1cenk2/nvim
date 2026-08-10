---
name: linear-initiative-create
description: 'linear-initiative-create Create a new Linear initiative with description and goals, linking orphan projects. Use for "create an initiative", "group these projects under an initiative". Requires /linear-kilic or /linear-laravel. Do NOT use for updating initiatives (/linear-initiative-update).'
references:
  - ../references/present-first.md
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/output-diff.md
---

## Linear Initiative Creation

Posture: `present-first`.
A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Process

1. **Gather requirements** — discuss with the user what the initiative is about, why it exists, and what it aims to achieve.
2. **Draft the initiative** — prepare `name`, `summary`, `description`, and other fields. Present to the user in logical chunks per `output-diff`.
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

Initiative description format per `linear-description-structure`.
