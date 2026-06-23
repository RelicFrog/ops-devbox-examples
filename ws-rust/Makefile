# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-rust/Makefile
#
# All targets use the gnumake binary provided by Nix (devbox package: gnumake).
# Do NOT rely on the system make (/usr/bin/make on macOS).
#
# Targets are documented with trailing ## comments and appear in `make help`.

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test audit clean docker-build docker-run

IMG := primes-rust:latest

# ---------------------------------------------------------------------------
# Help — auto-generated from ## comments on each target
# ---------------------------------------------------------------------------

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll targets are also available via: devbox run <target>\n\n'

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

build: ## cargo build --release
	cargo build --release

# ---------------------------------------------------------------------------
# Quality gate (run all checks in sequence — fail fast)
# ---------------------------------------------------------------------------

check: ## fmt-check + clippy + nextest (full quality gate)
	cargo fmt --all -- --check
	cargo clippy --all -- -D warnings
	cargo nextest run --all

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

fmt: ## cargo fmt --all (auto-format all source files)
	cargo fmt --all

# ---------------------------------------------------------------------------
# Linting
# ---------------------------------------------------------------------------

lint: ## cargo clippy --all -D warnings
	cargo clippy --all -- -D warnings

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test: ## cargo nextest run --all
	cargo nextest run --all

# ---------------------------------------------------------------------------
# Security audit
# ---------------------------------------------------------------------------

audit: ## cargo audit + cargo deny check
	cargo audit
	cargo deny check

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: ## cargo clean (remove build artefacts)
	cargo clean

# ---------------------------------------------------------------------------
# Container build (requires Docker on host — OrbStack / Docker Desktop)
# ---------------------------------------------------------------------------

docker-build: ## docker buildx build — primes-rust:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10

info: ## print workspace tool versions and Nix/rustup toolchain path
	@printf '\n'
	@printf '  \033[1m\033[34mws-rust — devbox workspace info\033[0m\n'
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "rustc"    "$$(rustc --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "cargo"    "$$(cargo --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s '; \
	  if which rustc 2>/dev/null | grep -q virtenv; then \
	    printf '\033[32mrustup virtenv\033[0m\n'; \
	  else \
	    printf '\033[33mnot in devbox virtenv\033[0m\n'; \
	  fi
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "rustfmt"  "$$(rustfmt --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "clippy"   "$$(cargo clippy --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "nextest"  "$$(cargo nextest --version 2>/dev/null || echo 'n/a')"
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "make"     "$$(make --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "git"      "$$(git --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "platform" "$$(uname -ms)"
	@printf '\n'
