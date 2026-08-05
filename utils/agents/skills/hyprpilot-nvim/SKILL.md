---
name: hyprpilot-nvim
description: Editor-aware work through the captain's running Neovim - LSP navigation over manual grepping, diagnostics, formatting, and driving their windows. Auto-invoked the moment the hyprpilot-nvim MCP server is detected in the session, before any symbol search or file navigation. Do NOT use for editing file contents (the server is read-and-navigate only).
---

## Context

`hyprpilot-nvim` exposes the captain's **live** Neovim over MCP: their buffers with unsaved changes, their attached language servers, their windows and cursor. It is not a second copy of the filesystem — a read through it sees what they see right now.

The server is read-and-navigate. It cannot change file contents; use the normal editing tools for that, and reach for these when the question is *where is this symbol*, *what is broken*, or *show the captain something*.

Tools come in two families plus `healthcheck`:

| Family | Tools |
|--------|-------|
| `lsp_*` | `definition`, `type_definition`, `implementation`, `references`, `incoming_calls`, `outgoing_calls`, `hover`, `document_symbols`, `workspace_symbols`, `code_actions`, `rename`, `ensure_loaded` |
| `editor_*` | `status`, `cursor`, `buffers`, `read`, `grep`, `files`, `file_open`, `jump`, `select`, `quickfix_set`, `format`, plus `diagnostics_get` |
| `plugin_*` | integrations with the captain's own plugins — see Plugins below. Present only when that plugin is installed |

Positions are **0-indexed** on the LSP tools, `editor_grep`, and `editor_quickfix_set`; `editor_jump` / `editor_file_open` / `editor_select` take **1-indexed** lines. Read each tool's schema rather than assuming.

## Process

### ⛔ LSP over manual searching — absolute

When a symbol is involved, ask the language server. `lsp_definition`, `lsp_references`, and `lsp_workspace_symbols` are faster and correct where grep is neither — grep cannot tell a definition from a mention, a method from a same-named field, or a live call site from a comment.

1. **Finding a symbol's uses** — `lsp_references`, never a hand-rolled grep for its name.
2. **Finding where something comes from** — `lsp_definition` for the symbol, `lsp_type_definition` for the type behind a variable.
3. **Finding what implements an interface** — `lsp_implementation`.
4. **Tracing a call path** — `lsp_incoming_calls` for who reaches this code, `lsp_outgoing_calls` for what it reaches. Two directions of the same question; pick the one that matches what you're chasing.
5. **Orienting in an unfamiliar file** — `lsp_document_symbols` with `kinds` and `max_results`, not a full read.
6. **Checking your own work** — `diagnostics_get` after an edit, scoped with `severity`, and `lsp_code_actions` when a fix is offered.
7. **Renaming** — `lsp_rename` over text replacement; it updates every reference including ones grep would miss.

Grep and read are still right for prose, config, comments, and anything with no language server. `editor_grep` and `editor_files` cover that and respect `.gitignore`.

### Formatting — the fast path

Use `editor_format` whenever a file needs formatting. It drives the buffer's own attached formatter in place, and it is far cheaper than shelling out to the project's format task for a single file. Keep the repo task for whole-repo runs and for anything the LSP doesn't format.

### Driving the captain's editor

Navigation moves what the captain is looking at, so treat it as an interruption:

- **Ask before navigating** unless they asked to be taken somewhere. Reporting `file:line` is often enough.
- `editor_file_open` / `editor_jump` place the file without stealing focus. `editor_select` is the exception — it must take the window's focus, because a selection nobody is looking at is not a selection.
- The captain may have wired an interactive window picker, in which case navigating **prompts them for a window and blocks until they answer**. Don't fire navigation calls speculatively or in a loop.
- **Findings go to the quickfix list.** When the answer is a set of locations — audit hits, every call site, all errors of a kind — `editor_quickfix_set` hands them to the captain's own `:cnext` and picker bindings. That beats a wall of paths in a response. It opens the list by default, which is the point: a list nobody sees is worse than the wall of paths. Pass `open: false` only when populating it as a side effect of other work.

### Plugins — state the editor holds that nothing else does

The `plugin_*` tools wrap plugins the captain runs. They exist because the data behind them lives only in their session: results of a run *they* triggered, files *they* marked, a process *they* paused. Anything obtainable from `git`, `rg`, or the language server is deliberately absent from this family — reach for those directly instead.

A tool missing from the session means that plugin isn't installed. Don't announce it; fall back and move on.

**`plugin_diffview_*` — the diff the captain is looking at.**

- `open` takes `revision` and, more usefully, `paths` — the way to *show* a set of changes rather than describe them. When the conversation is about specific files' changes, put them on screen.
- `selection_get` is human intent you can't get anywhere else: the files they marked in the panel. When they say "these files", ask it rather than guessing. `selection_set` hands a shortlist back — the files an audit flagged, the ones a change will touch.
- `files` / `current` frame the conversation on what they have open. For the diff *content*, use `git` — diffview adds framing, not data.
- No hunk-level detail exists; `current` resolves to a file and no finer.

**`plugin_neotest_*` — test state without re-running anything.**

- `status` gives pass / fail / skipped / running counts from the captain's last run. Ask before proposing a fix for a failure you assume exists.
- `positions` maps discovered tests to `file:line` — use it to name a test exactly, or to find which test covers the code under discussion.
- `run` queues a run in their editor and returns immediately; poll `status` for the outcome. Prefer it over shelling out to the test binary when they're already watching neotest's output.

**`plugin_dap_*` — a live debugger.** `status` is the cheap check for whether a session is even running; `stack` returns threads and frames as 0-indexed positions that feed straight into `editor_jump`. Runtime values from a paused process are something no shell command can produce — when they're debugging, this is the highest-value thing to read.

**`plugin_coverage_report`** — the parsed report, so you never guess whether the project emits lcov or cobertura. Empty means nothing loaded yet, not zero coverage; pass `load` and expect it on the next call.

**`plugin_todo_search`** — TODO / FIXME hits through the captain's own configured keywords and comment pattern. Prefer it over `editor_grep` for this one job, because a hand-rolled regex will miss their custom shapes.

### Reading state before acting

`editor_status` is one round-trip for mode, focused buffer, cursor, and buffer list — call it before assuming which file the captain means by "this one". `editor_read` sees unsaved buffer contents, so prefer it over a filesystem read when the captain has been editing.

## Key Principles

- **Their editor, not yours.** Every navigation call changes what a person is looking at mid-thought.
- **Ask the server, not the text.** Any question about a symbol has an LSP answer that beats a regex.
- **A set of locations belongs in the quickfix list**, not in prose.
- **Positions are indexed inconsistently across tools** — check the schema each time.
- **Degrade quietly.** No language server for a filetype, a `plugin_*` tool absent, or the MCP missing entirely — fall back to grep and the project's own tooling without ceremony or apology.
- **Read their state before assuming it.** Test results, debugger frames, marked files, and the open diff are all things the captain produced. Ask the tool rather than reconstructing them from the repo.
