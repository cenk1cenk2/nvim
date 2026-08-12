---
name: code-style
description: code-style How code gets written here - matching the surrounding neighbourhood, style and comment defaults, naming, design defaults, verification, debugging discipline, and which improvements to raise unprompted. Load before writing or editing code in any language. Not for reviewing a diff, auditing a repo for improvements, or debugging a specific failure.
references:
  - ../references/project-tooling.md
---

## Writing Code

Across languages and frameworks, **matching the local project first**. A convention the surrounding code already follows beats every default below.

## Match the Neighbourhood

**Read the code around your change before writing any of your own, and measure against it rather than a global ideal.** The target is code no reader can pick out as added later or by a different hand. This is the first check, not a polish pass — a default from this file applied over a neighbourhood that does it differently is a defect, however good the default.

Check each axis against the siblings solving the same problem:

- **Naming.** Casing per language, abbreviation habits, boolean prefixes (`is` / `has` / `should`), and how neighbours name this very concept.
- **Function signatures.** Parameter order and grouping, options bag versus positional, return discipline (`Result` / `error` / option / throw), sync versus async shape, and whether behaviour lives here as a method or a free function.
- **Comment density, including its absence.** A sparse-comment file is a deliberate convention, not a gap to fill. See `## Comments`.
- **Layout and idiom.** File and module structure, import ordering, error-handling and logging shape, dependency-injection style.

**Defer to the tooling.** Whatever the project's formatter or linter normalizes — import order, whitespace, quote style, trailing commas — is not your judgment call and not worth your attention. Discover the project's real commands per `project-tooling` and run them; spend the attention on what tooling cannot catch: naming, signatures, comment intent, structure.

`code-improve` audits these same axes across an area and reports drift as findings. This section is the writing side of that rule — same axes, applied before the code exists rather than after.

## Style Defaults

- Avoid trailing whitespace.
- Start YAML files with `---` unless the directory consistently does otherwise.
- In multi-statement functions, leave a blank line before the final return when the language and style support it. Single-statement functions and guard returns do not need it.

## Comments

- **Match the surrounding comment style, or add none.** Before writing any comment, look at the neighboring code and mirror its density, tone, and format — including when that means no comments at all. Do not add comments or docstrings unless the surrounding file already uses them or the user asks.
- **Never state the obvious — this is absolute.** A comment must explain *why*: a non-obvious constraint, trade-off, edge case, or gotcha that stays true and stays surprising long after the change lands. Never restate *what* the code already says. A comment that names the operation its line performs is noise; if it only paraphrases the line below it, delete it.
- **Keep your own reasoning out of the file — this is absolute.** A comment documents the code for whoever maintains it next. It is not where you explain the edit you just made, justify the option you picked, or argue against the one you rejected. This is thinking, not a comment:

  ```terraform
  # null_resource.karpenter_ami triggers on this rather than the variable, so the AMI stays
  # visible in the plan for callers that leave it null and take it from parameters
  ```

  Nothing there describes the code. It narrates a decision, addressed to whoever reviews the diff rather than whoever inherits the file — and a week later the alternative it argues against exists nowhere but in your head.

  **The test: would this comment exist if the code had always looked this way?** If it only makes sense as a defence of a change, it belongs in your chat message to the user, never in the file. Catch yourself on the tells — "rather than", "instead of", "so callers that…", any clause comparing against an alternative the file does not contain, and any sentence that would start with "I".

- **Tag every TODO-family comment with the user's handle, right after the colon** — `KEYWORD: @handle <message>`, e.g. `TODO: @cenk1cenk2 drop once the v2 endpoint ships`. The handle is the user's account on **that repository's git provider**, so read it off the remote rather than assuming; it is `@cenk1cenk2` on GitHub and on `gitlab.kilic.dev`. Recognised keywords, and nothing else: `FIX` (`FIXME`, `BUG`, `FIXIT`, `ISSUE`), `TODO`, `HACK`, `WARN` (`WARNING`, `XXX`), `PERF` (`OPTIM`, `PERFORMANCE`, `OPTIMIZE`), `NOTE` (`INFO`). This is how such a comment is written, not permission to add one — the rules above still decide whether it exists.

## Naming

Names should not repeat context their scope already provides — drop the qualifier the receiver, module, or component already implies (a `resolve` method on a `sandbox` needs no `sandbox` in its name). Keep the discriminating noun only when it is what actually distinguishes similar operations. If a name stutters, rename the concept and update call sites rather than adding aliases.

## Design Defaults

- **Solve today's problem:** the minimum code that solves the problem in front of you now, not the minimum that could solve every future version of it. No premature abstraction, no handling for errors that cannot occur, hardcoded values until something real needs them configurable. If the only reason a thing is abstracted is "in case we need it", it is over-built.
- **No compatibility shims in personal projects:** when a design changes, delete and rewire in one shape instead of leaving aliases, deprecated wrappers, or dead re-exports.
- **Stubs fail loudly:** unfinished code throws, errors, or panics with a clear message. Never a fake success.
- **Behavior lives with the owner:** helpers that operate on a type's state, handles, channels, or invariants should be methods or composable methods, not detached functions. Pure transformations can stay free.
- **Carry invariants in objects:** if every call passes the same base, config, or client, wrap it once and let the methods use the validated state.
- **Compose instead of bagging:** when consumers need behavior or rendering flexibility, use the language's composition mechanism — closures, callbacks, interfaces, traits, slots. Keep config bags for uniform data.
- **Inline single-use helpers:** extract only when there is a second caller or the abstraction clearly earns its name. Copy-paste twice before abstracting — an abstraction drawn from one example is **the Wrong Abstraction**.
- **Polymorphism for open sets, unions for closed sets:** reach for a shared one-method abstraction only when multiple concrete branches would otherwise repeat the same dispatch shape.
- **Every dependency is permanent code you do not control:** check the project's existing dependencies and the standard library first (`crypto.randomUUID()` over a `uuid` package). When you add one, say why in your report — never let the choice appear only in the manifest.

## Verification

The gap between code that works and code you think works is testing.

- **Fixing a bug starts with the failing test.** Write it, watch it fail, then fix — the only proof you fixed the cause and not the symptom.
- **Test behavior that can actually break**, not that a constructor sets a field. Cover the error path: a handled happy path with an ignored 500 is **the Optimistic Path**, not a finished feature.
- **Hard to test is information about the design**, not permission to skip the test.

## Debugging

- **Investigate, do not guess.** Read the whole error and the stack trace, reproduce the problem before changing anything, and change one thing at a time.
- **Never paper over a surprise.** An unexpected null gets a cause, not a null check — silenced, the bug just moves somewhere quieter.
- Suggest `code-debug` for behavioural bugs and `code-task-failed` for failing build, test, or lint commands. They own the full flow.

## Proactive Improvement

Beyond the change you were asked for, watch for improvements the user did not request and raise the worthwhile ones as short proposals — never act on them unprompted, never bury the main task under them. Worth flagging:

- **Architectural friction** — a boundary in the wrong place, a dependency cycle, a leaky abstraction.
- **Testability gaps** — untested critical paths, logic reachable only through heavy mocking.
- **Consistency drift** — the same thing done three different ways.
- **Dead code** — unreferenced exports, unreachable branches, obsolete flags.
- **Clarity problems** — a function doing five things, a name that misleads.

One or two high-value flags beat an exhaustive list. For a focused audit of these dimensions across an area or a whole repo, suggest `code-improve`.
