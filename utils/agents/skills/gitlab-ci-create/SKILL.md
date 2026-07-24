---
name: gitlab-ci-create
description: gitlab-ci-create Create or update GitLab CI/CD pipelines using the devops/pipelines task-based model. Use when user says "add a pipeline", "set up GitLab CI", or "modify .gitlab-ci.yml". Do NOT use for diagnosing failures (gitlab-ci-fix), GitHub Actions (github-ci-create), or MR descriptions (gitlab-mr-create).
disable-model-invocation: true
references:
  - ../references/present-first.md
  - ../references/scm-gitlab.md
---

## GitLab CI: Create and Update GitLab CI/CD Pipelines

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## Core Requirements

> Read the `scm-gitlab` reference for GitLab MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection

## Architecture: devops/pipelines + devops/pipes

The CI/CD system has two layers:

- **`devops/pipelines`** — Reusable pipeline templates with `spec:` inputs. Each template defines a hidden job (e.g., `.node-install`) that consumers extend. Templates are versioned with semantic tags (e.g., `node@1.2.0`).
- **`devops/pipes`** — Containerized Go CLI tools that implement the actual logic. Each pipe is a monorepo module at `pipes/<pipe-name>/` with one or more commands. Consumer pipelines should use these tools through `devops/pipelines`.

Consumer pipelines should only describe the current `devops/pipelines` model. The `devops/pipes` repository itself may still have custom CI for building and publishing the pipe CLIs, but consumers should not depend on its embedded template layer.

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

## Process

1. **Understand the requirement.** Clarify what the pipeline should do: build, test, lint, deploy, release, etc. Identify the language, framework, and runtime involved.
2. **Analyze existing patterns.** Read `.gitlab-ci.yml` in the current repository. Note existing includes, stages, variables, and job structure. New additions must be consistent with existing patterns.
3. **Normalize to the current model.** If the existing `.gitlab-ci.yml` still uses non-current consumer includes or raw scripts for behavior that has a template, migrate that behavior to explicit `devops/pipelines` includes. Do not preserve or document removed include paths unless needed as temporary evidence during analysis.
4. **Search for available templates.** Use `gitlab__get_repository_tree` on `devops/pipelines` to find templates for the required technology. Read the template file via `gitlab__get_file_contents` to understand its `spec:` inputs and job definition.
5. **Fetch latest template version.** Use `gitlab__list_tags` on `devops/pipelines` to find the latest tag for the relevant template (e.g., `node@1.2.0`). Always use the latest version.
6. **Discover available environment variables.** Read the corresponding pipe's flags from `devops/pipes`:
   - Find the pipe module in `pipes/<pipe-name>/`.
   - Read `flags.go` files for each relevant command.
   - Read `main.go` to understand `CombineTaskLists` and which tasklists (and their flags) are combined.
   - Follow subtask imports to find all available environment variables.
7. **Ask for reference implementation (optional).** Ask the user if they have a reference repository or `.gitlab-ci.yml` they want to base the pipeline on. If provided, read it via `gitlab__get_file_contents` and adapt its patterns to the current repository's conventions.
8. **Draft the pipeline.** Write the complete `.gitlab-ci.yml` and present it in chat. Explain what each include and job does. List the available environment variables the user can customize.
9. **Ask to implement.** After approval, write the pipeline file.

## Migration Guidance

When modernizing an existing consumer:

1. **Inventory behavior first.** Record the current includes, stages, variables, jobs, `only`/`except`, `rules`, schedules, branch/tag behavior, and artifacts.
2. **Preserve behavior by default.** Do not add new jobs just because another bundle exposed them. The new templates are intentionally composed one job at a time.
3. **Use current migrated repositories as examples.** Search for repositories already using the same `devops/pipelines` package and copy their style for stages, inputs, variables, and job names.
4. **Compose from new templates only.** Pick the minimal explicit template set from `devops/pipelines` for the real behavior: `node/install`, `node/build`, `node/lint`, `node/run`, `semantic-release/publish`, `buildah/build`, `buildah/registry-gitlab`, `buildah/registry-dockerhub`, `buildah/manifest`, `docker/update-docker-hub-readme`, or other current templates as appropriate.
5. **Do not add accidental jobs.** Add `node/test`, manifest publishing, DockerHub README updates, or other optional jobs only when the repository already has that behavior or the user asks for it.
6. **Translate variables by reading current templates and pipe flags.** Use the variable names expected by `devops/pipelines` and the current pipe implementation. Do not carry forward previous variable names unless the current template still accepts them.
7. **Modernize rules carefully.** Convert `only`/`except` to equivalent `rules` when touching the job. Add `workflow` rules only when they preserve or clarify the existing pipeline behavior, such as preventing duplicate branch/MR pipelines.
8. **Validate through the MR pipeline.** CI lint is useful for syntax, but the merge request pipeline is the runtime validation source unless the user asks for another verification path.

## Key Principles

- **Always use devops/pipelines templates.** Never write raw scripts when a template exists for the job.
- **Use only the current consumer model.** Keep `devops/pipes` as the CLI/flag source, not as a consumer template source.
- **Always fetch latest versions.** Check tags on `devops/pipelines` before referencing a template version.
- **Always read the pipe's flags.** Do not guess environment variables — read `flags.go` from `devops/pipes` to know what is available.
- **Follow the CombineTaskLists chain.** A pipe's full set of environment variables comes from all tasklists combined in `main.go`, not just one `flags.go`.
- **Compose intentionally.** Add only the templates and jobs the repository actually uses. Do not add `node/test`, manifests, or readme updates unless the repository has that behavior or the user asks for it.
- **Migrate instead of expanding non-current patterns.** If non-current consumer patterns are found during ordinary pipeline work, replace them with the current task-based model before adding new behavior.
- **Match existing patterns.** If the repository already has a `.gitlab-ci.yml`, follow its conventions for stages, rules, and variable naming.

## Related Skills

- **`gitlab-ci-fix`** — for diagnosing failures in existing GitLab CI pipelines. Auto-invoke when the user reports CI failures instead of wanting to create/update pipelines.
