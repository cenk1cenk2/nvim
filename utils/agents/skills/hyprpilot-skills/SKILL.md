---
name: hyprpilot-skills
description: hyprpilot-skills Auto-invoked at session start when the hyprpilot-skills server is present. The skills system itself - the servers hyprpilot injects, how a skill, its files, its references and served prompts reach you, and how to pay for a reference once. Not for authoring or editing a skill, and not for driving a separate agent session.
---

## The Hyprpilot Skills System

Mechanics of how skills reach you. Whether to route a task through a skill at all is `AGENTS.md` §II — that rule stands on its own and does not depend on this skill loading.

## Injected Servers

| Server | Carries | Its manual |
|---|---|---|
| `hyprpilot-skills` | `list_skills`, `read_skill`, `list_skill_references`, `read_skill_references`, `read_skill_files`, and `reload` for a root `list_skills` reports degraded or off; also serves prompts, the session's system prompt among them | this skill |
| `hyprpilot` | general tools — `open` (URL, file, or directory in the OS default handler) | none yet |
| `hyprpilot-nvim` | the captain's live Neovim — buffers, LSP, diagnostics | `hyprpilot-nvim`, eager at startup |
| `hyprpilot-harness` | `spawn` / `session_*` for separate agent sessions, where enabled | `hyprpilot-delegate`, loaded only on the captain's explicit ask |

Every `hyprpilot-skills` tool is auto-accepted and never prompts.

## Loading a Skill

A skill's slug is its path under the catalog root — `git-commit`, or `group/name` for a nested one.

- `list_skills` — the catalog. Descriptions and metadata for every skill, no bodies. Each row carries `referenceCount` and `fileCount`, served from cache with no filesystem access, so checking whether a skill is heavy costs nothing.
- `read_skill { slug }` — one body, **plus two manifests: the shared references it declares and the files it ships. Neither manifest carries bodies.**
- `read_skill { slug, bundle: true }` — body plus every reference body. Worth it on the first load of an unfamiliar skill; wasteful once you hold the shared conventions.
- `list_skill_references { slug }` — the reference manifest alone, no bodies and no skill body.
- `read_skill_references { references: [path] }` — the reference bodies you actually want. See below.
- `read_skill_files { uris }` — files the skill ships, by the `skill://` uris its file manifest lists. See below.

The same content is served as resources: `hyprpilot://skills` is the catalogue index in one read, `skill://<slug>/SKILL.md` is one skill's raw file, and `skill://<slug>/<file>` is any file it ships.

The roots are WATCHED, so an edit on disk is rescanned and announced without anything asked of you. When a change lands on something you already hold, Load `agent-read` to re-read it.

A skill the harness already attached is loaded — a `skill://<slug>/SKILL.md` mention, a palette pick, or auto-injection. Do not re-read its body.

**An attached skill is the raw file, with no manifests.** Its frontmatter `references:` names what it cites in the declared spelling, which is not an address. Call `list_skill_references { slug }` for the paths before fetching, and `read_skill { slug }` when you need its file manifest. A `read_skill` result carries both manifests as text footers too — under `skill_references:` and `skill_files:` banners — so a client that shows no structured content still sees them.

**Never use the runtime's own built-in skill tool for these.** That tool serves the harness's own skills, not the hyprpilot catalog.

## The Catalog Is Profile-Filtered

The active hyprpilot profile drops some skills, so `list_skills` — not the filesystem — is the source of truth for what exists this session. Reading a `SKILL.md` by path can pull in a skill the profile deliberately dropped. Use filesystem paths only when editing source.

## References Are Addressed by Path

**A reference is identified by its canonical absolute path**, and that path is what `read_skill`'s manifest hands you. Fetch bodies with `read_skill_references { references: [path, ...] }` — the argument is required, and the paths must come from a manifest, because a path no skill declares is refused.

Because the address is a path rather than a skill-and-name pair:

- **One call spans skills.** Ask for everything you need across every skill you are about to run, in a single call.
- **A repeated path is served once**, so passing the same file twice costs nothing.
- **There are no name collisions and no shadowing.** `git-commit`'s `output-diff` and `git-push`'s `output-diff` are literally the same path, so they are comparable and de-duplicate on sight.

Each manifest row carries `path`, `uri` (the same file as a `file://` resource), `name` (the display label — the reference's frontmatter `name`, else the file stem), `size`, `modified`, `created`, and `metadata` (the reference's own frontmatter, verbatim, and absent entirely when the file has none). Skill metadata carries the same `size` / `modified` / `created` alongside `path` and `bundleDir`.

A skill's metadata block is its whole frontmatter minus the three keys another field already carries — `title` and `description` (the spec `Resource` fields) and `references` (superseded by the manifest, which publishes the canonical path that actually addresses each file). Everything else, including keys nobody planned for, rides through verbatim.

**`modified` answers staleness, never caching.** It tells you whether a convention changed since you read it, which matters in a long session and after any rescan. The cache key is the path.

## ABSOLUTE — Keep a Loaded-Path Set and Never Fetch a Path Twice

**Track the set of reference paths you have loaded this session. Before any `read_skill_references` call, drop every path already in that set. Never fetch a path you already hold.**

This is what makes the shared corpus free after first use. `output-diff` is declared by 57 skills and `scm-detect` by 31 — under this rule a session pays for each of them once instead of dozens of times. Path identity is exactly what makes it mechanical rather than a judgement call: two citations either resolve to the same path or they do not.

The set survives everything except the file itself changing, which `modified` tells you about; drop that path from the set and re-fetch it, per the re-read above.

## Conditional Families — Declare All, Fetch One

**When several references cover the same slot and only one applies per session, declare every one of them and fetch only the live one.** The per-runtime harness files are the canonical case: a skill declares `agent-delegate-harness-claude`, `-codex`, and `-opencode`, and fetches whichever matches the runtime it is actually on.

This costs three manifest rows — roughly 450 bytes — and one body. **A reference beats a skill for this job**: the manifest hands you the path, so the fetch is mechanical, whereas loading a skill is a choice the agent can simply forget to make.

The pattern generalises to any mutually exclusive set — one platform of several, one provider of several, one workspace of several.

## Fetch What the Step Names, Not the Whole Manifest

A manifest is cheap and bodies are not. So:

- **Read the manifest first**, and fetch only the references the step in front of you actually names.
- **Pre-flight an expensive skill** with `list_skill_references { slug }` — a few hundred bytes to learn what it cites and how large each file is, against up to ~20 KB of bodies. Worth it for the agent-family skills; pointless for a skill citing one small file.
- **Reach for `bundle: true`** only when you genuinely want everything, on a skill you have not run before.

## Files a Skill Ships

A skill's own directory — `scripts/`, templates, a local `references/` — is served whole: every file but hidden and gitignored ones. `read_skill`'s file manifest lists each as a `skill://<slug>/<file>` uri with its size, and `read_skill_files { uris: [...] }` returns their bodies; a file that is not text is described rather than inlined. A local reference needs no frontmatter declaration to be reachable this way.

Use these uris when the skill's directory is not on your filesystem — a server reached over HTTP, or a sandboxed runtime. When it is, `bundleDir` in the metadata block is the directory, and a script is run by its path there.

## Reading a Reference Directly

Every declared reference publishes an absolute path, so `Read`ing one is a legitimate route rather than an exception — use it when you want a single file and already know where it is.

**The one case that has no alternative** is a file outside every skill directory that a body names and **no skill declares**. It appears in no manifest, so neither fetch tool serves it. Those bodies name the absolute path explicitly, and `Read` is the only way to get them.

## Served Prompts

The server also serves prompts: the session's own system prompt files, and any prompt directory the profile configures. Each is an MCP prompt and a `hyprpilot://prompts/<name>` resource — `AGENTS.md` is `AGENTS`. A system prompt is baked in at launch and cannot change mid-session, so when it is edited, re-read it through either route rather than trusting the copy in your context; in Claude Code the captain can also run it as a slash command named after the server and the prompt.

## Skill Source

Lives under `~/.config/nvim/utils/agents/skills/`, shared references in `references/` at that root. Authoring conventions — frontmatter, description shape, reference granularity — belong to `config-skills`; suggest it rather than editing a `SKILL.md` freehand.
