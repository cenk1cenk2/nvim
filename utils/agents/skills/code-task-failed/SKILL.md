---
name: code-task-failed
description: Investigate a failed command (build, test, lint, etc.) by capturing terminal output, analyzing errors, and systematically isolating the root cause. Always manually invoked. Do NOT use for behavioral bugs (code-debug) or code review (code-review-branch).
disable-model-invocation: true
references:
  - ../references/present-first.md
argument-hint: "[brief description of what failed, e.g., 'build failed', 'test suite', 'lint errors']"
---

## Code Failure Investigation

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Process

### Step 1: Capture the Failure

- Use `tmux__capture-pane` on the scratch pane to grab the terminal output.
- If the failure output is not visible in the pane (scrolled off or in a different pane), ask the user which pane or window contains the output.
- Extract the **error messages, stack traces, and exit codes** from the captured output.

### Step 2: Classify the Failure

Identify what kind of failure this is:

| Category | Signals |
|---|---|
| **Compilation / build error** | Syntax errors, type errors, missing imports, unresolved references. |
| **Test failure** | Assertion failures, expected vs. actual mismatches, timeout. |
| **Lint / format error** | Style violations, unused variables, formatting drift. |
| **Dependency error** | Missing packages, version conflicts, resolution failures, lockfile mismatch. |
| **Runtime / environment error** | Missing env vars, permission denied, port in use, config not found. |

The category determines the investigation path — don't apply build-error thinking to a dependency problem.

### Step 3: Ask the User

Before diving deep, ask:

- **"Is this a new failure or has it been happening?"** — recurring failures have different root causes than fresh ones.
- **"Did anything change recently?"** — code changes, dependency updates, environment changes, branch switches.
- **"Is there anything specific I should look at?"** — the user often has a hunch.

Wait for the user's response before proceeding. Their context narrows the search significantly.

### Step 4: Investigate

Based on the failure category and user context, investigate using available tools:

**For all failures:**
- Read the failing file(s) using `hyprpilot-nvim__editor_read` or the built-in `Read` tool.
- Check `git diff` (unstaged and staged) for recent changes that could have introduced the failure.
- Use `hyprpilot-nvim__diagnostics_get` to check for LSP errors in the relevant files.

**For dependency errors:**
- Read lockfiles and dependency manifests.
- Check if the dependency has known issues — use GitHub MCP to search the dependency's repository for open issues matching the error.
- Check if the dependency version changed recently (`git log` on lockfile).

**For test failures:**
- Read the failing test and the code it tests.
- Use treesitter or `hyprpilot-nvim` LSP tools (`lsp_definition`, `lsp_references`) to understand the call chain.
- If the test was passing before, use `git log` to find what changed in the tested code.

**For build/compilation errors:**
- Trace the error to the source — read the file and line referenced in the error.
- Check imports and dependencies of the failing module.
- Use `hyprpilot-nvim__lsp_hover` and `hyprpilot-nvim__lsp_definition` to verify types and references.

**For upstream/external issues:**
- Search GitHub/GitLab MCP for open issues on the relevant repository matching the error message or pattern.
- Check if this is a known bug with a workaround.
- Consult the user before assuming an external cause.

### Step 5: Isolate

If the root cause isn't immediately clear:

- **Narrow the scope** — re-run the failing command targeting a single file or test via tmux scratch pane.
- **Check if it reproduces** — sometimes failures are flaky. Run the command again before deep-diving.
- **Binary search recent changes** — if the failure is new, use `git log` and `git diff` to identify the introducing commit.

Always consult the user before running commands — describe what you want to run and why.

### Step 6: Present Findings

Present a concise report:

```
## Failure Analysis: <brief description>

### Error
<The exact error message, trimmed to the relevant part.>

### Root Cause
<What's causing the failure and why.>

### Evidence
<What you found — file paths, diffs, upstream issues, etc.>

### Proposed Fix
<Specific steps to resolve the issue.>

### Alternative Approaches (if applicable)
<Other options considered and why the proposed fix is preferred.>
```

Wait for user approval before applying any fix.

## Key Rules

- **Capture first, investigate second** — always start by reading the actual error output.
- **Never guess the error** — read it from the terminal. Don't assume what failed based on the user's description alone.
- **Consult the user before running commands** — describe the command and its purpose, wait for approval.
- **Consult the user before assuming external causes** — don't blame dependencies or upstream without evidence and user agreement.
- **Don't fix before understanding** — the investigation must produce a clear root cause before proposing a fix.
- **Present findings first** — present findings and proposed fix, let the user decide when to proceed.

## Related Skills

- **`code-debug`** — for behavioral bugs where code runs but produces wrong results. Auto-invoke when the problem is incorrect behavior, not a command failure.
