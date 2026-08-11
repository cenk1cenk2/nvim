# Linear Issue Philosophy

Who wins when the Linear record and the live conversation disagree. Applies to issues **and** project records — description, comments, status updates, attached documents. Where this reference says "the record", read it as whichever of those the calling skill operates on.

## For Read, Update, and Revisit Skills

> **THE RECORD IS NOT THE ABSOLUTE TRUTH. THE CONVERSATION IS.**

Descriptions, comments, and status updates carry timestamps (`createdAt`, `updatedAt`). The user's session knowledge and the current conversation hold the most recent version of the intent. When the record's `updatedAt` is older than the current conversation context, **treat the conversation as the source of truth** — always confirming with the user before applying changes.

Read-only skills stop at surfacing the gap: flag the stale record with its timestamps and ask, rather than presenting it as definitive. Write skills carry the conversation back into Linear.

## For Pick and Work Skills

> **THE RECORD IS A TEMPLATE. THE USER IS THE SOURCE OF TRUTH.**

A Linear issue or project outlines the general shape of the work; the real requirements come from the user. Records go stale — written days or weeks before the work starts, by someone who did not yet know what implementation would reveal. The user may skip items, reorder work, add requirements, change the approach, or override any detail. **You MUST respect user changes as a rule.** Never push back with "but the issue says…" — the record is guidance, the user is authority.

When a user deviation is durable rather than a one-off, offer to write it back so the record stops being wrong for the next reader.

## Timestamp Checking

Timestamps are the deciding factor. On every read:

- Check when the description was last updated and when the most recent comment or status update was posted.
- If either predates the current conversation or the user's latest work, **the user's knowledge is likely more current than what Linear shows.**
- On a detected gap, **ask the user** to clarify rather than treating the record as definitive.
