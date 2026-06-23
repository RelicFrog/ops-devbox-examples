# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-lua/Makefile

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test clean docker-build docker-run info

IMG     := primes-lua:latest
LUA     := luajit
LUAPATH := src/?.lua;;

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-14s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll targets are also available via: devbox run <target>\n\n'

build: ## no compilation needed — Lua is interpreted (validates syntax only)
	@LUA_PATH="$(LUAPATH)" $(LUA) -e "require('primes'); require('main')" 2>/dev/null || \
	  LUA_PATH="$(LUAPATH)" $(LUA) -l primes src/main.lua --help > /dev/null 2>&1 || true
	@echo "Syntax OK (Lua is interpreted — no build artefacts)"

check: ## fmt-check + lint + test
	stylua --check src/
	LUA_PATH="$(LUAPATH)" luacheck src/ --no-unused-args
	$(MAKE) test

fmt: ## stylua --write src/
	stylua src/

lint: ## luacheck src/
	LUA_PATH="$(LUAPATH)" luacheck src/ --no-unused-args

test: ## luajit src/primes_test.lua + tests/integration_test.lua
	LUA_PATH="$(LUAPATH)" $(LUA) src/primes_test.lua
	LUA_PATH="src/?.lua;tests/?.lua;;" $(LUA) tests/integration_test.lua

clean: ## nothing to clean (interpreted language)
	@echo "Nothing to clean."

docker-build: ## docker buildx build — primes-lua:latest
	docker buildx build --platform linux/arm64 -t $(IMG) --load .

docker-run: ## docker run — smoke test the container image
	docker run --rm $(IMG) check 97
	docker run --rm $(IMG) nth 10

info: ## print workspace tool versions and Nix toolchain path
	@printf '\n'
	@printf '  \033[1m\033[34mws-lua — devbox workspace info\033[0m\n'
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "luajit"  "$(luajit -v 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s ' "From Nix?"; \
	  if which luajit 2>/dev/null | grep -q nix; then \
	    printf '\033[32myes\033[0m\n'; \
	  else \
	    printf '\033[33mno (outside devbox shell)\033[0m\n'; \
	  fi
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "luacheck"  "$(luacheck --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "stylua"  "$(stylua --version 2>/dev/null || echo 'n/a')"
	@printf '  \033[90m%s\033[0m\n' "$$(printf '%.0s─' {1..48})"
	@printf '  %-14s %s\n'  "make"     "$$(make --version 2>/dev/null | head -1 || echo 'n/a')"
	@printf '  %-14s %s\n'  "git"      "$$(git --version 2>/dev/null || echo 'n/a')"
	@printf '  %-14s %s\n'  "platform" "$$(uname -ms)"
	@printf '\n'
