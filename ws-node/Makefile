# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-node/Makefile
#
# All targets use the gnumake binary provided by Nix (devbox package: gnumake).
# Do NOT rely on the system make (/usr/bin/make on macOS).
#
# Targets are documented with trailing ## comments and appear in `make help`.

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test audit clean

DIST := dist

# ---------------------------------------------------------------------------
# Help — auto-generated from ## comments on each target
# ---------------------------------------------------------------------------

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll targets are also available via: devbox run <target>\n\n'

# ---------------------------------------------------------------------------
# Build — compile TypeScript to JavaScript
# ---------------------------------------------------------------------------

build: ## tsc — compile TypeScript to dist/
	tsc --project tsconfig.json

# ---------------------------------------------------------------------------
# Quality gate (fmt-check + lint + typecheck + test)
# ---------------------------------------------------------------------------

check: ## biome check + tsc --noEmit + tsx --test (full quality gate)
	biome check ./src ./tests
	tsc --noEmit
	tsx --test src/*.test.ts tests/*.test.ts

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

fmt: ## biome format --write ./src ./tests
	biome format --write ./src ./tests

# ---------------------------------------------------------------------------
# Linting
# ---------------------------------------------------------------------------

lint: ## biome lint ./src ./tests + tsc --noEmit
	biome lint ./src ./tests
	tsc --noEmit

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test: ## tsx --test — run all unit and integration tests
	tsx --test src/*.test.ts tests/*.test.ts

# ---------------------------------------------------------------------------
# Security audit
# ---------------------------------------------------------------------------

audit: ## npm audit (no node_modules — zero deps to audit)
	@echo "No production dependencies — nothing to audit."
	@echo "Toolchain packages are managed by Nix (devbox), not npm."

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: ## remove dist/
	@rm -rf $(DIST)
