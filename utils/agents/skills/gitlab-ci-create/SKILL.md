---
name: gitlab-ci-create
description: gitlab-ci-create Create or update GitLab CI pipelines on the shared devops/pipelines templates. Use on "add a pipeline", "set up GitLab CI", "change .gitlab-ci.yml". Not for diagnosing a failing pipeline, for GitHub Actions, or for MR descriptions.
disableModelInvocation: true
references:
  - ../references/scm/scm-detect.md
  - ../references/scm/scm-gitlab.md
  - ../references/kilic/kilic-ci-pipelines.md
argumentHint: '[optional: what the pipeline should do]'
---

## GitLab CI: Create and Update GitLab CI/CD Pipelines

GitLab tooling, local git, CLI fallback, and platform detection per `scm-detect` and `scm-gitlab`. The template and pipe model, versions, rules and variable sources are covered in `kilic-ci-pipelines`.

## Process

1. **Understand the requirement.** Clarify what the pipeline should do: build, test, lint, deploy or release. Identify the language, framework and runtime involved.
2. **Analyze existing patterns.** Read the repository's `.gitlab-ci.yml`: includes, stages, variables and job structure. New additions stay consistent with them.
3. **Normalize to the current model.** Replace raw scripts that duplicate a template, and includes of anything other than `devops/pipelines`, with explicit `devops/pipelines` includes.
4. **Pick the templates.** List `devops/pipelines` with `gitlab__get_repository_tree`, and read each candidate template with `gitlab__get_file_contents` at the tag you will pin. Check its inputs, variables, rules and `script: pipe <command>`.
5. **Pin the latest version**, taken from the newest `<package>@*` tag or release, per `kilic-ci-pipelines`.
6. **Find the variables** in the pipe's generated `README.md` in `devops/pipes`, falling back to `flags.go` and the task lists `main.go` combines. Never guess a variable.
7. **Offer a reference implementation.** Ask whether a repository or `.gitlab-ci.yml` should be the base, or find one on the same package with `sourcebot-kilic__grep` for `ref: <package>@`. Adapt it to this repository's conventions.
8. **Draft the pipeline.** Present the complete `.gitlab-ci.yml` in chat. Explain each include and job, and list the variables the user can customise.
9. **Write it after approval.** CI lint checks syntax; the merge request pipeline is the runtime check.

## Migration Guidance

When modernising an existing consumer:

1. **Inventory behaviour first**: includes, stages, variables, jobs, `only`/`except`, `rules`, schedules, branch and tag behaviour, and artifacts.
2. **Preserve behaviour by default.** Templates are composed one job at a time. Add a job only for behaviour the repository already has or the user asks for, such as `node/test`, manifest publishing or Docker Hub README updates.
3. **Copy migrated repositories** on the same package for stages, inputs, variables and job names.
4. **Translate variables** by reading the current template and the pipe README. Drop names the current template does not accept.
5. **Rules**: convert `only`/`except` to `rules` when touching a job. A job-level `rules:` replaces the template's rules; it does not add to them. Add `workflow` rules only where they preserve or clarify existing behaviour.

## Key Principles

- **Templates over scripts.** A job a template covers extends the template.
- **Pinned tags, latest version.** Pin `<package>@<version>` from the GitLab tags and releases, never `main`.
- **Read, never guess, variables.** They come from the pipe README or `flags.go`.
- **Compose intentionally.** Add only the jobs the repository needs.
- **Match existing patterns** for stages, rules and variable naming.

## Related Skills

- **`gitlab-ci-fix`** — for a failing pipeline rather than a new or changed one. Suggest it when the user reports CI failures.
