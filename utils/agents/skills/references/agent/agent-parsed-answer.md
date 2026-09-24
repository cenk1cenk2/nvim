# Parsed Answer

Applies when an artifact you author for another agent asks for a final answer that a program parses as it arrives — JSON a caller loads, a status line a script matches, any exact format with no human in between to fix it.

## State the failure up front

The brief says, before the work: **an answer a strict parser cannot load as-is is a failed run, whatever the work found.** A thorough answer wrapped in a code fence, prefixed with a sentence, or carrying a raw line break inside a string is worth nothing — the parse fails and the caller counts the run as an error.

Then the format, as exact as the parser is:

- **The message is the payload and nothing else.** For JSON, its first character is `{` and its last is `}`: no code fence, no language tag, no heading, no prose before or after. "Here is the result" in front of the object is the same failure.
- **Exactly the keys the caller reads, every time.** Name them and give one example object.
- **Enumerated values spelled exactly**, case included.
- **Strings are valid strings.** In JSON a line break is the two characters backslash and `n`, and a double quote and a backslash are each escaped with a backslash; a raw line break or tab inside a string invalidates the whole answer.

## End with "before you send"

The brief's last section is a short checklist the agent runs against its own message, stating that any failing line means fixing the message first — never sending it and explaining afterwards. For JSON:

- The first character is `{` and the last is `}`, with nothing before or after.
- There is no `` ``` `` anywhere outside a string value.
- Every key the caller reads is present, and no other key is.
- Every enumerated value is one of the allowed words.
- No string value contains a raw line break, a raw tab or an unescaped double quote.
- The whole message loads with a strict parser, as-is.

For another format, the same list against its own grammar: nothing outside the payload, every required field, allowed values only, and a strict read of the message as sent.
