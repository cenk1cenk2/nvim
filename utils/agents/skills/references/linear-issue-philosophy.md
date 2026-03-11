# Linear Issue Philosophy

## For Update and Revisit Skills

> **THE ISSUE IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.**

Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). The user's session knowledge and the current conversation context hold the most recent version of the issue's intent. When the issue's `updatedAt` is older than the current conversation context, **treat the conversation as the source of truth** — always confirming with the user before applying changes.

## For Pick and Work Skills

> **THE ISSUE IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.**

Linear issues outline the general shape of the work, but the real requirements come from the user. The user may skip items, reorder work, add requirements, change the approach, or override any detail. **You MUST respect user changes as a rule.** Never push back with "but the issue says..." — the issue is guidance, the user is authority.

## Timestamp Checking

Issue descriptions and comments carry timestamps (`createdAt`, `updatedAt`). If the description was last updated or comments were posted before the current conversation context:

- **The user's knowledge may be more current than what Linear shows.**
- When you detect a gap between the issue's timestamps and the current session, **ask the user** to clarify rather than treating the issue content as definitive.
- Timestamps are the deciding factor — always check when the description was last updated and when the most recent comment was posted.
