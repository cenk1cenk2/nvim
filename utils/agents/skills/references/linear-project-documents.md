# Linear Project Documents

Use the active Linear workspace's `save_document` tool, for example `linear-kilic-dev__save_document`, to create or update project-scoped documents when multiple issues need the same shared context.

## When to Use Project Documents

Create a project document for shared information that would otherwise be duplicated across issues:

- Agent execution instructions.
- Migration guides.
- Candidate matrices.
- Research findings and decisions.
- Shared verification commands.
- Repeated acceptance criteria.
- Repository inventory and common conventions.

## How to Use Them

- Create or update documents with `project`, `title`, and `content`.
- When updating, list or fetch existing documents first and update by `id`.
- Present document drafts via the `output-diff` convention before writing.
- Create project documents after the project exists and before creating repetitive issues when possible.

## Lightweight Issues

When a project document holds shared agent context, keep issues focused on specifics:

- One-line task overview.
- Explicit repo/scope.
- Issue-specific checklist or delta.
- Any exception to the shared instructions.
- A "Read first" reference to the relevant project document.

Do not copy the same long guide, matrix, or research analysis into every issue. Use issues for the per-task specifics and project documents for shared context.
