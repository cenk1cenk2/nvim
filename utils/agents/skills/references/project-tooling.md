# Project Tooling Discovery

Before running agents or verification steps, discover how the project builds, tests, lints, and runs. Never assume commands — investigate first.

## Discovery Order

Check for task runners in this order. Stop at the first match for each category (lint, test, build, type-check, format-check):

| Runner | Files to check | Commands |
|--------|---------------|----------|
| Taskfile | `Taskfile.yml`, `Taskfile.yaml` | `task lint`, `task test`, `task build`, `task fmt` |
| Make | `Makefile` | `make lint`, `make test`, `make build`, `make fmt` |
| npm/pnpm/yarn | `package.json` (scripts section) | `pnpm run lint`, `pnpm run test`, `pnpm run build`, `pnpm run typecheck` |
| Cargo | `Cargo.toml` | `cargo check`, `cargo test`, `cargo clippy`, `cargo fmt --check` |
| Go | `go.mod` | `go test ./...`, `go vet ./...`, `golangci-lint run` |
| Python | `pyproject.toml`, `setup.py`, `setup.cfg` | `pytest`, `ruff check`, `mypy`, `black --check` |
| Gradle | `build.gradle`, `build.gradle.kts` | `./gradlew test`, `./gradlew build`, `./gradlew check` |
| Maven | `pom.xml` | `mvn test`, `mvn compile`, `mvn verify` |

For `package.json`, read the `scripts` section to find exact script names — don't assume `lint` or `test` exist. Use whatever the project defines.

## Process

1. **Check which files exist** in the project root.
2. **Read the runner config** to extract available commands.
3. **Categorize** what's available: lint, test, build, type-check, format-check.
4. **If no runner is found** — propose manual commands based on the language/framework and **ask the user to confirm** before proceeding. Do not assume.
5. **Present to the user** for confirmation:
   ```
   Discovered project tooling:
   - Lint: task lint
   - Test: task test
   - Build: task build

   These will run for verification. Confirm or adjust?
   ```
6. The user approves or overrides. Do not proceed without confirmation.

## Usage

- Include discovered commands in agent/subagent prompts under a `## Verification Commands` section.
- Run verification after each task (for sequential workflows) or after merge (for parallel workflows).
- Run full verification before claiming any work is complete.
