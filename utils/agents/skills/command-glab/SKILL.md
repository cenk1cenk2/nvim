---
name: command-glab
description: command-glab When to run the glab CLI rather than the GitLab MCP server, and how to build native MR stacks with glab stack and fall back when it fails. Load before running `glab`, or before opening a stack of MRs. Not for MR, issue or pipeline work the GitLab MCP server already does.
references:
  - ../references/scm/scm-gitlab.md
---

## Route

- **The GitLab MCP server first** for MRs, issues, pipelines, branches and file reads; tool surface per `scm-gitlab`.
- **`glab` for what the server cannot do**: streaming a job log, a stack, an output the server cannot return, a bulk job that would cost dozens of calls. Say in one line what the server was missing.
- **Writes gate like any external write**: summarize the change and wait unless the user already cleared that class of write. Reads never gate.

## Stacks — `glab stack`

`glab stack` is marked experimental and not ready for production use, so every step has a fallback. Load `gitlab-mr-create` before opening any stacked MR; its title, description, merge defaults and in-stack squash rule apply to every layer.

1. `glab stack create <name>` starts the stack.
2. `glab stack save` commits each layer.
3. `glab stack sync` pushes, rebases, and opens an MR per layer targeting the layer below. Flags that matter: `--update-base`, `--skip-mr-creation`, `--reviewer`. It writes to the remote, so it gates as an external write.
4. **After `sync`**, bring every MR it opened up to those title, description and merge defaults with `gitlab__update_merge_request`; `sync` creates them without those. Squash stays off on every MR in the stack.

**On any `glab stack` failure**, say so and fall back to plain MRs, each created with `--target-branch <layer below>`.

## Failure Modes

- **`glab` not authenticated** — `glab auth status` names the host; report it rather than switching accounts.
- **`glab` not on `PATH`** — resolve it per `AGENTS.md` §IV mise.
