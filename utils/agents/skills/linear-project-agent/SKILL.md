---
name: linear-project-agent
description: 'linear-project-agent Structure Linear projects for autonomous agent execution - agent-ready plans, self-contained issues, readiness review. Triggers: "set up this project for agents". Requires a workspace skill (/linear-kilic or /linear-laravel). Do NOT use for generic project creation (/linear-project-create) or status updates (/linear-project-post).'
argumentHint: "[create|update|review] [project-name] [description of what the project does]"
references:
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/output-diff.md
  - ../references/present-first.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/sourcebot-discovery.md
  - ../references/linear-pickup-execution.md
---

> **PREREQUISITE:** Read the `linear-prerequisite` reference for workspace detection rules. A Linear workspace skill MUST be active before this skill runs.

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> Read the `linear-description-structure` reference for issue/project description format or filesystem tools.

> Read the `linear-project-documents` reference for using Linear documents as shared agent context and for propagating investigations, plans, solved problems, and deviations. When issues would repeat the same instructions, keep issues light and store the shared guidance in project documents. Attach these documents on demand with the `linear-document` skill, kept tightly focused — one concern per document, like obsidian repository notes.

> Read the `linear-scm-discovery` reference when the user explicitly asks to discover repositories, enrich the project from GitHub/GitLab, or make the project easier for agents to implement. Use `sourcebot-discovery` through that workflow for broad or unknown-repo searches when available.

> Read the `output-diff` reference before writing project documents or issues to Linear — present document drafts and issue content in logical chunks for user approval.

> Read the `linear-pickup-execution` reference when the user wants the structured project executed after creation or review. Use `agents-pickup` for the execution phase instead of embedding implementation into this structure skill.

## What is an Agent Project?

An **agent project** is a Linear project designed for autonomous execution by LLM agents. Each issue must be:

1. **Single repository** — Does not span multiple repositories
2. **Single PR** — Doable as one logical, self-contained change
3. **Single concern** — Touches one section/layer of the project

## Why This Matters

LLM agents work best when:
- Each issue has a clear scope and boundaries
- The repository structure is evident from the issue description
- No cross-repository orchestration is needed
- PR reviews can focus on one area of concern

## Process

### Create

1. **Gather context** — Understand the work to be done. Ask the user what the project should accomplish.
2. **Identify repositories** — Determine which repositories are involved. If multiple repos, consider splitting into sub-projects.
3. **Discover implementation context** — If explicitly requested, run SCM discovery to identify involved repositories, existing implementation patterns, related MRs/PRs, likely file boundaries, and verification commands.
4. **Break down into layers** — Group work by concern (infrastructure, workload, networking, DNS, etc.).
5. **Extract shared context** — If many issues need the same instructions, candidate matrix, repository inventory, research, or verification commands, draft a project document for that shared information.
6. **One issue per layer per repo** — Each issue touches ONE repository and ONE layer.
7. **Keep repetitive issues light** — Put only the repo/scope, issue-specific checklist or delta, exceptions, and a "Read first" reference to the project document in each issue.
8. **Set dependencies** — Use `blockedBy`, `blocks`, and `parentId` fields for dependency ordering. Never put this in descriptions.
9. **Validate** — Run the issue checklist (see below).
10. **Present to user** — Show the structured project, project documents, and issues for approval.
11. **Execution handoff** — If the user wants work to start, hand off the approved project structure to `agents-pickup`.

### Update

1. **Read existing issues** — Get current project state from Linear.
2. **Identify changes needed** — What's new, changed, or removed.
3. **Check single-repo constraint** — If an issue spans repos, split it.
4. **Validate** — Run the issue checklist.
5. **Present changes** — Show what's changing.

### Review

1. **List all issues** — Get all issues in the project.
2. **Check each against principles** — Single repo? Single PR? Single concern?
3. **Identify violations** — Flag issues that span repos or concerns.
4. **Propose restructuring** — Suggest splits or merges.

## Issue Structure Checklist

For each issue, verify:

| Criterion | Valid | Invalid Example |
|-----------|-------|-----------------|
| **Single repository** | `cluster/workloads/teamspeak3` | Vault + K8s manifest in same issue |
| **Single PR** | Add deployment + service + secret | Add deployment in repo A, route in repo B |
| **Single concern** | Kubernetes manifests only | Manifests + DNS + routing |
| **Named repo** | "**Repo:** `cluster/sun/argocd-sun`" | No repo mentioned at all |
| **Clear boundary** | "Infrastructure layer" or "Workload layer" | Ambiguous scope |
| **Shared context** | "Read first: project document `Migration guide`" | Repeated long guidance copied into every issue |

## Manual Tasks

Small manual steps can be **tasks within an issue** if:
- They are dependencies for the main work
- They are relevant to the same concern
- They are one-time operations (e.g., create Vault secret)

**Examples:**

| Manual Task | Belongs In | Reason |
|--------------|-----------|---------|
| Create Vault secret | Workload issue (as task) | Dependency for ExternalSecret in same issue |
| Migrate data from old server | Separate issue | Significant work, different concern |
| Run terraform apply | Issue with terraform code | Part of completing the PR |

**Ask the user** when uncertain if a manual step should be separate or included.

## Agent Project Template

Use this structure for Linear project descriptions:

```markdown
## Context

[Brief description of what this project delivers]

## Architecture

[Diagram or description of components and their relationships]

## Repositories

| Repo | Purpose |
|------|---------|
| `cluster/workloads/teamspeak3` | Kubernetes manifests |
| `cluster/sun/argocd-sun` | Load balancer routing |
```

Set dependency ordering via `blockedBy` / `blocks` / `parentId` fields on each issue — never in the project description.

Use documents for shared agent instructions or durable findings that would make the project or issue descriptions too long — authored on demand via the `linear-document` skill, one focused concern each. Examples: `Agent execution guide`, `Candidate matrix`, `Migration guide`, `Research and decisions`, `Investigation: <topic>`, or `Deviations`.

## Key Principles

1. **Repository name in every issue** — Every issue description must state the repository explicitly (`**Repo:** path/to/repo`).

2. **One repo per issue** — If work touches multiple repos, create separate issues for each.

3. **Documents hold shared and durable context** — If multiple issues need the same guide, matrix, research, or agent instructions, or the work surfaces an investigation, solved problem, or deviation worth propagating, capture it as a document via the `linear-document` skill — one tightly focused concern per document, like obsidian repository notes — and reference it from the issues.

4. **Lightweight repetitive issues** — When a project document exists, each issue should only state the repo/scope, issue-specific work, exceptions, and the relevant project document to read first.

5. **External systems as tasks** — If an external step (Vault, manual migration) is needed for one issue's work, include it as a task within that issue, not a separate issue.

6. **Separate issue per external repo** — If an external system requires its own PR/change, create a separate issue in the appropriate project.

7. **Ask about external dependencies** — When an issue touches external systems (Vault, external APIs, services), ask:
   - "Is this external system configured via code, or is it a manual operation?"
   - If code → Create separate issue in that repository
   - If manual → Include as a task within the related issue

8. **Set dependencies via Linear fields** — Use `blockedBy`, `blocks`, and `parentId` for dependency ordering. Never put dependency chains or sub-issue tables in descriptions. Linear shows these relations natively.

9. **Execution is a separate phase** — This skill structures projects for agents; `agents-pickup` executes them.

## Common Patterns

| Pattern | Structure |
|---------|-----------|
| **Kubernetes workload** | One repo for manifests, one for ArgoCD Application, one for routing |
| **Infrastructure** | One repo per infrastructure change |
| **DNS changes** | One repo for DNS provider (Terraform, ExternalDNS, etc.) |
| **Secrets** | If Vault managed via code → separate repo issue; If manual → task in workload issue |

## Anti-Patterns

❌ **Don't create issues like:**
- "Set up TeamSpeak" (spans multiple repos, too vague)
- "Create workload and routing" (two concerns, two repos)
- "Configure Vault and create ExternalSecret" (could be one issue if Vault is manual)

✅ **Do create issues like:**
- "Create teamspeak3 workload manifests" (one repo, one PR)
- "Configure load balancer routes for teamspeak3" (one repo, one PR)
- "Create SRV records in tf-config-cloudflare" (one repo, one PR)

## Examples

---

**User says:** "Create an agent project for deploying PostgreSQL to Kubernetes"

1. Ask: "Which repositories are involved? Is this a new workload or adding to existing infrastructure?"
2. Identify layers: Workload manifests, ArgoCD Application, Storage, Secrets, Networking
3. Create shared project documentation for common architecture, conventions, and verification if multiple issues need it
4. Create one issue per layer per repo, keeping repetitive issues light and pointing them to the project document
5. Check for external dependencies (Vault, S3, etc.) — ask about code vs manual
6. Present structured project

---

**User says:** "Review the redis-operator project"

1. List all issues in the project
2. Check each for single-repo, single-PR, single-concern
3. Flag issues that violate principles
4. Propose restructure if needed
