# SCM Platform Detection and Git Tools

**Local git is always the raw `git` CLI via `Bash` — there is no git MCP server.** Nor a `kubernetes` one; same rule, use `kubectl`.

## Detect the platform

Read the remote (`git remote get-url origin`) and branch (`git status`), then load the matching platform reference — it carries that provider's tool list.

| Remote URL contains | Platform | Reference |
|---|---|---|
| `github.com` | GitHub | `scm-github` |
| `gitlab.*` (e.g. `gitlab.com`, `gitlab.kilic.dev`) | GitLab | `scm-gitlab` |

Parse out what the platform tools need:

- **GitHub:** `git@github.com:<owner>/<repo>.git` gives `owner` + `repo`.
- **GitLab:** `git@gitlab.example.com:<group>/<project>.git` gives `project_path` — and it **supports nested groups**, so `<group>/<subgroup>/<project>` is one path, not a group plus a project.

Skip detection when the platform is already known (the user gave a URL, or the skill is platform-specific) and read that platform's reference directly.

## The one git command worth stating

`git branch <name>` creates without switching — follow it with `git checkout <name>`. Everything else (`status`, `diff`, `log`, `show`, `add`, `commit`, `reset`, `checkout`) behaves as expected and needs no table here.
