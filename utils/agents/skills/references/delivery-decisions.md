# Delivery Decisions

A fast, non-binding second opinion from the `decision` model on how work gets delivered: the PR/MR shape and when to review. Load `decision` before the first call; its framing rules apply. The model reads narrow facts well and judgement calls badly, so ask it the facts and derive the call yourself.

## Facts to pass

Brief, factual `state` fields only, named plainly:

- the concerns in the change, one line each;
- which concern touches which files and repositories;
- what each concern changes at its boundary: an API, a schema, shared config, live state;
- rough size per concern, in files and lines;
- the user's stated preference on PR/MR count, when given.

Leave out the shape you are leaning towards. A field naming an option pulls the answer to it. Anything code can compute exactly, such as whether two concerns share a repository, you compute instead of asking.

## Questions to ask

Each is a two-option `choice` with both options described, batched into one call, asked per pair or per concern:

| Question | Options |
|---|---|
| Does B build on code A introduces? | `yes`: B will not compile or pass without A; `no`: B stands alone |
| Must A land or deploy before B can be verified? | `yes`: B's pipeline or tests read A's live effect; `no`: B verifies on its own |
| Can a reviewer judge this concern on its own diff? | `yes`: self-contained; `no`: needs another concern's diff in view |
| Does this concern change a shared boundary? | `yes`: an API, schema, shared config or live state others depend on; `no`: internal only |

## Deriving the call

- **Shape.** Build-on in the same repository makes a stack. Must-land-first across repositories makes an ordered pair with the order stated in both PRs/MRs. Neither makes parallel PRs/MRs, or one PR/MR when the concerns are small and reviewable together.
- **Review timing.** A shared-boundary change, or one a reviewer cannot judge alone, gets `agent-review` before the next step. Everything else is reviewed when the stretch is done. A review the user asked for always runs.

## Reading the answer

The threshold applies to the picked option's probability, not to `confidence`.

- **It agrees with your own read** — proceed and say so in one clause.
- **It disagrees at or above 0.85** — state both reads and why you pick yours, or switch.
- **Below 0.85** — undecided; make the call yourself.

It never decides alone, and never stands in for the user's blessing on the shape when the user asked to approve it.
