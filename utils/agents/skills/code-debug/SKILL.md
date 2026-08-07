---
name: code-debug
description: 'code-debug Debug a behavioral issue where code runs but produces wrong results; investigates via LSP, code hosting, web search, and terminal tools to find the root cause. Always manually invoked. Do NOT use for failed commands (code-task-failed) or code review (code-review-branch).'
disableModelInvocation: true
references:
  - ../references/present-first.md
  - ../references/tmux.md
argumentHint: "[description of the problem or paste the failing snippet]"
---

## Code Debugging

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Context

This skill is for **behavioral bugs** — code that runs without crashing but produces wrong results, unexpected side effects, or incorrect behavior. For command failures (build errors, test failures, lint errors), use `code-task-failed` instead.

## Process

### Step 1: Understand the Problem

The user provides a snippet, error description, or observed behavior. Before investigating, clarify:

- **"What is the expected behavior?"** — what should happen?
- **"What is the actual behavior?"** — what happens instead?
- **"Is this reproducible? Under what conditions?"** — always, sometimes, only with certain input?

If the user already provided clear expected/actual behavior, skip redundant questions — don't ask what they already told you.

### Step 2: Locate the Code

- If the user provided a snippet, find its location in the codebase using Grep or `hyprpilot-nvim__lsp_workspace_symbols`.
- If the user described the problem area, use `hyprpilot-nvim__lsp_workspace_symbols`, `hyprpilot-nvim__lsp_document_symbols`, or treesitter `get_symbols` to locate relevant code.
- Read the file(s) involved using `hyprpilot-nvim__editor_read` or the built-in `Read` tool.

### Step 3: Trace the Logic

Follow the execution path from input to incorrect output:

- **Map the call chain** — use `hyprpilot-nvim__lsp_definition` and `hyprpilot-nvim__lsp_references` to trace how data flows through the code.
- **Check types and signatures** — use `hyprpilot-nvim__lsp_hover` to verify that types, return values, and parameters match expectations.
- **Read the surrounding context** — don't just read the failing line. Read the function, the caller, and the callee. Bugs often live one level above or below the obvious location.
- **Check conditionals and edge cases** — look for off-by-one errors, missing null checks, wrong comparison operators, inverted conditions.

### Step 4: Research

When the logic trace isn't enough:

- **Check git history** — use `git log` and `git diff` on the affected files. Was this code recently changed? Did it ever work correctly?
- **Search for known issues** — use GitHub/GitLab MCP to search for open issues in the project or upstream dependencies matching the symptoms.
- **Consult documentation** — use Context7 or web search to verify that APIs, library methods, or framework features are being used correctly.
- **Check LSP diagnostics** — use `hyprpilot-nvim__diagnostics_get` to see if there are warnings or errors the user might have missed.

Always consult the user before concluding that the issue is in an external dependency or upstream.

### Step 5: Form a Hypothesis

Before proposing a fix, state a clear hypothesis:

- **"The bug is caused by X because Y."**
- Support the hypothesis with evidence — the specific line, the type mismatch, the wrong condition, the API misuse.
- If multiple hypotheses exist, list them ranked by likelihood.

### Step 6: Verify the Hypothesis

If possible, verify before proposing the fix:

- **Reproduce mentally** — walk through the code path with the failing input and confirm the hypothesis explains the actual behavior.
- **Check related code** — does the same pattern exist elsewhere? Is it broken there too, or is there a clue about the intended usage?
- **Run a targeted test** — if the user agrees, run a minimal reproduction with `Bash`. Always describe the command and ask before running. To read output the user produced themselves, capture their pane with `tmux__capture-pane` instead — see the `tmux` reference for which overlay holds it.

### Step 7: Present Findings

```
## Debug Report: <brief description>

### Problem
<Expected vs. actual behavior, in one sentence each.>

### Root Cause
<What's wrong and why, with specific file:line references.>

### Evidence
<The trace — what you followed, what you found, how it leads to the incorrect behavior.>

### Proposed Fix
<Specific code changes to resolve the issue.>

### Verification
<How to confirm the fix works — test to run, behavior to observe.>
```

Wait for user approval before applying any fix.

## Key Rules

- **Understand before investigating** — always clarify expected vs. actual behavior first.
- **Trace, don't guess** — follow the code path using LSP tools. Don't hypothesize without reading the code.
- **One hypothesis at a time** — verify the most likely cause before exploring alternatives.
- **Consult the user before running commands** — describe the command and its purpose, wait for approval.
- **Consult the user before blaming externals** — don't attribute bugs to dependencies or upstream without evidence and user agreement.
- **Present findings first** — present findings and proposed fix, let the user decide when to proceed.

## Related Skills

- **`code-task-failed`** — for command failures (build errors, test failures, lint errors) rather than behavioral bugs. Auto-invoke when the problem is a command failure, not a behavioral issue.
