---
name: config-reconcile
description: config-reconcile Reconcile a whole skill catalog - wiring, stale content, duplication, contradictions, concision - by slicing it, fanning out one agent per slice, and bringing meaning changes back for a decision. Use on "reconcile the skills", "make the catalog consistent", "audit all skills and references". Not for editing or authoring one named skill.
disableModelInvocation: true
argumentHint: '[catalog root] [focus]'
references:
  - ./references/slice-brief.md
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/current-state-only.md
  - ../references/config-targets.md
  - ../references/scm/commit-push-scoped.md
  - ../references/agent/agent-delegate.md
  - ../references/harness/agent-delegate-harness-claude.md
  - ../references/harness/agent-delegate-harness-codex.md
  - ../references/harness/agent-delegate-harness-opencode.md
---

## Catalog Reconcile

A catalog is a root holding `<slug>/SKILL.md` directories plus a `references/` tree, checked against its own authoring standard. The default target is `~/.config/nvim/utils/agents/skills/`, whose standard is `config-skills`, `config-references`, `hyprpilot-skills`, `current-state-only` and the central `AGENTS.md`. Any other catalog with that layout works the same way once its standard is named.

Posture: `present-first`. Agents apply only edits that preserve meaning; every change of meaning, deletion or merge comes back to the user first.

## Process

1. **Name the target and the standard.** Name back in one line the root, the authoring files that define "correct", and the central guidance files. Guidance files are edited only with the captain naming and blessing them, per `config-targets`.
2. **Baseline.** Load `config-skills` and run its `check_catalog.py` against the root by executing the path resolved from its `bundleDir`. Record the failure and warning counts, and size each family (`ls`, `wc -c`).
3. **Slice.** Partition the catalog into disjoint write scopes:
   - one slice per skill family;
   - each shared-reference folder owned by exactly one slice;
   - the root cross-cutting references in their own slice;
   - the central guidance plus the `config-*` skills as a read-only slice.

   Split a family whose bodies run past roughly 200 KB. Stay under the session's agent budget. Pick a tier per slice: smart where the slice holds doctrine, default where it is mostly wiring.
4. **Brief.** Copy `slice-brief` to the scratchpad and fill it. Each dispatch prompt carries only its slice: the writable files, the read-only neighbours, and the focus areas you already suspect, such as overlapping siblings, a stale example, or a family that should be symmetric.
5. **Dispatch.** Fetch `agent-delegate-harness-<provider>` before the first dispatch, then dispatch one agent per slice per `agent-delegate`, all in one message, in the background.
6. **Collect and verify.** For each report:
   - confirm its diff stays inside its slice;
   - spot-check the largest diff, to be sure nothing moved out without a new owner;
   - check its cheap live claims yourself, for example whether a tool exists in the session's tool list.

   Then re-run `check_catalog.py`.
7. **Apply cross-slice wiring yourself**, but only once the agent that owns each file has gone idle. Two writers never share a file.
8. **Present the decisions** as one numbered list, each item with a recommendation:
   - skills that contradict the live system;
   - contradictions between files (pick a side);
   - new gates;
   - structural changes (deletions, merges, splits);
   - central-guidance edits.

   Leave out anything already applied.
9. **Round two.** Steer the SAME agents with their approved items; they still hold the context. Items that touch the same file are sequenced, never given to two agents. Deletions run `git rm` only after the content they carry has a new home. The skill that absorbed each deleted skill must also take over its pointers.
10. **Close.**
    - `check_catalog.py` shows no FAIL rows, and every WARN is judged.
    - Run `git diff --stat`.
    - Commit on ask, per `commit-push-scoped`, scope `agents`.
    - Reap checkpoint per `agent-delegate`.

## Key Principles

- **One owner per rule.** A rule lives in one skill or reference; every other file names it. The central guidance keeps only what must hold when no skill has loaded.
- **Live source beats the catalog.** A tool list, a script's flags, or a config file outranks any skill that describes them. Flag what cannot be checked rather than guessing.
- **Meaning moves only on approval.** Wiring, dedup to a name, history removal and tightening are applied directly. Rules, gates, tiers, deletions and merges are proposed.
- **Current state only**, per `current-state-only`, on every edit.

## Example

**User says:** "go through all skills, references and AGENTS.md and make them consistent"

1. Name the root and the standard. The baseline `check_catalog.py` run shows 13 failures.
2. Nine slices: agent core; harness and hyprpilot; linear; scm; code and plan; posture and root references; infra; comms; central guidance (read-only). Dispatch runs in parallel.
3. The reports arrive. 80 files have meaning-preserving edits. Proposals: one harness reference contradicts the live dispatch schema; one workflow calls a tool the server does not register; two skills are fully absorbed by others.
4. The user approves the list. The same agents apply their items, the deletions land with their content moved, and `check_catalog.py` shows no FAIL rows.

**Result:** a consistent catalog, one commit, and a single decision round.
