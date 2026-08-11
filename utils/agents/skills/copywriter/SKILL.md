---
name: copywriter
description: copywriter Clean up text in the current buffer - typos, grammar, punctuation, markdown formatting - preserving meaning and tone. Use on "clean up this text", "proofread", "fix typos". Not for editing or refactoring code.
disableModelInvocation: true
argumentHint: '[optional: specific instructions]'
---

## Copywriter: Text Cleanup

## Process

1. **Get the current buffer content.**
   - Use `hyprpilot_nvim__editor_status` to identify the current buffer.
   - Read the file content via `hyprpilot_nvim__editor_read`.
   - If the buffer is empty, inform the user and stop.

2. **Apply the cleanup rules below to the entire buffer content.**

3. **Replace the buffer content** with the cleaned version via the built-in `Edit` tool.

4. **Confirm** to the user that the cleanup is done. Do NOT describe what changes you made unless asked.

## What to Fix

- Fix typos and misspellings.
- Fix grammatical errors: subject-verb agreement, tense consistency, article usage (a/an/the), pronoun reference, dangling modifiers, run-on sentences, and sentence fragments.
- Fix punctuation and capitalization.
- Recognize misspelled technical terms and replace them with correct spelling.
- **CRITICAL:** Do NOT "correct" words that are already valid technical terms, product names, project names, or domain-specific jargon. Many technical words look unusual but are correct as-is. Before changing any word, verify it is actually a misspelling and not a legitimate term. Examples: `Grafana Alloy`, `Cilium`, `Istio`, `Envoy`, `Pulumi`, `Traefik`, `Velero`, `Falco`, `Loki`, `Mimir`, `Tempo`, `Thanos`, `Longhorn`, `Knative`, `Dapr`, `Crossplane`, `Kyverno`, `Buildah`, `Podman`, `Talos`. If a word is already a recognized technical term and fits the context, leave it alone — do not replace it with a more common English word.
- Only correct a word when it is clearly garbled or makes no sense even as a technical term in context. The test is: "Could this word be a real product, tool, library, or technical concept?" If yes, preserve it.
- Preserve non-English words, proper nouns, and personal names that fit the context (e.g., `Cenk`, `Kilic`, or other names/words from any language). These are not typos — infer from context whether a word is a name or foreign term before attempting correction.
- When words or phrases make no sense in context, aggressively try to decode them as mangled technical/programming terms using phonetic similarity and surrounding context (e.g., "nook shed" → `NuxtJS`, "react hocks" → React hooks, "pie test" → `pytest`, "dango" → `Django`, "terra form" → `Terraform`, "answer bowl" → `Ansible`). It is better to make a reasonable technical guess than to leave nonsensical words in the output.
- Remove duplicate words or obviously repeated phrases.

## Markdown Formatting

- Wrap technical references in inline code (backticks): file names (`config.yaml`), file paths (`/etc/nginx/nginx.conf`), shell commands (`kubectl get pods`), CLI tool names (`docker`, `git`), environment variables (`HOME`), function/method names, and package names.
- Do NOT apply inline code to general technical terms used conversationally (e.g., "the API is slow", "we need better caching") — only to specific runnable commands, file references, and identifiers.
- Actively break longer text into paragraphs. Err on the side of MORE paragraph breaks rather than fewer — a wall of text is always worse than slightly over-separated text. Insert a blank line when the text:
  - Shifts to a new topic or subtopic.
  - Makes a new point or argument.
  - Transitions from one idea to another (e.g., problem → solution, context → action, observation → conclusion).
  - Moves between different aspects of the same subject (e.g., "what it does" → "why it matters" → "how to use it").
  - Changes addressee or perspective.
- Keep a single continuous argument or closely connected chain of thought as one paragraph — only avoid splitting mid-sentence or mid-thought.
- When outputting markdown elements (lists, blockquotes, code blocks), surround them with blank lines for proper rendering.
- Short text that is a single thought should be output as-is without structural changes.

## What to Preserve

- Preserve the original meaning, tone, wording, and sentence structure.
- Questions MUST remain questions, statements MUST remain statements.
- Preserve ALL content — do not drop, skip, or condense any part of the text.
- Do NOT reorder sentences, summarize, expand, or rewrite.
- Do NOT add decorative formatting (bold, headings) unless already present in the original.
- Take minimal liberties — your job is cleanup, not editing or improving.

## Key Principles

- **Minimal intervention** — fix errors, do not rewrite.
- **Preserve technical terms** — when in doubt, leave the word as-is.
- **Decode garbled terms** — use phonetic similarity and context to guess mangled technical terms.
- **Paragraph breaks are cheap** — err on the side of more breaks for readability.
