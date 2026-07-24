---
name: agent-read
description: 'agent-read Re-ground the session from scratch: re-read ~/.config/nvim/utils/agents/AGENTS.md, re-run list_skills, reload caveman, redo session initialization. Use after deviating from guidelines or when AGENTS.md changed mid-session. Always manually invoked. Do NOT use for normal work or a one-off file read.'
disableModelInvocation: true
references:
  - ../references/present-first.md
---

## Agent Read — Re-Ground From Scratch

> **Present-first.** Read the `present-first` reference — no plan mode. This skill re-reads and re-grounds; act on it immediately, then report what changed.

## Context

The session's guidelines and skill catalog go stale. You may have drifted from the rules, or the central `AGENTS.md` / system prompt was edited mid-session while your context still holds the old version — possibly compacted or summarized. This skill re-grounds you: it re-reads the source of truth and re-runs discovery from scratch, exactly as a fresh session would, so nothing stale is trusted.

## Absolute Rule

Do the discovery PROPERLY, as if starting a brand-new session. Do not shortcut it, and **never trust cached, compacted, or summarized copies** of any of it — read the live files and call the live tools again. Clearing stale context is the entire point of this skill.

## Process

1. **Re-read the central guidelines FRESH.** Read the full `AGENTS.md` from `~/.config/nvim/utils/agents/AGENTS.md` with the `Read` tool — the whole file, top to bottom. Do NOT rely on your in-context memory of it; the file on disk is the truth. If it differs from what you were operating on, the file wins.
2. **Re-read local instructions.** Re-read any `AGENTS.md` / `CLAUDE.md` that apply to the current working directory and the files in play (§I step 0), fresh.
3. **Rediscover the skills.** Call `list_skills` again and re-cache the catalog — it is the source of truth for what exists this session, and skills may have been added, edited, or reloaded. Note each skill's `description` and invocation tier for routing.
4. **Reload the caveman voice.** Call `read_skill { slug: "caveman" }` and re-apply it (level: full) as the default communication style, per `AGENTS.md` §I step 5. Read it live; don't answer from memory.
5. **Re-consult memory and the repo note** as at session start (§I steps 1 and 3), when the runtime provides them.
6. **Re-ground behavior.** Reconcile what you were doing against the freshly-read guidelines. If you had deviated, correct course now. If `AGENTS.md` changed, work out what changed that affects the current task.
7. **Report** in one or two lines: re-grounded — what (if anything) changed in the guidelines or catalog, and any course-correction you are making.

## When to Use

- **You have deviated** — you notice you drifted from the guidelines (skipped skill-first, wrong posture, ignored a rule).
- **AGENTS.md / the system prompt was updated mid-session** — the central guidelines changed on disk and your context is stale.
- On explicit `/agent-read`.

Not for normal work, and not a substitute for reading a specific file you need — this is a full re-initialization.

## Example

**User:** `/agent-read` (after editing `AGENTS.md`)

1. Read `~/.config/nvim/utils/agents/AGENTS.md` in full — spot the new/changed rules.
2. Re-read the current directory's `CLAUDE.md` / `AGENTS.md`.
3. `list_skills` — re-cache; note any skill added or changed.
4. `read_skill { slug: "caveman" }` — re-apply full.
5. Reconcile the current task against the fresh guidelines.
6. Report: "Re-grounded. AGENTS.md added rule X; catalog gained `agent-read`; adjusting the current flow to match."

## Key Principles

- **Fresh reads only — never trust cache.** Read the live `AGENTS.md` and call the live `list_skills` / `read_skill`; ignore compacted or summarized copies. Clearing stale context is the whole point.
- **The file on disk wins.** If the freshly-read `AGENTS.md` contradicts what you were operating on, adopt the file and correct course.
- **Do the full init, as if new.** Guidelines, local instructions, skills catalog, caveman, memory, repo note — the whole thing, not a subset.
- **Re-ground, then say so.** After re-reading, reconcile and report what changed and any correction in a line.
