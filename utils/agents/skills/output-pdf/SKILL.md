---
name: output-pdf
description: output-pdf Deliver long reports as PDF file attachments. Use on reports, plans, reviews or investigations that outgrow an inline reply, "send me that as a document", "attach the plan", "give me the report as a file". Not for content short enough to read inline.
---

## Context

The format depends on where it lands. In chat, Markdown is fine. A report long enough to exceed the inline budget goes as a PDF.

## Delivery

1. **Find the source.** The document usually already exists: a plan file the runtime wrote, a document produced earlier in the session, or a file in a worktree. When it does not exist yet, assemble it and write it to the chosen durable directory first.
2. **Render to an absolute path in a durable directory**, with a descriptive filename. The directory must not be a worktree, a runtime's private directory, or a path that dies with the session. The running harness's scratch discipline decides the location; `/absolute/durable/` below stands for that chosen directory.
3. **Deliver it.** Hand back the absolute path. Attaching the file uses the running harness's own mechanism, which this skill does not define. One file per attachment, one absolute path. The accompanying message says what the file contains plus any blocker, and never repeats the report body.

## Rendering a PDF

**A long structured report is a PDF.** Reports, investigations, reviews, plans and tables all take this path once they outgrow the inline reply.

`md-printer` is the renderer. It renders a Markdown or YAML file through a Svelte template and prints it with a locally installed Chromium-based browser, so the input is markdown, with inline HTML where markdown runs out.

```sh
md-printer /absolute/durable/TOPIC-report.md /absolute/durable/TOPIC-report.pdf -t kilic.dev
```

The output argument wins over `dest` in front matter, which wins over the input filename with the output extension. `dest` resolves against the current directory, not the input file.

### Templates

| Template | What it gives | Use it for |
|---|---|---|
| `kilic.dev` | GitHub-flavoured Markdown styling with Montserrat, a logo header and a footer with title and page numbers | the default for a report that goes to a person |
| `default` | the same styling, no header or footer | a plain document, or one embedded elsewhere |
| `invoice` | an invoice from YAML data plus Markdown notes | invoices |
| `mail` | plain content, no margin, Tailwind typography | HTML output for correspondence |

A template is a directory holding `Template.svelte` and an optional `settings.json`, `i18n/` and `components/`; `-t ./path` selects a custom one. Utility classes work only where the template compiles Tailwind in a `<style lang="postcss">` block; under `kilic.dev` and `default` a utility class does nothing.

### Front matter

YAML front matter; every key not listed here reaches the template as `data`.

```yaml
---
documentTitle: Cluster resource review
dest: /absolute/durable/cluster-resource-review.pdf
pdfOptions:
  format: A4
  landscape: true
  margin: 18mm 12mm
---
```

- `documentTitle` is the PDF title and the footer title; without it the title falls back to the input filename.
- `pdfOptions` are Puppeteer PDF options, merged key by key over the defaults and the template's `settings.json`. `landscape: true` for anything table-shaped.
- `template`, `language`, `continuous` and `outputFiletype` are front-matter keys too; a flag wins over each.

### Useful flags

- `-F html` renders HTML instead of PDF, which is how you debug a layout without a print cycle.
- `-O` writes to stdout, `-I` reads from stdin.
- `--continuous` renders one long page with no page breaks; `::page-break` in the markdown forces one anywhere.
- `-T` overrides the title without editing the file.
- `-p` opens a live preview that rebuilds on every save.

### Writing the report itself

- Open with the title, the scope, the evidence window, and the few decisions that need attention.
- One candidate per row in a compact table, headers repeated across pages.
- Keep current values, recommended values, the deltas and a short rationale.
- Split a large table across pages. Never shrink text below readable to force one page.

### Verify before delivering

A silently truncated or empty PDF looks identical to a good one in the response text.

- `pdfinfo` confirms it is a real PDF and reports the page count, page size (landscape shows width above height) and title.
- `pdftotext -layout` confirms the title, the summary, and both an early and a late table row - a table that got cut shows up here and nowhere else.
- `pdftoppm` renders the first and last pages for inspection when vision is available.

Then deliver the verified PDF per the delivery section.

### When md-printer cannot run

Render the same HTML through headless Chromium and verify it identically:

```sh
chromium --headless --no-sandbox --disable-gpu --no-pdf-header-footer \
  --print-to-pdf=/absolute/durable/TOPIC-report.pdf file:///absolute/durable/TOPIC-report.html
```

This path has no templates: the CSS is whatever the HTML carries.

## Other formats

CSV and XLSX remain correct for data the user will sort, filter or edit. Attach one when the user asks for source data, and pair it with the PDF when a readable summary is wanted too.

## Filename convention

- Plans: `/absolute/durable/TOPIC-plan.md`.
- Reviews: `/absolute/durable/TOPIC-review.md`.
- Investigations: `/absolute/durable/TOPIC-investigation.md`.
- Reports: `/absolute/durable/TOPIC-report.pdf`.

## Pitfalls

- **Delivering a path that will not survive the session.** A path inside a worktree or a runtime's private directory may disappear before the attachment is read. Render to the chosen durable directory.
- **A relative attachment path.** Hand back an absolute path so the harness can find the file.
- **Several files behind one attachment path.** One attachment carries one file; hand back one absolute path per file.
- **Delivering a render nobody opened.** A silently truncated or empty PDF looks identical to a good one in the response text, so an unverified render is an unverified report.
- **A misspelt front-matter key.** An unknown key is passed to the template as data and changes nothing, so `pdf_options` or `title` silently leave the defaults in place. `pdfinfo` showing portrait or a filename title is the tell.
