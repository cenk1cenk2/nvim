# SCM Platform Detection and Git Tools

## Detect Current Branch and Platform

**Step 1: Get current branch and remote URL.**

Use `git__git_status` to get the current branch name. If git MCP is unavailable, fall back to `git rev-parse --abbrev-ref HEAD` and `git remote get-url origin` via CLI.

**Step 2: Determine the SCM platform from the remote URL.**

| Remote URL pattern | Platform | Reference to read |
|---|---|---|
| `github.com` in URL | GitHub | `scm-github` reference |
| `gitlab.*` in URL (e.g., `gitlab.com`, `gitlab.kilic.dev`) | GitLab | `scm-gitlab` reference |

Parse the remote URL to extract:

- **GitHub:** `git@github.com:<owner>/<repo>.git` → `owner` + `repo`.
- **GitLab:** `git@gitlab.example.com:<group>/<project>.git` → `project_path` (supports nested groups: `<group>/<subgroup>/<project>`).

**Step 3: Read the matching platform reference** from the `<References>` block via MCP filesystem tools. The platform reference contains the full list of available MCP tools for that provider.

If the skill already knows the platform (e.g., user provided a URL, or it's a platform-specific skill), skip detection and read the platform reference directly.

## Local Git MCP Tools

Use these for all local repository operations. Fall back to CLI equivalents if git MCP is unavailable.

| Tool | Purpose | CLI fallback |
|------|---------|--------------|
| `git__git_status` | Current branch, staged/unstaged changes. | `git status` |
| `git__git_branch` | List, create, or check branches. | `git branch` |
| `git__git_diff` | Diff between refs (branches, commits). | `git diff <ref1> <ref2>` |
| `git__git_diff_staged` | Staged changes only. | `git diff --cached` |
| `git__git_diff_unstaged` | Unstaged changes only. | `git diff` |
| `git__git_log` | Commit history. | `git log` |
| `git__git_show` | Show a specific commit. | `git show <ref>` |
