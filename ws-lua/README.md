# ws-lua — primes-cli

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Lua](https://img.shields.io/badge/LuaJIT-2.1-2C2D72?logo=lua&logoColor=white)](https://luajit.org)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example LuaJIT workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment for a LuaJIT CLI project with
all tooling sourced from the Nix package store — no system Lua installation
required. No compilation, no build artefacts: Lua is interpreted.

**Application:** `primes-cli` — a command-line prime number generator,
identical interface to the Rust, Go, Node.js, and Zig variants.

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [CLI usage](#cli-usage)
- [Project structure](#project-structure)
- [Development tasks](#development-tasks)
- [Devbox environment](#devbox-environment)
- [Pre-commit hooks](#pre-commit-hooks)
- [CI pipeline](#ci-pipeline)
- [License](#license)

---

## Requirements

| Tool | Purpose |
|------|---------|
| [Devbox](https://www.jetify.com/devbox) >= 0.13 | Hermetic toolchain management |
| [Nix](https://nixos.org/download) | Package backend (auto-installed by Devbox) |
| macOS Apple Silicon | Primary development platform |

---

## Getting started

```bash
cd ws-lua
devbox shell

# primes-cli is on PATH immediately — no build step needed
primes-cli help
primes-cli nth 100
```

---

## CLI usage

```
primes-cli <command> [arguments]

Commands:
  check <N>              Test whether N is prime (exit 0=prime, 1=not prime)
  list  --to <N>         List all primes up to N (inclusive)
  range --from <A> --to <B>
                         List all primes in the closed interval [A, B]
  nth   <N>              Print the N-th prime (1-indexed, nth 1 == 2)
  version                Print version information
  help                   Show this help message
```

### Examples

```bash
primes-cli check 97       # → 97 is prime
primes-cli list --to 20   # → 2 3 5 7 11 13 17 19
primes-cli range --from 10 --to 30  # → 11 13 17 19 23 29
primes-cli nth 100        # → 541
```

---

## Project structure

```
ws-lua/
├── devbox.json                  # Pinned Nix packages + devbox run scripts
├── Makefile                     # check / fmt / lint / test / docker-build
├── Dockerfile                   # alpine:3.21 + luajit + src/ (no build step)
├── .luacheckrc                  # luacheck configuration (std=luajit)
├── .pre-commit-config.yaml      # stylua + luacheck hooks
├── bin/
│   └── primes-cli               # Shell wrapper: LUA_PATH + luajit src/main.lua
├── src/
│   ├── primes.lua               # Core algorithms (is_prime, sieve, range, nth)
│   ├── primes_test.lua          # Unit tests — inline harness, 59 tests
│   └── main.lua                 # CLI entry point
└── tests/
    └── integration_test.lua     # Integration tests — 13 tests
```

---

## Development tasks

| Target | Command | Description |
|--------|---------|-------------|
| `build` | syntax validation | Lua is interpreted — no compilation |
| `check` | stylua + luacheck + test | Full quality gate |
| `fmt` | `stylua src/` | Auto-format (tabs, 120 cols) |
| `lint` | `luacheck src/` | Static analysis |
| `test` | `luajit primes_test.lua` + `integration_test.lua` | 59 + 13 = 72 tests |
| `clean` | no-op | Nothing to clean |

---

## Devbox environment

### Pinned packages

| Package | Version | Purpose |
|---------|---------|---------|
| `luajit` | 2.1.1774638290 | LuaJIT 2.1 runtime (Lua 5.1 compatible) |
| `lua51Packages.luacheck` | 1.2.0-1 | Static analyser |
| `stylua` | 2.5.2 | Formatter (tab-indented, 120-col) |
| `gnumake` | 4.4.1 | Build system |
| `git` | 2.54.0 | Version control |
| `gh` | 2.52.0 | GitHub CLI |
| `gitleaks` | 8.30.1 | Secret detection |
| `glow` | 2.1.2 | Terminal Markdown renderer |
| `pre-commit` | 4.5.1 | Git hook manager |

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `PATH` | `$PATH:$PWD/bin` | Adds `bin/primes-cli` wrapper |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k warning |

---

## Pre-commit hooks

| Hook | What it checks |
|------|----------------|
| `trailing-whitespace` | No trailing whitespace |
| `end-of-file-fixer` | Files end with newline |
| `check-yaml` | Valid YAML |
| `check-merge-conflict` | No unresolved markers |
| `mixed-line-ending` | LF enforced |
| `stylua` | `stylua --check src/` |
| `luacheck` | `luacheck src/ --no-unused-args` |

---

## CI pipeline

```
ws-lua CI
  ├── lint (ubuntu-latest + macos-latest)
  │     ├── stylua --check src/
  │     └── luacheck src/
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        ├── luajit src/primes_test.lua
        └── luajit tests/integration_test.lua
```

> LuaJIT and luacheck are installed from system packages in CI
> (apt/brew) since the Nix LuaJIT package is not cross-platform in
> all GitHub Actions environments.

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
