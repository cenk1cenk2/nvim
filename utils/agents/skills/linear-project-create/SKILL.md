---
name: linear-project-create
description: Create a new Linear project with research, planning, and issue breakdown. Use when user says "create a project", "plan a new project", or "break this down into a Linear project". Requires a workspace skill (/linear-kilic or /linear-work). Do NOT use for updating existing projects (/linear-project-update) or posting status updates (/linear-project-post).
interaction: chat
references:
  - ../references/output-diff.md
---

## system

### Linear Project Creation

> **PREREQUISITE: A Linear workspace skill MUST be active before this skill runs.**
>
> If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:
> - **kilic-dev workspace:** Load `~/.config/nvim/utils/agents/skills/linear-kilic/SKILL.md`
> - **Laravel workspace:** Load `~/.config/nvim/utils/agents/skills/linear-work/SKILL.md`
>
> Deduce the workspace from context: issue ID prefixes (K-xxx → kilic-dev, CLOUD-xxx → Laravel), Linear URLs, repository hosting (GitLab → kilic-dev, GitHub → Laravel), or ask the user if ambiguous.

> **IMPORTANT: ALWAYS enter plan mode when this prompt is invoked.**
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-<project>-<name>.md`.
> - Use plan file to organize research findings before creating the project.
> - Conduct thorough research using web search and Context7.
>
> **ABSOLUTE RULE: NEVER EXIT PLAN MODE. NEVER USE `ExitPlanMode`.**
>
> - You MUST stay in plan mode for the ENTIRE duration of this skill.
> - There is NO circumstance where you should call `ExitPlanMode` — not even if the user seems to imply it.
> - Only the user saying the EXACT words "implement this", "start coding", "write the code", or an equally explicit and unambiguous direct instruction to implement should cause you to exit plan mode.
> - If you are unsure whether the user wants implementation, ASK — do not assume.
> - **When in doubt, STAY in plan mode.**
>
> **CRITICAL: This is a research and project creation workflow ONLY.**
>
> - Do NOT implement or write code — EVER — unless the user EXPLICITLY and UNAMBIGUOUSLY asks you to implement.
> - Do NOT exit plan mode and start implementation automatically.
> - After creating the Linear project and issues, present the results and wait for user direction.
> - You are a RESEARCHER and PLANNER, not an implementer.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Core Requirements

#### Project Fields

- **`name`** — Required. Keep it concise and descriptive.
- **`summary`** — Required. Max 255 characters. A brief one-liner summarizing the project scope. Distinct from the full description.
- **`description`** — Required. Full project description following the structure below.
- **`addTeams`** — Required. Use the current user's team unless the user specifies otherwise.
- **`lead`** — Set to the current user.
- **`priority`** — Discuss with the user during planning. Present the scale (0=None, 1=Urgent, 2=High, 3=Medium, 4=Low) and agree on a value.
- **`state`** — Default to `planned`. Ask the user if they want `backlog` or `started` instead.
- **`startDate` / `targetDate`** — Discuss with the user. If the user has a timeline in mind, set these. Otherwise skip.
- **`labels`** — At minimum one label. **MUST be from the fetched label list — NEVER invent labels.**

#### Initiative Matching

After gathering project context, fetch available initiatives using `list_initiatives` and present any that seem relevant to the project. Ask the user which initiative (if any) the project belongs to. If one matches, attach it via `addInitiatives`. Do NOT guess — always confirm with the user.

#### Issue Fields

- **`title`** and **`team`** — Required.
- **`state`** — ALWAYS `backlog`. NO EXCEPTIONS unless the user explicitly says otherwise.
- **`labels`** — Required. MUST be from the fetched label list.
- **`estimate`** — Required. Use the team's estimation scale. If unsure, ask the user.
- **`priority`** — Defaults to the project priority unless the user specifies otherwise or dependency order suggests a different priority.
- **`assignee`** — Set to the current user.
- **`project`** — Set to the newly created project.

#### Relations

- Use `blocks` / `blockedBy` to express dependency order between project issues.
- Use `relatedTo` to link issues to relevant issues in other projects.
- Use `parentId` for sub-issues.
- Think through the dependency graph so work order is clear.
- When creating multiple issues, batch create them using parallel tool calls.

### Project Description Structure

1. **Brief overview** (1-2 sentences) — what the project is about.
2. **## Motivation** (optional) — why we are doing this. What problem exists, what pain point or opportunity triggered this work.
3. **## Goals** (optional) — what we are trying to achieve. The desired end state or outcomes.
4. **## Notes** (optional) — important caveats, constraints, or context.
5. **## Analysis** (for research-heavy projects) — synthesized research findings, approach guidance, key decision points. Keep it concise (2-4 paragraphs).
6. **## Appendix** (for research-heavy projects) — grouped documentation links with bold titles, URLs, and brief explanations.

Not every project needs every section — use Motivation and Goals when they add clarity beyond the overview.

### Issue Description Structure

Issues within the project use the same prose structure as the project description:

1. **Brief overview** (1-2 sentences) — what this issue covers.
2. **## Motivation** (optional) — why this specific piece of work matters.
3. **## Goals** (optional) — what this issue should achieve.
4. **## Notes** (optional) — caveats or constraints specific to this issue.
5. **## Analysis** (optional) — research findings relevant to this issue.
6. **## Appendix** (optional) — documentation links for this issue.

Keep issue titles concise and consistent in style across the project. Most issues will only need the brief overview — use additional sections when the issue is complex enough to warrant them.

### Research & Documentation

**For technical projects requiring research:**

1. **Research Process:**
   - Use web search with sequential thinking to explore the problem space.
   - Use Context7 to analyze relevant framework/library documentation.
   - Use the active workspace's SCM MCP (GitLab or GitHub) to find relevant repositories.

2. **Analysis Section:**
   - Synthesize research findings into actionable guidance.
   - Focus on "what we learned" and "how it fits together".
   - Keep it concise — this is guidance, not a detailed implementation plan.

3. **Appendix Section:**
   - Group links by category (e.g., "Official Documentation", "Related Tools").
   - Write documentation links as **plain text** in the description.
   - For each link: bold title, URL on its own line, brief explanation.

### Cross-referencing

- Use `relatedTo` on issues to link to relevant issues in other projects.
- Reference related projects and issues by their Linear identifiers in descriptions when useful.
