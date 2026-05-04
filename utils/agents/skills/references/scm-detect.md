# SCM Platform Detection and Git Tools

## Detect Current Branch and Platform

**Step 1: Get current branch and remote URL.**

Use `git status` to get the current branch name. If git MCP is unavailable, fall back to `git rev-parse --abbrev-ref HEAD` and `git remote get-url origin` via CLI.

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

## Local Git MCP Tools

Use these for all local repository operations. Fall back to CLI equivalents if git MCP is unavailable.

| Tool | Purpose | CLI fallback |
|------|---------|--------------|
| `git status` | Current branch, staged/unstaged changes. | `git status` |
| `git branch` | List, create, or check branches. | `git branch` |
| `git diff` | Diff between refs (branches, commits). | `git diff <ref1> <ref2>` |
| `git diff --staged` | Staged changes only. | `git diff --cached` |
| `git diff` | Unstaged changes only. | `git diff` |
| `git log` | Commit history. | `git log` |
| `git show` | Show a specific commit. | `git show <ref>` |
| `git add` | Stage files for commit. | `git add <path>` |
| `git commit` | Create a commit with staged changes. | `git commit -m "<msg>"` |
| `git reset` | Unstage files or reset to a ref. | `git reset` |
| `git checkout` | Switch branches or restore files. | `git checkout <ref>` |
| `git branch` | Create a new branch from current HEAD or a ref. **Does NOT switch to it** — call `git checkout` after. | `git branch <branch>` |
