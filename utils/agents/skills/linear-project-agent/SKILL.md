---
name: linear-project-agent
description: Structure and manage Linear projects for autonomous agent execution. Use when creating project plans, breaking down work into issues, or reviewing project structure. Do NOT use for loading or chaining other skills.
interaction: chat
argument-hint: "[create|update|review] [project-name] [description of what the project does]"
references:
  - ../references/linear-description-structure.md
---

## system

> **ALWAYS enter plan mode.**
>
> Read the `linear-description-structure` reference for issue/project description format — resolve references from the `<References>` block via `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/linear-project-agent/references" })` or filesystem tools.

### What is an Agent Project?

An **agent project** is a Linear project designed for autonomous execution by LLM agents. Each issue must be:

1. **Single repository** — Does not span multiple repositories
2. **Single PR** — Doable as one logical, self-contained change
3. **Single concern** — Touches one section/layer of the project

### Why This Matters

LLM agents work best when:
- Each issue has a clear scope and boundaries
- The repository structure is evident from the issue description
- No cross-repository orchestration is needed
- PR reviews can focus on one area of concern

### Process

#### Create

1. **Gather context** — Understand the work to be done. Ask the user what the project should accomplish.
2. **Identify repositories** — Determine which repositories are involved. If multiple repos, consider splitting into sub-projects.
3. **Break down into layers** — Group work by concern (infrastructure, workload, networking, DNS, etc.).
4. **One issue per layer per repo** — Each issue touches ONE repository and ONE layer.
5. **Order by dependency** — Issues should have clear dependencies stated.
6. **Validate** — Run the issue checklist (see below).
7. **Present to user** — Show the structured project for approval.

#### Update

1. **Read existing issues** — Get current project state from Linear.
2. **Identify changes needed** — What's new, changed, or removed.
3. **Check single-repo constraint** — If an issue spans repos, split it.
4. **Validate** — Run the issue checklist.
5. **Present changes** — Show what's changing.

#### Review

1. **List all issues** — Get all issues in the project.
2. **Check each against principles** — Single repo? Single PR? Single concern?
3. **Identify violations** — Flag issues that span repos or concerns.
4. **Propose restructuring** — Suggest splits or merges.

### Issue Structure Checklist

For each issue, verify:

| Criterion | Valid | Invalid Example |
|-----------|-------|-----------------|
| **Single repository** | `cluster/workloads/teamspeak3` | Vault + K8s manifest in same issue |
| **Single PR** | Add deployment + service + secret | Add deployment in repo A, route in repo B |
| **Single concern** | Kubernetes manifests only | Manifests + DNS + routing |
| **Named repo** | "**Repo:** `cluster/sun/argocd-sun`" | No repo mentioned at all |
| **Clear boundary** | "Infrastructure layer" or "Workload layer" | Ambiguous scope |

### Manual Tasks

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

### Agent Project Template

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

## Issue Order

1. K-171: Create GitLab repo access (prereq)
2. K-173: Create workload manifests
3. K-170: Create ArgoCD Application
4. K-175: Configure load balancer routes
5. K-177: Create DNS SRV records
6. K-174: Migrate data (manual)
7. K-176: Validate and cutover (manual)

## Dependencies

- K-173 requires K-172 (Vault secret) — manual prereq
- K-171 is a prerequisite for K-170, K-173
```

### Key Principles

1. **Repository name in every issue** — Every issue description must state the repository explicitly (`**Repo:** path/to/repo`).

2. **One repo per issue** — If work touches multiple repos, create separate issues for each.

3. **External systems as tasks** — If an external step (Vault, manual migration) is needed for one issue's work, include it as a task within that issue, not a separate issue.

4. **Separate issue per external repo** — If an external system requires its own PR/change, create a separate issue in the appropriate project.

5. **Ask about external dependencies** — When an issue touches external systems (Vault, external APIs, services), ask:
   - "Is this external system configured via code, or is it a manual operation?"
   - If code → Create separate issue in that repository
   - If manual → Include as a task within the related issue

6. **State dependencies clearly** — Use "Related Issues" sections to link dependencies.

### Common Patterns

| Pattern | Structure |
|---------|-----------|
| **Kubernetes workload** | One repo for manifests, one for ArgoCD Application, one for routing |
| **Infrastructure** | One repo per infrastructure change |
| **DNS changes** | One repo for DNS provider (Terraform, ExternalDNS, etc.) |
| **Secrets** | If Vault managed via code → separate repo issue; If manual → task in workload issue |

### Anti-Patterns

❌ **Don't create issues like:**
- "Set up TeamSpeak" (spans multiple repos, too vague)
- "Create workload and routing" (two concerns, two repos)
- "Configure Vault and create ExternalSecret" (could be one issue if Vault is manual)

✅ **Do create issues like:**
- "Create teamspeak3 workload manifests" (one repo, one PR)
- "Configure load balancer routes for teamspeak3" (one repo, one PR)
- "Create SRV records in tf-config-cloudflare" (one repo, one PR)

### Examples

---

**User says:** "Create an agent project for deploying PostgreSQL to Kubernetes"

1. Ask: "Which repositories are involved? Is this a new workload or adding to existing infrastructure?"
2. Identify layers: Workload manifests, ArgoCD Application, Storage, Secrets, Networking
3. Create one issue per layer per repo
4. Check for external dependencies (Vault, S3, etc.) — ask about code vs manual
5. Present structured project

---

**User says:** "Review the redis-operator project"

1. List all issues in the project
2. Check each for single-repo, single-PR, single-concern
3. Flag issues that violate principles
4. Propose restructure if needed