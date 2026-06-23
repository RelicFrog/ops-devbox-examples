# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-zig/Makefile
#
# Note on macOS + Nix: 'zig build' (the build runner) requires macOS SDK
# symbols that Nix does not expose by default. We work around this by:
#   1. Setting -target aarch64-macos.15.0 explicitly (avoids macOS 26 mismatch)
#   2. Using direct 'zig build-exe' and 'zig test' instead of 'zig build'
# On Linux (CI), 'zig build' works without additional flags.

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test clean docker-build docker-run

IMG     := primes-zig:latest
OUTDIR  := zig-out/bin
BINARY  := $(OUTDIR)/primes-cli
ZIG     := zig

# macOS: detect and set target to avoid SDK version mismatch with Nix
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  # uname -m returns 'arm64' on Apple Silicon, but Zig uses 'aarch64'
  UNAME_M  := $(shell uname -m)
  ZIG_ARCH := $(subst arm64,aarch64,$(UNAME_M))
  ZIG_TARGET := -target $(ZIG_ARCH)-macos.15.0
else
  ZIG_TARGET :=
endif

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll targets are also available via: devbox run <target>\n\n'

build: ## zig build-exe (ReleaseSafe) → zig-out/bin/primes-cli
	@mkdir -p $(OUTDIR)
	$(ZIG) build-exe src/main.zig \
	  -O ReleaseSafe \
	  $(ZIG_TARGET) \
	  -lc \
	  -femit-bin=$(BINARY)

check: ## fmt-check + build + test
	$(ZIG) fmt --check src/
	$(MAKE) build
	$(MAKE) test

fmt: ## zig fmt src/
	$(ZIG) fmt src/

lint: ## zig fmt --check (Zig has no separate linter; fmt is canonical)
	$(ZIG) fmt --check src/

test: ## zig test src/primes.zig + src/integration_test.zig
	$(ZIG) test src/primes.zig $(ZIG_TARGET) -lc
	$(ZIG) test src/integration_test.zig $(ZIG_TARGET) -lc

clean: ## remove zig-out/, zig-cache/, .zig-cache/
	@rm -rf zig-out zig-cache .zig-cache

docker-build: ## docker buildx build — primes-zig:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10
