---
name: agent-refactor
description: "Use when restructuring a repository — investigation, blast radius analysis, step-by-step implementation with agent delegation and audit cycles. Covers single-MR incremental refactors, parallel repo preparation, and devil's advocate review."
disableModelInvocation: false
references:
  - ../references/agent/agent-aware.md
---

# Agent Refactor

Structured approach to large repository restructures. Investigation first, then incremental implementation with agent delegation and audit cycles between steps.

## When to use

- Restructuring a repository's folder layout, module structure, or shared packages
- Migrating to a new pattern (go.work, internal packages, workspace setup)
- Any multi-step refactor where each step builds on the previous and blast radius matters

## Process

### Phase 1: Investigation

1. **Spawn a Fable investigation session** (restricted auto, read-only) on a fresh worktree of the target repo. Give it creative freedom — ask it to look at everything, not just what the user mentioned.
2. **Steer the investigation** across multiple turns as the user adds requirements. The Fable session retains all context, so each steer deepens the analysis without re-reading files.
3. **Let the user confirm the target state** — the investigation should end with a clear set of recommendations the user agrees with.

### Phase 2: Plan

4. **Steer the same Fable session** to produce a detailed, step-by-step implementation plan. Each step needs: what, why, files touched, changes, verification, dependencies, MR scope, and risk.
5. **Spawn a fresh Fable session** (different session, no prior context) to do a devil's advocate review of the plan. Give it the plan file and the repo — let it verify claims, check for breaking changes, find missed risks, identify what other repos need parallel work.
6. **Fix critical issues** found by the review in the plan before starting implementation.

### Phase 3: Implementation

7. **Create a single branch** for the whole refactor. All steps commit to this branch.
8. **Delegate each step to an opus agent** — write a self-contained prompt from the plan, spawn on the shared worktree in auto mode.
9. **Audit each step with the original Fable session** — steer it with the commit hash and ask it to verify against the plan. Green-light or send back for fixes.
10. **Fixes go back to the opus agent** via `session_send` — never apply fixes directly as the lead. The agent retains context and can amend its commit.
11. **Push after each step** so CI runs on the growing branch.
12. **Parallel repo work** — while the main MR progresses, delegate agents for other repos that need changes (consumer repos, shared libraries, config repos). These MRs merge after the main MR.

### Phase 4: Final review

13. **Spawn a fresh Fable session** for a final independent review of the complete MR diff against the plan. This is a different session from the investigation/audit one.
14. **Follow-up cleanup** — after the main MR merges, create separate PRs for legacy cleanup (removing old env aliases, dead code, etc).

## Key rules

- **Single branch, single MR** for the main refactor. Steps commit incrementally. The branch grows step by step.
- **Fable for investigation and audit. Opus for implementation.** The Fable session that wrote the plan audits each step — it has the full context. A fresh Fable does the final review — no prior bias.
- **Never apply fixes directly as lead.** Steer the opus agent to fix its own work. The agent has the context, the lead doesn't.
- **Additive changes only** for env vars, flags, and other consumer-facing interfaces. Old names stay as aliases. Cleanup is a separate follow-up PR.
- **Parallel repo agents** can run while the main MR progresses. Their MRs merge after the main MR.
- **Don't review parallel repo MRs** — the user handles those. Only review the main MR.
- **Each step must verify** — `go build`, `go test`, `go vet`, lint, docs regeneration. The agent's prompt lists exact verification commands.
- **Arm watchers** on every spawned agent. Detached sessions finish into silence — use `done.json` watchers to wake on completion.

## Prompt structure for implementation steps

Each step prompt sent to an opus agent must include:

1. **Step number and title** — which step from the plan
2. **Goal** — one-line description
3. **Working directory** — absolute path to the shared worktree, branch name
4. **What to do** — concrete file-by-file changes with code snippets where the pattern isn't obvious
5. **What NOT to touch** — scope guard
6. **Verification** — exact commands to run before committing
7. **Commit format** — conventional commit, git identity, no K-xxx trailer if no Linear issue
8. **Done criteria** — checklist of what "complete" means

For complex steps (many files, non-obvious patterns), use `file:` parameter with a temp file prompt instead of inline.

## Audit prompt structure

When steering Fable to audit a step:

1. **Commit hash** — what to review
2. **What the step should have done** — from the plan
3. **Agent notes** — any deviations or issues the implementation agent flagged
4. **Verification questions** — specific things to check
5. **Verdict request** — green-light and proceed, or send back for fixes?

## Session management

- **Investigation Fable** — one session, steered across many turns. Keep it alive throughout — it audits every step.
- **Implementation opus** — one session per step. Steer for fixes if needed. Can reap after the step is green-lit and committed.
- **Review Fable** — fresh session for the final review. Different from the investigation session.
- **Parallel repo agents** — separate sessions, separate worktrees, separate repos. Independent lifecycle.

## Pitfalls

- **Blast radius** — every consumer repo that uses `latest` tags gets the change immediately. Tag stable images before starting, or add smoke tests.
- **Stale vendor** — after go.work, any `go.mod` edit without `go work vendor` breaks everything. Document it, make Taskfile depend on it.
- **Remote Taskfiles** — shared Taskfile includes that use `go mod vendor` break under `go.work`. Prepare a workspace-aware Taskfile in the shared library repo before the go.work step.
- **CI lint validation** — GitLab CI lint can't resolve local includes from unpushed branches. Push first, then lint with `content_ref`.
- **golangci-lint** — no native `go.work` support. Must pass per-module dirs explicitly.
- **Renovate** — `gomodTidyAll` in `postUpdateOptions` handles workspace `replace` directives. Verify the first Renovate MR after merge shows all go.mod files tidy.