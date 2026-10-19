---
name: labrat-handoff
description: labrat-handoff Hand work to labrat and let it run - an agent-aware brief posted as a labrat mention in Slack, with an optional delegate provider and tier, no watcher by default. Use on "hand this to labrat", "let labrat do it", "send it to labrat and forget it". Not for reading or following a running offsite session, or taking its work back.
disableModelInvocation: true
argumentHint: '[what to hand off] [provider: claude|codex|opencode] [tier: cheap|default|smart|max]'
references:
  - ../references/agent/agent-target-capability.md
  - ../references/identifier-legibility.md
---

## Context

labrat is the offsite Hermes agent. It is **aware** on every axis per `agent-target-capability`: it loads this same hyprpilot skills catalog, reaches nearly the same MCP servers (GitLab, Linear, ArgoCD, Grafana, Kubernetes, Vault, Sourcebot, Slack), clones the repos itself, and dispatches its own delegates through `hyprpilot-delegate` with its `dispatch-*` skills. It lacks only this conversation. So the brief carries intent and pointers, never procedure; Load `agent-aware` before drafting it.

The transport is a Slack message posted as the user through the workspace's Slack skill. labrat reads it as a human turn, and one Slack thread is one labrat session. A connector post carries a "Sent using Claude" context block that labrat sees as a duplicated payload; it is noise and needs no workaround.

## Delegation

| Given | labrat does |
|---|---|
| nothing | picks provider and tier per unit itself |
| provider only | uses that provider and picks the tier per unit |
| provider and tier | uses both for every unit |
| tier only | uses that tier on its default provider |

Provider is `claude`, `codex` or `opencode`; tier words resolve per `agent-harness`. Name only what the user named, and state the remainder as labrat's call so it does not ask back.

## Process

1. **Scope the handoff.** The goal, the scope and its edges, the decisions already made, and what done looks like. When another skill shaped the work, a plan, a Linear project, an annihilation handoff, hand over its output by name rather than restating it.
2. **Draft the brief per `agent-aware`.** Open with the declaration line, then:
   - the goal and acceptance;
   - pointers: the Linear project or issues, the plan file, the repos, every identifier a titled link per `identifier-legibility`;
   - the skills and postures to load by slug, `code-style` for any code;
   - the delegation line from the table above;
   - holds: never merge, gates that stay with the user, anything else this conversation settled;
   - the stance: autonomous, checkpointed or gated, and what to report back to the thread.
3. **Pick the place.** A top-level post in the agents channel that mentions labrat starts a new session. Every later message in that thread reaches the same session without a mention, so steers and answers are plain thread replies; mention labrat again only to start a new thread. Resolve the channel through the workspace's Slack skill.
4. **Present the exact message** and post it on approval.
5. **Confirm it landed, then let go.** Load `labrat` and find the session by the post's thread ts; labrat typically opens it within seconds and its reply lands in the thread. Report the Slack permalink as the handle. No watcher is armed unless the user asks to follow; following and taking the work back are the `labrat` and `labrat-pickup` skills.

## Composition

This skill only delivers. Any `agent-*` or planning skill that produces a self-contained brief can feed it: `agent-annihilate-handoff` writes the project and kickoff line, this skill posts it; `plan-handoff` writes the plan, this skill points labrat at it. Postures named in the brief (`agent-bulldozer`, `agent-coordinator`, `agent-bohrhammer`) run on labrat, not here.

## Example

**Trigger:** "hand the dashboard split to labrat, claude, let it pick tiers"

1. Scope: split the oversized monitoring dashboards, one MR per repository, the user merges.
2. Brief: declaration line, goal, repos, "load `code-style`", delegation "provider claude, tiers your call per unit", holds "no merges", stance checkpointed with an MR link per unit to the thread.
3. Place: new post in the agents channel, mentioning labrat.
4. Message presented, approved, posted.
5. A labrat session appears for that thread ts; the permalink is reported and the handoff ends.

**Result:** labrat owns the work with a brief that names everything and copies nothing.
