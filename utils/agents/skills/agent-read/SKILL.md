---
name: agent-read
description: agent-read Re-ground the session from scratch - sweep timestamps to find what changed since your context formed, re-read the central guidelines, re-list the skill catalog, reload the voice, redo session initialization. Use first after a context compaction, after drifting from the guidelines, or when they changed mid-session. Not for normal work or a one-off file read.
disableModelInvocation: true
---

## Agent Read — Re-Ground From Scratch

## Context

The session's guidelines and skill catalog go stale. You may have drifted from the rules, or the central `AGENTS.md` / system prompt was edited mid-session while your context still holds the old version — possibly compacted or summarized. This skill re-grounds you: it re-reads the source of truth and re-runs discovery from scratch, exactly as a fresh session would, so nothing stale is trusted.

## Absolute Rule

Do the discovery PROPERLY, as if starting a brand-new session. Do not shortcut it, and **never trust cached, compacted, or summarized copies** of any of it — read the live files and call the live tools again. Clearing stale context is the entire point of this skill.

**After a compaction, this skill IS the first task.** Before any task work, before reading a plan or an anchor, before answering the question in front of you. A summary flattens the guidelines and the skills catalog into tone, and every step taken on the flattened copy inherits the drift — silently, because nothing fails.

## Process

1. **Sweep the timestamps first — find what moved.** Before re-reading anything, work out what actually changed. This directs the re-read; it never replaces it.

   ```bash
   # The guideline corpus, newest first.
   find ~/.config/nvim/utils/agents -name '*.md' \
     -printf '%TY-%Tm-%TdT%TH:%TM %P\n' | sort -r | head -20

   # What was committed while you were working, with content.
   git -C ~/.config/nvim log --since='<when this session started>' --stat -- utils/agents
   ```

   Sort-by-mtime rather than a relative `-newermt`: `find` here is `bfs`, which rejects `-3 hours` and demands ISO 8601, and `ls` is `lsd`, which has no `--time-style`. The `-printf | sort -r` form survives both.

   **Both halves matter.** mtime catches the uncommitted edit the captain just made — the usual reason this skill runs — while `git log` says *what* changed rather than merely that something did. Anything stamped after the point your context was formed is the suspect list.

   **Do the same in the working repo.** `git -C <repo> log --since=…` and `git status` show what the captain did behind you while you held a stale picture, per `AGENTS.md` §VI.

2. **Re-read the central guidelines FRESH.** Read the full `AGENTS.md` from `~/.config/nvim/utils/agents/AGENTS.md` with the `Read` tool — the whole file, top to bottom. Do NOT rely on your in-context memory of it; the file on disk is the truth. If it differs from what you were operating on, the file wins. **A quiet timestamp is not permission to skip this** — mtime says where to look hardest, not whether to look.
3. **Re-read local instructions.** Re-read any `AGENTS.md` / `CLAUDE.md` that apply to the current working directory and the files in play (§I step 0), fresh.
4. **Rediscover the skills.** Call `list_skills` again and re-cache the catalog — it is the source of truth for what exists this session, and skills may have been added, edited, or reloaded. Note each skill's `description` and invocation tier for routing.

   **Read the `modified` stamp on every entry.** The catalog carries `size`, `modified` and `created` per skill, and `list_skill_references { slug }` carries the same per reference — so the server answers "what is new" without a shell, and it covers skill directories outside this repo and whatever the active profile filters in. Cross-check it against what you already loaded: a path whose `modified` moved since you read it is stale and must be fetched again, per `hyprpilot-skills`.
5. **Reload the caveman voice.** Call `read_skill { slug: "caveman" }` and re-apply it (level: full) as the default communication style, per `AGENTS.md` §I step 5. Read it live; don't answer from memory.
6. **Re-consult memory and the repo note** as at session start (§I steps 1 and 3), when the runtime provides them.
7. **Re-ground behavior.** Reconcile what you were doing against the freshly-read guidelines. If you had deviated, correct course now. If `AGENTS.md` changed, work out what changed that affects the current task.
8. **Report** in one or two lines: re-grounded — **name what was new and when it changed**, and any course-correction you are making. "Nothing moved since <time>" is a real and useful answer; a report that cannot say either way means the sweep was skipped.

## When to Use

- **The context was compacted or summarized** — the summary says so, or specifics it references are gone from your context. Run this **before any other action**, unasked. **If unsure whether it happened, assume it did** — running it needlessly costs minutes, skipping it costs correctness.
- **You have deviated** — you notice you drifted from the guidelines (skipped skill-first, wrong posture, ignored a rule).
- **AGENTS.md / the system prompt was updated mid-session** — the central guidelines changed on disk and your context is stale.
- **You learned that anything you already loaded changed on disk** — a `modified` stamp newer than your read, a guidance file in a `git status` or `find` result, a `reload`, or the captain saying they edited something. This is a mandatory trigger, not a judgment call: `AGENTS.md` §I, "A Changed Guidance File Re-Grounds You". Run it before the next action rather than after finishing the current thought.
- On explicit `/agent-read`.

Not for normal work, and not a substitute for reading a specific file you need — this is a full re-initialization.

## Example

**User:** `/agent-read` (after editing `AGENTS.md`)

1. Sweep mtimes — `AGENTS.md` is stamped four minutes ago, `references/open-artifact.md` an hour ago, everything else older. Two files to look at hardest.
2. Read `~/.config/nvim/utils/agents/AGENTS.md` in full — spot the new/changed rules.
3. Re-read the current directory's `CLAUDE.md` / `AGENTS.md`.
4. `list_skills` — re-cache; `modified` shows `git-commit` changed since you loaded it, so that path is stale.
5. `read_skill { slug: "caveman" }` — re-apply full.
6. Reconcile the current task against the fresh guidelines.
7. Report: "Re-grounded. AGENTS.md gained rule X four minutes ago; `git-commit` changed since I loaded it and I have re-read it; adjusting the current flow to match."

## Key Principles

- **Fresh reads only — never trust cache.** Read the live `AGENTS.md` and call the live `list_skills` / `read_skill`; ignore compacted or summarized copies. Clearing stale context is the whole point.
- **Timestamps aim the re-read, they do not shorten it.** The sweep tells you which files changed and roughly what to expect; the fresh read still happens in full. Treating "nothing moved" as licence to skip step 2 turns this skill back into the cached guess it exists to replace.
- **The file on disk wins.** If the freshly-read `AGENTS.md` contradicts what you were operating on, adopt the file and correct course.
- **Do the full init, as if new.** Guidelines, local instructions, skills catalog, caveman, memory, repo note — the whole thing, not a subset.
- **Re-ground, then say so.** After re-reading, reconcile and report what changed and any correction in a line.
