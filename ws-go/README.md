# ws-go — primes-cli

[![ws-go CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-go.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-go.yml)
[![Go](https://img.shields.io/badge/go-1.24.13-00ADD8?logo=go)](https://go.dev)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example Go workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment for a Go CLI project with all
tooling sourced directly from the Nix package store — no system Go installation
required. The application is a port of the [ws-rust `primes-cli`](../ws-rust/)
with identical subcommands and behaviour.

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

All other tools (Go 1.24.13, gofumpt, golangci-lint, govulncheck, gnumake, gh, …)
are provided by Devbox from the Nix store and require no separate installation.

---

## Getting started

```bash
# From the repository root
cd ws-go

# Start the Devbox shell — installs all pinned packages on first run
devbox shell
```

The init hook (`scripts/devbox/dbx_init.sh`) runs automatically on shell entry
and displays a preflight status matrix for all toolchain components.

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

# List all primes up to 50
primes-cli list --to 50

# List primes in a range
primes-cli range --from 10 --to 50

# Print the 100th prime
primes-cli nth 100
```

---

## Project structure

```
ws-go/
├── devbox.json                     # Pinned Nix packages + devbox run scripts
├── Makefile                        # Build targets via gnumake (Nix package)
├── go.mod                          # Go module definition
├── src/
│   ├── primes.go                   # Core algorithms: IsPrime, Sieve, Range, Nth
│   ├── primes_test.go              # Unit tests (25 tests)
│   └── cmd/
│       └── main.go                 # CLI entry point (flag-based subcommands)
├── tests/
│   └── integration_test.go         # End-to-end API consistency tests (8 tests)
├── .pre-commit-config.yaml         # Pre-commit hooks: gofumpt + go vet + golangci-lint
└── scripts/
    └── devbox/
        ├── dbx_init.sh             # Init hook: preflight checks + status matrix
        ├── lib/
        │   └── common.sh           # Shared library (colors, OS detection, helpers)
        └── init/
            ├── os_darwin/
            │   └── override.sh     # macOS: no-op (pure Go, CGO disabled)
            └── os_linux/
                └── override.sh     # Linux: no-op (pure Go, CGO disabled)
```

---

## Development tasks

All tasks are available as both `make <target>` and `devbox run <target>`.

| Target | Command | Description |
|--------|---------|-------------|
| `build` | `go build -trimpath` | Produce `bin/primes-cli` |
| `check` | fmt-check + lint + test | Full quality gate |
| `fmt` | `gofumpt -w ./src` | Auto-format all source files |
| `lint` | `golangci-lint run` | Lint with golangci-lint |
| `test` | `go test -race -count=1` | Run all tests with race detector |
| `audit` | `go mod verify` + `govulncheck` | Dependency integrity + vulnerability scan |
| `clean` | remove `bin/` + test cache | Remove build artefacts |

Additional devbox-only targets (no Makefile equivalent):

| Target | Description |
|--------|-------------|
| `devbox run run` | `go run ./src/... <args>` — run directly without building |
| `devbox run info` | Print workspace tool versions |
| `devbox run docs` | Render `README.md` in the terminal via `glow --pager` |

---

## Devbox environment

### Toolchain origin

All Go toolchain binaries come directly from the Nix store via devbox:

```
.devbox/nix/profile/default/bin/go         ← Nix store (go@1.24.13)
.devbox/nix/profile/default/bin/gofmt      ← ships with go package
.devbox/nix/profile/default/bin/gofumpt    ← Nix store (gofumpt@0.10.0)
.devbox/nix/profile/default/bin/golangci-lint ← Nix store (golangci-lint@1.64.8)
.devbox/nix/profile/default/bin/govulncheck   ← Nix store (govulncheck@1.3.0)
```

Unlike the Rust workspace (which uses a rustup proxy), Go tooling is provided
**directly** by Nix packages — no secondary download step required.

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `CGO_ENABLED` | `0` | Disable cgo — pure Go builds, no C toolchain needed |
| `GOPATH` | `$PWD/.devbox/go` | Workspace-local Go module cache |
| `GOBIN` | `$PWD/.devbox/go/bin` | Workspace-local installed binaries |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k console-I/O warning during zsh init |

### Pinned packages

| Package | Version | Purpose |
|---------|---------|---------|
| `go` | 1.24.13 | Go toolchain (includes gofmt) |
| `gofumpt` | 0.10.0 | Stricter gofmt superset formatter |
| `golangci-lint` | 1.64.8 | Meta-linter (vet, staticcheck, errcheck, …) |
| `govulncheck` | 1.3.0 | Vulnerability scanner (Go equivalent of cargo audit) |
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

The `devbox shell` init hook installs them automatically:

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
| `check-merge-conflict` | pre-commit/pre-commit-hooks | No unresolved merge markers |
| `mixed-line-ending` | pre-commit/pre-commit-hooks | LF line endings enforced |
| `go-fmt` | `gofumpt -l ./src` | Code is formatted per gofumpt rules |
| `go-vet` | `go vet ./src/...` | Common Go errors |
| `go-lint` | `golangci-lint run ./src/...` | Full golangci-lint pass |

### Manual run

```bash
pre-commit run --all-files
pre-commit run go-lint --all-files
```

---

## CI pipeline

```
ws-go CI
  ├── lint (ubuntu-latest + macos-latest)
  │     ├── gofumpt -l ./src  (format check)
  │     └── golangci-lint run ./src/...
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        ├── go build -trimpath ./src/cmd/...
        └── go test -race -count=1 ./src/... ./tests/...
```

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
