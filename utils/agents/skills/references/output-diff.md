# Output Diff

How to present a change for approval, so the user sees exactly what will be written — and why — before anything executes.

## Core Principle

Present changes in **logical chunks**. Each chunk is:

1. **Reasoning** — 1-2 sentences: what this chunk does and why.
2. **Content block** — a fenced block showing the content to be created, or the diff to be applied.

Reasoning sits on top so the user can decide whether to read the block below it. Present **all** chunks before asking for approval; never interleave chunks with approval prompts.

## Rules

- One chunk per logical change; group related small changes under a shared reason.
- Omit unchanged fields entirely. For long-form edits, show a concise diff of what moved, was added, or was removed — never dump unchanged surrounding text.
- Group short metadata fields (title, priority, labels, estimate, team) into one chunk; give long-form sections (description body, analysis) their own.
- Language tag by content: `diff` for field changes, `markdown` for prose, `yaml` for structured config, plain for short field groups.
- Wait for explicit approval before the write — unless the request already blessed it, in which case act and report.

## Examples

Update:

> Title was generic. Updated to name the actual scope.
>
> ```diff
> - fix: update config
> + fix(auth): rotate JWT signing key
> ```

Create:

> High priority because the certificates are managed by hand today.
>
> ```
> title:    Add cert-manager to <cluster>
> team:     Infrastructure
> priority: High
> labels:   kubernetes, security
> ```

Slack posts use the same shape with lighter formatting: present the full message draft in a quoted block, then ask.

## Scope

Applies to **any** change presented for approval — external resources (Linear, GitHub/GitLab, Obsidian, Slack, Notion) and local files alike, including code edits, skills, references, and guidance files when a skill directs you here.

Does not apply to read-only operations (fetching, listing, searching) or to lightweight status transitions such as adding an emoji reaction.
