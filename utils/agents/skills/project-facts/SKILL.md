---
name: project-facts
description: project-facts Report what a repository builds with, which of those commands its CI actually enforces, and how it releases. Use when you need a project's real commands before running or delegating them. Not for running the gates, and not for a repository whose tooling you would have to invent.
references:
  - ../references/project-tooling.md
  - ../references/scm/release-convention.md
  - ../references/agent/agent-conventions.md
scripts:
  # Relative to this skill's own directory: resolve against the `bundleDir` the
  # skill metadata carries, never a hardcoded absolute path, because the tree
  # sits at a different root on every runtime that serves this catalog.
  - ./scripts/project_facts.py
---

## Context

Three questions asked before running or delegating anything in an unfamiliar repository, each mechanical and each with a silent failure mode:

| Question | Answer |
|---|---|
| What does it build with? | the task runner and the commands it defines |
| What actually gates a merge? | the commands CI runs |
| How does it release? | whether a commit type sets a version bump |

`project-tooling` owns the discovery table and `release-convention` owns the release detection; both remain the prose. This skill is the mechanical version of the same questions, so an agent stops re-deriving them by hand and stops guessing when the answer is absent.

**The third question is the one usually skipped and the one that matters most.** Discovery says which commands *exist*. Only the pipeline says which of them a merge waits on. A green task runner is not a green pipeline, and acting on the first without the second is the mistake this exists to remove.

## Process

Run the script against the repository root; `--json` for a machine-readable report.

```sh
"<bundleDir>/scripts/project_facts.py" /absolute/path/to/repo
```

The listing is the set of gates, not their execution order - it does not read GitLab `stages:` or job dependencies.

```
runner:   task  (Taskfile.yml)
commands: format, lint, test, build
ci:       .gitlab-ci.yml
  ci runs: task lint
  ci runs: task test
release:  semantic-release  (release.config.js)
note:     semantic-release releases from commits: the commit type sets the version bump
```

Then:

1. **Run what CI runs, in the order the pipeline uses.** A task the runner defines but the pipeline never invokes is optional; a step CI runs with no local task still has to pass.
2. **Carry the commands into a dispatch prompt** rather than letting a delegate rediscover them, per `agent-conventions`.
3. **Heed a `note:` line.** Each one is a case where the repository does not answer the question, and the correct response is to ask rather than to substitute a plausible command.

## Pitfalls

- **Treating the runner's command list as the gate list.** They overlap; they are not the same set, and only the pipeline decides a merge.
- **Inventing a command when `runner: none`.** A language-generic guess passes or fails on rules the pipeline does not apply, so it proves nothing. Ask instead.
- **Ignoring the release line before writing a commit subject.** Where release automation is commit-driven, the type chooses the version bump, and a wrong type ships a wrong version silently.
- **Reading `ci: none` as "no gates".** It means nothing in the repository establishes them, which is a question for the user, not a licence to skip checks.
- **Running it somewhere other than the repository root.** It reads marker files at the path it is given and finds nothing one directory down.
