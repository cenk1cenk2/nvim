# SCM Change Kind

A fast second opinion from the `decision` model on the Conventional Commit type of a change and on whether it breaks callers. Both drive the release version, so a wrong read changes the bump. Load `decision` before the first call; its framing rules apply.

**Optional.** Use it only when the `decision` server is in the session; without it, make the call yourself as the consuming skill already says.

## Questions

Pass the diff summary and the changed paths as `state`. Leave out the type you are leaning towards.

| Question | Options |
|---|---|
| What does the change do? | `feat`: adds a capability callers can use; `fix`: corrects behaviour that was wrong; `refactor`: same behaviour, different structure; `other`: none of these |
| Does it break existing callers? | `yes`: a public API, schema, CLI or config contract changes so existing callers fail; `no`: existing callers keep working |

`docs`, `test`, `ci`, `build` and `style` follow from the changed paths; set those yourself instead of asking.

## Reading the answer

The threshold applies to the picked option's probability. At or above 0.85 and agreeing with your read, proceed. Disagreeing at or above 0.85, state both reads and pick. Below 0.85, it is undecided. A `yes` on breaking at or above 0.85 is worth raising even when you read it as safe, because a missed `!` skips a major bump.
