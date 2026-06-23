# ws-python — primes-cli

[![ws-python CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-python.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-python.yml)
[![Python](https://img.shields.io/badge/python-3.13-3776AB?logo=python&logoColor=white)](https://www.python.org)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Example Python workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible Devbox environment where **Python and all tooling
come directly from the Nix package store** — no system Python, no `pip install`,
no virtual environment required.

**Application:** `primes-cli` — a command-line prime number generator,
identical interface to the Rust, Go, Node.js, Zig, and Lua variants.

---

## Table of contents

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Nix Python integration](#nix-python-integration)
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
cd ws-python
devbox shell

# primes-cli is on PATH immediately — no build step needed
primes-cli help
primes-cli nth 100
```

---

## Nix Python integration

The defining feature of this workspace: **all Python tooling comes from the
Nix store**, not from the system Python or a virtual environment.

```bash
# Inside devbox shell:
which python
# → .devbox/nix/profile/default/bin/python

python -c "import sys; print(sys.executable)"
# → /nix/store/...-python3-3.13.3/bin/python3.13

which pytest
# → .devbox/nix/profile/default/bin/pytest

which ruff
# → .devbox/nix/profile/default/bin/ruff
```

The interpreter is the `python@3.13.3` Nix package. `pytest` is
`python313Packages.pytest` — installed as a Nix package alongside the
interpreter, not via pip. There is no `requirements.txt`, no `.venv`,
no `pip install` step.

`uv` is included as a Nix package to demonstrate that modern Python
tooling can also come from Nix — useful if you need to manage
additional dependencies in a project.

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
  --version              Print version information
  --help                 Show this help message
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
ws-python/
├── devbox.json                  # Pinned Nix packages (python, pytest, ruff, mypy, uv)
├── Makefile                     # check / fmt / lint / test / audit / clean / docker-build
├── pyproject.toml               # ruff + mypy + pytest configuration
├── Dockerfile                   # python:3.13-alpine runtime (no compilation)
├── .pre-commit-config.yaml      # ruff format + ruff lint + mypy hooks
├── bin/
│   └── primes-cli               # Shell wrapper: PYTHONPATH + python -m primes_cli
├── src/
│   └── primes_cli/
│       ├── __init__.py
│       ├── __main__.py          # Enables 'python -m primes_cli'
│       ├── primes.py            # Core algorithms (is_prime, sieve, range, nth)
│       ├── main.py              # CLI entry point (argparse)
│       └── test_primes.py       # Unit tests (pytest, 45 tests)
└── tests/
    └── integration_test.py      # Integration tests (pytest, 12 tests)
```

---

## Development tasks

| Target | Command | Description |
|--------|---------|-------------|
| `build` | import validation | Interpreted — no compilation |
| `check` | ruff format-check + ruff lint + mypy + pytest | Full quality gate |
| `fmt` | `ruff format src/ tests/` | Auto-format |
| `lint` | `ruff check` + `mypy src/` | Lint + type check |
| `test` | `pytest src/ tests/` | 57 tests |
| `audit` | notice | No runtime deps to audit |
| `clean` | remove `__pycache__` etc. | Remove artefacts |

---

## Devbox environment

### Nix Python packages

| Package | Version | Purpose |
|---------|---------|---------|
| `python` | 3.13.3 | CPython interpreter (from Nix, not system) |
| `python313Packages.pytest` | 9.0.3 | Test runner (from Nix, not pip) |
| `python313Packages.pytest-cov` | latest | Coverage plugin |
| `ruff` | 0.15.17 | Formatter + linter (replaces black + flake8 + isort) |
| `mypy` | 1.20.1 | Static type checker |
| `uv` | 0.11.19 | Fast Python package manager (available, zero-dep demo) |
| `gnumake` | 4.4.1 | Build system |
| `git` | 2.54.0 | Version control |
| `gh` | 2.52.0 | GitHub CLI |
| `gitleaks` | 8.30.1 | Secret detection |
| `glow` | 2.1.2 | Terminal Markdown renderer |
| `pre-commit` | 4.5.1 | Git hook manager |

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `PYTHONDONTWRITEBYTECODE` | `1` | No `.pyc` files |
| `PYTHONUNBUFFERED` | `1` | Unbuffered stdout/stderr |
| `PATH` | `$PATH:$PWD/bin` | Adds `bin/primes-cli` wrapper |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k warning |

---

## Pre-commit hooks

| Hook | What it checks |
|------|----------------|
| `trailing-whitespace` | No trailing whitespace |
| `end-of-file-fixer` | Files end with newline |
| `check-yaml` | Valid YAML |
| `check-toml` | Valid TOML |
| `check-merge-conflict` | No unresolved markers |
| `mixed-line-ending` | LF enforced |
| `ruff-format` | `ruff format --check src/ tests/` |
| `ruff-lint` | `ruff check src/ tests/` |
| `mypy` | `mypy src/` (strict mode, tests excluded) |

---

## CI pipeline

```
ws-python CI
  ├── lint (ubuntu-latest + macos-latest)
  │     ├── ruff format --check src/ tests/
  │     ├── ruff check src/ tests/
  │     └── mypy src/
  └── test (ubuntu-latest + macos-latest)  [needs: lint]
        └── pytest src/ tests/ -v
```

> Python and tooling are installed via `pip install` in CI (pinned versions),
> not via Nix. This ensures the exact same versions as in devbox without
> requiring Nix on the CI runners.

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
