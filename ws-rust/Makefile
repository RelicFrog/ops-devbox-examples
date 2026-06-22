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

.PHONY: help build check fmt lint test audit clean

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
