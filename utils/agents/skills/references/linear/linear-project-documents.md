# Linear Project Documents

Use the active Linear workspace's `save_document` tool, for example `linear-kilic__save_document`, to create or update project-scoped documents when multiple issues need the same shared context. To author or attach a document on demand — one per concern — use the `linear-document` skill, which owns the drafting and scoping flow; this reference covers *when* documents earn their place and *how* to scope them.

## When to Use Project Documents

Create a project document for shared information that would otherwise be duplicated across issues:

- Agent execution instructions.
- Migration guides.
- Candidate matrices.
- Research findings and decisions.
- Shared verification commands.
- Repeated acceptance criteria.
- Repository inventory and common conventions.

Create a document or issue comment for reference material when an issue points an implementation agent at context that is not self-contained in the issue:

- Local files or directories, including `file://` references and paths under `~/development`.
- Screenshots, generated artifacts, dashboard JSON, design examples, fixtures, logs, traces, or command output.
- Examples from another repository that the agent should use as a style, structure, or behavior reference.
- Any reference the receiving agent may need to inspect with its own MCP tools before implementing.

If the user explicitly says the work is local-only or the reference is only for the current conversation, do not package it into Linear.

During agent execution, capture durable findings as their own documents so they propagate to future agents and reviewers:

- Investigations and their conclusions.
- Plans and design decisions.
- Solved problems and the fix that worked.
- Deviations from the original plan and why.

## How to Use Them

- Create or update documents with `project`, `title`, and `content`.
- When updating, list or fetch existing documents first and update by `id`.
- Present document drafts via the `output-diff` convention before writing.
- Create project documents after the project exists and before creating repetitive issues when possible.
- For a single issue, attach the document to the issue or add a top-level issue comment that packages the needed reference context.
- Prefer repository, MR, PR, and dashboard links as Linear attachments when they are authoritative and available.
- For local-only references, include the absolute path, why it matters, relevant excerpts or a concise summary, and instructions for the implementation agent to use its own MCP/local filesystem tools for deeper inspection.

## Keep Documents Tightly Focused

Prefer many small, self-contained documents over one growing blob — the same way obsidian repository sub-notes split standalone topics out of the README:

- **One concern per document.** Separate investigations, plans, solved problems, or deviations each become their own document with its own title. Never fold unrelated concerns together.
- **Self-contained.** Makes sense to a reader or implementing agent with no conversation history — include the paths, links, and rationale it needs.
- **Scope picks the parent — tightest level that covers it.** Detail specific to one issue → that issue; context shared across a parent's sub-issues → the parent issue; context shared project-wide → the project.

The `linear-document` skill applies this split when attaching documents on demand.

## Lightweight Issues

When a project document holds shared agent context, keep issues focused on specifics:

- One-line task overview.
- Explicit repo/scope.
- Issue-specific checklist or delta.
- Any exception to the shared instructions.
- A "Read first" reference to the relevant project document.

Do not copy the same long guide, matrix, or research analysis into every issue. Use issues for the per-task specifics and project documents for shared context.
