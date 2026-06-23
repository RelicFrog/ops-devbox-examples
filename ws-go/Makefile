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

.PHONY: help build check fmt lint test audit clean docker-build docker-run info

BINARY    := primes-cli
IMG       := primes-go:latest
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

# ---------------------------------------------------------------------------
# Container build (requires Docker on host — OrbStack / Docker Desktop)
# ---------------------------------------------------------------------------

docker-build: ## docker buildx build — primes-go:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10

info: ## print workspace tool versions and Nix toolchain path
	@printf '\n'
	@printf '  \033[1m\033[34mws-go — devbox workspace info\033[0m\n'
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "go"  "$(go version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s ' "From Nix?"; \
	  if which go 2>/dev/null | grep -q nix; then \
	    printf '\033[32myes\033[0m\n'; \
	  else \
	    printf '\033[33mno (outside devbox shell)\033[0m\n'; \
	  fi
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "gofumpt"  "$(gofumpt --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "golangci"  "$(golangci-lint --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "govulncheck"  "$(govulncheck --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "make"     "$$(make --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "git"      "$$(git --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "platform" "$$(uname -ms)"
	@printf '\n'
