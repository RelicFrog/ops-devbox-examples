# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-go/Makefile
#
# All targets use the gnumake binary provided by Nix (devbox package: gnumake).
# Do NOT rely on the system make (/usr/bin/make on macOS).
#
# Targets are documented with trailing ## comments and appear in `make help`.

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test audit clean

BINARY    := primes-cli
BUILD_DIR := bin
SRC       := ./src/cmd/...

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

build: ## go build — produces bin/primes-cli
	@mkdir -p $(BUILD_DIR)
	go build -trimpath -o $(BUILD_DIR)/$(BINARY) $(SRC)

# ---------------------------------------------------------------------------
# Quality gate (run all checks in sequence — fail fast)
# ---------------------------------------------------------------------------

check: ## fmt-check + lint + test (full quality gate)
	gofumpt -l -e ./src && test -z "$$(gofumpt -l ./src)"
	golangci-lint run ./src/...
	go test -race -count=1 ./src/... ./tests/...

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

fmt: ## gofumpt -w ./src (auto-format all source files)
	gofumpt -w ./src

# ---------------------------------------------------------------------------
# Linting
# ---------------------------------------------------------------------------

lint: ## golangci-lint run ./src/...
	golangci-lint run ./src/...

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test: ## go test -race -count=1 ./src/... ./tests/...
	go test -race -count=1 ./src/... ./tests/...

# ---------------------------------------------------------------------------
# Security audit
# ---------------------------------------------------------------------------

audit: ## govulncheck + go mod verify
	go mod verify
	govulncheck ./...

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: ## remove bin/ and test cache
	@rm -rf $(BUILD_DIR)
	go clean -testcache
