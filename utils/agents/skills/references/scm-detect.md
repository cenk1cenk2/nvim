# SCM Platform Detection and Git Tools

## Detect Current Branch and Platform

**Step 1: Get current branch and remote URL.**

Use `git status` to get the current branch name, and `git rev-parse --abbrev-ref HEAD` / `git remote get-url origin` for scripted parsing. Local git is always the raw `git` CLI via `Bash` — there is no git MCP server.

**Step 2: Determine the SCM platform from the remote URL.**

| Remote URL pattern | Platform | Reference to read |
|---|---|---|
| `github.com` in URL | GitHub | `scm-github` reference |
| `gitlab.*` in URL (e.g., `gitlab.com`, `gitlab.kilic.dev`) | GitLab | `scm-gitlab` reference |

Parse the remote URL to extract:

- **GitHub:** `git@github.com:<owner>/<repo>.git` → `owner` + `repo`.
- **GitLab:** `git@gitlab.example.com:<group>/<project>.git` → `project_path` (supports nested groups: `<group>/<subgroup>/<project>`).

**Step 3: Read the matching platform reference**. The platform reference contains the full list of available MCP tools for that provider.

If the skill already knows the platform (e.g., user provided a URL, or it's a platform-specific skill), skip detection and read the platform reference directly.

## Local Git Operations

Local git is the raw `git` CLI via `Bash` — there is no git MCP server. Common commands:

| Command | Purpose |
|---------|---------|
| `git status` | Current branch, staged/unstaged changes. |
| `git branch` | List branches. |
| `git diff <ref1> <ref2>` | Diff between refs (branches, commits). |
| `git diff --cached` | Staged changes only. |
| `git diff` | Unstaged changes only. |
| `git log` | Commit history. |
| `git show <ref>` | Show a specific commit. |
| `git add <path>` | Stage files for commit. |
| `git commit -m "<msg>"` | Create a commit with staged changes. |
| `git reset` | Unstage files or reset to a ref. |
| `git checkout <ref>` | Switch branches or restore files. |
| `git branch <branch>` | Create a branch from HEAD or a ref. **Does NOT switch** — run `git checkout` after. |
