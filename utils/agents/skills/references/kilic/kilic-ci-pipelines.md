# Kilic CI Pipelines

How GitLab CI works across `gitlab.kilic.dev`: two repositories in the `devops` group back almost every `.gitlab-ci.yml` in the estate. Read this when authoring a pipeline or tracing a failing job to its cause.

## The two layers

| Repo | Holds | Consumers touch it by |
|---|---|---|
| [`devops/pipelines`](https://gitlab.kilic.dev/devops/pipelines) | GitLab CI templates, one directory per package (`buildah`, `docker`, `go`, `helm`, `kustomize`, `node`, `pulumi`, `references`, `semantic-release`, `terraform`). Each `<package>/<template>.gitlab-ci.yml` defines one hidden job `.<name>`. | `include: project: devops/pipelines`, `ref: <package>@<version>`, then `extends: .<name>` on their own job with their own `stage:` |
| [`devops/pipes`](https://gitlab.kilic.dev/devops/pipes) | Go CLIs, one directory per pipe at the repository root, each with a directory per command (`terraform/plan/`, `terraform/apply/`, …), built on [`libraries/plumber`](https://gitlab.kilic.dev/libraries/plumber) and published as the `cenk1cenk2/pipe-<pipe>` images. Shared code sits in `internal/`. | never directly. A template's job runs `image: cenk1cenk2/pipe-<pipe>:<version>` with `script: pipe <command>`, configured by environment variables |

Consumer templates live only in `devops/pipelines`. `devops/pipes` builds the images and nothing includes CI files from it.

## Versions

- Every package is released on its own and tagged `<package>@<semver>`. `ref:` pins that tag and never `main`.
- The latest version of a package, and what changed in it, is in the GitLab tags and releases of `devops/pipelines`: the newest `<package>@*` tag and its release notes. The GitLab server registers no tag or release listing, so use `glab release list -R devops/pipelines`, `glab release view <package>@<version> -R devops/pipelines`, or `git ls-remote --tags` on the repo. The in-repo `CHANGELOG.md` files and the README version table are not maintained, so trust the tags, the releases and the template file.
- The template's `version` input picks the pipe image tag. It defaults to `latest`, and the `pulumi` package defaults to `latest-node`.

## Template contract

- Almost every template has three inputs: `name`, the hidden job name; `version`, the image tag; and `tags`, the runner tags, default `["docker"]`. To get two differently named jobs from one template, include the same file twice with a different `name`.
- `rules` is hardcoded in the job body in every package, not taken as an input. The standard block runs on merge request events (interruptible), on the default branch, and on tags.
- **Deploying templates are manual.** `terraform/deploy` and `pulumi/up` have no merge request rule and run `when: manual` on the default branch and on tags.
- To change a job's rules, write `rules:` on the consuming job. GitLab CI replaces a `rules` array; it never merges one. The reusable rule lists are the `.references.rules.*` entries in `references/rules.gitlab-ci.yml`.
- `semantic-release/workflow.gitlab-ci.yml` sets `workflow:rules`: tags, MRs and parent pipelines run, protected branches run, other branch pushes do not, and `chore(release):` pushes are dropped. A repository with its own workflow rules writes them before `!reference [.semantic-release-workflow, rules]`. If two included files both set `workflow:`, the last one wins.

## Where a variable comes from

Each pipe's `README.md` in `devops/pipes`, for example `terraform/README.md`, is generated from its flags. It lists every environment variable per command, with its type and default, and it is the first place to look. The source is `<pipe>/<command>/flags.go`, and `<pipe>/main.go` combines the task lists that one `pipe <command>` runs, which adds their flags as well. A template may also set variables of its own, such as `TF_ROOT`, `TF_STATE_TYPE` or `PULUMI_CWD`. Read the template file at the pinned tag.

## Tracing a failing job

1. In the consuming `.gitlab-ci.yml`, find the job's `extends: .<name>`, then the `include` that provides it and its `ref: <package>@<version>`.
2. Read that template at that tag: its image, `script: pipe <command>`, variables and rules.
3. The log lines come from `devops/pipes` `<pipe>/<command>/`. Match the failing task there, and check the flag it needs in the pipe README.
4. Decide where the fix belongs:
   - the consumer (a variable, input or rule);
   - a template bump (a newer `<package>@<version>`, read its release notes);
   - `devops/pipelines` or `devops/pipes` itself. That is a separate MR on those repos, and every consumer picks it up only when it bumps its tag or image.

## Authoring in the devops repos

`devops/pipelines` keeps its scaffolds for a new package or template in `.claude/skills/` (`create-pipeline-package`, `create-pipeline-template`). Read those before adding a template.
