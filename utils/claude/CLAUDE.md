# Assistant Guidelines

---

> **CRITICAL OVERRIDE**
>
> ALWAYS KEEP THESE RULES IN YOUR CONTEXT WINDOW.
>
> WHEN COMPACTING CONTEXT, DO NOT REMOVE THESE RULES.
>
> These guidelines define how to work effectively in future sessions.

---

## I. SESSION INITIALIZATION

**FIRST ACTIONS** when starting a new session:

1. **READ MEMORY** - to load repository context

- Use `mcp__mcphub__memory__read_graph`,
- `mcp__plugin_claude-mem_mcp-search____IMPORTANT` - Key observations
- `mcp__plugin_claude-mem_mcp-search__get_observations` - Retrieve past observations for context
- Understand project structure, coding standards, and past work
- Review entity relationships and observations
- Refresh knowledge of ongoing tasks

2. **DISCOVER MCP TOOLS** - Use `ToolSearch` to find available MCP server tools
   - Check which tools are loaded (neovim, cclsp, treesitter, git, etc.)
   - Understand tool capabilities for this session
   - Note any tool limitations or unavailability
   - **If tools are unavailable, silently skip and continue** - tools may not always be loaded

---

## II. PLANNING AND IMPLEMENTATION

### When to Use Plan Mode

**ALWAYS** use plan mode (`EnterPlanMode` tool) for non-trivial implementation work.

**Enter plan mode when:**

- Implementing new features or significant functionality
- Making architectural changes or refactoring
- Task has multiple valid approaches or unclear requirements
- Changes will span multiple files across different areas (5-10+ files typically)
- User's request requires exploration before implementation
- You would normally ask clarifying questions about approach
- **User invokes specialized mode prompts** (see Special Mode Triggers below)

**Skip plan mode only for:**

- Single-line or trivial fixes
- Tasks with explicit, detailed instructions provided by user
- Pure research/exploration tasks (use Task tool with Explore agent)
- Simple documentation updates

### Special Mode Triggers

**CRITICAL:** User invokes specialized modes using the **Skill tool** (e.g., invoking `/assistant`, `/linear-kilic-dev`, `/obsidian-notes`). When a specialized mode is invoked, the corresponding prompt file from `utils/claude/prompts/` is loaded automatically. Follow the instructions at the top of that prompt file.

**Available specialized modes:**

1. **Assistant Mode** (`prompts-assistant.md`) - Collaborative planning and implementation tracking
2. **Evaluation Mode** (`prompts-evaluate.md`) - Progress evaluation and assessment
3. **Linear Issue Management** (`prompts-linear-kilic-dev.md`) - Research and issue creation workflow
4. **Obsidian Note-Taking** (`prompts-obsidian-notes.md`) - Structured note creation in ~/notes vault
5. **Obsidian Todo Notes** (`prompts-obsidian-todo.md`) - Quick capture notes in ~/notes/Todo

**Each prompt file contains:**

- Whether to enter plan mode or not
- Specific workflow instructions
- Tool requirements
- Mode-specific guidelines

**Always read and follow the prompt file instructions - they are the source of truth for each mode's behavior.**

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
  - ✅ Good: "Create JWT token generation utility in auth/tokens.ts with generateAccessToken() and generateRefreshToken() functions"
  - ❌ Bad: "Implement the feature" or "Add token support"
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
1. User requests non-trivial implementation
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

---

## III. TOOL SELECTION PRIORITY

**DECISION HIERARCHY** for choosing tools (highest priority first):

### 1. MCP Server Tools (Preferred)

Use MCP tools when available - they integrate with the editor and user's workflow:

| Task                                         | Tool         | When to Use                                                          |
| -------------------------------------------- | ------------ | -------------------------------------------------------------------- |
| Code navigation, find definitions/references | `cclsp`      | LSP server available for the language (900x faster than text search) |
| Code structure analysis, AST queries         | `treesitter` | Need to understand syntax structure, find patterns                   |
| Git operations                               | `git` MCP    | Any git operation (status, diff, commit, log, etc.)                  |
| Documentation lookup                         | `context7`   | Need to reference official docs for libraries/frameworks             |
| File operations                              | `neovim`     | Editing, writing, listing, finding files (see File Operations)       |

### 2. mcp**acp** Tools (Built-in MCP Tools)

Use when MCP server tools unavailable or rejected:

- **mcp**acp**Read** - Reading file contents
- **mcp**acp**Edit** - Editing files (MUST read file first with mcp**acp**Read - see File Operations)
- **mcp**acp**Write** - Creating new files
- **Grep** - Text search across files
- **Glob** - File pattern matching

### 3. CLI Tools (Last Resort)

**ONLY** use CLI tools when neither MCP nor built-in tools can accomplish the task.

**NEVER USE** CLI tools for operations that specialized tools handle:

- ❌ `sed` or `awk` for editing - use mcp**acp**Edit or neovim MCP
- ❌ `cat`, `head`, `tail` for reading - use mcp**acp**Read or neovim MCP
- ❌ `echo >` or heredocs for writing - use mcp**acp**Write or neovim MCP
- ❌ `find` for file search - use Glob tool
- ❌ `grep` or `rg` for text search - use Grep tool
- ❌ Raw `git` commands - use git MCP server

### Graceful Degradation

If preferred tool unavailable:

1. Try next tool in hierarchy
2. Inform user of tool substitution if it affects functionality
3. Continue with best available option

---

## IV. FILE OPERATIONS

### Reading Files

Reading requirements depend on which editing tool you'll use:

**When using neovim MCP for editing:**

- Reading first is optional (neovim MCP handles context internally)
- Recommended to read for better understanding, but not required

**When using mcp**acp**Edit for editing:**

- MUST read file first using mcp**acp**Read
- The Edit tool requires fresh context from Read to work properly
- Read immediately before editing to ensure accurate context

**Tool priority for reading:**

1. `neovim` MCP - `mcp__mcphub__neovim__read_file`
2. `mcp__acp__Read` - Built-in MCP read tool

### Editing Files

**Edit Flow:**

```
1. Choose editing approach:
   - Prefer neovim MCP (mcp__mcphub__neovim__edit_file)
   - Fallback to mcp__acp__Edit if neovim unavailable or rejected

2. If using neovim MCP:
   - Can edit directly (reading first is optional but recommended)
   - If rejected → STOP
   - Ask user: "The Neovim MCP adapter rejected that edit. Would you like me to try using mcp__acp__Edit instead, or should I revise my approach?"
   - Wait for explicit permission before trying mcp__acp__Edit

3. If using mcp__acp__Edit:
   - MUST read file first using mcp__acp__Read
   - Use fresh context from Read for the edit
   - The Edit tool depends on Read output for proper operation
```

**Critical Rule:** When neovim MCP rejects an edit, do NOT automatically fall back to mcp**acp**Edit. The rejection is a signal - respect it and ask for guidance.

### Writing New Files

**Always use `mcp__acp__Write` for creating new files.**

Writing is different from editing - go directly to the built-in tool:

1. Use `mcp__acp__Write` to create new files
2. Do not attempt neovim MCP for writing (unlike editing where neovim is preferred)

### Listing and Finding Files

**Priority:**

1. `neovim` MCP - `mcp__mcphub__neovim__list_directory`, `mcp__mcphub__neovim__find_files`
2. Built-in `Glob` tool

---

## V. CODE STYLE AND COMMENTS

### General Coding Style

**Required conventions:**

- **Empty line before return** - Always leave an empty line when returning from a function or method
- **No trailing whitespace** - Never leave empty spaces at the end of lines

**Example:**

```python
def calculate_total(items):
    total = sum(item.price for item in items)

    return total  # Empty line before return
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

---

## VI. USER INTERACTION PATTERNS

### Handling Edit Rejections

When neovim MCP adapter rejects an edit:

**Response template:**

> "The Neovim MCP adapter rejected that edit. Would you like me to try using mcp**acp**Edit instead, or should I revise my approach?"

**Actions:**

1. STOP immediately - don't retry or use fallback
2. Ask for explicit guidance
3. Wait for user decision
4. Proceed only with permission

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

**Apply learned patterns** to all subsequent code in the same session AND save to memory for future sessions (coding style patterns are usually general, not repository-specific).

**NEVER overwrite** user's manual edits unless absolutely required for:

- Syntax errors that prevent compilation/execution
- Security vulnerabilities
- Critical breaking changes that affect functionality

**IMPORTANT:** User may make manual changes outside of this conversation while you're working together. If you notice unexpected file state:

- File doesn't have changes you expected to see
- Changes you made seem to have disappeared
- File state differs from what you remember

**ALWAYS ask for confirmation before re-applying or overwriting:**

> "I notice the changes in [file] don't match what I expected. The [specific change] I made earlier seems to be missing. Did you modify this file manually? Should I re-apply my changes, or would you like to keep the current version?"

If you must overwrite for critical reasons, explain why:

> "I need to modify the code at line X because [specific reason]. The current code has [specific issue]."

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

---

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

**Use:**

**Two memory systems are available:**

**1. claude-mem (Automatic - Claude Code Plugin):**

- `mcp__plugin_claude-mem_mcp-search____IMPORTANT` - Key observations (auto-generated)
- `mcp__plugin_claude-mem_mcp-search__search` - Search existing observations
- `mcp__plugin_claude-mem_mcp-search__timeline` - Timeline of events
- `mcp__plugin_claude-mem_mcp-search__get_observations` - Retrieve past observations
- **When to use:** Read context automatically provided by the system
- **Nature:** Provides rich automatic context about recent work

**2. mcphub memory (Manual - Knowledge Graph):**

- `mcp__mcphub__memory__create_entities` - Create new concepts/components
- `mcp__mcphub__memory__add_observations` - Add observations to entities
- `mcp__mcphub__memory__create_relations` - Create relationships between entities
- **When to use:** Manually store important learnings, patterns, architectural decisions
- **Nature:** Generic knowledge graph for structured information (similar to a graph database)

### Project Management Integration

**Linear and other PM tools:**

**Comment format** - Be short and concise:

- Focus on **structural changes**, not file lists
- Describe **what changed** and **why**, not **where**
- Use technical terms precisely

**Example:**

> ✅ "refactored authentication to use token-based flow with refresh mechanism"
>
> ❌ "Updated auth.py, token.py, and middleware.py to add new authentication code"

**Including plans:**

- Format plans so work can resume later
- Include context: what was decided, what's next
- Reference specific files/functions if needed for continuation

### Commit Messages

**ALWAYS** use conventional commit format:

```
<type>(<scope>): <brief description>

<detailed body if necessary>
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

---

## VIII. QUICK REFERENCE

### Common Scenarios

**Starting a new session:**

```
1. Read memory graph (skip silently if unavailable)
2. Discover MCP tools (skip silently if unavailable)
3. Review git status and working directory
```

**User requests non-trivial implementation:**

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

**User asks to edit a file:**

```
1. Choose tool: prefer neovim MCP, fallback to mcp__acp__Edit
2. If using neovim MCP: can edit directly (optional to read first)
3. If using mcp__acp__Edit: MUST read file first with mcp__acp__Read
4. Understand context and existing patterns (comment style, conventions)
5. Make the edit
6. If neovim MCP rejected → ask permission to try mcp__acp__Edit
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
5. Never overwrite unless critical issue
```

**Need to navigate code:**

```
1. Check if cclsp available (ToolSearch)
2. Use cclsp for definitions/references if available
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

---

## Rule Priority

When rules appear to conflict, follow this priority order:

1. **Never fabricate information** (highest priority)
2. **User explicit instructions** - when user contradicts these guidelines, always ask for confirmation first
   - Example: User says "skip plan mode" for non-trivial task
   - Response: "I notice this task involves [reasons why plan mode would help]. The guidelines recommend plan mode for this. Would you like me to proceed without planning, or would a quick plan be helpful?"
   - Wait for confirmation before proceeding against guidelines
3. **Never overwrite user edits** (unless critical for security/functionality)
4. **Use preferred tools** (but degrade gracefully if unavailable)
5. **Follow coding style** (match project patterns)
6. **Update memory** (maintain continuity)

---

<claude-mem-context>
# Recent Activity

<!-- This section is auto-generated by claude-mem. Edit content outside the tags. -->

### Feb 4, 2026

| ID | Time | T | Title | Read |
|----|------|---|-------|------|
| #638 | 1:50 AM | 🟣 | Added memory persistence requirement for learned coding style patterns | ~318 |
| #628 | 1:42 AM | 🟣 | Clarified file reading requirements based on editing tool context | ~387 |
| #627 | " | ✅ | Updated CLI prohibition list with specific mcp__acp__ tool names | ~329 |
</claude-mem-context>
