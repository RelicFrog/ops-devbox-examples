# ws-zig — primes-cli

[![ws-zig CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-zig.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-zig.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Zig](https://img.shields.io/badge/zig-0.14.1-F7A41D?logo=zig&logoColor=white)](https://ziglang.org)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example Zig workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment for a Zig 0.14 CLI project
with all tooling sourced from the Nix package store.

**Highlight:** the first 1000 prime numbers are computed at **compile time**
via a `comptime` Sieve of Eratosthenes and embedded as a constant array in
the binary. `isPrime()` and `nthPrime()` for `n <= 1000` are O(log N) binary
searches into this table — zero runtime arithmetic required.

**Application:** `primes-cli` — a command-line prime number generator.

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [CLI usage](#cli-usage)
- [The comptime sieve](#the-comptime-sieve)
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

All other tools (Zig 0.14.1, zls, gnumake, gh, …) are provided by Devbox
from the Nix store and require no separate installation.

---

## Getting started

```bash
cd ws-zig
devbox shell
```

The init hook (`scripts/devbox/dbx_init.sh`) runs automatically on shell entry
and displays a preflight status matrix for all toolchain components.

After `devbox shell`, `primes-cli` is available directly on `PATH` via a
`bin/primes-cli` wrapper. If the binary has not been built yet, the wrapper
runs `make build` automatically on first invocation.

```bash
# Direct invocation — builds automatically if needed
primes-cli help
primes-cli nth 100

# Explicit build first, then run
make build
primes-cli check 97
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
```

---

## The comptime sieve

The defining feature of this workspace is Zig's `comptime` — code that
executes at **compile time**, not at runtime.

```zig
// Computed once during compilation, stored as a constant in the binary.
pub const PRIMES_TABLE: [1000]u64 = comptimePrimes(1000);
```

`comptimePrimes` runs a full Sieve of Eratosthenes **inside the compiler**:

```zig
fn comptimePrimes(comptime count: usize) [count]u64 {
    @setEvalBranchQuota(1_000_000);
    var composite: [8000]bool = [_]bool{false} ** 8000;
    // ... sieve logic runs at compile time ...
    return result; // embedded directly in the binary
}
```

**Consequences:**

| Operation | n ≤ 1000 | n > 1000 |
|-----------|----------|----------|
| `isPrime(n)` | O(log 1000) binary search | O(√n) trial division |
| `nthPrime(n)` | O(1) array lookup | O(n·√n) incremental search |

The 1000th prime is 7919. For any n above that, the runtime algorithms take
over seamlessly. You can verify the embedding:

```bash
# The binary contains the prime table as a read-only data segment
strings zig-out/bin/primes-cli | grep -c "^[0-9]*$"
```

---

## Project structure

```
ws-zig/
├── devbox.json                  # Pinned Nix packages + devbox run scripts
├── Makefile                     # build / check / fmt / lint / test / clean / docker-build
├── build.zig                    # Zig build script (used in CI / Linux)
├── Dockerfile                   # Multi-stage: zig:0.13 builder → alpine:3.21 runtime
├── .pre-commit-config.yaml      # Pre-commit hooks: file hygiene + zig fmt check
├── bin/
│   └── primes-cli               # Shell wrapper — builds if needed, then execs binary
│                                # Added to PATH via devbox.json env
└── src/
    ├── primes.zig               # Core algorithms + comptime sieve + 26 unit tests
    ├── main.zig                 # CLI entry point (flag parsing, subcommands)
    └── integration_test.zig     # Integration tests (35 total incl. unit re-runs)
```

> **Note on `tests/` directory:** Zig's module system resolves `@import`
> relative to the source file. Integration tests live in `src/` alongside
> the library code so `@import("primes.zig")` works without module registry
> flags. The `tests/` directory is reserved for future use.

---

## Development tasks

All tasks are available as both `make <target>` and `devbox run <target>`.

| Target | Command | Description |
|--------|---------|-------------|
| `build` | `zig build-exe -O ReleaseSafe` | Produce `zig-out/bin/primes-cli` |
| `check` | fmt-check + build + test | Full quality gate |
| `fmt` | `zig fmt src/` | Auto-format all source files |
| `lint` | `zig fmt --check src/` | Check formatting (no separate linter — `fmt` is canonical in Zig) |
| `test` | `zig test src/primes.zig` + `zig test src/integration_test.zig` | 26 unit + 35 integration tests |
| `clean` | remove `zig-out/`, `zig-cache/`, `.zig-cache/` | Remove build artefacts |

Additional devbox-only targets:

| Target | Description |
|--------|-------------|
| `devbox run run` | Run `zig-out/bin/primes-cli <args>` directly |
| `devbox run info` | Print workspace tool versions |
| `devbox run docs` | Render `README.md` via `glow --pager` |

---

## Devbox environment

### Toolchain origin

All tooling comes directly from the Nix store via devbox:

```
.devbox/nix/profile/default/bin/zig     ← Nix store (zig@0.14.1)
.devbox/nix/profile/default/bin/zls     ← Nix store (zls@0.14.0)
```

### macOS + Nix caveat

Zig 0.14 on macOS with Nix detects the OS version as macOS 26 (Tahoe) from
the running kernel, but the installed SDK is for macOS 15. This causes the
Zig linker to fail with `undefined symbol` errors for standard library
functions.

**Fix:** the Makefile automatically detects macOS and sets the explicit target:

```makefile
ifeq ($(UNAME_S),Darwin)
  ZIG_ARCH   := $(subst arm64,aarch64,$(shell uname -m))
  ZIG_TARGET := -target $(ZIG_ARCH)-macos.15.0
endif
```

This resolves the SDK mismatch. The CI pipeline runs on Linux where the
issue does not occur and `zig build` (the build runner) works normally.

### Pinned packages

| Package | Version | Purpose |
|---------|---------|---------|
| `zig` | 0.14.1 | Zig compiler and toolchain |
| `zls` | 0.14.0 | Zig Language Server (LSP) |
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

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `PATH` | `$PATH:$PWD/bin` | Adds `bin/primes-cli` auto-build wrapper |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k warning |

---

## Pre-commit hooks

Pre-commit hooks run automatically before every `git commit` inside `devbox shell`.

```bash
devbox shell   # runs: pre-commit install --install-hooks
```

| Hook | Tool | What it checks |
|------|------|----------------|
| `trailing-whitespace` | pre-commit/pre-commit-hooks | No trailing whitespace |
| `end-of-file-fixer` | pre-commit/pre-commit-hooks | Files end with a newline |
| `check-yaml` | pre-commit/pre-commit-hooks | Valid YAML syntax |
| `check-merge-conflict` | pre-commit/pre-commit-hooks | No unresolved merge markers |
| `mixed-line-ending` | pre-commit/pre-commit-hooks | LF line endings enforced |
| `zig-fmt` | `zig fmt --check src/` | Code is formatted per Zig style rules |

```bash
pre-commit run --all-files
pre-commit run zig-fmt --all-files
```
```bash
pre-commit run --all-files
pre-commit run zig-fmt --all-files
```

---

## CI pipeline

The workspace sub-workflow (`.github/workflows/ci.yml`) runs on every push
and pull request to `main` that touches `ws-zig/**`.

```
ws-zig CI
  ├── lint (ubuntu-latest + macos-latest)
  │     └── zig fmt --check src/
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        ├── zig build -Doptimize=ReleaseSafe
        └── zig build test
```

> On Linux CI runners, `zig build` works normally without the macOS SDK
> workaround. The Makefile's `ZIG_TARGET` flag is Darwin-only and has no
> effect on Linux.

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
