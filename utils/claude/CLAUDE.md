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

3. **UNDERSTAND CONTEXT** - Review the working directory and git status
   - Current branch and recent commits
   - File structure and language ecosystem
   - Existing patterns and conventions

---

## II. PLANNING AND IMPLEMENTATION

### When to Use Plan Mode

**ALWAYS** use plan mode (`EnterPlanMode` tool) for non-trivial implementation work.

**Enter plan mode when:**

- Implementing new features or significant functionality
- Making architectural changes or refactoring
- Task has multiple valid approaches or unclear requirements
- Changes will span across the whole code base with multiple files
- User's request requires exploration before implementation
- You would normally ask clarifying questions about approach
- **User invokes specialized mode prompts** (see Special Mode Triggers below)

**Skip plan mode only for:**

- Single-line or trivial fixes
- Tasks with explicit, detailed instructions provided by user
- Pure research/exploration tasks (use Task tool with Explore agent)
- Simple documentation updates

### Special Mode Triggers

**CRITICAL:** When user provides these specialized mode prompts, **ALWAYS enter plan mode** and adjust behavior:

**1. Assistant Mode (`prompts-assistant.md`):**

- Enter plan mode for collaborative planning and research
- Focus on planning and implementation tracking (not direct implementation)
- Use TodoWrite extensively to track the evolving plan
- Provide feedback as direct messages, not in Linear issues
- Be proactive about identifying problems and deviations
- Create plan file in `~/.claude/plans/` to track the collaborative work

**2. Evaluation Mode (`prompts-evaluate.md`):**

- Enter plan mode for thorough analysis and assessment
- Use Git MCP tools to review commits and diffs
- Research and analyze the actual implementation vs. the original plan
- Update TodoWrite plan based on actual implementation
- Provide comprehensive feedback about what was accomplished
- Identify deviations and ask clarifying questions
- Document findings in the plan file

**3. Linear Issue Management (`prompts-linear-kilic-dev.md`):**

- Enter plan mode for research and issue structuring
- Use Linear MCP (`linear/kilic.dev`) and GitLab MCP
- Conduct thorough research using web search and Context7
- Use plan file to organize research findings before creating issues
- Follow specific issue structure guidelines
- Create structured issues with checklists and analysis sections
- Transfer organized research from plan to Linear issues

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

## Files Affected

- `path/to/file.ext` - what changes
- `path/to/other.ext` - what changes

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

In plan mode, use tools to understand the codebase.

**IMPORTANT:** Spend adequate time exploring. Don't rush to implementation.

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

**Example response:**

> "I've drafted an implementation plan. Here's the approach:
>
> [Present key points from the plan]
>
> Would you like me to refine any part of this plan? I can:
>
> - Adjust the approach
> - Add more detail to specific steps
> - Consider alternative strategies
> - Clarify any unclear sections"

**5. Exit Plan Mode (Only When Ready):**

**ONLY** use `ExitPlanMode` when:

- Plan is thoroughly refined
- User has approved the approach
- You feel absolutely ready to implement
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

- Spend adequate time exploring before planning
- Write specific, actionable implementation steps (not vague steps like "implement the feature")
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

### 2. Built-in Specialized Tools

Use when MCP tools unavailable or task doesn't require MCP features:

- **Read** - Reading file contents
- **Edit** - Editing files (only if neovim MCP rejected or unavailable)
- **Write** - Creating new files (only if neovim MCP rejected or unavailable)
- **Grep** - Text search across files
- **Glob** - File pattern matching

### 3. CLI Tools (Last Resort)

**ONLY** use CLI tools when neither MCP nor built-in tools can accomplish the task.

**NEVER USE** CLI tools for operations that specialized tools handle:

- ❌ `sed` or `awk` for editing - use Edit tools
- ❌ `cat`, `head`, `tail` for reading - use Read tool
- ❌ `echo >` or heredocs for writing - use Write tools
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

**ALWAYS** read files before making edits.

**Priority:**

1. `neovim` MCP - `mcp__mcphub__neovim__read_file`
2. Built-in `Read` tool

### Editing Files

**Edit Flow:**

```
1. Read file first (understand context)
2. Attempt edit with neovim MCP (mcp__mcphub__neovim__edit_file)
3. If rejected → STOP
4. Ask user: "The Neovim MCP adapter rejected that edit. Would you like me to try using the built-in Edit tool instead, or should I revise my approach?"
5. Wait for explicit permission
6. Only use built-in Edit if user approves
```

**Critical Rule:** When neovim MCP rejects an edit, do NOT automatically fall back to built-in tools. The rejection is a signal - respect it and ask for guidance.

### Writing New Files

Follow same flow as editing:

1. Try `neovim` MCP - `mcp__mcphub__neovim__write_file`
2. If rejected → ask permission before using built-in Write

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

> "The Neovim MCP adapter rejected that edit. Would you like me to try using the built-in Edit tool instead, or should I revise my approach?"

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

> "I notice you changed [specific pattern] to [user's pattern]. I'll apply this style to the remaining code."

**Apply learned patterns** to all subsequent code in the same session.

**NEVER overwrite** user's manual edits unless absolutely required for:

- Syntax errors that prevent compilation/execution
- Security vulnerabilities
- Critical breaking changes that affect functionality

If you must overwrite, explain why:

> "I need to modify your edit at line X because [specific reason]. The current code has [specific issue]."

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

**ALWAYS** update memory MCP server to track session progress.

**When to update:**

- After completing major milestones
- When discovering important patterns or decisions
- When learning new project structure or conventions
- At natural breakpoints in work

**What to record:**

- Technical decisions and rationale
- Coding patterns and conventions discovered
- Project structure insights
- Implementation strategies
- Issues encountered and resolutions

**Use:**

It is very IMPORTANT to use the following memory MCP tools for understanding what we are working with and keeping track of important information:

- `mcp__plugin_claude-mem_mcp-search____IMPORTANT` - Key observations
- `mcp__plugin_claude-mem_mcp-search__search` - Search for existing entities before creating new ones
- `mcp__plugin_claude-mem_mcp-search__timeline` - Timeline of significant events
- `mcp__plugin_claude-mem_mcp-search__get_observations` - Retrieve past observations for context

- `mcp__mcphub__memory__create_entities` - New concepts/components
- `mcp__mcphub__memory__add_observations` - Updates to existing entities
- `mcp__mcphub__memory__create_relations` - Relationships between entities

### Project Management Integration

**Linear and other PM tools:**

**Comment format** - Be short and concise:

- Focus on **structural changes**, not file lists
- Describe **what changed** and **why**, not **where**
- Use technical terms precisely

**Example:**

> ✅ "Refactored authentication to use token-based flow with refresh mechanism"
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

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types:** feat, fix, docs, style, refactor, test, chore

**Brief description:**

- Be concise (under 72 characters)
- Use imperative mood ("add" not "added")
- Don't end with period

**Example:**

```
feat(auth): implement token refresh mechanism

Add automatic token refresh using refresh tokens stored in httpOnly cookies.
Handles token expiration gracefully with retry logic.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## VIII. QUICK REFERENCE

### Common Scenarios

**Starting a new session:**

```
1. Read memory graph
2. Discover MCP tools
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
1. Read file with neovim MCP or Read tool
2. Understand context and existing patterns
3. Check for comment style (add if file has comments)
4. Make edit with neovim MCP
5. If rejected → ask permission for fallback
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
2. **Never overwrite user edits** (unless critical)
3. **Use preferred tools** (but degrade gracefully if unavailable)
4. **Follow coding style** (match project patterns)
5. **Update memory** (maintain continuity)

---

<claude-mem-context>
# Recent Activity

<!-- This section is auto-generated by claude-mem. Edit content outside the tags. -->

*No recent activity*
</claude-mem-context>
