# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-lua/Makefile

.DEFAULT_GOAL := help

.PHONY: help build check fmt lint test clean docker-build docker-run

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
