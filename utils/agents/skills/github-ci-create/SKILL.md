---
name: github-ci-create
description: 'github-ci-create Create or update GitHub Actions workflows for the current repo. Triggers: "add CI", "set up GitHub Actions", "modify the workflow". Do NOT use for diagnosing failures (github-ci-fix), GitLab pipelines (gitlab-ci-create), or PR descriptions (github-pr-create).'
disableModelInvocation: true
references:
  - ../references/scm-github.md
---

## GitHub CI: Create and Update GitHub Actions Workflows

## Core Requirements

- GitHub MCP tools, local git (raw `git` CLI), CLI fallback, and platform detection per `scm-github`.
- **ALWAYS prefer existing, well-maintained GitHub Actions over writing custom steps.** Search GitHub for a preexisting action before building your own.
- **ALWAYS fetch the latest version** of any action from its GitHub repository before referencing it in a workflow. Do not hardcode old versions.
- **ALWAYS consult documentation** for actions and tools via GitHub MCP when unsure about configuration options.

## Process

1. **Understand the requirement.** Clarify what the workflow should do: build, test, lint, deploy, release, etc. Identify the language, framework, and runtime involved.
2. **Analyze existing patterns.** Read `.github/workflows/` in the current repository for existing workflows. Note naming conventions, reusable patterns, shared secrets, matrix strategies, and runner choices. New workflows must be consistent with existing ones.
3. **Research reference implementations.** If the user provides a reference repository, use `github__get_file_contents` to read its workflows and understand how they are structured. Adapt the patterns to the current repository's conventions.
4. **Search for existing actions.** Use `github__search_repositories` and `github__search_code` to find well-maintained actions for the job. Evaluate candidates by: stars, recent activity, maintenance status, and community adoption. Prefer official actions (`actions/*`) and verified creators.
5. **Fetch latest versions.** For every action to be used, fetch its latest release via `github__get_latest_release` or `github__list_tags` from the action's repository. Use the latest stable version tag, never `@master` or `@main`.
6. **Consult documentation.** Read the action's `README.md` via `github__get_file_contents` to understand all available inputs, outputs, and configuration options. Do not guess at configuration — verify from the source.
7. **Draft the workflow.** Write the complete workflow YAML and present it in chat. Explain the purpose of each job and step. Highlight any decisions or trade-offs made.
8. **Ask to implement.** After approval, write the workflow file to `.github/workflows/`.

## Key Principles

- **Never reinvent the wheel.** Always search for an existing action before writing custom shell steps.
- **Always use latest versions.** Fetch and verify the current version tag from the action's repository.
- **Always read the docs.** Do not configure actions from memory — read the README from the source repository.
- **Match existing patterns.** If the repository already has workflows, follow their conventions for naming, triggers, runners, and structure.
- **Be explicit.** Pin action versions to exact tags (e.g., `v4.1.0`), not major-only refs (e.g., `v4`), unless the repository's existing workflows use major-only refs.

## Related Skills

- **`github-ci-fix`** — for diagnosing failures in existing GitHub Actions workflows. Auto-invoke when the user reports CI failures instead of wanting to create/update workflows.
