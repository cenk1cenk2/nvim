# mise

Almost every CLI here is installed by **mise** — `gh`, `glab`, `kubectl`, `helm`, `terraform`, `task`, `selene`, language runtimes. It resolves in the interactive session and in anything launched from the graphical session, so **call the tool directly**: no wrapper, no prefix, nothing to reason about.

Where it does not resolve, the cause is a process that did not inherit the session environment — a systemd unit, cron, a headless or remote launch — and the fallback is `~/.local/share/mise/shims` on `PATH` the way the existing unit files do it, or `mise exec -- <command>`. The mise binary sits outside its own shims, so it is reachable from anywhere.

**Diagnose before working around.** A tool that fails from a shell where `PATH` already carries the shims is not an environment problem, and wrapping the call hides whatever is actually broken. Read the error: a zsh function or completion wrapper failing before the binary runs is a shell-config bug to fix at its source, not something to route around.
