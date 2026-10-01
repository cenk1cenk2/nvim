# SCM Review Thread Kind

A fast pre-sort from the `decision` model on what a review thread asks for, before the triage rules decide whether to act or ask. Load `decision` before the first call; its framing rules apply.

**Optional.** Use it only when the `decision` server is in the session; without it, make the call yourself as the consuming skill already says.

## Question

Pass the thread's messages as `state`, latest last. Batch every open thread into one call, one question per thread.

| Question | Options |
|---|---|
| What does the latest message ask for? | `fix`: a specific change to the targeted lines; `question`: why something is so, or whether it is intended; `design`: a broader restructure beyond the targeted lines; `ack`: no action, an acknowledgement or approval |

Suggestion blocks and stale threads are facts you detect yourself: the block is in the payload, and staleness is the diff of the targeted lines since the comment.

## Reading the answer

The threshold applies to the picked option's probability. It only sorts the queue: a `fix` read still goes through triage, and every rule there that says to ask the user still asks.
