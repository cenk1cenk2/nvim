---
name: agent-labrat
description: 'agent-labrat Hand work off to @labrat, the offsite Hermes agent, over a Slack thread - a one-off task, a Linear issue or project, or an investigation rooted in an existing alert thread. Writes the brief as an aware-target handoff, optionally routes it to claude/codex/opencode with a model, and arms a watcher on the thread so its progress comes back as events. Use on "hand this to labrat", "give this to the offsite agent", "let labrat take this". Do NOT use for local subagents (/agents-delegate, /agents-plan) or for posting an ordinary Slack message (/slack-message).'
disableModelInvocation: true
argumentHint: "[task, Linear issue/project, or Slack thread] [optional: claude|codex|opencode, model name]"
references:
  - ../references/present-first.md
  - ../references/slack-prerequisite.md
  - ../references/slack.md
  - ../references/agent-target-capability.md
  - ../references/agent-watchers.md
  - ../references/redact-private-data.md
  - ../references/linear-prerequisite.md
  - ../references/output-diff.md
---

## Handing Work to labrat

> **Present-first.** Read the `present-first` reference — the brief is drafted and presented before it is posted. Posting into Slack is an external write and reaches other people.

> **PREREQUISITE:** Read the `slack-prerequisite` reference — a Slack workspace skill MUST be active before posting. Read the `slack` reference for mrkdwn formatting, thread conventions, and the **absolute rule that the harness-provided Slack integration is used over the standalone workspace server**. Slack does not render normal markdown.

> **PREREQUISITE for Linear scopes:** Read the `linear-prerequisite` reference when handing off an issue or project.

> Read the `agent-target-capability` reference, then compose the `agent-aware` skill to write the brief — labrat is an **aware** target and the brief must point, not paste.

> Read the `agent-watchers` reference before arming the thread watch. Yours is an **awareness** watcher: it reconciles and reports, it does not push labrat's work forward.

> **No private specifics.** Read the `redact-private-data` reference. Slack is a shared surface and the thread is durable — never post secrets, tokens, or credentials into it, whatever the task needs.

## Context

labrat is an **offsite agent running the Hermes agent mechanism** (`nousresearch/hermes-agent`). It is not a subagent of this session: it runs on its own host with its own memory, its own skills, and its own permission posture, and the **only channel to it is Slack**.

What that means for you:

- **It is an aware target.** It reaches hyprpilot skills, an MCP surface close to yours, and runs on a system prompt close to yours. Point at skills by slug and tools by name; do not inline what it can load itself. Its shape is not identical to yours, so name what matters and let it map.
- **It delegates further.** Hermes can route work to Claude Code, Codex, or OpenCode, and can spawn its own subagents. Those inherit the same awareness — a brief written for labrat survives being handed down.
- **You cannot see its machine.** No shared filesystem, no shared repo checkout, no shared session state. Anything not in the thread, in Linear, or in a repo it can reach does not exist for it.
- **Everything is asynchronous.** There is no blocking dispatch. You post, it works, it replies in the thread — possibly much later.

## Treat it as a subagent with its own machine

Brief it the way you brief a local subagent — **it is simply more capable, because it has a host of its own.** Concretely, and worth saying out loud in the brief:

- **It clones repositories itself.** Give it a repo name or URL; it fetches from GitLab/GitHub on its side. Never paste file contents you expect it to edit, and never assume your working tree is its working tree.
- **It runs the toolchain.** Builds, tests, terraform plans, migrations — on its host, against its own credentials.
- **It opens MRs/PRs end to end.** Branch, commit, push, open the MR, react to pipeline results. The MR link comes back in the thread as the deliverable.
- **It delegates onwards** to Claude Code, Codex, or OpenCode, and spawns its own subagents — so a brief written once survives being handed down.

What that changes about the brief: name the **repo, branch policy, and what artifact you expect back** (an MR link, a plan output, a verdict), then let it do the retrieval. What it cannot have is your conversation, your uncommitted working tree, or anything only reachable from this machine.

**Validation stays on this side when the user asks for it.** It returns the MR; you check the diff, the pipeline, and the claim against reality before anyone merges. Merging is the user's call unless they said otherwise.

## Brief the outcome, not the steps

**labrat is a capable model with capable delegates of its own.** Handing it a numbered command list wastes that and ages badly — it knows its host, its credentials, and which tool fits better than you do from here.

- **Give it the goal, the constraints, the flow, and the evidence you want back.** Not the commands, not the tool choices, not the order of operations inside a phase.
- **Let it research.** Anything it can find out on its host — versions in use, whether a resource is even declared, how a pipeline is wired — is its job, not something to pre-answer. Say what matters *why*, and it will work out *whether*.
- **Step-by-step only for genuinely explicit tasks** — a specific change, in a specific place, done a specific way because the user said so.

The test: if a line would be equally true written by someone who has never seen the repo, it is context worth sending. If it is you guessing at commands it will run, cut it.

**State the invariant, not just the task.** The thing that makes a verdict meaningful is what must NOT change — "we do not want any breaking changes to our config", "no behavioural change on the live system", "the API contract stays". Without it, a capable agent optimises for finishing: it will happily absorb an upstream change that plans cleanly and behaves differently. With it, the same agent knows a clean plan is not automatically a pass.

Pair the invariant with the escalation: **which findings it fixes, and which it must stop and report.** Anything that changes live behaviour is normally the user's call, not the agent's — say so, or it will decide for you.

## Pick the flow, then say it

State which shape the work takes. This is the part it should not have to infer:

| Flow | Use when |
|------|----------|
| **Investigate only** | You want an answer or a verdict, and any change is a separate decision. |
| **Investigate → Linear issue → MR** | The finding deserves a tracked issue before code moves — bigger scope, or work others should see queued. |
| **Investigate → fix → MR** | The change is only justified if the investigation says so. Most "does this break us?" work. |
| **Fix → MR** | The change is already decided; the MR is the deliverable. |

Name the branch point explicitly when there is one: *investigate first, and only if it actually affects us, fix forward.* That single sentence is what keeps it from either stopping short of a fix or fixing something that needed no fixing.

## Tell it to delegate

**Say "delegate to opus" (or codex, or opencode) explicitly — it is generally what the user wants**, and without the instruction labrat may just do the work itself on its own model.

- **The user's runtime and model pass through verbatim.** "delegate opus" means Claude Code on Opus, not your interpretation of it.
- **Delegate per phase when the flow has phases** — "investigate with opus, then delegate again to fix" is a normal and useful instruction.
- **Do NOT choreograph its delegation.** How many sessions it spawns, how it splits the work, how it collects results — that coordination lives in the Hermes harness. You state which runtime and roughly which phases; it runs the orchestration.
- **Silence means it decides.** If the user named no runtime, say nothing about runtimes rather than inventing one.

## Plan handoff, delivered in-thread

For anything beyond a one-liner, hand off a **plan**, not a sentence — the `plan-handoff` shape (problem statement, repository context, goal with acceptance criteria, approach, research needed, end state) is the right amount of structure for a target with zero conversation.

**But the plan travels in the thread, not as a file path.** `plan-handoff` normally writes into this machine's internal plans directory; labrat cannot read that. So:

- Post the plan **as the thread message** — trimmed to what it cannot derive itself.
- Or, when it is too long for one message, put it where labrat can fetch it: a Linear document or issue description, and link that.
- Never hand it a local plan path. A path it cannot open reads as a lost brief.
- Keep the plan's **Research Needed** section — it is the honest way to say "work this part out on your host", and it is exactly what a capable remote should be doing rather than guessing.

## ⛔ The thread is the handle

**Mention `@labrat` exactly once, in the opening message.** Hermes starts a conversation on the mention and replies in a thread. Every later message in that thread reaches it **without** re-mentioning — re-tagging mid-thread is noise at best and can restart context at worst.

**Record the thread's `ts` the moment the opening message posts.** It is the only handle to the work:

- it is what you watch,
- it is what you reply into to steer, answer, or approve,
- it is what a resumed session needs in order to find the work at all.

State it in chat, and put it anywhere durable the task already uses — the Linear issue comment, the plan file, the `plan-compact` anchor. A lost thread `ts` means a running agent you can no longer reach and whose output you will never collect.

Thread commands (Slack blocks native slash commands inside threads, so Hermes accepts the `!` form):

| Command | Use |
|---------|-----|
| `!model <name>` | Switch the model mid-thread. |
| `!queue` | Queue another instruction while it is busy. |
| `!stop` | Stop the current run. |
| `!approve` / `!deny` | Answer an approval prompt when buttons are not usable. |
| `!goal <text>` | Set a standing goal it keeps working toward across turns (observed in use — e.g. "delegate opus sessions until you rule it out"). |

## Where to post

- **Default `#agents`** for a handoff that has no existing home. Resolve the channel through the active Slack integration rather than assuming an id.
- **Reply into the existing thread** when the work is rooted in one — an alert, an incident, a discussion. Posting there gives labrat the whole thread as context for free and keeps the answer where the people watching it are. This is the case for "look at that alert and investigate": the handoff is a reply to the alert, mentioning `@labrat` once.
- **Never open a second thread for work that already has one.** Two threads on one task means two contexts, and the watcher only follows one.

## Engagement level — the user sets it

**How involved you stay is the user's call, not yours.** Three levels, and they say which:

| Level | They say | You do | Watcher |
|---|---|---|---|
| **Fire and forget** | "hand it to labrat", "just give it to it", "don't babysit this" | Post the brief, capture the thread `ts`, report the link, **stop**. Pick it up again only when they ask. | None. |
| **End to end** | "see it through", "own this until it's done", "come back when it's finished" | Drive it to completion: answer its questions, clear blockers, verify the deliverable, report once at the end rather than narrating every step. | Armed. Terminal-signal cadence, tightened while an exchange is live. |
| **Watch and control** | "stay on top of it", "check its claims", "verify its work", "i want to steer this" | Read every reply, verify each claim against its artifact as it lands, steer and queue continuously, validate the MR before anyone acts on it. | Armed tight — 2-3 min, every reply. |

Rules:

- **Ask when it is unstated and the levels would differ materially** — a throwaway investigation and a production-touching change deserve different answers, and one line settles it.
- **The level can change mid-run, in either direction.** "actually keep an eye on it" upgrades; "that's enough, let it run" downgrades. Re-arm or reap accordingly, and say which you did.
- **Fire and forget still captures the thread `ts`.** Not watching is not the same as losing the handle — without it, picking the work back up later means hunting for the thread.
- **Fire and forget does not mean unverified.** When the result eventually matters, verification happens when the user comes back to it, not never.

### Delegate or converse

Within an engaged handoff, decide this **before arming anything** — it sets what the watcher listens for and how much of your turn budget the handoff costs.

| | **Delegate and collect** | **Steer in-thread** |
|---|---|---|
| When | Scope is closed, acceptance is mechanical, no decisions left | Judgement you hold remains, the brief carries assumptions, or it is an investigation |
| Watcher listens for | The terminal signal — its report, the MR, the merge | **Every reply**, so a question is answered while it is still working |
| Your role on wake | Verify the artifact, reconcile, report | Enrich the conversation: answer, correct, add findings, tighten scope — then keep watching |
| Cost | One or two wakes | A turn per exchange |

- **Default to steering for anything not fully specified.** Downgrading later is free — widen the cadence. Upgrading after it has sat blocked for an hour is not.
- **Escalate on a question.** A delegated run that asks something becomes a steered one: tighten the cadence and answer. A blocked offsite agent is idle time you are paying for in wall-clock, and it will not nudge you twice.
- **Answer approval prompts as a first-class duty**, not an observation. `!approve` / `!deny` in-thread when buttons are not usable.
- **De-escalate when it converges.** Once the remaining work is mechanical, drop back to watching for the terminal signal only.

**Enriching is not re-briefing.** New context, a corrected assumption, a link to something you found — those go in as thread replies. Rewriting the whole brief mid-flight throws away the context it has built; if the goal genuinely changed, say so explicitly rather than pasting a new brief over the old one.

## Choosing the runtime

If the user names a runtime, pass it through verbatim — labrat knows how to drive each:

| Runtime | Typical fit |
|---------|-------------|
| `claude` | Careful review, refactors, reasoning-heavy debugging. |
| `codex` | Focused implementation and repo changes, fast feedback loops. |
| `opencode` | Local project navigation, terminal-first workflows, cheaper lanes. |

- **Model names pass through too** — "codex with gpt-5.5", "claude on opus". Do not remap them; they are the user's choice.
- **Say nothing when the user said nothing.** An unrequested runtime directive removes a choice labrat is better placed to make from its own host.
- **Codex lane caveat:** very high reasoning effort can consume a turn entirely in hidden reasoning and produce no visible thread output. If a Codex-routed run goes quiet without text, suspect that before assuming failure.

## Process

1. **Resolve the scope.** A one-off task, a Linear issue, a Linear project, or an existing Slack thread to investigate. If the request could mean more than one, ask once.
2. **Make the source agent-ready first.** For Linear work, the issue or project must already be self-contained — compose `linear-project-agent` if it is not. Handing off a vague issue just moves the ambiguity offsite, where it costs a round trip measured in hours.
3. **Draft the brief** with `agent-aware`. It carries:
   - the goal and what done means,
   - **the invariant** — what must not break, and which findings it must stop and report rather than fix,
   - **the flow**, with its branch point stated (see Pick the flow),
   - **the delegation directive** when the user gave one — "delegate opus", per phase where the flow has phases,
   - **links, not contents** — Linear ids/URLs, repo, branch, PR/MR, the alert thread,
   - **why it is non-trivial** — the specific risk or unknown, so it knows what to look for without being told how,
   - decisions already made and constraints or holds that bind (what not to touch, who merges),
   - what to report and where: **in this thread**, with evidence rather than narrative,
   - a degradation line: what it should say if something is unreachable from its host, instead of guessing.

   Leave out anything it can find on its own host, and leave out the commands entirely.
4. **Present the draft, then post.** Chunked per `output-diff`, in Slack mrkdwn per the `slack` reference. One `@labrat` mention, in this message only.
5. **Capture the thread `ts`** from the post result and state it in chat, per the rule above.
6. **Arm a watcher only if the user asked to follow it** — see below. Otherwise read the thread on demand.
7. **Steer in-thread, never by re-briefing.** Follow-ups, corrections, and answers to its questions go into the same thread as plain replies.
8. **Verify what it claims.** Its report is a claim like any agent's: check the PR/MR, the pipeline, the tracker state, the artifact. Never relay an offsite agent's summary as fact.
9. **Reconcile and close.** Update Linear per `linear-state-transitions` when work actually lands, record findings where future agents read them, reap the watcher, and report.

## Watching the thread

**⛔ Arm a watcher only when the user asks for one.** Watching costs their session — each wake is a turn — so it is their call, not a default. Without a watcher you simply read the thread when they next ask, which is often exactly right for a long-running handoff.

When they do ask, arm for what the chosen mode needs: **every reply** when steering, the **terminal signal** when delegating. Both are awareness watchers — they reconcile and report, they never push labrat's work forward.

**Cadence: judge it from how fast the thread actually moves, and bias tight.** An agent mid-run answers in minutes, so **2-3 minutes** is right while it is working — 10 is slack you pay for in stalled turns, and a question of its own sitting unanswered for ten minutes is ten minutes of an idle offsite agent. Stretch the interval only for a phase you know is slow (a long plan, a queued pipeline, a human approval), and tighten it again as the expected reply approaches.

The thread is the only signal, and thread replies are reachable only through Slack MCP — **bash cannot call MCP**. So:

- **Preferred:** a deferred-wakeup loop (self-paced `/loop`) that re-invokes the session on an interval, where you read the thread through the active Slack integration on the main loop and diff against the last `ts` you processed.
- **If a Slack token is reachable from the shell**, a background loop polling `conversations.replies` for a new reply is a valid bash-visible proxy — still do the authoritative read over MCP on wake.
- **Cadence:** minutes, not seconds. An offsite agent's turn takes as long as real work takes, and Slack rate limits punish tight polling.

On each wake, run the awareness cycle from `agent-watchers`: read what is new, verify any claim against its artifact, reconcile the tracker, report terse, then re-arm — until the work reaches a terminal state or the user stops it.

**Not every message is progress.** Hermes posts its own housekeeping into the thread — gateway online/restarting notices, cron job responses, and `:floppy_disk: Self-improvement review` lines where it patches its own skills and memory mid-run. Read those as "still alive, not advancing the task": they are not a stall to escalate on, and they are not work to report as progress either. An **empty message** is the same class of signal — a turn that produced no visible text.

Judge liveness by task-relevant replies, not message count. If two or three consecutive checks bring only housekeeping, ask for a one-line status in-thread rather than assuming either progress or death.

**The last message tells you whether it is still running — decide the watcher from it, every check.** Hermes marks its own state:

| Last message | Meaning | Watcher |
|---|---|---|
| Progress line (`⏳ Working — N min — iteration x/y`) | Mid-run | Keep armed. |
| A phase narration ("let me dig into…", "opus dispatched") | Mid-run | Keep armed. |
| Housekeeping or empty | Alive, not advancing | Keep armed; status-ping after 2-3 such checks. |
| A verdict, a report, an MR link, "done" | **Terminal** | Verify the claim, then **reap the watcher** — the run is over and every further tick is a wasted turn. |
| Gateway restarting / offline notice | Interrupted | Re-send or re-steer once it is back; do not treat as failure. |

A terminal report is the signal to stop watching, not to keep watching in case something else arrives. If more work follows, that is a new steer and, if the user wants it, a new watcher.

**A quiet thread is not a verdict.** It can mean working, blocked on an approval prompt, or a stalled run. Check the thread before concluding anything, and if it is waiting on approval, answer it — that is a reply you owe, not an event to observe.

## Steer and queue mid-run

**You do not have to wait for a wake, and it does not have to be idle.** Both matter more than the watcher:

- **Reply into the thread the moment you have something worth adding** — a corrected premise, a new finding, a narrowed scope, an answer it has not asked for yet but will need. New information mid-run is normal and it costs nothing to send.
- **`!queue <instruction>` stacks work while it is busy**, instead of interrupting the run or waiting for it to finish. Use it for the obvious next phase, or for a second task that shouldn't wait.
- **`!stop` when the premise collapses.** If what you asked for turns out to be wrong, stop it rather than letting a run finish against a false brief — then re-steer with the correction.
- **Correct rather than restate.** A short "actually X, not Y — carry on" preserves everything it has built; a re-pasted brief throws that away.

**Hand over the question, do not answer it yourself.** A steer is a pointer, not an analysis: "the pipeline looks red — check it and fold it in" is the whole message. Digging through job logs, diffs, and traces on this side to hand it a finished diagnosis burns your context to produce something it can get faster on its host, from the machine that actually runs the thing.

The only verification you owe first is the cheap sanity kind — enough that you are not sending it after a stale run or a wrong link. Where even that is uncertain, say what you saw and let it confirm: "there was a failure earlier, latest run may be green — confirm which."

## Closing out a handoff

When the terminal report lands:

1. **Verify from the artifact it cited, not from its restatement.** If it says "CI plan is clean", open that job's output and find the line. A capable agent summarising honestly and a capable agent summarising optimistically produce identical-looking messages.
2. **Expect credential asymmetry, and treat it as information.** Its host is not your host: it may be blocked where CI is not (here, Vault returned 403 for its delegate while the pipeline had full auth). An agent that says "I could not reach X, but Y covers it" is doing exactly what the brief asked; an agent that quietly works around it is the failure mode.
3. **Reap the watcher** — the run is over.
4. **Report the verdict with its evidence**, and leave the decision the user reserved (merging, applying, deploying) with them.
5. **A "nothing to fix" verdict is a successful outcome of an investigate-then-fix flow**, not a wasted run. The branch point existed precisely so the fix phase could be skipped.

**It evolves between runs.** Hermes writes its own skills and memory from experience — it created a reusable skill for this task shape mid-run. So its behaviour is not fixed: something it needed spelled out last week may already be internalised, and a brief that over-explains is wasted twice.

## Boundaries

- **Posting is an external write.** Draft, present, post — unless the user already blessed this specific handoff.
- **Never post secrets** into the thread. If the work needs a credential, say how to obtain it, never what it is.
- **Destructive or production-touching work needs explicit approval before handoff**, not after. The remote runs with its own permissions and you cannot pull it back mid-flight.
- **Scope drift is the user's call.** If labrat proposes going beyond the brief, bring it back rather than approving it in-thread on your own.

## Example

**Trigger:** "/agent-labrat hand K-482 to labrat, use codex"

1. Scope: a Linear issue. `linear-kilic` active; the issue is already self-contained, so no restructuring.
2. Draft the brief with `agent-aware`: assumed surface, goal, `K-482` link, target repo and branch policy, the decision to keep the migration reversible, acceptance = pipeline green and MR open, report in-thread with the MR link, runtime `codex`.
3. Present, then post to `#agents` with one `@labrat` mention. Thread `ts` `1753875421.118` captured, stated in chat, and added as a comment on `K-482`.
4. Arm an awareness watcher on the thread, cadence 5 min.
5. Wake: labrat asks which base branch. Reply in-thread, no mention.
6. Wake: it reports an MR. Verify the MR exists and its pipeline is green rather than trusting the message, move `K-482` to `In Review`, report.
7. Wake: merged. Reconcile to `Done`, reap the watcher, report final state.

**Result:** the work runs offsite, the thread stays the single source of truth, and every state change reaches the user as an event instead of a question.

## Key Principles

- One mention, one thread, one handle — and the `ts` is recorded durably the moment it exists.
- Point, never paste: labrat loads the skills, clones the repos, and reads the issues itself.
- It is a subagent with a machine: name the repo and the artifact you want back, not the file contents.
- Plans travel in the thread or in Linear — never as a path on this machine.
- Ambiguity handed offsite costs hours; make the source agent-ready before the handoff.
- Pass the user's runtime and model through verbatim; invent neither.
- Steer inside the thread, never by opening a new one.
- Verify its claims from the artifact it cited — distance does not make a report evidence.
- A terminal report ends the watch; reap it rather than ticking on in case more arrives.
- The user sets the engagement level — fire and forget, end to end, or watch and control; ask when it is unstated and the stakes differ.
- Watchers are armed on the user's ask, never by default — and when armed, tight (2-3 min), because a stalled question is the real cost.
- Steer and queue mid-run: reply the moment you have something, `!queue` while it is busy, `!stop` when the premise collapses.
- Hand over questions, not finished diagnoses — it investigates faster from the host that runs the thing.
- Verify a steer before sending it; a quiet thread is a question, not an answer.
- Slack is shared and durable: no secrets, ever.

## Keep this skill current

**This skill improves from live runs — fold what you learn back in as you go, without being asked.** Each handoff teaches something the next one needs: a Hermes command that turned out to exist, a phrasing that made it stop over-asking, a cadence that was wrong, a failure mode that cost a round trip.

- Update it **during** the run, not as a retrospective — the detail is exact while the thread is open and vague an hour later.
- Record the mechanism, not the anecdote: "state the invariant or it optimises for finishing" travels; "the opnsense bump went fine" does not.
- Follow `config-skills` for the edit itself, and reload after.

## Related Skills

- **`agent-aware`** — writes the brief itself; this skill decides scope, channel, routing, and watching.
- **`agent-supervisor`** — the posture for keeping the record honest while offsite work runs.
- **`agents-delegate` / `agents-plan`** — the local equivalents, for subagents on this machine.
- **`linear-project-agent`** — makes a Linear project or issue fit to hand off.
- **`agent-background`** and the `agent-watchers` reference — the arming mechanics for the thread watch.
- **`slack-message`** — an ordinary Slack post that is not an agent handoff.
