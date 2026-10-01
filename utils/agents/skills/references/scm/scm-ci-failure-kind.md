# SCM CI Failure Kind

A fast second opinion from the `decision` model on whether a failing CI job broke because of infrastructure or because of the code. Load `decision` before the first call; its framing rules apply.

**Optional.** Use it only when the `decision` server is in the session; without it, make the call yourself as the consuming skill already says.

## Question

Pass the failing job's log tail, whole rather than trimmed, as `state`.

| Question | Options |
|---|---|
| What kind of error is this? | `infra`: runner, network, registry, quota, timeout or another transient environment failure; `code`: a compile, test, lint or config error in the repository |

Whether the log names a file or symbol this branch changed is a fact you check yourself against the branch diff. Combine the two: `code` touching changed files is branch-caused; `infra`, or `code` in files the branch never touched, is external.

## Reading the answer

The threshold applies to the picked option's probability. At or above 0.85 it is a usable read; below, diagnose it yourself. It never replaces reading the log.
