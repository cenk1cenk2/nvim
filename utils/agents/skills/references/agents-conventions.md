# Agent Conventions Agreement

Before dispatching agents or subagents, establish a shared conventions document that every agent receives in its prompt. Agents cannot coordinate at runtime — conventions must be agreed upfront.

## Process

1. **Read the codebase for existing patterns.** Don't invent conventions — discover them from the code that already exists.
2. **Build the conventions list** covering the categories below (skip categories that don't apply to the project).
3. **Present to the user** for confirmation before including in agent prompts.
4. **Include in every agent prompt** as a `## Conventions` section.

## What to Discover

### Testing

- **Framework:** What test framework does the project use? (Ginkgo, Jest, pytest, go test, Vitest, etc.)
- **Style:** Table-driven tests? BDD describes? Test file naming (`_test.go`, `.test.ts`, `.spec.ts`)?
- **Location:** Co-located with source or separate `tests/` directory?
- **Patterns:** How do existing tests set up fixtures, mocks, assertions? Match them.

### Code Style

- **Formatting:** Does the project use a formatter? (gofmt, prettier, black, rustfmt) If so, agents should run it or use `vim__vim_format` MCP tool after editing.
- **Whitespace patterns:** Blank line before returns? Blank lines between function groups? Match existing files.
- **Naming:** camelCase vs snake_case vs PascalCase for functions, variables, types, files. Check what the codebase uses.
- **Imports:** Grouped? Sorted? Aliased? Check existing files for the pattern.
- **Error handling:** How does the codebase handle errors? (return err, wrap with fmt.Errorf, custom error types, Result type, try/catch patterns)

### Project Patterns

- **Architecture:** What pattern does the codebase follow? (MVC, clean architecture, hexagonal, flat modules) Agents should place new code where it belongs.
- **Dependency injection:** How are dependencies passed? (constructor, context, global, DI container)
- **Logging:** Which logger? What format? What log levels for what?
- **Configuration:** How is config loaded? (env vars, config files, flags) Where do new config values go?

### Git

- **Commit style:** Conventional commits? Scope prefixes? Check `git log` for the pattern.
- **Branch naming:** Does the project have a convention? (feature/..., fix/..., etc.)

### Tooling

- **Formatter MCP:** If `vim__vim_format` is available and the project uses LSP-based formatting, agents should call it after editing files.
- **Linter:** What linter runs and what rules matter? Agents should not introduce linter violations.

## Output Format

Present the conventions to the user as a concise block ready to paste into agent prompts:

```
## Conventions

- Tests: Ginkgo BDD style. Test files co-located as `*_test.go`.
- Formatting: Run `vim__vim_format` after editing Go files. Blank line before return statements.
- Naming: PascalCase for exported, camelCase for unexported. Errors wrapped with `fmt.Errorf("context: %w", err)`.
- Imports: stdlib first, external second, internal third. Blank line between groups.
- Commits: Conventional commits with scope — `feat(auth): add token rotation`.
- Architecture: Clean architecture. Domain in `internal/domain/`, adapters in `internal/adapters/`.
```

Keep it short — agents have limited context. Only include conventions that are non-obvious or where the project deviates from language defaults.
