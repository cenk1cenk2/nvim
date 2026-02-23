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
   - Search for key tool categories: `neovim`, `git`, `treesitter`, `cclsp`, `context7`, `tmux`
   - Understand tool capabilities for this session
   - Note any tool limitations or unavailability
   - **If tools are unavailable, silently skip and continue** - tools may not always be loaded

3. **DISCOVER TMUX SCRATCH PANE** - If tmux MCP is loaded, identify the scratch pane for the current neovim session
   - List tmux sessions and find `root/nvim/<project-path>/scratch`
   - Resolve the pane ID for command execution during the session
   - **If no scratch session exists, CREATE one** — see "Creating a scratch session" below

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

User invokes specialized modes using personal slash commands (e.g., `/assistant`, `/linear`, `/note`). These are Claude Code personal skills stored in `~/.claude/skills/`. When a skill is invoked, follow the instructions in its SKILL.md — the skill instructions are the source of truth for each mode's behavior.

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
| **File reading and editing** | `neovim` | **ALWAYS first choice** for reading and editing files (see File Operations) |
| Code navigation, find definitions/references | `cclsp` | LSP server available for the language. **No fallback exists** — if cclsp is unavailable, use Grep as a last resort |
| Code structure analysis, AST queries | `treesitter` | Need to understand syntax structure, find patterns |
| Git operations | `git` MCP | Any git operation — available tools: `mcp__mcphub__git__git_status`, `git_diff_unstaged`, `git_diff_staged`, `git_diff`, `git_commit`, `git_add`, `git_reset`, `git_log`, `git_show`, `git_branch`, `git_checkout`, `git_create_branch` |
| Documentation lookup | `context7` | Need to reference official docs for libraries/frameworks |
| Shell command execution (visible to user) | `tmux` | Long-running commands, builds, tests, and commands the user should see — via neovim session's scratch pane |

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

Use **ONLY** when the corresponding MCP server tools are not loaded:

- **Read** (`mcp__acp__Read`) - Reading file contents. **Only use when neovim MCP is not loaded.**
- **Edit** (`mcp__acp__Edit`) - Editing files. **Only use when neovim MCP is not loaded.** MUST read file first with Read.
- **Write** (`mcp__acp__Write`) - **Always use for creating NEW files** (neovim MCP write does not work properly for new file creation)
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

### Graceful Degradation

**Unavailable (tool not loaded):**

1. Silently try the next tool in the hierarchy
2. Continue with best available option

**Rejected (tool loaded but operation failed/denied by user):**

1. STOP immediately — do not silently fall back
2. Ask the user for guidance before trying an alternative tool
3. Wait for explicit permission before proceeding

## IV. FILE OPERATIONS

> **MANDATORY:** Neovim MCP is the **ABSOLUTE FIRST CHOICE** for all file reading and editing operations. Do NOT drift to using built-in Read/Edit tools when neovim MCP is available. This is the single most important tool preference in this entire document.

> **EXCEPTION — Claude Code internal directories:** For files under `.claude/` or `~/.claude/` (including plans, skills, memory, CLAUDE.md, and any other Claude Code configuration), **ALWAYS use built-in Claude Code tools** (Read, Edit, Write) directly. Do NOT use neovim MCP for these paths. These are Claude Code's own configuration files and should be managed with its native tools.

### Reading Files

**Tool priority for reading (strictly enforced):**

1. **`neovim` MCP - `mcp__mcphub__neovim__read_file`** — ALWAYS use this first
2. `mcp__acp__Read` — ONLY when neovim MCP is not loaded

**When using neovim MCP for editing:**

- Reading first is optional (neovim MCP handles context internally)
- Recommended to read for better understanding, but not required

**When using `mcp__acp__Edit` for editing (fallback only):**

- MUST read file first using `mcp__acp__Read`
- The Edit tool requires fresh context from Read to work properly
- Read immediately before editing to ensure accurate context

**If you think the file is not found at the expected location please search the repository for it because it might be renamed, moved or combined with something else. Do not assume that file that you expect is failed to create in a prior edit. Ask if unsure and can not find it.**

### Editing Files

> **REMINDER:** Use neovim MCP (`mcp__mcphub__neovim__edit_file`) for editing. Every time. Do not switch to built-in Edit unless neovim MCP is genuinely not loaded.

**Edit Flow:**

```
1. Choose editing approach:
   - USE neovim MCP (mcp__mcphub__neovim__edit_file) — this is NOT optional, it is the required first choice
   - Fallback to mcp__acp__Edit ONLY if neovim MCP is not loaded

2. If using neovim MCP:
   - Can edit directly (reading first is optional but recommended)
   - If REJECTED (tool loaded but operation denied/failed) → STOP
   - Ask user: "The Neovim MCP adapter rejected that edit. Would you like me to try using Edit instead, or should I revise my approach?"
   - Wait for explicit permission before trying Edit

3. If neovim MCP is NOT LOADED (unavailable):
   - Silently fall back to mcp__acp__Edit
   - MUST read file first using mcp__acp__Read
   - Use fresh context from Read for the edit
   - The Edit tool depends on Read output for proper operation
```

**Critical Rule:** When neovim MCP **rejects** an edit, do NOT automatically fall back to Edit. The rejection is a signal — respect it and ask for guidance. Only fall back silently when the tool is not loaded at all.

### Writing New Files

**Always use Write (`mcp__acp__Write`) for creating new files.**

The neovim MCP write tool does not work properly for new file creation. Always go directly to the built-in Write tool:

1. Use `mcp__acp__Write` to create new files
2. Do not attempt neovim MCP for writing new files

### Listing and Finding Files

**Priority:**

1. `neovim` MCP - `mcp__mcphub__neovim__list_directory`, `mcp__mcphub__neovim__find_files`
2. Built-in `Glob` tool

## V. CODE STYLE AND COMMENTS

### General Coding Style

**Required conventions:**

- **Empty line before return** - Leave an empty line before the return statement when the function body has multiple statements. For single-statement functions or early-return guard clauses that are the only statement in their block, the empty line may be omitted.
- **No trailing whitespace** - Never leave empty spaces at the end of lines

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

When neovim MCP adapter rejects an edit:

**Response template:**

> "The Neovim MCP adapter rejected that edit. Would you like me to try using Edit instead, or should I revise my approach?"

**Actions:**

1. STOP immediately - don't retry or use fallback
2. Ask for explicit guidance
3. Wait for user decision
4. Proceed only with permission

### Handling Unexpected File State

When you notice a file doesn't match what you expected (e.g., your previous edits seem missing or changed):

**Analyze the situation.** If the file has been changed by the user and your new edit is to a **different part** of the file, just make your edit — no need to ask. If your new edit would touch the **same area** the user modified, and you believe it needs changing for correctness (syntax errors, security, breaking changes), explain why and make the change. Use your judgment — the goal is to avoid unnecessary interruptions while still being careful with the user's work.

### Learning from Manual Edits

When user manually modifies your changes:

**CRITICAL:** Treat user edits as teaching signals about coding style preferences.

**Analysis checklist:**

- Formatting differences (spacing, indentation, line breaks)
- Naming convention changes (camelCase vs snake_case, prefixes, etc.)
- Structural changes (order, grouping, organization)
- Idiom preferences (language-specific patterns)

**Response template when you notice edits:**

> "I notice you changed [specific pattern] to [user's pattern]. I'll apply this style to the remaining code and save it to memory for future sessions."

**Apply learned patterns** to all subsequent code in the same session AND save to memory for future sessions.

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
3. Review git status and working directory
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
1. If file is under .claude/ or ~/.claude/ → use built-in Read/Edit/Write directly (skip neovim MCP)
2. Otherwise: ALWAYS use neovim MCP first (mcp__mcphub__neovim__read_file / edit_file)
3. Fall back to built-in Read/Edit ONLY if neovim MCP is not loaded
4. If using built-in Edit: MUST read file first with Read
5. Understand context and existing patterns (comment style, conventions)
6. Make the edit
7. If neovim MCP rejected → STOP and ask permission to try built-in Edit
```

**User asks for information you don't know:**

```
1. Say "I don't know"
2. Offer to search documentation or web
3. Use context7 MCP for docs or WebSearch
4. Provide answer with sources
```

**User manually edits your code:**

```
1. Review the diff carefully
2. Identify pattern changes (naming, style, structure)
3. Acknowledge the pattern in chat
4. Apply same pattern to future code
5. Save pattern to memory for future sessions
```

**Need to navigate code:**

```
1. Check if cclsp available (ToolSearch)
2. Use cclsp for definitions/references if available (no fallback for this capability)
3. Fall back to treesitter for structure analysis
4. Use Grep only if others unavailable
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
3. **Use neovim MCP for reading and editing** (do not drift to built-in tools)
4. **Use preferred tools** (but degrade gracefully if unavailable)
5. **Follow coding style** (match project patterns)
6. **Update memory** (maintain continuity)
