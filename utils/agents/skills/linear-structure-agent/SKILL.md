---
name: linear-structure-agent
description: linear-structure-agent Shape Linear work for agent execution and keep it honest while implementing it - one repo, one PR, one concern per issue, a parent hosting per-repo sub-issues, ownership blessed once, verification recorded as you go. Structuring and picking work up are one mentality. Use on "structure this for agents". Not for plain issue or project CRUD.
argumentHint: '[project or issue] [what it does]'
references:
  - ../references/long-running-work.md
  - ../references/reconcile-state.md
  - ../references/linear-prerequisite.md
  - ../references/linear-description-structure.md
  - ../references/linear-project-documents.md
  - ../references/linear-scm-discovery.md
  - ../references/output-diff.md
  - ../references/identifier-legibility.md
---

Issues, MRs and PRs are never listed as bare identifiers - carry a title, and the repository or parent scope when more than one is in play, per `identifier-legibility`.

A Linear workspace skill MUST be active before this skill runs — detection rules in `linear-prerequisite`.

**This skill owns two things: the shape of the work, and the honesty of the record while that work is implemented.** It does not create, update, or reconcile Linear records itself — `linear-project-create`, `linear-issue-create`, `linear-issue-update`, `linear-issue-comment`, `linear-document`, and `linear-project-reconcile` write; this skill decides what they write and when.

Present a proposed structure per `output-diff`. Description format for whatever gets written per `linear-description-structure`.

## Two Modes, One Mentality — and You Will Switch Mid-Flight

**This skill covers structuring the work AND picking it up.** They are not two skills or two phases; they are two modes of one way of thinking, and a single piece of work moves between them repeatedly.

| Mode | You are | The record is |
|------|---------|---------------|
| **Structuring** | deciding the shape — which issues exist, what each holds, how they nest | written **for** the agent who has not started yet |
| **Picking up** | implementing, alone or through agents, and watching what comes back | kept **true to** what actually happened |

**Infer the mode from what you are doing, not from how the request was worded.** Drafting or reshaping issues is structuring. Reading an issue in order to implement it, or pointing an agent at one, is picking up. Nobody has to announce the switch.

**Switching back is normal and needs no ceremony.** Implementation is what discovers that the structure was wrong — a repository nobody knew about, a deviation that applies to three repos, a layer that has to split. Reshape it in place under the rules below, then carry on implementing. **Structuring is not a phase that closes**, and finishing the shape is not permission to stop maintaining it.

The mentality is identical in both directions:

1. **The executable unit is one repo, one PR, one concern.** A mid-flight discovery that breaks it means restructuring, never a bigger issue.
2. **The parent holds the description, sub-issues hold deviations.** A finding gets filed by that rule whichever mode surfaced it.
3. **Ownership is blessed once and covers both modes** — settled before the first agent, not re-asked at the first write.
4. **What you learn gets written where the next reader will look**, per the notebook rules below, at the moment you learn it.

**Execution mechanics are borrowed, not re-specified here.** Scope resolution, exploration, task scheduling, branches, commits, PRs/MRs, state transitions, and the final report belong to `agent-pickup` and the `linear-issue-pickup` / `linear-project-pickup` skills — load whichever fits when the work becomes implementation. This skill stays loaded across both modes because the shape rules and the record rules apply the whole way through.

## The Executable Unit

An **executable unit** is one issue an agent picks up and finishes alone. Every executable unit is:

1. **Single repository** — does not span repositories.
2. **Single PR** — one logical, self-contained change.
3. **Single concern** — one section or layer.

Everything above it is a **container**: it holds shared context and is never implemented directly. Two containers exist — a project, and a parent issue.

Agents work best this way: scope and boundaries are clear, the repository is evident from the issue itself, no cross-repository orchestration is needed, and a PR review stays inside one area of concern.

## Choosing the Shape

**Repo span is rarely obvious from the request — investigate before choosing.** "Add X" means adding X to one repository about as often as it means adding the same X to six. Getting it wrong late is expensive: an issue discovered mid-flight to span four repositories has to be torn apart after agents already started on it.

Investigate first per `linear-scm-discovery` — its Discovery Ladder picks the tools from what the active profile carries, so never assume a code-discovery MCP is there. Establish how many repositories carry the change, whether the change is identical in each, and what differs where.

Then pick:

| Finding | Shape |
|---------|-------|
| One repository, one concern | A single issue. It is the executable unit. |
| One repository, several concerns or layers | One issue per concern; a project when there are enough to need shared context. |
| Several repositories, same change repeated | **Parent issue + one sub-issue per repository.** |
| Several repositories, several concerns each | Project, with a parent issue per concern and sub-issues under each. |

**For a lone issue whose change is mechanical or convention-driven — a lint rule, a CI job, a dependency bump, a config key, a renamed field — assume several repositories.** Confirm the repo list before concluding it really is just one.

## Parent Issue and Sub-Issues

The pattern for one change landing in several repositories. It exists because keeping N near-identical descriptions in sync is a losing job — one drifts, and the agent working that repo implements the stale version.

Nest with `parentId`. Never describe the hierarchy in prose; Linear shows it natively.

### The parent carries everything

The parent issue holds the real description — the one a reader or agent actually reads:

- What the change is and why.
- The **mechanical change**, spelled out concretely: exact config, exact snippet, exact command, before and after.
- Conventions, constraints, what must not break.
- Acceptance criteria and verification commands.
- The repository inventory, with any known per-repo difference.

The parent is a container, not work. It is not picked up, it produces no PR of its own, and it closes when its sub-issues do.

### The sub-issue carries only the delta

**A sub-issue MUST NOT restate the parent's description.** A copied description is exactly the drift this pattern prevents.

Each sub-issue is one repository, and carries:

- **Repo** — `**Repo:** ` plus the path.
- **Read first** — a pointer to the parent issue, and to any document that applies.
- **Deviations** — what differs for this repository and nothing else: a different path, an extra step, an exception to a shared convention, a known conflict.
- **A short checklist** only when this repo needs steps the parent does not cover.

No deviations means the section says so — "None; follow the parent as written." An empty body is ambiguous; an explicit "no deviations" is not.

### Templates

Parent:

```markdown
## Context

[what changes and why]

## Change

[the exact mechanical change — config, snippet, command, before and after]

## Conventions

[what must hold, what must not break]

## Repositories

| Repo | Deviation |
|------|-----------|
| `org/repo-a` | none |
| `org/repo-b` | vendored config path |

## Verification

[commands, expected result]
```

Sub-issue:

```markdown
**Repo:** `org/repo-b`

**Read first:** parent issue K-123 — full change and conventions live there.

## Deviations

- Config lives at `vendor/ci.yml`, not the repo root.
```

## Where Shared Context Lives

Scope picks the parent — tightest level that covers it, per `linear-project-documents`:

| Shared by | Lives on |
|-----------|----------|
| One repository only | That sub-issue |
| Every repo under one parent | The parent description, or a document attached to the parent |
| Every issue in the project | The project description, or a project document |

Attach documents on demand with the `linear-document` skill — one concern per document, tightly focused like obsidian repository notes. Investigations, plans, candidate matrices, migration guides, solved problems, deviations.

## Ownership — Bless It Once, Up Front

**Before the first agent starts, ask one question and get one answer: is this project or issue tree ours to keep current?** Ownership rules per `reconcile-state` — the permission is "what this session created, or what the user explicitly handed you", and everything else is off limits.

This matters most under the agent postures — `agent-coordinator`, `agent-supervisor`, `agent-bulldozer`, `agent-pickup`, and any delegated agent working the tree. Those run for many turns and produce a steady stream of write-worthy findings. Without a blessing on file, every one of them is either an interruption or an unauthorized write into someone else's tracker.

1. **Ask at structure time, not mid-flight.** One line: `Is K-123 and its sub-issues ours to keep updated as we go?` Asking after four agents have finished is asking too late.
2. **Record the answer durably** per `long-running-work`. Ownership held only in the transcript is gone at the next compaction, and the session that resumes cannot tell whether it may write.
3. **Ours** — reconcile on by default, no re-asking per write. Corrections to your own artifacts are corrections, not new decisions.
4. **Not ours** — never write. Surface drift in one line and let the user decide: `K-402 contradicts what we just implemented — not ours to edit, want me to?`
5. **The blessing is scoped to that tree.** A parent plus its sub-issues, or a project plus its issues. A different project needs its own blessing; a general `g` / `yolo` / autopilot does not supply one.
6. **An opt-out suppresses the write, never the question.** "Don't touch the tracker" gets honored and reported.

## The Record Is a Notebook, Not Just a Blueprint

**Structure is half the job. While agents implement, the Linear tree is the running log of what was actually observed and done.** An agent-ready structure that ends up describing work nobody did is worse than no structure — a stale parent gets read by the next agent and implemented as written.

### Record verification, before and after

Agent work is bracketed by state checks — Grafana panels, `terraform plan` and state, cluster or ArgoCD state, migration counts, test output, pipeline result. **Capture the baseline before the change and the result after, and write both down as they happen.**

| Moment | Record |
|--------|--------|
| Before the task | The baseline — what the state actually was, with the command or query that read it. |
| After the task | The result of the same check, and the delta from baseline. |
| Anything surprising | The observation and what it means, whether or not it changed the plan. |

A delta reconstructed at the end from memory is not evidence. The baseline is only capturable before the change, so a skipped pre-check cannot be recovered.

### Where each note goes

| Note | Goes to |
|------|---------|
| Evidence, deviations, decisions for one repo's task | Comment on that sub-issue, via `linear-issue-comment` |
| A finding that changes how every repo under the parent is done | Comment on the parent, and fix the parent's description |
| An investigation, plan, solved problem, or candidate matrix | A document at the tightest covering scope, via `linear-document` |
| A per-repo difference discovered mid-flight | That sub-issue's **Deviations** section — this is what it is for |

Prefer comments over description edits for ordinary deviations. Edit a description when leaving it would misalign the agents that read it next — above all the parent's, since every sub-issue points at it.

### Record as you go

**Checkpoint per task, not once at the end** per `long-running-work` — the checkpoint you skip is the one before the compaction, and a note living only in the transcript is already gone.

Reconcile in the same rhythm, per `reconcile-state`: when implementation departs from what the parent claims, bring the parent back in line in one batched pass rather than a write per realization, and report each one — `Reconciled K-123 — parent now reflects the vendored-path variant found in three repos.`

## Manual Tasks

A small manual step belongs as a **task inside an issue** when it is a dependency for that issue's work, sits in the same concern, and is a one-time operation.

| Manual task | Belongs in | Reason |
|-------------|-----------|--------|
| Create Vault secret | Workload issue, as a task | Dependency for the ExternalSecret in the same issue |
| Migrate data from old server | Separate issue | Significant work, different concern |
| Run terraform apply | The issue holding the terraform code | Part of completing that PR |

Ask the user when uncertain whether a manual step is separate or included.

## Structure Checklist

| Criterion | Valid | Invalid |
|-----------|-------|---------|
| **Single repository** | `cluster/workloads/teamspeak3` | Vault + K8s manifest in one issue |
| **Single PR** | Deployment + service + secret | Deployment in repo A, route in repo B |
| **Single concern** | Kubernetes manifests only | Manifests + DNS + routing |
| **Named repo** | "**Repo:** `cluster/sun/argocd-sun`" | No repo named |
| **Clear boundary** | "Infrastructure layer" | Ambiguous scope |
| **Multi-repo nested** | Parent issue, one sub-issue per repo | One issue listing six repos |
| **Sub-issue is a delta** | "Deviations: none; follow the parent" | Parent's description copied in |
| **Shared context placed once** | "Read first: `Migration guide`" | Same guidance pasted into every issue |
| **Ownership settled** | Blessing recorded before the first agent | Writing into a tree nobody blessed |

## Common Patterns

| Pattern | Structure |
|---------|-----------|
| **Kubernetes workload** | One repo for manifests, one for the ArgoCD Application, one for routing |
| **Infrastructure** | One repo per infrastructure change |
| **DNS changes** | One repo for the DNS provider |
| **Secrets** | Vault via code means a separate repo issue; manual means a task in the workload issue |
| **Fleet-wide mechanical change** | Parent issue with the exact change, one sub-issue per repo |

## Anti-Patterns

**Don't:**

- "Set up TeamSpeak" — spans repositories, too vague.
- "Create workload and routing" — two concerns, two repos.
- One issue listing six repositories in its description.
- Sub-issues each carrying a full copy of the parent's description.
- Deciding single-issue versus parent/sub-issue without investigating repo span.
- Starting agents without settling ownership, then writing into the tree anyway.
- Reconstructing verification evidence at wrap-up instead of capturing it at the task.
- Dependency chains or sub-issue tables written into descriptions.

**Do:**

- "Create teamspeak3 workload manifests" — one repo, one PR.
- "Configure load balancer routes for teamspeak3" — one repo, one PR.
- Parent "Adopt shared CI template" with one sub-issue per repository.

## Key Principles

1. **The executable unit is one repo, one PR, one concern.** Everything above it is a container.
2. **Investigate repo span before choosing the shape.** A mechanical change is multi-repo until proven otherwise.
3. **Repository named explicitly in every executable issue.**
4. **The parent holds the description; sub-issues hold deviations.** Never both.
5. **Containers are never implemented.** A project and a parent issue produce no PR.
6. **Shared context at the tightest scope that covers it** — sub-issue, parent, or project.
7. **Ownership is blessed once, up front, and recorded durably.** No blessing means surface drift, do not write.
8. **The record is a notebook during execution.** Baseline before, result after, deviations as they surface, reconciled in batches.
9. **External systems:** ask whether the system is configured via code or by hand. Code means a separate issue in that repository; manual means a task inside the related issue.
10. **Dependencies via Linear fields** — `blockedBy`, `blocks`, `parentId`. Never in descriptions.
11. **Structuring and picking up are one mentality.** The mode follows what you are doing; switching back to reshape mid-implementation needs no ceremony.
12. **Shape and record honesty here; writing and execution mechanics elsewhere.** The create/update/comment skills write; `agent-pickup` and the pickup skills execute.

## Examples

**User says:** "Structure adding the shared renovate config to our repos for agents"

1. Investigate repo span per `linear-scm-discovery` — 7 repositories carry a `renovate.json`, 2 vendor it under `.github/`.
2. Multi-repo, same change: parent issue plus 7 sub-issues.
3. Parent carries the exact config file, the merge conventions, and the repo table with the 2 deviations.
4. Each sub-issue carries repo, "read first: parent", and its deviation or "none".
5. Ask once whether the tree is ours to keep current; record the answer.
6. Present the structure per `output-diff`; hand to `linear-issue-create`.

**Result:** One description to maintain, 7 independently pickable units, ownership settled before any agent runs.

---

**User says:** "Structure a project for deploying PostgreSQL to Kubernetes"

1. Ask what is new versus existing; investigate repositories.
2. Layers: workload manifests, ArgoCD Application, storage, secrets, networking.
3. One repository each — no repeated change, so no parent issues needed.
4. Shared architecture and verification go into a project document.
5. Ask whether Vault is code-managed or manual; place it accordingly.
6. Present the structure; hand to `linear-project-create`.

**Result:** One issue per layer per repo, shared context in one document.

---

**Agents are running the renovate parent, and a sub-issue's pipeline fails**

1. Capture the failing pipeline output and the pre-change baseline for that repo.
2. Comment on that sub-issue with the evidence and the cause.
3. The cause is a vendored path nobody had recorded — add it to that sub-issue's **Deviations**.
4. Two more repos share the pattern; reconcile the parent's repo table in one pass and report it.

**Result:** The parent stays true, and the next agent reads the corrected version.

---

**User says:** "Review the redis-operator project structure"

1. List the issues.
2. Check each against the structure checklist.
3. Flag any issue spanning repositories, any sub-issue duplicating its parent, any guidance repeated across issues.
4. Propose the restructure.
