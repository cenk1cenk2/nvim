---
name: agent-aware
description: agent-aware Author instructions for a target agent that shares your access - skills, MCP servers, repo, instruction files - so you point at things by name instead of inlining what it already has. Use when drafting subagent prompts, handoff plans, AGENTS.md, or issues your own agents pick up. Not for a target with no tools or skills.
disableModelInvocation: true
argumentHint: '[artifact being authored]'
references:
  - ../references/agent/agent-target-capability.md
---

## Writing for a Capable Target

Capability axes, tier defaults, mixed/unknown handling, and the opening declaration line: `agent-target-capability`.

## Context

The target executes the same setup you do: hyprpilot skills, this MCP catalog, this machine's repos and instruction files. It is missing exactly one thing — the conversation. So the artifact carries **intent and pointers**, never procedure the reader already owns.

Pasting a skill body into a prompt forks it: the skill gets fixed next week, your copy does not, and the agent follows the stale copy. Point at the source of truth and let the target load it fresh.

## Process

1. **Confirm the target is aware.** Per the `agent-target-capability` reference. Ask if unstated; do not assume from the artifact type alone.
2. **Verify what exists.** Resolve skill slugs with `list_skills` and server names against the active tool list. A pointer to a skill dropped by the current profile is worse than no pointer.
3. **Open with the declaration line.** State the assumed surface so a wrong assumption surfaces immediately.
4. **Write pointers for anything covered by a skill, reference, or repo file.**
   - Skills by slug: "load the `git-commit` skill and follow it".
   - Tools in `<server>__<tool>` short form.
   - Repo conventions by path: "follow `CLAUDE.md` in the repo root".
5. **Inline only what the target cannot derive** — the goal, scope, file ownership, boundaries, decisions already made, gotchas found this session, anything that lives solely in this conversation.
6. **State intent and acceptance, not keystrokes.** Give what done looks like and how to prove it; leave method selection to the target.
7. **Name prerequisites and ordering.** Workspace skills that must be active first, skills that must load before an action, holds and sequencing gates.
8. **Add a degradation line.** One sentence on what to do if a named skill or server is missing — do it manually, or stop and report. The artifact must fail loudly, not silently improvise.
9. **Present the draft**, iterate, then write.

## Conventions

Do:

- Point at the skill: "load `plan-hard`" beats a paraphrase of its process.
- Point at the tool: "find call sites with `sourcebot-kilic__grep`".
- Point at the file: "conventions in `docs/CONTRIBUTING.md`".
- Spell out the conversation-only parts in full — the target has zero history.
- Give acceptance criteria and verification commands.

Don't:

- Don't inline a skill body — it forks and rots.
- Don't dictate every tool call when the target can pick better at runtime.
- Don't name a skill or server you did not verify.
- Don't assume the target's MCP profile equals yours without saying so.
- Don't write "as we discussed" — that context does not travel.

## Example

**Trigger:** "/agent-aware — brief a subagent to land the branch cleanup"

1. Confirm target: subagent in this harness, aware on skills and MCP.
2. `list_skills` confirms `git-branch` and `git-commit` exist.
3. Draft prompt: declaration line, goal, owned paths, "load `git-branch` for naming and `git-commit` for the message format", acceptance criteria, degradation line.
4. Present prompt, dispatch after approval.

**Result:** a short prompt that stays correct as the skills evolve, because it carries no copy of them.

## Key Principles

- Point, do not paste — an inlined copy of a skill is a stale fork the day it is written.
- Verify every slug and server name before referencing it; never fabricate capability.
- Conversation-only context is the one thing that MUST be inlined.
- Intent and acceptance over keystrokes — the target picks the method.
- Declare the assumed surface, and say what to do when it is wrong.

## Related Skills

- **`agent-unaware`** — same job, target with no tools or skills.
- **`agent-delegate`** / **`agent-plan`** — dispatch mechanics; this skill shapes the prompt they send.
- **`plan-handoff`** — handoff plan files; this skill decides how much they inline.
- **`linear-structure-agent`** — Linear issues written for agent pickup.
