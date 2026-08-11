---
name: agent-unaware
description: agent-unaware Author instructions for a target with no MCP tools and no skills - a plain chat model, a hosted coding agent, a CI job, or a person - by inlining every convention and spelling out exact commands instead of pointing at things it cannot open. Use when drafting prompts, issues, or docs for an outside executor. Not for a target that shares your skills and servers.
disableModelInvocation: true
argumentHint: '[artifact being authored]'
references:
  - ../references/agent/agent-target-capability.md
  - ../references/redact-private-data.md
---

## Writing for a Bare Target

Capability axes, tier defaults, mixed/unknown handling, and the opening declaration line: `agent-target-capability`. An unaware target usually sits outside this setup, so every specific that reaches the artifact is redacted per `redact-private-data`.

## Context

The target has no hyprpilot skills, no MCP servers, and often no memory or repo. Every pointer you would normally write is a dead link to it: a skill slug is noise, `linear-kilic__get_issue` is an unknown function, `~/.config/nvim/utils/agents/...` is a path it cannot open.

So the artifact carries the **content itself** and the **exact method**. Where an aware target gets intent and picks its own path, an unaware target gets the path — because a wrong guess is the likely outcome, and it cannot check its work against anything.

## Process

1. **Establish what it actually has.** Per the `agent-target-capability` reference, per axis: shell, network, repo, write authority. Ask the user; unknown counts as unavailable.
2. **List every pointer your draft wants to use** — skills, MCP tools, references, internal paths, prior conversation. Each one becomes an inlining task.
3. **Translate each pointer to content** using the table below. Inline only the slice that applies to this task — never dump a whole reference.
4. **Replace intent with exact method.** Concrete commands, exact file paths, expected output. Where you would say "handle the errors appropriately", name the errors.
5. **Restate every decision made in conversation.** No "as discussed", no "the approach we picked".
6. **Give runnable verification** — the exact command and what passing output looks like. If the target cannot run anything, say so and give a review checklist instead.
7. **Define the blocked path.** It cannot consult anything, so state plainly: report what is missing and stop, do not invent. Say where the output goes and in what format.
8. **Redact.** Sweep for private specifics per the reference before presenting.
9. **Present the draft**, iterate, then write.

## Pointer Translation

| Aware phrasing | Unaware rewrite |
|----------------|-----------------|
| "Load the `git-commit` skill." | Paste the commit format rules that apply, with one example subject line. |
| "Use `github__create_pull_request`." | `gh pr create --title "..." --body-file pr.md`, or "print the PR body and stop; a human opens it". |
| "Read the repo `AGENTS.md`." | Paste the handful of rules that bear on this task. |
| "Fetch issue `K-123`." | Paste title, description, and acceptance criteria. |
| "Follow project conventions." | Name them: formatter command, test command, naming, file layout. |
| "Verify as appropriate." | `task lint && task test`, expected: exit 0, no diff. |
| "Explore the codebase." | Paste the relevant files or excerpts with their paths. |
| "As we discussed." | State the decision and the reason. |

## Conventions

Do:

- Number the steps. One bounded action each.
- Give absolute or repo-relative paths, never "the config file".
- Quote error strings and expected output exactly.
- Cap the scope: what to touch, what to leave alone.
- Say what to produce — diff, file, message body — and where it lands.

Don't:

- Don't name a skill slug, `hyprpilot://` URI, or `<server>__<tool>` tool.
- Don't reference this repo's internal agent paths.
- Don't paste an entire reference when three rules apply.
- Don't leave placeholders: "TBD", "handle edge cases", "similar to above".
- Don't assume it can ask a follow-up question. Often it cannot.

## Example

**Trigger:** "/agent-unaware — write a prompt for the hosted CI agent to fix the failing lint job"

1. Establish: shell yes, repo yes, MCP no, skills no, network no.
2. Pointers found: `git-commit` skill, repo `CLAUDE.md`, the failing job output.
3. Inline: the two commit rules that matter, the three style rules from `CLAUDE.md` touching this file, the exact failing lines.
4. Method: `stylua --config-path .stylua.toml <file>`, then `task lint`, expected exit 0.
5. Blocked path: "if lint still fails, print the full output and stop."

**Result:** a prompt that runs correctly in an environment sharing none of this setup.

## Key Principles

- Every pointer is a dead link — translate it into content or delete it.
- Inline the slice, not the whole reference.
- Prescribe the method; a bare target guessing is a bad outcome, not an acceptable one.
- Verification must be runnable by the target, or replaced by a checklist.
- Define blocked behavior explicitly: report and stop, never invent.
- No private specifics leave the setup.

## Related Skills

- **`agent-aware`** — same job, target sharing your skills and MCP servers.
- **`plan-handoff`** — cross-repo/session plans; this skill sets their inlining depth.
- **`agent-delegate`** — its self-contained-prompt rule covers missing conversation; this covers missing tools.
