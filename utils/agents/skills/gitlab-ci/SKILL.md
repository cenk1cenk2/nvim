---
name: gitlab-ci
description: Create or update GitLab CI/CD pipelines using the devops/pipelines task-based model. Use when user says "add a pipeline", "set up GitLab CI", or "modify .gitlab-ci.yml". Do NOT use for diagnosing failures (gitlab-ci-fix), GitHub Actions (github-ci), or MR descriptions (gitlab-mr-create).
interaction: chat
disable-model-invocation: true
references:
  - ../references/plan-mode.md
  - ../references/scm-gitlab.md
---

## system

### GitLab CI: Create and Update GitLab CI/CD Pipelines

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — resolve references from the `<References>` block via MCP filesystem tools.
>
> - Use `EnterPlanMode` tool immediately.
> - Research existing patterns and available templates before proposing anything.
> - Present findings and proposed pipeline to the user.
> - Do NOT write files until the user explicitly approves.

### Core Requirements

> Read the `scm-gitlab` reference for GitLab MCP tools, git MCP tools, CLI fallback, and platform detection — resolve references from the `<References>` block via MCP filesystem tools.

### Architecture: devops/pipelines + devops/pipes

The CI/CD system has two layers:

- **`devops/pipelines`** — Reusable pipeline templates with `spec:` inputs. Each template defines a hidden job (e.g., `.node-install`) that consumers extend. Templates are versioned with semantic tags (e.g., `node@1.2.0`).
- **`devops/pipes`** — Containerized Go CLI tools that implement the actual logic. Each pipe is a monorepo module at `pipes/<pipe-name>/` with one or more commands.

**Environment variables** for a given template are defined in the corresponding pipe's flags:
- Single-command pipes: `pipes/<pipe-name>/pipe/flags.go`.
- Multi-command pipes: `pipes/<pipe-name>/<command>/flags.go`.
- Combined arguments are visible in `pipes/<pipe-name>/main.go` via `CombineTaskLists()` calls, which merge multiple tasklists and their flags into one pipe.
- Subtask imports may define additional flags — follow the `CombineTaskLists` chain to find all available environment variables.

**Consumer pattern** (the new way):
```yaml
include:
  - project: devops/pipelines
    ref: node@1.2.0
    file:
      - /node/install.gitlab-ci.yml
      - /node/build.gitlab-ci.yml
    inputs:
      rules:
        - when: always

node-install:
  extends: .node-install
```

### Process

1. **Understand the requirement.** Clarify what the pipeline should do: build, test, lint, deploy, release, etc. Identify the language, framework, and runtime involved.
2. **Analyze existing patterns.** Read `.gitlab-ci.yml` in the current repository. Note existing includes, stages, variables, and job structure. New additions must be consistent with existing patterns.
3. **Check for old template usage.** If the existing `.gitlab-ci.yml` uses raw scripts or the old template-based approach instead of `devops/pipelines` includes, prompt the user: "This pipeline uses the old template approach. Would you like to migrate to the task-based model from devops/pipelines?" Offer to migrate if accepted.
4. **Search for available templates.** Use `gitlab__get_repository_tree` on `devops/pipelines` to find templates for the required technology. Read the template file via `gitlab__get_file_contents` to understand its `spec:` inputs and job definition.
5. **Fetch latest template version.** Use `gitlab__list_tags` on `devops/pipelines` to find the latest tag for the relevant template (e.g., `node@1.2.0`). Always use the latest version.
6. **Discover available environment variables.** Read the corresponding pipe's flags from `devops/pipes`:
   - Find the pipe module in `pipes/<pipe-name>/`.
   - Read `flags.go` files for each relevant command.
   - Read `main.go` to understand `CombineTaskLists` and which tasklists (and their flags) are combined.
   - Follow subtask imports to find all available environment variables.
7. **Ask for reference implementation (optional).** Ask the user if they have a reference repository or `.gitlab-ci.yml` they want to base the pipeline on. If provided, read it via `gitlab__get_file_contents` and adapt its patterns to the current repository's conventions.
8. **Draft the pipeline.** Write the complete `.gitlab-ci.yml` and present it in chat. Explain what each include and job does. List the available environment variables the user can customize.
9. **Ask to implement.** After user approval, exit plan mode and write the pipeline file.

### Key Principles

- **Always use devops/pipelines templates.** Never write raw scripts when a template exists for the job.
- **Always fetch latest versions.** Check tags on `devops/pipelines` before referencing a template version.
- **Always read the pipe's flags.** Do not guess environment variables — read `flags.go` from `devops/pipes` to know what is available.
- **Follow the CombineTaskLists chain.** A pipe's full set of environment variables comes from all tasklists combined in `main.go`, not just one `flags.go`.
- **Prompt for migration.** If old templates or raw scripts are found, ask the user if they want to migrate to the task-based model.
- **Match existing patterns.** If the repository already has a `.gitlab-ci.yml`, follow its conventions for stages, rules, and variable naming.

### Related Skills

- **`gitlab-ci-fix`** (resource: `skills://skill/gitlab-ci-fix`) — for diagnosing failures in existing GitLab CI pipelines. Auto-invoke when the user reports CI failures instead of wanting to create/update pipelines.
