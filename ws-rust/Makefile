# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-rust/Makefile
#
# All targets use the gnumake binary provided by Nix (devbox package: gnumake).
# Do NOT rely on the system make (/usr/bin/make on macOS).
#
# Usage inside devbox shell:
#   make build    — release build
#   make check    — full quality gate (fmt + clippy + nextest)
#   make fmt      — auto-format all source files
#   make lint     — clippy with deny-warnings
#   make test     — run all tests via cargo-nextest
#   make audit    — dependency security audit (cargo-audit + cargo-deny)
#   make clean    — remove build artefacts
#
# Alternatively via devbox run:
#   devbox run build / check / fmt / lint / test / audit / clean

.PHONY: build check fmt lint test audit clean

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

build:
	cargo build --release

# ---------------------------------------------------------------------------
# Quality gate (run all checks in sequence — fail fast)
# ---------------------------------------------------------------------------

check:
	cargo fmt --all -- --check
	cargo clippy --all -- -D warnings
	cargo nextest run --all

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

fmt:
	cargo fmt --all

# ---------------------------------------------------------------------------
# Linting
# ---------------------------------------------------------------------------

lint:
	cargo clippy --all -- -D warnings

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test:
	cargo nextest run --all

# ---------------------------------------------------------------------------
# Security audit
# ---------------------------------------------------------------------------

audit:
	cargo audit
	cargo deny check

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean:
	cargo clean
