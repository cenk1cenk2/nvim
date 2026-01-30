# Claude Assistant Guidelines

CRITICAL OVERRIDE: ALWAYS KEEP THESE RULES IN YOUR CONTEXT WINDOW. WHEN COMPACTING CONTEXT, DO NOT REMOVE THESE RULES.

## Core Principles

### Memory and Context Management

- **ALWAYS** keep these rules in mind while working - do not let information be forgotten over time
- **ALWAYS** use the memory MCP server to record milestones about repositories
- **ALWAYS** keep memory updated with current repository information and coding style
- **ALWAYS** read memory at session start to remind yourself about the repository

### MCP Server Tools

- **ALWAYS** discover what MCP server tools are available and use them as needed
- Tool priority hierarchy (use in this order when applicable):
  1. **cclsp MCP server** for code navigation and analysis (900x faster than text search)
  2. **treesitter MCP server** for code structure analysis
  3. **git MCP server** instead of raw git commands
  4. **context7 MCP server** for documentation lookups
  5. **neovim MCP adapter** for file operations (see File Operations below)

## File Operations

### Reading Files

- **ALWAYS** read files before making edits

### Editing and Writing Files

- **ALWAYS** use neovim MCP adapter for `edit_file` and `write_file` operations when available
- **ALWAYS** use neovim MCP adapter for listing and finding files when available
- **If edit is rejected by Neovim MCP adapter**: STOP and ask the user for clarification or explicit permission before attempting to use built-in Edit/Write tools as a fallback

### Tool Restrictions

- **NEVER** perform operations through CLI tools that can be done with internal tools
- **DON'T** use `sed` directly - use editing tools
- **DON'T** use `cat` for writing scripts

## Code Comments and Documentation

### When to Add Comments

- **NEVER** write comments or explanations unless:
  1. Explicitly asked by the user, OR
  2. The surrounding code already contains comments of that type

### Matching Existing Style

- When comments are appropriate, **ALWAYS**:
  - Check the surrounding context to understand commenting conventions
  - Match the existing comment style, density, and format of the file
  - If file has no docstrings, don't add docstrings
  - If file has detailed inline comments, match that level
  - If file is sparse with comments, keep additions sparse

### Output Comments to Chat

- Output explanations directly to the chat window, not as code comments

## Handling User Edits

### When User Manually Modifies Your Changes

- **NEVER** overwrite manual edits unless absolutely required for:
  - Syntax errors
  - Security vulnerabilities
  - Critical breaking changes

### Learning from User Edits

- **ALWAYS** analyze user's manual edits as teaching signals about their coding style
- Note patterns in:
  - Formatting preferences
  - Naming conventions
  - Code structure
  - Language idioms
- Apply learned patterns to future code in the same session

## Coding Style Guidelines

### General Rules

- Always leave an empty line when returning from a function or method
- Never leave empty spaces at the end of lines

### Commit Messages

- **ALWAYS** use conventional commit message format
- Be VERY CONCISE in the summary line
- Include more details in the commit body if necessary

## Information Accuracy

### When Uncertain

- **NEVER** fabricate information
- If unsure, say "I don't know"
- Consult web search or documentation search for up-to-date information

## Project Management Integration

### Linear and Other PM Tools

- When updating with comments: be short and concise
- Focus on structural changes, not individual files edited
- When including plans: format them so work can be picked up where it left off

## Tool Selection Priority

When multiple tools can accomplish a task, prefer them in this order:

1. MCP server tools (cclsp, treesitter, git, neovim, context7)
2. Built-in specialized tools (Read, Edit, Write, Grep, Glob)
3. CLI tools (only when no other option exists)
