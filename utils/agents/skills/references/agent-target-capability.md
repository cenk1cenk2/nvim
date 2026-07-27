# Target Agent Capability

Applies when you author an artifact that **another agent executes** — subagent dispatch prompt, handoff plan file, Linear issue/project description, repository `AGENTS.md`/`CLAUDE.md`, scaffolded project docs, a prompt pasted into some other tool.

How you write it depends entirely on what the reader can reach. Decide that first, before drafting a line.

## Capability Axes

Judge each axis separately — targets are often mixed.

| Axis | Available means | Unavailable means |
|------|-----------------|-------------------|
| Hyprpilot skills | Can load `hyprpilot://skills/<slug>` and follow it. | Skill slugs are meaningless text — inline the content. |
| MCP servers | Can call `<server>__<tool>` (which servers, exactly). | Only CLI, or nothing but its own reasoning. |
| Repository | Has the checkout, can read any path. | Needs the code pasted, or works blind. |
| Instruction files | Reads `AGENTS.md` / `CLAUDE.md` on its own. | Rules must be inlined. |
| Memory / prior sessions | Carries durable context. | Zero history — restate everything. |
| Shell / network | Can run commands, fetch docs. | Cannot verify its own work. |
| Write authority | Commits, pushes, opens PRs. | Produces text only; a human executes. |

## Deciding the Tier

Ask the user when it is not stated. Defaults when they do not answer:

| Target | Default |
|--------|---------|
| Subagent in this harness | Aware — same tools, same skills, no conversation context. |
| Another session on this machine | Aware. |
| Cloud/vendor coding agent (CI job, hosted agent, IDE assistant) | Unaware. |
| Plain chat model, or a human colleague | Unaware. |

Rules:

- **Unknown axis counts as unavailable.** Inlining costs tokens; a pointer to something the reader cannot open costs the whole task.
- **Mixed targets are normal.** Aware on MCP, unaware on skills is common — write per axis, not per label.
- **Never fabricate capability.** Only name a skill slug confirmed via `list_skills` and a server confirmed in the active tool list. Profile filtering drops some.

## Declare It in the Artifact

Every artifact written for another agent opens with one line stating the assumed surface, so a wrong assumption is visible instead of silent.

```
Assumes: hyprpilot skills available, `github` + `linear-kilic` MCP, repo checked out at `<path>`.
```

Unaware artifacts state the inverse — "no MCP tools assumed; every command below is plain CLI".
