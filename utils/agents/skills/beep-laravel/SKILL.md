---
name: beep-laravel
description: "beep-laravel Daily check-in that narrates the user's update back to them in a chosen tone, then DMs the styled check-in to the beep bot/app in the Laravel Slack on approval — never to a channel. Use when the user says 'beep', 'daily check-in', 'check me in', or invokes /beep-laravel. Do NOT use for status reports to others or standup writeups (write those plainly)."
references:
  - ../references/present-first.md
  - ../references/claude-ai-connectors.md
disable-model-invocation: true
argument-hint: "[tone] <your check-in>"
---

## Beep: Daily Check-In

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

> **NEVER post to a channel — absolute rule.** The beep check-in is only ever a **direct message to the beep bot/app**. Do not post it to any Slack channel under any circumstances. If you cannot resolve the bot/app DM, stop and ask — never fall back to a channel.

> Read the `claude-ai-connectors` reference to load the Laravel Slack tools (`mcp__claude_ai_Slack__*`, deferred) via `ToolSearch` — `slack_search_users`, `slack_send_message_draft`, `slack_send_message`.

A daily ritual. The user shares what their day held — and often what tomorrow holds — and beep plays it back to them. **Vanilla is the default** — a clean, professional replay of the check-in. When the user picks a tone, the point shifts to delight: beep dresses the facts in that voice. Offer a rich, varied menu of tones, but absent a pick, vanilla wins.

## Process

1. **Take the user's check-in** from the message or `/beep-laravel` arguments. If there is no check-in content, ask one short question: "What's the check-in?" and wait.
   - The check-in often comes in two buckets: **things done today** and **things planned for tomorrow.** Parse both. Either bucket may be empty.

2. **Settle the tone.**
   - If the user explicitly named a tone (in the arguments or message, e.g. "pirate", "do it noir", "weather report"), use it — including tones outside the roster.
   - Otherwise, **propose tones before narrating.** Offer a generous, varied handful to spark ideas, then invite the user to name their own.
   - **Always vary the proposals, and reach wide.** Don't reprint the same list — regenerate a fresh set each run (5-7 options), mixing house/extended tones with several invented on the spot that riff on the day's content (a rough day → therapy session; a shipping day → launch control). Pull from far afield — genres, eras, formats, voices — so the menu surprises. Always keep **📋 vanilla** on the list as the no-tone option, and always end with "…or name your own." Example shape (regenerate the tones each time):
     ```
     What tone? A few to spark ideas:
     - 🎙️ late-night talk show
     - 🧙 fantasy quest log
     - 🛰️ mission control
     - 🕵️ film noir
     - 🎡 carnival barker
     - 📋 vanilla (no tone — a clean, professional replay)
     …or name your own.
     ```
   - **Vanilla is the absolute default.** A tone the user names always wins. If they don't pick one — they just say go/beep, or ignore the menu — narrate in 📋 vanilla rather than choosing a costume for them.

3. **Narrate the check-in in the chosen tone** — just the narration itself, no preamble or framing sentence (never "here's your day as a weather report:"), keeping done and tomorrow unmistakably distinct (see **Done vs. Tomorrow**). Keep it short, understandable, and concise — a couple of punchy beats, not an essay. **ABSOLUTE: never lose important information the user passed.** Every real item, name, and technical detail must survive the styling; tone dresses the facts, it never invents, drops, or buries them.

4. **End naturally** — let the narration land on its own last beat. No canned sign-off or catchphrase ("that's a wrap", "and scene", "signing off"), no meta-summary, no explaining the joke.

5. **Send to beep (DM only, on approval).** The styled narration from steps 3-4 is the message body — do not re-style it.
   - **Resolve the target (confirmed method)** — the beep app does **not** surface in `slack_search_users` (queries like `beep`, `beep bot`, `standup` return nothing). Use the known beep **DM channel** directly: `channel_id` `D0B5SBB8QUF` (the `beep2` direct message, member `U08MDLB9U0Z`). This is a DM, never a channel. If that DM ever stops resolving, stop and ask — never fall back to a channel.
   - **Draft it** — create a real Slack draft with `slack_send_message_draft` (`channel_id` = the beep DM above). Confirmed working. If it returns `draft_already_exists`, replace the previous draft rather than stacking. Present the styled text plus "DM to the beep app" for approval.
   - **Send only on an explicit go-word** — `post`, `send`, or `go`. Then send with `slack_send_message` (`channel_id` = the beep DM, passing the `draft_id` so the draft clears on send). Without a go-word, leave the draft in place — invoking the skill produces the draft, the go-word posts it.
   - **If the app cannot be DM'd** (`cannot_dm_bot` / `channel_not_found`), STOP and tell the user — the beep app must have direct messages enabled. Never fall back to a channel.
   - **Report** the sent message link (or the draft link) and that it went to the bot/app DM.

## Done vs. Tomorrow

When the check-in has both buckets, distinguish them through tense and a natural paragraph break — no headers or labels needed. The line between them should be unmistakable:

- **Done** → past tense, settled, triumphant or grim-but-finished. The kill is made, the case is closed, the front has passed.
- **Tomorrow** → future tense, anticipatory, foreshadowing. The hunt ahead, the storm moving in, the next job, uncharted space.

If only one bucket exists, narrate just that one. Never let a planned item read as already done.

## Tone Guides

These are **examples, not a fixed menu** — a reference palette to show the range and the done/tomorrow split. Invent tones freely beyond this list; each tone just needs a *Done* voice (past/settled) and a *Tomorrow* voice (future/incoming). Vanilla is the one fixed option that's always offered.

**No tone**

- **📋 Vanilla** — no styling. Replay the check-in professionally in the user's own words: tidy grammar and phrasing, keep every fact, name, and technical term intact, no metaphors or costume. Still split done (past tense) from tomorrow (future tense) with a paragraph break, and close with a plain sign-off. This is the one tone where a faithful summary is the goal.

**House tones**

- **🏴‍☠️ Pirate** — second-person, salty, nautical. Tasks are plunder, bugs are krakens, meetings are doldrums. *Done:* loot dragged aboard, krakens keelhauled. *Tomorrow:* at first light we hunt the horizon. Close on a toast or a curse.
- **🌿 Nature documentary** — hushed third-person, present tense, Attenborough cadence. The user is "the developer," a creature in its habitat. *Done:* a rare kill, a parasite shed. *Tomorrow:* come morning, it will stalk its prey, which waits in the tall grass.
- **🔪 Cheap crime novel** — hard-boiled noir, short sentences, rain on the window. Tasks are cases, bugs are suspects, deadlines are dames. *Done:* the bug's not flaky anymore — it's just gone. *Tomorrow:* the job's still out there, on my desk, waiting. Close on a grim one-liner.

**Extended palette**

- **🌦️ Weather forecast** — meteorologist cadence; the today/tomorrow split is built in. *Done:* a front of merged PRs cleared the fog. *Tomorrow:* scattered webhooks moving in overnight, 70% chance of a PR review.
- **🔭 Captain's log (Star Trek)** — stardate, measured command voice. *Done:* the API is online; we made safe orbit at staging. *Tomorrow:* we set course for the webhook cluster; a migration looms in uncharted space.
- **🎬 Movie trailer guy** — booming "In a world…" voice. *Done:* this week, one engineer merged the impossible and lived. *Tomorrow:* coming soon — the webhooks, and a migration no one saw coming.
- **🔮 Horoscope / astrology** — cosmic, fated. *Done:* the stars aligned; a flaky test released its grip. *Tomorrow:* Mercury favors webhooks; a migration enters your house of long-avoided chores.
- **🥏 Sports play-by-play** — breathless commentator. *Done:* the API is GOOD — straight through the uprights! *Tomorrow:* coming up after the break, the webhooks drive and a review of Dana's tape.
- **🃏 Heist briefing** — cool crew-leader brief. *Done:* the crew cracked it clean, no alarms. *Tomorrow:* we hit the webhooks at dawn; then the big one — the migration.
- **🛡️ War-room briefing** — clipped general's report, 24h clock. *Done:* the objective is taken and held, no losses. *Tomorrow:* at 0600 we advance; the migration is our objective by nightfall.
- **🍳 Cooking show** — warm chef patter. *Done:* today we plated a gorgeous API and deglazed that flaky test. *Tomorrow:* we're prepping webhooks and — the showstopper — a migration from scratch.

## Example

**User:** `today i have done some random things on my side to just take time to look to the current state of stuff. region module versioning migration is coming to an end and is issued for request for comments. it will be a multistep migration as always but should be quick enough to not affect anybody. did my checkins with justin with hurting his head for an hour. tomorrow i will finalize the region module versioning migration in the morning when it is a bit more silent.`

**Beep (proposes tone):**
> What tone? Here are a few to spark ideas:
> - 🏴‍☠️ pirate
> - 🌿 nature documentary
> - 🔪 cheap crime novel
> - 🌦️ weather forecast
> …or name your own.

**User:** weather forecast

**Beep (narrates):**
> A mixed bag moved through — some light reconnaissance, a migration nearing landfall, and an hour of turbulence over Justin's mind with me talking non stop. RFC conditions for the region module monorepository are now in effect; the front should pass clean over everyone.
>
> Quieter skies expected in the morning. The region module versioning migration will be finalized in a couple of steps.

## Key Principles

- **Never lose important information — ABSOLUTE.** Every real item, name, and technical detail the user passed must survive the styling. Preserve their actual words, names, and technical terms; tone wraps around the facts, it never replaces, drops, or buries them. Proper nouns, project names, and specific situations appear in recognizable form, optionally with a tonal adjective or metaphor on top. Example: `"an hour of turbulence over Justin's mind with me talking non stop"` keeps Justin clear and the situation legible; `"a turbulent low-pressure system moved through Justin's office"` buries both.
- **Understandable and concise** — tone never costs clarity or brevity; if the styling makes the check-in harder to follow, dial it back.
- **Just the narration** — no preamble, framing sentence, or tacked-on sign-off; deliver the styled check-in itself, nothing wrapped around it.
- **Settle the tone first** — never narrate before it's settled; absent a pick, the tone is vanilla.
- **Done ≠ tomorrow** — past/settled for done, future/incoming for tomorrow; the line between them must be unmistakable.
- **Short and punchy** — a couple of beats, then let it land. No essays, no meta.
- **Honor custom tones** — if the user names their own, run with it over the roster.
- **Vanilla is the default** — it's what beep uses when no tone is named: drop the costume and give a clean professional replay. A named tone opts into delight; vanilla is the faithful baseline.
- **DM the beep app, never a channel** — the beep check-in goes only to the beep DM (`D0B5SBB8QUF`, member `U08MDLB9U0Z`) as a direct message; `slack_search_users` won't find the app, so use that DM directly. Posting it to a channel is never allowed.
- **Draft, then send on the go-word** — produce the Slack draft on invocation; only `post` / `send` / `go` actually sends it.
