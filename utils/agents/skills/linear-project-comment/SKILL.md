---
name: linear-project-comment
description: linear-project-comment Record findings, deviations, and decisions as a discussion comment on a Linear project. Use on "comment on the project", "log this on the project". Not for a project status update, rewriting the project description, or attaching a document.
argumentHint: '[project name, id, or URL] [what to record]'
references:
  - ../references/linear/linear-prerequisite.md
  - ../references/linear/linear-comment-style.md
  - ../references/linear/linear-description-structure.md
  - ../references/identifier-legibility.md
  - ../references/agent-owned.md
---

Issues, projects, MRs and PRs carry their title and link, per `identifier-legibility`.

## Linear Comment: Project Documentation

A Linear workspace skill must be active first — detection rules in `linear-prerequisite`.

## Context

A project comment is a top-level discussion thread on the project. It records a deviation or finding that spans the project: a decision that reshapes several issues, a path abandoned, an assumption corrected. A status update is a separate thing — a progress narrative with health — and a document is durable structured context.

The conversation holds the current intent; the project description may be stale. The comment carries the deviation from the conversation back into Linear.

## Process

1. **Resolve the project** from its name, id, slug, or URL with the active workspace's Linear tools; a URL names its workspace.
2. **Check the thread** — `list_comments { projectId }`. When an existing thread already covers this concern, reply to it with `parentId` rather than opening a new one.
3. **Distill the comment** per `linear-comment-style` — critical findings and deviations only.
4. **Post** with `save_comment { projectId, body }` (or `parentId` for a reply), markdown normaliser traps per `linear-description-structure`, then report it with the project's titled link.

## Example

1. Research for a project found that the chosen ingress controller cannot do the required header rewrite.
2. Post: "Dropped ingress-nginx for Traefik: header rewrite on the auth path is unsupported upstream. Issues touching ingress config need re-scoping." Report it with the project link.
