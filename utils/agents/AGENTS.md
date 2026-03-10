# Assistant Guidelines

> **CRITICAL OVERRIDE**
>
> ALWAYS KEEP THESE RULES IN YOUR CONTEXT WINDOW.
>
> WHEN COMPACTING CONTEXT, DO NOT REMOVE THESE RULES.
>
> These guidelines define how to work effectively in future sessions.
>
> ALWAYS APPLY THESE RULES AT ANY POINT OF THE CONVERSATION WITH THE USER.

## I. SESSION INITIALIZATION

**FIRST ACTIONS** when starting a new session:

1. **READ MEMORY** - to load repository context

- Use `mcp__mcphub__memory__read_graph`,
- Understand project structure, coding standards, and past work
- Review entity relationships and observations
- Refresh knowledge of ongoing tasks

2. **DISCOVER MCP TOOLS** - Use `ToolSearch` (Claude Code's internal tool discovery mechanism) to find available MCP server tools
   - Search for key tool categories: `neovim`, `git`, `treesitter`, `mcp-diagnostics`, `context7`, `tmux`
   - Understand tool capabilities for this session
   - Note any tool limitations or unavailability
   - **If tools are unavailable, silently skip and continue** - tools may not always be loaded

3. **DISCOVER TMUX SCRATCH PANE** - If tmux MCP is loaded, identify the scratch pane for the current neovim session
   - List tmux sessions and find `root/nvim/<project-path>/scratch`
   - Resolve the pane ID for command execution during the session
   - **If no scratch session exists, CREATE one** — see "Creating a scratch session" below

4. **LOAD REPOSITORY NOTE** - If obsidian MCP is available, check for a repository note
   - Derive the note path from the current working directory relative to `~/development/` (e.g., `~/development/laravel/cloud-app-operator/` → `Repositories/laravel/cloud-app-operator`)
   - Read the note via `mcp__mcphub__obsidian__obsidian_read_note` with the derived path
   - If the note exists, treat its content as **established context** — architecture, conventions, stack, and gotchas documented there have already been verified and should inform your work throughout the session
   - **If the note does not exist or obsidian MCP is unavailable, silently skip and continue**

## II. PLANNING AND IMPLEMENTATION

### When to Use Plan Mode

**ALWAYS** use plan mode (`EnterPlanMode` tool) for complex implementation work.

**Enter plan mode when:**

- Task spans multiple files across different areas of the codebase
- User asks you to research, read remote code, or explore before implementing
- Task has multiple valid approaches or unclear requirements
- Making architectural changes or significant refactoring
- You would normally ask clarifying questions about approach

**Skip plan mode for:**

- Single-file or few-file changes where the approach is clear
- Tasks with explicit, detailed instructions provided by user
- Pure research/exploration tasks (use Task tool with Explore agent)
- Simple documentation updates
- Adding a straightforward feature where the implementation path is obvious

**Evaluate complexity first** — the threshold is whether the task genuinely requires multi-file research and design decisions, not just whether it touches multiple files. A "delete button on user profile" that needs a component + API call is straightforward. A "refactor authentication system" that touches 10 files with design tradeoffs warrants planning.

### Special Mode Triggers

User invokes specialized modes using personal slash commands (e.g., `/assistant`, `/linear`, `/note`). These are Claude Code personal skills stored in `~/.config/nvim/utils/agents/skills` directory. When a skill is invoked, follow the instructions in its SKILL.md — the skill instructions are the source of truth for each mode's behavior.

### Plan File Location

**CRITICAL:** All plan files MUST be created in `~/.claude/plans/`

**Never create plan files in:**

- Project directories
- Working directory
- Temporary locations

**File naming convention:**

```
~/.claude/plans/YYYY-MM-DD-<project-name>-<descriptive-name>.md
```

**Include the project name to make plans easier to find across different projects.**

**Examples:**

```
~/.claude/plans/2026-02-03-myapp-implement-auth-tokens.md
~/.claude/plans/2026-02-03-nvim-config-refactor-plugin-system.md
~/.claude/plans/2026-02-03-api-gateway-add-kubernetes-integration.md
```

**How to determine project name:**

- Use the repository name (e.g., `nvim-config`, `my-api`)
- Use the project directory name if no repository
- Keep it short and lowercase with hyphens
- Be consistent across plans for the same project

### Plan Structure

**Required sections in every plan:**

```markdown
# [Feature/Task Name]

## Context

- What problem are we solving?
- Why is this needed?
- Relevant background from codebase exploration

## Requirements

- What must the solution do?
- What constraints exist?
- What are the acceptance criteria?

## Approach

- High-level strategy
- Key architectural decisions
- Trade-offs considered

## Implementation Steps

1. [Step 1 - specific, actionable]
2. [Step 2 - specific, actionable]
3. ...

## Risks and Mitigations

- What could go wrong?
- How do we address it?

## Testing Strategy

- How will we verify this works?
- What test cases are needed?
```

### Planning Workflow

**1. Enter Plan Mode:**

```
User: "Add user authentication with JWT tokens"
→ Use EnterPlanMode tool
→ System transitions to plan mode
```

**2. Explore and Research:**

In plan mode, use tools to understand the codebase (see Section III for tool selection).

**IMPORTANT:** Explore until you understand:

- What needs to change and why
- Existing patterns and conventions to follow
- All files that will be affected by the changes
- Dependencies and potential side effects

**3. Draft the Plan:**

Write plan to `~/.claude/plans/YYYY-MM-DD-<project-name>-<name>.md`

- Document findings from exploration
- Outline clear, specific implementation steps
- Identify all files that need changes
- Note potential issues and solutions
- Include architectural decisions and rationale
- **Update memory** with a reference to the new plan file (path, date, task summary)
- Maintain at least the **last three plan files** in memory for historical context, you can get rid of the ones that are older than 3 months.

**4. Present Plan to User:**

**CRITICAL:** After drafting the plan, ALWAYS:

1. **Show the complete plan to the user**
2. **Ask for feedback and refinement**
3. **Iterate on the plan based on user input**
4. **Continue refining until user is satisfied**

**NEVER** immediately ask to switch to coding mode after creating the plan.

**Example plan presentation (structured summary format):**

> "I've drafted an implementation plan. Here's the structured overview:
>
> **Context:** Need to add JWT token authentication to replace session-based auth. Current system uses cookies which don't work for mobile API clients.
>
> **Requirements:**
>
> - Support JWT access and refresh tokens
> - Maintain backward compatibility with existing sessions
> - Token refresh mechanism for mobile clients
>
> **Approach:** Middleware-based approach using existing auth system as foundation. Add JWT validation layer that runs before session check.
>
> **Implementation Steps:**
>
> 1. Create JWT token generation utility in auth/tokens.ts
> 2. Add token validation middleware in middleware/auth.ts
> 3. Update login endpoint to return both session and JWT
> 4. Add refresh endpoint at /api/auth/refresh
> 5. Update API routes to accept Authorization header
>
> **Risks:** Token storage on client side, refresh token rotation complexity
>
> Would you like me to refine any part of this plan? I can adjust the approach, add more detail, or clarify sections."

**5. Exit Plan Mode (Only When Ready):**

**ONLY** use `ExitPlanMode` when:

- Plan has all required sections filled out
- User has explicitly approved the approach
- You can explain each implementation step clearly
- You understand what files need changes and why
- User explicitly requests to move to implementation

**Ask permission before exiting:**

> "The plan is ready. Would you like me to proceed with implementation, or should we refine anything further?"

**Wait for explicit approval before using ExitPlanMode.**

**6. Implement from Plan:**

After approval and exiting plan mode:

- Follow the plan steps sequentially
- Update plan file if you discover issues during implementation
- Reference plan file in commits and Linear comments

### Plan Updates During Implementation

**When implementation reveals new information:**

1. **Document the discovery** in the plan file
2. **Update affected sections** (approach, steps, files)
3. **Note the reason** for deviation from original plan
4. **Continue with updated plan**

**Example update:**

```markdown
## Implementation Updates

### 2026-02-03 15:30

Discovered existing token validation in `auth/validator.ts` that we can reuse. Updated Step 3 to integrate with existing code rather than reimplementing.
```

### Plan Mode Best Practices

**DO:**

- Explore thoroughly before planning (understand what, why, where, dependencies)
- Write specific, actionable implementation steps with file paths and function names
  - Good: "Create JWT token generation utility in auth/tokens.ts with generateAccessToken() and generateRefreshToken() functions"
  - Bad: "Implement the feature" or "Add token support"
- Document architectural decisions and rationale
- Present plan to user and iterate based on feedback
- Update the plan when you discover new information during implementation
- Reference the plan file in related commits and Linear comments
- Keep plan files in `~/.claude/plans/` for future reference

**DON'T:**

- Rush through planning to start coding
- Write vague steps like "implement the feature" or "add functionality"
- Immediately ask to switch to coding mode after drafting plan
- Exit plan mode without user approval
- Ignore the plan once implementation starts
- Create plan files outside `~/.claude/plans/`
- Delete plan files after implementation (keep for historical reference)
- Use ExitPlanMode unless you feel absolutely ready

### Quick Reference: Planning Workflow

**Complete planning process:**

```
1. User requests complex implementation
2. Use EnterPlanMode tool
3. Explore codebase thoroughly using available tools
4. Draft detailed plan in ~/.claude/plans/YYYY-MM-DD-<project-name>-<name>.md
5. Present plan to user
6. Ask for feedback and refinement
7. Iterate on plan based on user input
8. When plan is refined and user is satisfied:
   - Ask: "Would you like me to proceed with implementation?"
   - Wait for approval
9. Use ExitPlanMode (ONLY after approval)
10. Implement following the plan step-by-step
11. Update plan file if you discover new information
```

## III. TOOL SELECTION PRIORITY

**DECISION HIERARCHY** for choosing tools (highest priority first):

### 1. MCP Server Tools (Preferred)

Use MCP tools when available - they integrate with the editor and user's workflow:

| Task | Tool | When to Use |
| --- | --- | --- |
| **File reading** | `neovim` MCP | **ALWAYS first choice** for reading files — no exceptions (see File Operations) |
| **File editing** | `neovim` MCP | **ALWAYS** use `mcp__mcphub__neovim__edit_file` for editing existing files — no exceptions (see File Operations) |
| **File creation** | Built-in `create_file` | Use the builtin `create_file` tool for creating new files |
| Code navigation (definitions/references/hover) | `mcp-diagnostics` (native) | **ALWAYS first choice** for LSP operations — uses Neovim's running LSP clients. Tools: `lsp_definition`, `lsp_references`, `lsp_hover`, `lsp_document_symbols`, `lsp_workspace_symbols`, `lsp_code_actions`. Fallback: `treesitter` for structure, then Grep |
| **Renaming symbols** | `mcp-diagnostics` (native) | **ALWAYS use `lsp_rename` instead of find-and-replace or manual edits.** Single tool call renames across the entire workspace via LSP — the fastest way to rename. Accepts `new_name`, optional `path`/`line`/`col` to target. |
| Diagnostics (errors, warnings) | `mcp-diagnostics` (native) | Diagnostic analysis from running LSP servers. Tools: `document_diagnostics`, `workspace_diagnostics`, `diagnostics_summary` |
| Code structure analysis, AST queries | `treesitter` | Need to understand syntax structure, find patterns |
| Git operations | `git` MCP | Any git operation — available tools: `mcp__mcphub__git__git_status`, `git_diff_unstaged`, `git_diff_staged`, `git_diff`, `git_commit`, `git_add`, `git_reset`, `git_log`, `git_show`, `git_branch`, `git_checkout`, `git_create_branch` |
| **GitHub operations** (PRs, issues, repos, code search) | `github` MCP | **ALWAYS first choice** for any GitHub interaction. Fallback: `gh` CLI via tmux/Bash. Never use raw API calls |
| **GitLab operations** (MRs, issues, repos, pipelines) | `gitlab` MCP | **ALWAYS first choice** for any GitLab interaction. Fallback: `glab` CLI via tmux/Bash. Never use raw API calls |
| **Linear operations** (issues, projects, cycles, docs) | `linear` MCP | **ALWAYS first choice** for any Linear interaction. Two workspaces: `linear_kilic-dev` and `linear_laravel`. No CLI fallback |
| **Obsidian operations** (notes, search, tags) | `obsidian` MCP | **ALWAYS first choice** for vault operations. No CLI fallback — do not manipulate vault files directly |
| **Filesystem operations** (beyond neovim scope) | `filesystem` MCP | Directory trees, file info, media files. Fallback: built-in Glob/Read, then shell commands |
| Documentation lookup | `context7` | Need to reference official docs for libraries/frameworks |
| Shell command execution (visible to user) | `tmux` | Long-running commands, builds, tests, and commands the user should see — via neovim session's scratch pane |
| Web search | `web_search` (built-in) | **Preferred for web search** |
| Fetch webpage content | `fetch_webpage` (built-in) | **Preferred for extracting content from URLs** |
| Deep research / web search (last resort) | `tavily` MCP | **Last resort only.** Use when built-in web search and fetch are insufficient. Tools: `tavily-search`, `tavily-extract`, `tavily-crawl`, `tavily-map` |

#### Tmux Scratch Pane (Command Runner)

Each neovim session has attached tmux sessions following the pattern `root/nvim/<path>/<type>`. The `scratch` session is the command runner.

**Session types:**

- `root/nvim/<path>/scratch` — **Command runner.** Use this for executing commands.
- `root/nvim/<path>/lazygit`, `root/nvim/<path>/k9s`, etc. — **Observation panes.** Do NOT send commands to or capture output from these unless explicitly asked.

**Discovery:**

1. List tmux sessions (`mcp__mcphub__tmux__list-sessions`)
2. Find the session ending in `/scratch` that matches the current project path (dots replaced with underscores in path)
3. Get the pane ID from the session's active window

**Use tmux scratch pane for:**

- Build commands: `make`, `go build`, `npm run build`
- Test suites: `go test ./...`, `pytest`, `npm test`
- Linters and formatters: `golangci-lint run`, `eslint`, `black`
- Live config testing: `swaymsg reload`, `hyprctl reload`
- Deploy or infrastructure commands
- Any command the user should be able to observe in their terminal

**Execution workflow:**

1. Execute command via `mcp__mcphub__tmux__execute-command` with the pane ID
2. The tool returns a command ID for tracking
3. Retrieve results via `mcp__mcphub__tmux__get-command-result` using the command ID
4. **IMPORTANT:** `get-command-result` may return partial output (only lines near the end marker). For full output, use `capture-pane` after the command completes.
5. For long-running commands: poll `get-command-result` to detect completion (status changes from `pending` to `completed`), then use `capture-pane` if full output is needed.
6. **Avoid firing multiple commands in rapid succession** to the same pane — `get-command-result` can return output from a different command. Wait for one command to complete before sending the next, or use separate panes for parallel execution.

**Creating windows and panes:**

**ALWAYS** create a dedicated window (`create-window`) in the scratch session for your own command execution. Do NOT use the user's existing window/pane. The user's window is their workspace — create your own and use it for the entire session. For parallel commands, split panes within your dedicated window as needed.

**Use built-in Bash for:**

- Quick and dirty investigative commands that only the LLM needs (not visible to user)
- Short-lived lookups: `jq`, `wc`, `stat`, quick one-liners

**CRITICAL:** Only use tmux sessions matching `root/nvim/<project-path>/scratch`. Do NOT use other tmux sessions (e.g., `root/scratch`) as substitutes — they are not associated with the neovim session.

**Creating a scratch session:**

If the scratch session does not exist but tmux MCP is loaded and you need to run a command:

1. Derive the session name: `root/nvim/<path>/scratch` where `<path>` is the project directory with dots and special characters (except `/` and `-`) replaced by underscores. Slashes stay as-is.
   - Example: `/home/cenk/.dotfiles` → `root/nvim//home/cenk/_dotfiles/scratch`
   - Example: `/home/cenk/development/my-project` → `root/nvim//home/cenk/development/my-project/scratch`
2. Create a new tmux session with that name using `mcp__mcphub__tmux__execute-command` via Bash: `tmux new-session -d -s 'root/nvim/<path>/scratch'`
3. Then create your dedicated window in that session as usual, ideally named `agent` if you do not need multiple windows

**Fallback:** If tmux MCP is not loaded, silently fall back to the built-in Bash tool.

### 2. Claude Code Built-in Tools

- **`create_file`** - **ALWAYS use for creating NEW files.** This is the builtin tool for file creation.
- **Read** (`mcp__acp__Read`) - Reading file contents. **Only use when neovim MCP is not loaded.**
- **Edit** (`mcp__acp__Edit`) - Editing files. **Only use when neovim MCP is not loaded.** MUST read file first with Read.
- **Grep** - Text search across files
- **Glob** - File pattern matching

### 3. CLI Tools (Last Resort)

**ONLY** use CLI tools when neither MCP nor built-in tools can accomplish the task.

**NEVER USE** CLI tools for operations that specialized tools handle:

- `sed` or `awk` for editing - use neovim MCP or Edit
- `cat`, `head`, `tail` for reading - use neovim MCP or Read
- `echo >` or heredocs for writing - use Write
- `find` for file search - use Glob tool
- `grep` or `rg` for text search - use Grep tool
- Raw `git` commands WHENEVER POSSIBLE - use `mcp__mcphub__git__*` MCP server tools
- `gh` CLI for GitHub when `github` MCP is available — use `mcp__mcphub__github__*` first
- `glab` CLI for GitLab when `gitlab` MCP is available — use `mcp__mcphub__gitlab__*` first
- Direct vault file manipulation for Obsidian when `obsidian` MCP is available — use `mcp__mcphub__obsidian__*` first

### Graceful Degradation

**Unavailable (tool not loaded):**

1. Silently try the next tool in the hierarchy
2. Continue with best available option

**Rejected (tool loaded but operation failed/denied by user):**

1. STOP immediately — do not silently fall back
2. Ask the user for guidance before trying an alternative tool
3. Wait for explicit permission before proceeding

## IV. FILE OPERATIONS

> **MANDATORY:** Neovim MCP is the **ABSOLUTE FIRST CHOICE** for all file reading and editing operations — **NO EXCEPTIONS**. Do NOT use built-in Read/Edit tools, adapter-provided edit tools, or any other mechanism when neovim MCP is available. This is the single most important tool preference in this entire document.

> **EXCEPTION — Claude Code internal directories:** For files under `.claude/` or `~/.claude/` (including plans, skills, memory, CLAUDE.md, and any other Claude Code configuration), **ALWAYS use built-in Claude Code tools** (Read, Edit, Write) directly. Do NOT use neovim MCP for these paths. These are Claude Code's own configuration files and should be managed with its native tools.

### Reading Files

**Tool: `mcp__mcphub__neovim__read_file` — ALWAYS, without exception.**

- Fallback to `mcp__acp__Read` ONLY when neovim MCP is not loaded.

**If you think the file is not found at the expected location please search the repository for it because it might be renamed, moved or combined with something else. Do not assume that file that you expect is failed to create in a prior edit. Ask if unsure and can not find it.**

### Editing Files

**Tool: `mcp__mcphub__neovim__edit_file` — ALWAYS, without exception.**

- Do NOT use the adapter-provided `insert_edit_into_file` builtin tool — it bypasses the neovim MCP editing flow.
- Do NOT use `mcp__acp__Edit` or any other editing mechanism.
- Reading the file first is recommended for better understanding but not required — the neovim MCP edit tool handles context internally.
- The neovim MCP edit tool uses mcphub's EditSession with SEARCH/REPLACE blocks and provides fuzzy matching, interactive hunk-by-hunk review, and detailed feedback.
- Fallback to `mcp__acp__Edit` ONLY when neovim MCP is not loaded (and MUST read file first with `mcp__acp__Read` before editing).

### Creating New Files

Use the builtin `create_file` tool for creating new files. Do not use the edit tool to create files that do not exist yet.

### Listing and Finding Files

**Priority:**

1. `neovim` MCP - `mcp__mcphub__neovim__list_directory`, `mcp__mcphub__neovim__find_files`
2. Built-in `Glob` tool

### Editor Navigation (Showing Code to User)

Use vim MCP navigation tools to navigate the user's editor when referring to specific code locations or when the user wants to see something. **If these tools are unavailable, skip silently — do not fall back to other tools.**

**Available tools:**

| Tool                              | Purpose                                                                   |
| --------------------------------- | ------------------------------------------------------------------------- |
| `mcp__mcphub__vim__vim_status`    | Get current editor state (cursor, mode, filename, open buffers).          |
| `mcp__mcphub__vim__vim_file_open` | Open a file by path (reuses buffer if open), optionally jump to line/col. |
| `mcp__mcphub__vim__vim_jump`      | Jump to a specific line/column, optionally target a path or bufnr.        |
| `mcp__mcphub__vim__vim_select`    | Visually select a range of lines, optionally target a path or bufnr.      |

**Rules:**

- **Always ask before navigating.** The user's cursor position is their workspace — never move it without permission.
- Use `vim_status` to understand where the user currently is before suggesting navigation.
- When referring to a specific line of code in chat, offer: _"Want me to jump to that line in the editor?"_
- In assistant mode, when listing lines to change, offer to navigate to each location.
- Skip asking when the user explicitly requests navigation (e.g., "show me that file", "go to line 42").
- If the user seems lost or not following along, offer to show the relevant code in the editor.

## V. CODE STYLE AND COMMENTS

### General Coding Style

**Required conventions:**

- **Empty line before return** - Leave an empty line before the return statement when the function body has multiple statements. For single-statement functions or early-return guard clauses that are the only statement in their block, the empty line may be omitted.
- **No trailing whitespace** - Never leave empty spaces at the end of lines
- **YAML document separator** - Always start YAML files with `---` (document separator) unless explicitly stated otherwise or the other documents in the same folder do not follow this convention.

**Example:**

```python
# Required: multi-statement function
def calculate_total(items):
    total = sum(item.price for item in items)

    return total  # Empty line before return

# Not required: single-statement early return / guard clause
def get_name(self):
    if not self.name:
        return None  # No empty line needed — only statement in this block

    return self.name  # Empty line required — multi-statement function body
```

### Comment Policy

**NEVER** write comments or explanations in code unless one of these conditions is met:

1. **Explicitly requested** by user
2. **Existing pattern** in the file

**Decision Tree:**

```
Need to add function/code?
├─ Check surrounding code in file
├─ Does file have docstrings for functions? → Add docstring to new function
├─ Does file have inline comments? → Match density and style
├─ Does file have no comments? → Don't add comments
└─ Sparse comments only? → Keep additions minimal
```

**Example Scenarios:**

```python
# Scenario 1: File has docstrings
def existing_function():
    """Existing function with docstring."""
    pass

# Your addition SHOULD have docstring:
def new_function():
    """New function following pattern."""
    pass

# Scenario 2: File has no docstrings
def existing_function():
    pass

# Your addition should NOT have docstring:
def new_function():
    pass
```

**Output explanations to chat** - Don't use code comments to communicate with user. Write explanations directly in the chat window.

## VI. USER INTERACTION PATTERNS

### Handling Edit Rejections

When the user rejects an edit during the interactive review session:

**Actions:**

1. STOP immediately — do not retry with the same content.
2. Read the feedback from the edit session (match failures, rejected hunks, user modifications).
3. Ask the user what they would like changed.
4. Revise the edit based on feedback and try again.

### Handling Unexpected File State

When you notice a file doesn't match what you expected (e.g., your previous edits seem missing or changed):

**Analyze the situation.** If the file has been changed by the user and your new edit is to a **different part** of the file, just make your edit — no need to ask. If your new edit would touch the **same area** the user modified, and you believe it needs changing for correctness (syntax errors, security, breaking changes), explain why and make the change. Use your judgment — the goal is to avoid unnecessary interruptions while still being careful with the user's work.

### Learning from User Deviations

When the user overrides, rewrites, or modifies code you produced, treat it as a **teaching signal** — not a disagreement to resolve. Never fight back, revert, or silently undo user changes on subsequent edits.

**Detection — identify the category:**

- **Style:** formatting, naming, structure, indentation, ordering.
- **Logic:** different approach, edge case handling, algorithm choice.
- **Removal:** user deleted something you added (a comment, a guard clause, an abstraction).

**Analysis — before reacting:**

- Read surrounding code for context.
- Check if the user's change aligns with existing patterns in the file or project.
- Consider whether the deviation is a one-off fix or a recurring preference.

**Ask questions when the reasoning is not obvious:**

- Be specific: _"I see you changed X to Y — is this because of Z, or is there a different reason?"_
- Do NOT assume you understand the motivation. If there is any ambiguity, ask.
- Accept short answers — the user may say "preference" or "just cleaner" without elaboration. Respect that.

**Acknowledge briefly** — one sentence is enough: _"Got it — you prefer early returns over nested conditionals. I'll follow that pattern."_

**Apply to future edits:**

- Follow the learned pattern when editing the same file or similar code.
- You are **free to edit any area**, including areas the user modified. Do not avoid those areas — just incorporate the user's style and choices into your edits.
- Never silently revert a user's stylistic or logic choices when editing the same area.

**Save to memory when critical** — use `mcp__mcphub__memory__add_observations` when the deviation reveals a project-wide convention, a strong user preference that applies across sessions, or an architectural decision. Do NOT save one-off or ambiguous deviations.

### Markdown Output Formatting

When generating markdown content for project updates, documentation, or any external output, **always wrap technical terms in code blocks** (backticks) for clarity and consistency.

**Terms that should be code-blocked:**

| Category            | Examples                                             |
| ------------------- | ---------------------------------------------------- |
| Repository names    | `renovate/renovate-runner`, `cluster/charts`         |
| Tool/command names  | `kustomize`, `helmCharts`, `pulumi`, `kubectl`       |
| Cluster/host names  | `cluster-rubik`, `cluster-sun`, `renovate.kilic.dev` |
| File paths          | `.deploy/rubik/kustomization.yaml`, `src/workloads/` |
| CRD/resource types  | `RenovateJob`, `ApplicationSet`, `HTTPRoute`         |
| Package/chart names | `mogenius/renovate-operator`, `chart-cert-manager`   |
| Configuration keys  | `system.feature.kilic.dev/renovate-operator`         |
| Git references      | `HEAD`, `main`, `feature-branch`                     |

**Example:**

> "The workload configuration uses `kustomize` with nested `helmCharts` to deploy the `mogenius/renovate-operator` to `cluster-rubik`. The `RenovateJob` CRDs are defined in the `renovate/renovate-runner` repository."

**Not:**

> "The workload configuration uses kustomize with nested helmCharts to deploy the mogenius/renovate-operator to cluster-rubik. The RenovateJob CRDs are defined in the renovate/renovate-runner repository."

**Exceptions:** Plain English words, proper nouns (company names, product marketing names), and sentences where code blocks would hurt readability.

### Information Accuracy

**NEVER fabricate** information.

**When uncertain:**

1. Say "I don't know" honestly
2. Offer to search: "I'm not sure about X. Would you like me to search for current information?"
3. Use web search or documentation search for up-to-date info
4. Cite sources when providing searched information

**Don't guess** - especially for:

- API signatures or method names
- Configuration options or flags
- Version-specific behaviors
- File paths or structure

### Mandatory Research for External Technical Details

> **CRITICAL MANDATORY RULE — NO EXCEPTIONS.**
>
> You MUST verify ALL technical details from external projects, services, and APIs by reading the actual source code or documentation. NEVER write an assumed, guessed, or "likely" value into a plan or code. This applies even when you are "fairly confident" — confidence is not verification.

**Details that MUST be verified before use:**

- Callback URLs, redirect URIs, webhook paths, route paths
- API endpoints, query parameters, request/response formats
- Configuration keys, secret key names, environment variable names
- Default values, version-specific behaviors, feature flags
- Any technical detail originating outside the current repository

**Verification process (MANDATORY — do this BEFORE writing the detail anywhere):**

1. **Use the appropriate MCP tool to read the source:**
   - `github` MCP (`get_file_contents`, `search_code`) for open-source projects
   - `gitlab` MCP for internal repositories
   - `context7` for library/framework documentation
   - Web search / `tavily` as fallback
2. **Cite the source** — note the file path, doc URL, or code reference where you verified the information
3. **If you cannot verify, say so explicitly** — write "I could not verify this — please confirm" rather than writing an assumed value

**This rule is non-negotiable.** Having the right MCP tools available and choosing to guess instead of using them is a failure mode. The cost of one extra tool call is negligible; the cost of a wrong value propagating into infrastructure is not.

## VII. SESSION MAINTENANCE

### Memory Updates

**Update memory MCP server to track session progress.**

**When to update (batch approach with breakthrough exception):**

**Periodic Batch Updates** - accumulate learnings and write at milestones:

- After completing a major feature or milestone
- At end of significant work session
- When user pauses or switches context
- Before ending conversation

**Immediate Breakthrough Updates** - write immediately when:

- Discovered existing system/pattern you didn't know about
- Realized wrong assumption about architecture or approach
- Found significantly better approach than originally planned
- Learned critical pattern that fundamentally changes understanding
- User manually corrects your mental model with important information

**Example breakthrough:** You assumed database was PostgreSQL and designed SQL queries accordingly, then discovered it's actually MongoDB - update memory immediately to avoid repeating the mistake.

**What to batch:** Incremental learnings like coding style patterns, small decisions, file locations - accumulate these and write periodically at milestones.

**What to record:**

- Technical decisions and rationale
- Coding patterns and conventions discovered
- Project structure insights
- Implementation strategies
- Issues encountered and resolutions
- Architectural discoveries and assumptions corrected

**Use the mcphub memory (Knowledge Graph):**

- `mcp__mcphub__memory__create_entities` - Create new concepts/components
- `mcp__mcphub__memory__add_observations` - Add observations to entities
- `mcp__mcphub__memory__create_relations` - Create relationships between entities

**Memory scope:**

- **Project-scoped observations** → store on project entity (e.g., "cloud-mysql-operator uses Go modules", "this project's API uses camelCase")
- **General observations** → store on general entities like `Coding-Style` (e.g., "user prefers snake_case in Python", "conventional commit format", "language-level conventions")

### Project Management Integration

**Linear and other PM tools:**

**Comment format** - Be short and concise:

- Focus on **structural changes**, not file lists
- Describe **what changed** and **why**, not **where**
- Use technical terms precisely

**Example:**

> "refactored authentication to use token-based flow with refresh mechanism"

**Including plans:**

- Format plans so work can resume later
- Include context: what was decided, what's next
- Reference specific files/functions if needed for continuation

### Commit Messages

**ALWAYS** use conventional commit format:

```
<type>(<scope>): <brief description>

<detailed body if necessary>

BREAKING CHANGE: <description of breaking change if applicable>
```

**Types:** feat, fix, docs, style, refactor, test, chore

**Brief description:**

- Be concise
- Use imperative mood ("add" not "added")
- Don't end with period

**Example:**

```
feat(auth): implement token refresh mechanism

Add automatic token refresh using refresh tokens stored in httpOnly cookies.
Handles token expiration gracefully with retry logic.
```

## VIII. QUICK REFERENCE

### Common Scenarios

**Starting a new session:**

```
1. Read memory graph (skip silently if unavailable)
2. Discover MCP tools (skip silently if unavailable)
3. Discover tmux scratch pane (skip silently if unavailable)
4. Load repository note from Obsidian (skip silently if unavailable)
```

**User requests complex implementation:**

```
1. Use EnterPlanMode
2. Explore codebase thoroughly
3. Draft plan in ~/.claude/plans/YYYY-MM-DD-<project>-<name>.md
4. Present plan to user
5. Iterate based on feedback
6. Ask permission to proceed
7. Use ExitPlanMode (only after approval)
8. Implement following the plan
```

**User asks to read or edit a file:**

```
1. Read: neovim MCP (mcp__mcphub__neovim__read_file) — no exceptions
2. Edit: neovim MCP (mcp__mcphub__neovim__edit_file) — no exceptions
3. Create: builtin create_file tool
4. .claude/ or ~/.claude/ paths → use built-in Claude Code tools directly
5. Understand context and existing patterns (comment style, conventions)
```

**User asks for information you don't know:**

```
1. Say "I don't know"
2. Offer to search documentation or web
3. Use context7 MCP for docs or WebSearch
4. Provide answer with sources
```

**Using external technical details (URLs, paths, config keys, defaults):**

```
1. NEVER guess — verify from source code or docs BEFORE writing the value
2. Use GitHub/GitLab MCP to read actual source, Context7 for docs, web search as fallback
3. Cite the source (file path, doc URL, code reference)
4. If unverifiable, explicitly state so — never write an assumed value
```

**User manually edits your code (deviations):**

```
1. Detect category: style, logic, or removal
2. Analyze — read surrounding code, check project patterns
3. Ask if reasoning is not obvious (be specific)
4. Acknowledge briefly in chat
5. Apply learned pattern to future edits (free to edit same areas — just respect choices)
6. Save to memory only if it reveals a project-wide or cross-session preference
```

**Need to navigate code:**

```
1. Use mcp-diagnostics for definitions/references/hover (native server, always available)
2. Fall back to treesitter for structure analysis
3. Use Grep only if others unavailable
```

**Showing code to user in editor:**

```
1. Use vim_status to check current editor state (skip silently if unavailable)
2. Ask permission before navigating (unless user explicitly requested it)
3. Use vim_file_open / vim_jump to navigate
4. Use vim_select to highlight code ranges for the user
```

**Interacting with external services (GitHub, GitLab, Linear, Obsidian):**

```
1. MCP tool for that service (ALWAYS first choice)
2. Dedicated CLI tool (gh, glab) via tmux/Bash (fallback)
3. Raw shell commands / API calls (last resort, avoid)
```

**Completing a milestone:**

```
1. Update memory with key learnings
2. Add observations about patterns/decisions
3. Create entities for new components
4. Establish relations between entities
```

## Rule Priority

When rules appear to conflict, follow this priority order:

1. **Never fabricate information** (highest priority)
2. **User explicit instructions** - when user contradicts these guidelines, always ask for confirmation first
   - Example: User says "skip plan mode" for complex task
   - Response: "I notice this task involves [reasons why plan mode would help]. The guidelines recommend plan mode for this. Would you like me to proceed without planning, or would a quick plan be helpful?"
   - Wait for confirmation before proceeding against guidelines
3. **Use neovim MCP for reading and editing — no exceptions** (do not use adapter builtins, do not drift to built-in tools)
4. **Use preferred tools** (but degrade gracefully if unavailable)
5. **Follow coding style** (match project patterns)
6. **Update memory** (maintain continuity)
