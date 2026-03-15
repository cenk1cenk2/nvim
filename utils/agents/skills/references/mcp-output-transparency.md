# MCP Output Transparency

Standardized chat output conventions for skills that write to external systems (Linear, GitHub, GitLab, Obsidian, Slack, Notion). These rules ensure the user sees exactly what will be created or changed — and why — before any MCP write operation executes.

## Core Principle

Always present changes in **logical chunks**. Each chunk has:

1. **Reasoning** (1-2 sentences) — explains what this chunk does and why.
2. **Content block** — a fenced code block (with appropriate language tag) showing the actual content being created or the diff being applied.

The reasoning sits on top so the user can decide whether to read the content block below. Present ALL chunks before asking for approval — do not interleave with approval prompts.

## Update Operations

Before applying any update, chunk each logical change. Use diff-style formatting to show what changed.

**Format:**

> <1-2 sentence reasoning for this change.>
>
> ````diff
> - <old content>
> + <new content>
> ````

**Rules:**

- One chunk per logical change. Group related small changes (e.g., two label additions) when the reasoning is shared.
- For long-form content changes (descriptions, bodies), show a concise diff — highlight what moved, was added, or was removed. Do not dump unchanged surrounding text.
- Omit unchanged fields entirely.
- Use the appropriate code block language: `diff` for field changes, `markdown` for description rewrites, `yaml` for configuration changes.
- Wait for explicit user approval before calling any MCP write tool.

**Example:**

> Title was generic. Updated to reflect the actual scope — auth key rotation.
>
> ```diff
> - fix: update config
> + fix(auth): rotate JWT signing key
> ```

> This is a security-related change, not routine maintenance.
>
> ```diff
> labels:
> - chore
> + security
> ```

> The original description lacked context on why the rotation was needed. Added a reasoning section.
>
> ```markdown
> ## Reasoning
>
> The signing key exceeded its 90-day rotation policy. Rotating now
> to prevent token validation failures when the key expires next week.
> ```

## Create Operations

Before creating any resource, chunk each logical section. Show the actual content that will be written.

**Format:**

> <1-2 sentence reasoning for including this content.>
>
> ````<language>
> <actual content being created>
> ````

**Rules:**

- One chunk per meaningful section or logical group.
- For short metadata fields (title, priority, labels, estimate, team), group them into a single chunk.
- For long-form sections (description body, analysis, appendix), show the full content that will be written.
- Use appropriate code block language: `markdown` for descriptions, `yaml` for structured metadata, plain (no tag) for short field groups.
- Present ALL sections before asking for approval.
- Wait for explicit user approval before calling any MCP create tool.

**Example:**

> High priority because TLS certificates are currently managed manually. Estimate based on similar operator deployments.
>
> ```
> title:    Add cert-manager to cluster-rubik
> team:     Infrastructure
> priority: High
> labels:   kubernetes, security
> estimate: 3
> ```

> One-liner covering what is being deployed and where.
>
> ```markdown
> Deploy cert-manager v1.14 to cluster-rubik for automated TLS certificate
> management via Let's Encrypt.
> ```

> Four steps covering deployment, configuration, migration, and verification.
>
> ```markdown
> - [ ] Add cert-manager Helm chart to ArgoCD workloads.
> - [ ] Configure ClusterIssuer for Let's Encrypt production.
> - [ ] Migrate existing manual certificates.
> - [ ] Verify renewal cycle works end-to-end.
> ```

> Research findings on cert-manager 1.14 changes and cluster-rubik compatibility.
>
> ```markdown
> ## Analysis
>
> cert-manager 1.14 introduces gateway API support natively, removing the
> need for the separate gateway-shim. cluster-rubik runs gateway API v1.1
> which is fully compatible. The migration path from manual certs requires
> annotating existing Ingress resources with cert-manager solver references.
> ```

## Slack-Specific Guidance

For Slack posts (channel summaries, thread replies), the create pattern applies but with lighter formatting — present the full message draft in a quoted block and ask for approval before sending.

## Scope

This reference applies to ANY MCP tool call that creates or modifies a resource in an external system. It does NOT apply to:

- Read-only operations (fetching, listing, searching).
- Local file operations (code edits, plan files).
- Reactions or lightweight status transitions (e.g., adding an emoji reaction).
