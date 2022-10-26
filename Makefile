SHELL := /usr/bin/env bash

lint-check: lint-check-lua lint-check-sh

lint-check-lua:
	stylua --config-path .stylua.toml --check .

lint-check-sh:
	shfmt -f . | xargs shellcheck

lint: lint-lua lint-sh

lint-lua:
	stylua --config-path .stylua.toml .

lint-sh:
	shfmt -f .

test:
	bash ./utils/ci/run_test.sh "$(TEST)"

.PHONY: lint
