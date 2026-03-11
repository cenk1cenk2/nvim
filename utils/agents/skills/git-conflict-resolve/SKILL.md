---
name: git-conflict-resolve
description: Resolve git merge conflicts interactively. Use when user says "resolve conflicts", "fix merge conflicts", "there are conflicts", "help with rebase conflicts", or when git status shows unmerged paths. Detects conflicting files, analyzes each conflict, resolves clear cases autonomously, and asks the user for ambiguous or important conflicts. Do NOT use for general git operations (use git CLI or git MCP directly).
interaction: chat
references: ../references/scm-detect.md
---

## system

### Git Conflict Resolution

> **DO NOT enter plan mode.** This is an interactive, conflict-by-conflict resolution skill.

> Read the `scm-detect` reference for git MCP tool availability and CLI fallback rules — resolve references from the `<References>` block via `skills__read_reference`.

### Process

1. **Detect conflict state.**
   - Use `git__git_status` to identify unmerged paths (files with conflicts).
   - If git MCP is unavailable, fall back to `git status` via CLI.
   - If no conflicts are detected, inform the user and stop.
   - Note the operation in progress (merge, rebase, cherry-pick) from the status output.

2. **List all conflicting files.**
   - Present the list to the user with file paths.
   - Ask if they want to provide any high-level guidance before starting (e.g., "prefer our changes for config files", "keep theirs for the migration").

3. **Process each conflicting file.**
   - Read the file to find conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
   - For each conflict hunk in the file, analyze both sides:
     - **Ours** (current branch / HEAD side, above `=======`).
     - **Theirs** (incoming branch side, below `=======`).
   - Classify each hunk into one of these categories:

   | Category | Action |
   |----------|--------|
   | **Trivial — one side is empty** | Keep the non-empty side. Resolve autonomously. |
   | **Trivial — identical after whitespace normalization** | Keep either side. Resolve autonomously. |
   | **Clear — one side is a strict superset** | Keep the superset. Resolve autonomously. |
   | **Clear — user gave guidance that applies** | Follow user guidance. Resolve autonomously. |
   | **Ambiguous — both sides have meaningful changes** | Ask the user. |
   | **Ambiguous — semantic conflict (same area, different logic)** | Ask the user. |

4. **For autonomous resolutions:**
   - State what you chose and why in a brief one-liner per hunk.
   - Example: `file.ts:42 — kept theirs (ours was empty).`

5. **For ambiguous conflicts — ask the user:**
   - Show both sides with enough surrounding context (3-5 lines above and below).
   - Explain what each side does.
   - Suggest a resolution if you have an informed opinion, but let the user decide.
   - Offer options: **ours**, **theirs**, **both** (concatenated), or **custom** (user provides the merged version).
   - Wait for user response before proceeding.

6. **Apply resolutions.**
   - Edit the file to remove conflict markers and apply the chosen resolution using neovim MCP (`neovim__edit_file`).
   - If neovim MCP is unavailable, fall back to built-in Edit tool.
   - After resolving all hunks in a file, re-read the file to verify no conflict markers remain.

7. **Stage resolved files.**
   - After all conflicts in a file are resolved, stage it with `git add <file>` via git MCP or CLI.

8. **Final summary.**
   - List all resolved files and the strategy used for each.
   - If a rebase or merge is in progress, inform the user of the next step (e.g., `git rebase --continue`, `git merge --continue`).
   - Do NOT run the continue command automatically — let the user decide when to proceed.

### Key Principles

- **Autonomy for the obvious, consultation for the ambiguous.** Resolve clear-cut conflicts without asking. Ask for anything that requires judgment.
- **Respect user guidance.** If the user says "prefer theirs for X files", apply that consistently without re-asking.
- **Never lose code.** When in doubt, prefer keeping both sides and letting the user trim, over dropping one side silently.
- **One file at a time.** Process and fully resolve each file before moving to the next. This keeps the conversation focused.
- **Verify after resolving.** Always re-read the file after editing to confirm no stray conflict markers remain.
