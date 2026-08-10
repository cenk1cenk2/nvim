---
name: plan-revise
description: 'plan-revise Revise an existing plan file when the direction was wrong - gathers what went wrong (and partial implementation via git), re-interviews on the deltas, updates the plan in place with a dated revision entry. Triggers: "revise the plan", "we got it wrong", "change direction". Do NOT use for new plans (/plan-hard), unchanged pickup (/plan-pickup), or handoffs (/plan-handoff).'
references:
  - ../references/reconcile-state.md
  - ../references/plan-mode.md
  - ../references/provider-paths.md
---

## Plan Revise — Going Back to the Drawing Board

When work deviates from what an artifact claims, reconcile it per `reconcile-state` — only what this session created or the user handed you, never someone else's; ask when in doubt.

> **⛔ ALWAYS enter plan mode** — full directives per `plan-mode`.
>
> - Enter plan mode immediately.
> - **NEVER exit plan mode.** Stay in plan mode until the user explicitly says "implement", "start coding", "write the code", `g`, `go`, `y`, or `yolo`.
> - Do NOT undo, revert, or modify any implementation code during this skill. Revision happens in the plan file only.

## Context

A plan was written, possibly some work was done against it, and now it is clear the plan got something wrong or the chosen direction is not working. This skill revises the plan **in place** so the plan file remains the single source of truth. The goal is NOT to throw away the plan — it is to correct course while preserving the reasoning history.

This skill composes with `plan-hard` — the interview protocol is the same, but the scope is narrower: you are interviewing about the **delta** (what changed, what was wrong, what to do differently), not the full plan from scratch.

## Process

1. **Locate the plan file.**
   - If the user provides a file path or name, use it directly.
   - Otherwise, list recent plan files in your internal plans directory (resolved for the active runtime via `provider-paths`; never hardcode a path) filtered to the current project (prefix match on project name), sorted by modification time, and ask the user to pick one.
   - If the current working directory has a matching recent plan, offer it as the default.

2. **Read the plan file completely.** Do not skim. Understand the original problem statement, requirements, approach, and implementation steps. Note any existing `## Revision History` section.

3. **Gather what went wrong.**
   - Ask the user (one question at a time): what is wrong with the current plan, or why is the direction not working?
   - Listen for: incorrect assumption, missed constraint, new information, discovered complexity, failed approach, scope change.
   - Do NOT move on until the failure mode is clearly understood.

4. **Check implementation state.**
   - Use `git log` and `git diff` to see what has been committed since the plan was written (compare against the plan's creation date or initial commit on the branch).
   - Use `git status` to see uncommitted work.
   - Report to the user: "You've committed X, Y, Z and have unstaged changes to A, B. Want me to factor these into the revision?"
   - Decide per change: **keep** (still valid), **revert** (wrong direction), or **reshape** (salvage but adjust). Ask the user when unclear.

5. **Re-interview on the deltas.** Follow the `plan-hard` interview protocol (one question per turn, recommended answer format, self-answer from codebase where possible), but scoped to:
   - Which original decisions still hold?
   - Which decisions are overturned, and what replaces them?
   - What new branches open up as a result?
   - What is the new end state?

6. **Draft the revised plan** and present it in chat before writing.

7. **Write the revision back to the plan file.** Update the file in place:
   - Add or update a `## Revision History` section at the top (after the title). Prepend a dated entry — newest first.
   - Update the body sections (Context, Requirements, Approach, Implementation Steps, Risks, Verification) to reflect the revised plan.
   - Do NOT delete the original sections wholesale — rewrite them. The plan file is the living source of truth.
   - In the Revision History entry, list: date, trigger/reason, decisions that changed, decisions that still hold, impact on implemented work (keep/revert/reshape).

8. **Present the revised plan** in chat and stop. Wait for the user to signal next steps (implement, further revise, hand off).

## Revision History Entry Format

Prepend to the plan file's `## Revision History` section (create the section if missing, place it right after the title):

```markdown
## Revision History

### YYYY-MM-DD — <short reason>

**Trigger:** <what prompted the revision — new info, failed approach, constraint discovered, scope change>.

**Changed decisions:**

- <decision> — was `<old>`, now `<new>`. Because: <why>.
- ...

**Decisions that still hold:**

- <decision> — still valid despite the revision. Because: <why>.
- ...

**Impact on implemented work:**

- **Keep:** <what stays — commits, files, modules>.
- **Revert:** <what needs to be undone — commits to revert, files to delete>.
- **Reshape:** <what stays but must be adjusted — and how>.

**New risks introduced by the revision:**

- <risk> — <mitigation>.
```

After the Revision History, the rest of the plan file reflects the **current** revised state — not a merge of old and new.

## Interview Protocol (delta-scoped)

Same Recommendation Format as `plan-hard`:

> **Question:** <the single focused decision being revised>
>
> **Recommended:** <your pick> — <one-line rationale>.
>
> **Alternatives:** <other viable options, each with a one-line trade-off>.
>
> **Depends on:** <prior decisions — original or revised — this answer affects>.

**Order to ask in:**

1. First, confirm the failure mode (what is wrong).
2. Then, establish which original decisions are overturned.
3. Then, walk the new branches that open up — depth-first, one at a time.
4. Finally, confirm the updated end state.

## Self-Answering Rule

Same as `plan-hard`: before asking the user, check if the codebase answers the question. Use `hyprpilot-nvim` MCP (LSP + editor + diagnostics), `git` CLI via Bash, `Grep`, `Glob`, `Read`, `github__*` / `gitlab__*`, and `context7` for documentation. Only escalate to the user for intent, preference, or unknowable-from-code decisions.

Extra sources specific to `plan-revise`:

- `git log --since=<plan-date>` — what has been done since the plan.
- `git diff` — concrete changes on the branch.
- Build / test output — run it with `Bash`, or capture what the user already ran with `tmux__capture-pane` — to confirm whether the current approach actually fails.

## Stop Conditions

Write the revision to the plan file and stop the interview when:

- The user signals `g`, `go`, `y`, `yolo`, "good", "good enough", "proceed", "revise it", or equivalent.
- All delta branches are resolved.
- The user says "quick revision" — produce a minimal revision entry and update only the affected sections.

Do NOT auto-stop because questions feel repetitive. Keep going until a signal.

## Key Principles

- **Preserve history.** The original plan is valuable context. Do not delete it — rewrite it, and record what changed in the Revision History.
- **One plan file per task.** Always update in place. Do not create `plan-v2.md`. Git preserves earlier versions.
- **Factor in implemented work.** If code has been written, the revision must address it — keep, revert, or reshape. Never pretend the implementation state doesn't exist.
- **Be honest about sunk cost.** If work has to be reverted, say so directly. Do not soften the blow with vague language.
- **Scope to the delta.** Do not re-interview decisions that are unaffected. Only revisit branches that the revision opens up.
- **Compose, don't duplicate.** The interview protocol is `plan-hard`'s. This skill scopes it narrower.

## Examples

**Example 1 — Failed approach:**

1. User: "plan revise, the JWT refresh token approach isn't working, the mobile team says their SDK doesn't support httpOnly cookies."
2. Locate `2026-04-15-myapp-jwt-auth.md`. Read it.
3. Confirm failure: "The plan assumed httpOnly cookie storage for refresh tokens. Mobile SDK can't read them. Is that the blocker?"
4. Check implementation state: `git log` shows 3 commits against this plan. Report: "You've shipped access token generation and the login endpoint. Refresh endpoint is unbuilt. Want to keep the first two and reshape refresh storage?"
5. Interview: "Recommended: store refresh tokens in secure device storage (Keychain/Keystore) on mobile, httpOnly cookie on web, dispatched by a platform header. Alternative: symmetric refresh-token-rotation via response body. Depends on: whether the mobile SDK can send a platform header at login." → user answers.
6. Continue walking new branches (rotation policy, revocation).
7. Write revision to plan file. Present. Stop.

**Example 2 — Scope change:**

1. User: "plan revise, we now need to support SAML SSO too."
2. Locate plan. Read.
3. Confirm: "The original plan was auth for email/password and JWT. Adding SAML as a new identity source on top?"
4. No prior decisions are overturned — they are extended. Report: "All original decisions hold. New branches: IdP list, attribute mapping, session bridging."
5. Interview those branches.
6. Append revision history. Update Approach and Implementation Steps to include the SAML work.
7. Present. Stop.

## Composition with Other Skills

- **`plan-hard`** — the interview protocol this skill inherits from. If the user wants a full re-plan rather than a delta revision, defer to `plan-hard`.
- **`plan-pickup`** — if the revised plan is to be executed immediately after revision, the user may invoke `plan-pickup` next.
- **`plan-handoff`** — if the revised plan needs to be handed to a different session or repository, compose with `plan-handoff` after revision.
- **`code-deviations`** — when the revision trigger was a discovered deviation between plan and reality, apply the code-deviations handling pattern to record the learning.

## Related Skills

- **`plan-hard`** — build a plan from scratch via interview.
- **`plan-pickup`** — load and execute an existing plan file.
- **`plan-handoff`** — produce a self-contained plan for another session or repository.
