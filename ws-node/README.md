# ws-node — primes-cli

[![ws-node CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-node.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-node.yml)
[![Node.js](https://img.shields.io/badge/node.js-22.22.3-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/typescript-5.9.3-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example Node.js workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment for a TypeScript CLI project
with all tooling sourced directly from the Nix package store — no system
Node.js installation required. The application is a TypeScript port of the
[ws-rust `primes-cli`](../ws-rust/) and [ws-go `primes-cli`](../ws-go/) with
identical subcommands and behaviour.

**Application:** `primes-cli` — a command-line prime number generator.

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

All other tools (Node.js 22.22.3, TypeScript 5.9.3, tsx, Biome, gnumake, gh, …)
are provided by Devbox from the Nix store and require no separate installation.

---

## Getting started

```bash
cd ws-node
devbox shell
```

The init hook (`scripts/devbox/dbx_init.sh`) runs automatically on shell entry
and displays a preflight status matrix for all toolchain components.

After shell entry, `primes-cli` is directly available on `PATH` via
`bin/primes-cli` — a shell wrapper that invokes `tsx src/main.ts`. No build
step required.

```bash
primes-cli --help
primes-cli list --to 20
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
# Check whether 97 is prime (exits 0 if prime, 1 otherwise)
primes-cli check 97
# → 97 is prime

# List all primes up to 20
primes-cli list --to 20
# → 2 3 5 7 11 13 17 19

# List primes in a range
primes-cli range --from 10 --to 30
# → 11 13 17 19 23 29

# Print the 100th prime
primes-cli nth 100
# → 541

# Run directly without building (via devbox)
devbox run run -- check 97
tsx src/main.ts nth 100
```

---

## Project structure

```
ws-node/
├── devbox.json                     # Pinned Nix packages + devbox run scripts
├── Makefile                        # Build targets via gnumake (Nix package)
├── tsconfig.json                   # TypeScript compiler configuration (strict)
├── biome.json                      # Biome formatter + linter configuration
├── package.json                    # npm metadata + @types/node devDependency
├── bin/
│   └── primes-cli                  # Shell wrapper: exec tsx src/main.ts "$@"
│                                   # Added to PATH via devbox.json env (no build needed)
├── src/
│   ├── primes.ts                   # Core algorithms (isPrime, sieve, range, nth)
│   ├── primes.test.ts              # Unit tests — node:test built-in (25 tests)
│   └── main.ts                     # CLI entry point (process.argv, no framework)
├── tests/
│   └── integration.test.ts         # Integration tests — node:test (8 tests)
├── .pre-commit-config.yaml         # Pre-commit hooks: Biome + tsc --noEmit
└── scripts/
    └── devbox/
        ├── dbx_init.sh             # Init hook: preflight checks + status matrix
        ├── lib/
        │   └── common.sh           # Shared library (colors, OS detection)
        └── init/
            ├── os_darwin/override.sh
            └── os_linux/override.sh
```

---

## Development tasks

All tasks are available as both `make <target>` and `devbox run <target>`.

| Target | Command | Description |
|--------|---------|-------------|
| `build` | `tsc --project tsconfig.json` | Compile TypeScript to `dist/` |
| `check` | biome check + tsc + tsx --test | Full quality gate |
| `fmt` | `biome format --write` | Auto-format all source files |
| `lint` | `biome lint` + `tsc --noEmit` | Lint + type check |
| `test` | `tsx --test src/*.test.ts tests/*.test.ts` | Run all tests |
| `audit` | notice (no npm deps) | No production dependencies to audit |
| `clean` | remove `dist/` | Remove build artefacts |

Additional devbox-only targets (no Makefile equivalent):

| Target | Description |
|--------|-------------|
| `devbox run run` | `tsx src/main.ts <args>` — run directly without building |
| `devbox run info` | Print workspace tool versions |
| `devbox run docs` | Render `README.md` via `glow --pager` |

---

## Devbox environment

### Toolchain origin

All tooling comes directly from the Nix store via devbox — no `npm install`
required for the development toolchain:

```
.devbox/nix/profile/default/bin/node     ← Nix store (nodejs@22.22.3)
.devbox/nix/profile/default/bin/npm      ← ships with nodejs package
.devbox/nix/profile/default/bin/tsc      ← Nix store (typescript@5.9.3)
.devbox/nix/profile/default/bin/tsx      ← Nix store (tsx@4.21.0)
.devbox/nix/profile/default/bin/biome    ← Nix store (biome@2.4.16)
```

The only npm dependency is `@types/node` (type declarations for TypeScript),
installed locally for IDE and compiler support. There are **zero production
runtime dependencies**.

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `NODE_ENV` | `development` | Standard Node.js environment mode |
| `NODE_NO_WARNINGS` | `1` | Suppress Node.js experimental feature warnings |
| `PATH` | `$PATH:$PWD/bin` | Adds `bin/primes-cli` wrapper to shell PATH |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k console-I/O warning during zsh init |

### Pinned packages

| Package | Version | Purpose |
|---------|---------|---------|
| `nodejs` | 22.22.3 | Node.js LTS runtime (includes npm) |
| `typescript` | 5.9.3 | TypeScript compiler (`tsc`) |
| `tsx` | 4.21.0 | TypeScript executor (run TS directly) |
| `biome` | 2.4.16 | Formatter + linter (replaces eslint + prettier) |
| `gnumake` | 4.4.1 | Build system (from Nix, not system make) |
| `git` | 2.54.0 | Version control |
| `gh` | 2.52.0 | GitHub CLI |
| `gitleaks` | 8.30.1 | Secret detection |
| `glow` | 2.1.2 | Terminal Markdown renderer (`devbox run docs`) |
| `bat` | 0.24.0 | Syntax-highlighted cat |
| `ripgrep` | 14.1.0 | Fast grep |
| `fd` | 10.4.2 | Fast find |
| `jq` | 1.8.1 | JSON processor |
| `curl` | 8.17.0 | HTTP client |
| `pre-commit` | 4.5.1 | Git hook manager |

---

## Pre-commit hooks

Pre-commit hooks run automatically before every `git commit` inside `devbox shell`.

```bash
devbox shell   # runs: pre-commit install --install-hooks
```

### Hooks

| Hook | Tool | What it checks |
|------|------|----------------|
| `trailing-whitespace` | pre-commit/pre-commit-hooks | No trailing whitespace |
| `end-of-file-fixer` | pre-commit/pre-commit-hooks | Files end with a newline |
| `check-yaml` | pre-commit/pre-commit-hooks | Valid YAML syntax |
| `check-toml` | pre-commit/pre-commit-hooks | Valid TOML syntax |
| `check-json` | pre-commit/pre-commit-hooks | Valid JSON syntax |
| `check-merge-conflict` | pre-commit/pre-commit-hooks | No unresolved merge markers |
| `mixed-line-ending` | pre-commit/pre-commit-hooks | LF line endings enforced |
| `biome-check` | `biome check ./src ./tests` | Format + lint in one pass |
| `tsc` | `tsc --noEmit` | Full TypeScript type check |

```bash
pre-commit run --all-files
pre-commit run biome-check --all-files
```

---

## CI pipeline

```
ws-node CI
  ├── lint (ubuntu-latest + macos-latest)
  │     ├── biome check ./src ./tests
  │     └── tsc --noEmit
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        └── tsx --test src/*.test.ts tests/*.test.ts
```

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
