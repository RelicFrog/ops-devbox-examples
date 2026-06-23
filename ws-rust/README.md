# ws-rust — primes-cli

[![ws-rust CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml)
[![Rust](https://img.shields.io/badge/rust-stable-orange?logo=rust)](https://www.rust-lang.org)
[![Edition](https://img.shields.io/badge/edition-2024-orange?logo=rust)](https://doc.rust-lang.org/edition-guide/rust-2024/)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example Rust workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment for a Rust 2024 CLI project,
including Makefile-based build targets, a preflight init hook, platform-aware
package configuration, and a full CI pipeline.

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

All other tools (Rust stable, cargo-nextest, cargo-audit, gnumake, gh, …) are
provided by Devbox and require no separate installation.

---

## Getting started

```bash
# From the repository root
cd ws-rust

# Start the Devbox shell — installs all pinned packages on first run
devbox shell
```

The init hook (`scripts/devbox/dbx_init.sh`) runs automatically on shell entry
and displays a preflight status matrix for all toolchain components.

On first entry, `rustc` and `cargo` will not yet be present — they are
installed lazily by `rustup` on the first `cargo build` invocation via
`rust-toolchain.toml`.

---

## CLI usage

```
Usage: primes-cli <COMMAND>

Commands:
  check  Check whether a single number is prime
  list   List all prime numbers up to a given limit (inclusive)
  range  List all prime numbers in a closed interval [from, to]
  nth    Print the N-th prime number (1-indexed)
  help   Print help

Options:
  -h, --help     Print help
  -V, --version  Print version
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
ws-rust/
├── Cargo.toml                      # Crate manifest (edition 2024, Apache-2.0)
├── rust-toolchain.toml             # Stable toolchain, target aarch64-apple-darwin
├── Makefile                        # Build targets via gnumake (Nix package)
├── devbox.json                     # Pinned Nix packages + devbox run scripts
├── src/
│   ├── main.rs                     # CLI entry point (clap subcommands)
│   ├── lib.rs                      # Library root — re-exports public API
│   └── primes.rs                   # Core algorithms + unit tests (30+)
├── tests/
│   └── integration_test.rs         # End-to-end API consistency tests
└── scripts/
    └── devbox/
        ├── dbx_init.sh             # Init hook: preflight checks + status matrix
        ├── lib/
        │   └── common.sh           # Shared library (colors, OS detection, helpers)
        └── init/
            ├── os_darwin/
            │   └── override.sh     # macOS: strip mold from RUSTFLAGS, optional sccache
            └── os_linux/
                └── override.sh     # Linux: enable mold linker, optional sccache
```

---

## Development tasks

All tasks are available as both `make <target>` and `devbox run <target>`.

| Target | Command | Description |
|--------|---------|-------------|
| `build` | `cargo build --release` | Release build |
| `check` | fmt-check + clippy + nextest | Full quality gate |
| `fmt` | `cargo fmt --all` | Auto-format all source |
| `lint` | `cargo clippy --all -- -D warnings` | Lint with deny-warnings |
| `test` | `cargo nextest run --all` | Run all tests |
| `audit` | `cargo audit` + `cargo deny check` | Dependency security audit |
| `clean` | `cargo clean` | Remove build artefacts |

Additional devbox-only targets (no Makefile equivalent):

| Target | Description |
|--------|-------------|
| `devbox run run` | `cargo run -- <args>` — run the binary with arguments |
| `devbox run info` | Print workspace tool versions |
| `devbox run docs` | Render `README.md` in the terminal via `glow --pager` |

---

## Devbox environment

### Pinned packages

All packages are pinned to explicit versions. No `latest` tags.

| Package | Version | Purpose |
|---------|---------|---------|
| `rustup` | 1.29.0 | Rust toolchain manager |
| `cargo-nextest` | 0.9.137 | Fast test runner |
| `cargo-audit` | 0.22.1 | Dependency vulnerability scanner |
| `cargo-deny` | 0.19.8 | Dependency policy enforcement |
| `cargo-deny` | 0.19.8 | Dependency policy enforcement |
| `rust-analyzer` | 2026-06-01 | LSP language server |
| `grcov` | 0.9.1 | Code coverage tool |
| `gnumake` | 4.4.1 | Build system (from Nix, not system make) |
| `git` | 2.54.0 | Version control |
| `gh` | 2.52.0 | GitHub CLI |
| `gitleaks` | 8.30.1 | Secret detection |
| `glow` | 2.1.2 | Terminal Markdown renderer (`devbox run docs`) |
| `ripgrep` | 14.1.0 | Fast grep |
| `fd` | 10.4.2 | Fast find |
| `bat` | 0.24.0 | Syntax-highlighted cat |
| `jq` | 1.8.1 | JSON processor |
| `curl` | 8.17.0 | HTTP client |
| `mold` | 2.41.0 | Fast linker (**Linux only** — platform-excluded on macOS) |

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `RUST_BACKTRACE` | `1` | Full backtraces on panic |
| `CARGO_TERM_COLOR` | `always` | Force coloured cargo output |
| `CARGO_INCREMENTAL` | `0` | Disable incremental compilation (reproducible builds) |
| `RUSTC_WRAPPER` | `""` | Explicitly unset to prevent sccache interference from host shell |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k console-I/O warning during zsh init |

### Platform package exclusion

`mold` is Linux-only and is excluded on macOS via the `platforms` field:

```json
"mold": {
  "version": "2.41.0",
  "platforms": ["x86_64-linux", "aarch64-linux"]
}
```

This is the canonical pattern for platform-conditional packages in Devbox.

### devbox run scripts

```bash
devbox run build    # make build  — cargo build --release
devbox run check    # make check  — fmt-check + clippy + nextest
devbox run fmt      # make fmt    — cargo fmt --all
devbox run lint     # make lint   — cargo clippy -D warnings
devbox run test     # make test   — cargo nextest run --all
devbox run audit    # make audit  — cargo audit + cargo deny check
devbox run clean    # make clean  — cargo clean
devbox run run      # cargo run -- <args>   (no make equivalent)
devbox run info     # print workspace tool versions (no make equivalent)
```

---

## Pre-commit hooks

Pre-commit hooks run automatically before every `git commit` and enforce the
same quality gate as CI — catching formatting and lint issues locally before
they reach the pipeline.

### Setup

The `devbox shell` init hook installs the hooks automatically:

```bash
devbox shell   # runs: pre-commit install --install-hooks
```

To install manually or to re-install after updating the config:

```bash
pre-commit install          # install the pre-commit hook
pre-commit install --install-hooks  # also download hook environments
```

### Hooks

| Hook | Tool | What it checks |
|------|------|----------------|
| `trailing-whitespace` | pre-commit/pre-commit-hooks | No trailing whitespace |
| `end-of-file-fixer` | pre-commit/pre-commit-hooks | Files end with a newline |
| `check-yaml` | pre-commit/pre-commit-hooks | Valid YAML syntax |
| `check-toml` | pre-commit/pre-commit-hooks | Valid TOML syntax (`Cargo.toml`) |
| `check-merge-conflict` | pre-commit/pre-commit-hooks | No unresolved merge markers |
| `mixed-line-ending` | pre-commit/pre-commit-hooks | LF line endings enforced |
| `rust-fmt` | `cargo fmt` | Code is formatted per `rustfmt` rules |
| `rust-check` | `cargo check` | Code compiles (type + borrow check) |
| `rust-clippy` | `cargo clippy` | No clippy warnings (`-D warnings`) |

All Rust hooks are defined as `local` entries in `.pre-commit-config.yaml` —
they invoke `cargo` directly and always use the toolchain pinned in
`rust-toolchain.toml`. No external hook repository is required.

### Manual run

```bash
# Run all hooks against all files (useful after adding the config)
pre-commit run --all-files

# Run a single hook
pre-commit run rust-clippy --all-files
pre-commit run rust-fmt --all-files
```

### Skipping hooks

In exceptional cases (e.g. a WIP commit) hooks can be bypassed:

```bash
git commit --no-verify -m "wip: ..."
```

This should not be used to bypass failing checks on commits intended for `main`.

---

## CI pipeline

The workspace sub-workflow (`.github/workflows/ci.yml`) runs on every push and
pull request to `main` that touches `ws-rust/**`.

```
ws-rust CI
  ├── lint (ubuntu-latest + macos-latest)
  │     ├── cargo fmt --all -- --check
  │     └── cargo clippy --all -- -D warnings
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        ├── cargo build --all
        └── cargo nextest run --all
```

The root pipeline (`.github/workflows/ci-ws-rust.yml`) wraps this as a
reusable `workflow_call` target so it can be composed from the repository-level
`ci.yml`.

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
