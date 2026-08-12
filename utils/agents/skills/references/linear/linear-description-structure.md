# Linear Description Structure

Standard structure for Linear issue, project, and initiative descriptions. Not every item needs every section — use additional sections when they add clarity beyond the overview.

## Issue Descriptions

1. Brief overview paragraph (1-2 sentences explaining the issue/task).
2. Checklist immediately after overview (NO `## Checklist` header — just start checkboxes directly).
   - Use `- [ ]` for pending items.
   - Use `- [X]` for completed items.
3. Additional sections as needed (Requirements, Configuration Examples, etc.).
4. `## Analysis` (for research-heavy issues) — synthesized research findings, approach guidance, key decision points. Keep it concise (2-4 paragraphs).
5. `## Notes` (optional) — important caveats or context.
6. `## Appendix` (for research-heavy issues) — grouped documentation links.

## Project Descriptions

1. Brief overview (1-2 sentences) — what the project is about.
2. `## Motivation` (optional) — why we are doing this. What problem, pain point, or opportunity triggered this work.
3. `## Goals` (optional) — what we are trying to achieve. The desired end state or outcomes.
4. `## Notes` (optional) — important caveats, constraints, or context.
5. `## Analysis` (for research-heavy projects) — synthesized research findings. Keep concise (2-4 paragraphs).
6. `## Appendix` (for research-heavy projects) — grouped documentation links with bold titles, URLs, and brief explanations.

## Initiative Descriptions

1. Brief overview (1-2 sentences) — what the initiative is about.
2. `## Motivation` (optional) — why this initiative exists. What problem, pain point, or opportunity triggered it.
3. `## Goals` (optional) — what we are trying to achieve. The desired end state or outcomes.

## Markdown Formatting

- Use `##` and smaller headings to break sections when descriptions are large or involve extensive research.
- Keep descriptions clean and scannable.
- Keep issue titles concise and consistent in style across the project.

## The Normaliser Rewrites What You Send

Linear normalises markdown on write, and two constructs come back broken. **Both fail silently — the write succeeds either way, so read the echoed body back and look at it.**

- **A line ending in bold, immediately before a line starting with bold, merges into `****`.** Patching the whitespace does not fix it; Linear re-normalises straight back. Change the content so the line does not end in bold.
- **Strikethrough spanning an inline code span shreds**, leaking the tildes inside the code and stranding nearby bold markers. Never wrap a code span in `~~`; strike a pure-prose phrase or nothing.

**For an item that is now resolved, lead with a bold `RESOLVED <date>:` rather than striking the original text.** It sidesteps both traps and stays readable in a long checklist.
