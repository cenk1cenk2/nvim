---
name: clipboard-copy
description: clipboard-copy Copy a skill's output to clipboard instead of executing it. Use when user says "cbcp", "copy to clipboard", or "clipboard" alongside another skill invocation. Skips confirmation and copies the drafted content directly. Do NOT use standalone without a companion skill.
references:
  - ../references/present-first.md
disable-model-invocation: true
---

## Clipboard Copy

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

This skill is a **modifier**. It intercepts the final output of a companion skill and copies it to the clipboard by piping the content to `wl-copy` via the `Bash` tool (Wayland clipboard) instead of performing the skill's write action.

## Process

1. **Identify the companion skill.**
   - If exactly one other skill is active or invoked alongside `cbcp` — use it.
   - If multiple skills are invoked — ask the user which skill's output to copy. Do NOT guess.
   - If no companion skill is identifiable — ask the user what they want copied.

2. **Run the companion skill normally** — follow its full process (research, analysis, drafting) but **stop before the write/execute step**.

3. **Copy to clipboard immediately.**
   - Do NOT present a draft for approval. Do NOT ask "does this look good?".
   - Take the final drafted content and copy it by piping it to `wl-copy` via the `Bash` tool.
   - Confirm with a one-liner: what was copied and from which skill.

## Key Principles

- **No confirmation.** Draft → clipboard. No review step.
- **Never execute the companion skill's write action.** No commits, no PR updates, no issue creates, no messages sent.
- **Ask when ambiguous.** Multiple skills or unclear target → ask before doing anything.
