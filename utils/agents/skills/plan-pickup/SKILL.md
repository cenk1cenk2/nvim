---
name: plan-pickup
description: Load and execute a plan file from a previous session. Use when user says "pick up this plan", "load the plan", "continue from this plan file", "apply the plan from", or "resume the plan". Do NOT use for creating plans (use /plan-handoff).
disable-model-invocation: true
argument-hint: "[plan-file-path or plan-name]"
references:
  - ../references/present-first.md
---

## Plan Pickup — Loading and Executing Existing Plans

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Context

This skill is the counterpart to `/plan-handoff`. It picks up a self-contained plan file created by a previous session and drives it through to implementation. The plan file is the single source of truth — it contains everything needed to understand the goal, context, and approach.

## Process

1. **Locate the plan file.**
   - If the user provides a file path, use it directly.
   - If the user provides a plan name or partial match, search `~/.claude/plans/` for matching files.
   - If no path is given, list recent plan files from `~/.claude/plans/` (sorted by modification time) and ask the user to pick one.

2. **Read the plan file completely.** Do not skim — read every section.

3. **Assess the plan.** Check the plan metadata and content:
   - **Status** — is it `draft` or `ready`?
   - **Mode** — is it `full` (complete plan) or `delegation` (requires research first)?
   - **Research Needed** — are there unchecked research items?
   - **Preliminary Steps** — are steps marked as unverified?

4. **Branch by assessment.**

### Complete Plan (no pending research)

5. **Present the plan summary** to the user:
   - Problem statement (1-2 sentences).
   - Goal and acceptance criteria.
   - Implementation steps overview.
   - Any originating context or cross-repo dependencies.
6. **Ask the user to confirm** before proceeding with implementation.
7. After approval, exit plan mode and implement step by step.

### Incomplete Plan (pending research or delegation mode)

5. **Complete all "Research Needed" items.** Use available MCP tools (LSP, git, GitHub/GitLab file reading, code search) to research each item.
6. **Revise the plan** based on research findings:
   - Replace "Preliminary Steps (Unverified)" with verified, concrete implementation steps.
   - Update "Repository Context" with discoveries.
   - Fill in any gaps in the plan.
   - Update the plan file status from `draft` to `ready`.
7. **Write the revised plan** back to the plan file.
8. **Present the revised plan** to the user:
   - What research was completed and key findings.
   - Updated implementation steps.
   - Any issues, risks, or deviations from the original plan.
9. **Ask the user to confirm** before proceeding with implementation.
10. After approval, exit plan mode and implement step by step.

## During Implementation

- Follow the plan steps sequentially.
- **Update the plan file** with any discoveries or deviations during implementation.
- If you encounter something that contradicts the plan, pause and inform the user before proceeding.

## Key Principles

- **Read completely before acting.** The plan file is self-contained — all context is there. Do not skip sections.
- **Research before implementation.** If the plan has pending research items, complete ALL of them before writing any code.
- **Never implement unverified steps blindly.** Preliminary steps are explicitly marked as unverified — they must be revised after research.
- **The plan file is a living document.** Update it with findings, revisions, and deviations as you go.
- **Assess honestly.** If the plan is incomplete or unclear, say so. Ask the user for clarification rather than guessing.
