# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-python/Makefile

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test audit clean docker-build docker-run info

IMG     := primes-python:latest
SRCDIR  := src
TESTDIR := tests
PKG     := primes_cli

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll targets are also available via: devbox run <target>\n\n'
	@printf 'Python interpreter: %s\n\n' "$$(which python)"

build: ## no compilation needed — Python is interpreted (validates imports)
	python -c "import primes_cli; import primes_cli.primes; import primes_cli.main"
	@echo "Import check passed — Python source is valid."

check: ## ruff format-check + ruff lint + mypy + pytest
	ruff format --check $(SRCDIR) $(TESTDIR)
	ruff check $(SRCDIR) $(TESTDIR)
	mypy $(SRCDIR)
	pytest $(SRCDIR) $(TESTDIR)

fmt: ## ruff format (auto-format all source files)
	ruff format $(SRCDIR) $(TESTDIR)

lint: ## ruff check + mypy
	ruff check $(SRCDIR) $(TESTDIR)
	mypy $(SRCDIR)

test: ## pytest src/ tests/
	pytest $(SRCDIR) $(TESTDIR)

audit: ## pip-audit (no runtime deps — prints notice)
	@echo "No production dependencies — nothing to audit."
	@echo "All tooling (python, pytest, ruff, mypy) comes from Nix via devbox."

clean: ## remove __pycache__, .mypy_cache, .pytest_cache, .ruff_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	rm -rf .mypy_cache .pytest_cache .ruff_cache

docker-build: ## docker buildx build — primes-python:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10

info: ## print workspace tool versions and Nix Python path
	@printf '\n'
	@printf '  \033[1m\033[34mws-python — devbox workspace info\033[0m\n'
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "Python"   "$$(python --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "Path"     "$$(which python 2>/dev/null | sed 's|.*/\.devbox/|.devbox/|' || echo 'n/a')"
	@printf '  %-14s ' "From Nix?"; \
	  if which python 2>/dev/null | grep -q nix; then \
	    printf '\033[32myes\033[0m\n'; \
	  else \
	    printf '\033[33mno (outside devbox shell)\033[0m\n'; \
	  fi
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "pytest"   "$$(pytest --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "ruff"     "$$(ruff --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "mypy"     "$$(mypy --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "uv"       "$$(uv --version 2>/dev/null | cut -d' ' -f1-2 || echo 'n/a')"
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "make"     "$$(make --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "git"      "$$(git --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "platform" "$$(uname -ms)"
	@printf '\n'
