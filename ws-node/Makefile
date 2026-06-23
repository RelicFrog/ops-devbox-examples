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

.PHONY: help build check fmt lint test audit clean docker-build docker-run info

IMG := primes-node:latest

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

# ---------------------------------------------------------------------------
# Container build (requires Docker on host — OrbStack / Docker Desktop)
# ---------------------------------------------------------------------------

docker-build: ## docker buildx build — primes-node:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10

info: ## print workspace tool versions and Nix toolchain path
	@printf '\n'
	@printf '  \033[1m\033[34mws-node — devbox workspace info\033[0m\n'
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "node"  "$(node --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s ' "From Nix?"; \
	  if which node 2>/dev/null | grep -q nix; then \
	    printf '\033[32myes\033[0m\n'; \
	  else \
	    printf '\033[33mno (outside devbox shell)\033[0m\n'; \
	  fi
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "tsc"  "$(tsc --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "tsx"  "$(tsx --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "biome"  "$(biome --version 2>/dev/null || echo 'n/a')"
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "make"     "$$(make --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "git"      "$$(git --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "platform" "$$(uname -ms)"
	@printf '\n'
