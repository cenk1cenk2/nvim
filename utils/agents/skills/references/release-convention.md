# Release Convention Detection

Detect the repository's automated release method and follow the convention it consumes, so a merge publishes the intended version and bump. Used by `git-push`, `github-pr-create`, `gitlab-mr-create`.

Do not assume — detect from repo files (via `github__get_file_contents` / `gitlab__get_file_contents`, or local `Read` / `git` on a checked-out branch). Different repos configure differently, and CI-driven tools often have no standalone config file.

## Detect the method

A repo may combine several (e.g. commitlint + release-please).

**release-please** — commit-driven; opens a release PR that bumps the version and CHANGELOG.
- `release-please-config.json`, `.release-please-manifest.json`, or a workflow (`.github/workflows/*.yml`) using `googleapis/release-please-action`.
- Consumes Conventional Commits on the default branch.

**semantic-release** — commit-driven; publishes from CI. Often has NO config file — it runs from the pipeline with defaults.
- Config (optional): `.releaserc`, `.releaserc.json`, `.releaserc.yaml` / `.yml`, `.releaserc.js` / `.cjs` / `.mjs`, `release.config.js` / `.cjs` / `.mjs`, or a `"release"` key in `package.json`.
- CI signal: `semantic-release` / `npx semantic-release` (or `cycjimmy/semantic-release-action`) in a GitHub Actions workflow or `.gitlab-ci.yml`; or `semantic-release` in `package.json` devDependencies.
- Default preset is **Angular** (`@semantic-release/commit-analyzer`): `feat` → minor, `fix` / `perf` → patch.

**changesets** — file-driven, NOT commit-driven.
- `.changeset/config.json` plus `.changeset/*.md` files.
- Each user-facing change needs a changeset file; the bump comes from those files, not commit messages.

**commitlint** — enforces the format (no release on its own; usually paired with the above or a CI title check).
- `commitlint.config.(js|cjs|mjs|ts|cts|mts)`, `.commitlintrc` (`.json` / `.yaml` / `.yml` / `.js` / …), or `"commitlint"` in `package.json`. `@commitlint/config-conventional` = Conventional Commits.

**conventional-changelog / commit-and-tag-version** (formerly `standard-version`) — commit-driven changelog + tag.
- `.versionrc`, `.versionrc.json`, `.versionrc.js`, or the tool in `package.json`.

If none match, there is no release automation to satisfy — use the normal conventional-commit title/commit and skip the rest.

## Apply the convention

### Commit-driven (release-please, semantic-release, commitlint, conventional-changelog)

Commits — and, on a squash-merge repo, the **PR/MR title** — MUST be valid Conventional Commits: `type(scope): subject`.

- `feat:` → **minor**; `fix:` / `perf:` → **patch**. Other types (`docs`, `chore`, `refactor`, `test`, …) do not trigger a release by default.
- **Squash vs merge decides what the tool reads.** Squash-merge → the PR/MR title becomes the release commit, so the title must carry the right type and breaking marker. Merge / rebase → every commit on the branch must be conventional. (GitLab uses the MR title as the squash commit subject when "Squash commits" is on — see `gitlab-mr-create`'s squash logic.)

### Breaking changes — get the MAJOR bump right

A breaking change must be marked, or the tool ships it as a minor/patch. Mark it **both** ways for cross-tool safety:

- `!` after the type/scope: `feat(api)!: drop v1 auth`.
- a footer: `BREAKING CHANGE: v1 auth is removed; migrate to v2.`

Why both:
- The Conventional Commits spec accepts either the `!` or the footer.
- release-please honors the `!` (`feat!:`) and a `BREAKING-CHANGE:` footer.
- semantic-release's default **Angular** preset keys on the `BREAKING CHANGE:` **footer** — always include the footer for semantic-release, not just the `!`.
- On squash-merge, put the breaking marker in the **title (`!`)** AND the `BREAKING CHANGE:` footer in the PR/MR description so both survive into the squash commit.

### Changesets

- The bump is driven by `.changeset/*.md`, not commits. For any user-facing change the branch MUST include a changeset; a `.changeset/` folder with only `config.json` counts as missing.
- If none is present, tell the user and offer to add one — `npx changeset` (interactive), or write `.changeset/<name>.md`:
  ```markdown
  ---
  "<package-name>": minor
  ---

  Short summary of the change.
  ```
  Bump level is `patch` | `minor` | `major` (major = breaking). Add it BEFORE the PR/MR merges.
- The title follows the repo's normal style; the changeset — not the title — sets the version.

## When unsure

If the method is ambiguous or the required convention is unclear, state what you found (cite the file/workflow) and ask before overriding a title, rewording a commit, or adding a changeset.

## Sources

- Conventional Commits v1.0.0 — https://www.conventionalcommits.org/en/v1.0.0/
- semantic-release configuration — https://semantic-release.gitbook.io/semantic-release/usage/configuration
- semantic-release commit-analyzer (Angular default, `BREAKING CHANGE` footer) — https://github.com/semantic-release/commit-analyzer
- release-please — https://github.com/googleapis/release-please ; action — https://github.com/googleapis/release-please-action
- changesets config + adding — https://github.com/changesets/changesets/blob/main/docs/config-file-options.md , https://github.com/changesets/changesets/blob/main/docs/adding-a-changeset.md
- commitlint configuration — https://commitlint.js.org/reference/configuration.html
