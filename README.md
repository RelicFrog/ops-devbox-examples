# DevBox Examples

Reference workspace collection demonstrating reproducible developer environments
using [Devbox](https://www.jetify.com/devbox) for multiple language ecosystems.
Each workspace is self-contained and targets macOS ARM Silicon (aarch64-darwin)
as the primary development platform.

## Overview

This repository is structured as a multi-workspace monorepo. Each subdirectory
is an independent Devbox workspace with its own toolchain, Makefile, CI pipeline,
and example application.

## Workspaces

| Directory               | Language  | Application                               | Status  |
|-------------------------|-----------|-------------------------------------------|---------|
| [`ws-rust`](./ws-rust/) | Rust 2024 | `primes-cli` — prime number generator CLI | active  |
| `ws-go` _(coming)_      | Go        | TBD                                       | planned |
| `ws-node` _(coming)_    | Node.js   | TBD                                       | planned |

## Prerequisites

- [Devbox](https://www.jetify.com/devbox/docs/installing_devbox/) >= 0.13
- [Nix](https://nixos.org/download) (installed automatically by Devbox)
- macOS with Apple Silicon (primary target platform)

## Quick Start

```bash
# Enter a workspace
cd ws-rust

# Start the Devbox shell (installs all tools on first run)
devbox shell

# Or run a command directly without entering the shell
devbox run build
devbox run test
devbox run lint
```

## Workspace Conventions

Each workspace follows a consistent structure:

```
ws-<lang>/
  devbox.json              # Devbox environment definition (pinned nixpkgs)
  devbox.lock              # Locked package resolution
  Makefile                 # Build targets (via gnumake from Nix, not system make)
  rust-toolchain.toml      # (Rust only) toolchain pin
  scripts/
    devbox/
      lib/common.sh        # Shared shell library (color, OS detection, helpers)
      dbx_init.sh          # Devbox init_hook: preflight checks + status matrix
      init/
        os_darwin/override.sh
        os_linux/override.sh
  src/                     # Application source
  tests/                   # Integration tests
  .github/
    workflows/
      ci.yml               # Sub-workflow: lint + test for this workspace
```

### Devbox run scripts

All `devbox run` targets that correspond to Makefile targets delegate directly
to `make <target>`, so both invocation styles are equivalent:

```bash
devbox run build   # == make build
devbox run test    # == make test
devbox run lint    # == make lint
devbox run check   # == make check
devbox run clean   # == make clean
```

Additional targets not backed by Makefile (direct devbox scripts) are also
available per workspace. See the individual workspace README or `devbox.json`
for the full list.

### Platform notes

The devbox configurations target `aarch64-darwin` (Apple Silicon Mac) as the
primary development platform. The CI pipelines run on `ubuntu-latest` (aarch64
runners where available) and `macos-latest`. Packages that are unavailable on
macOS are excluded via the `platforms` field in `devbox.json`.

## CI Pipeline

The root workflow (`.github/workflows/ci.yml`) calls each workspace sub-workflow
as a reusable job. Adding a new workspace only requires registering its workflow
file in the root pipeline.

```
.github/workflows/
  ci.yml              # Root pipeline — calls sub-workflows
ws-rust/.github/
  workflows/
    ci.yml            # Rust workspace: fmt + clippy + test
```

## Reference Links

| Resource               | URL                                                 |
|------------------------|-----------------------------------------------------|
| Devbox documentation   | https://www.jetify.com/devbox/docs/                 |
| Devbox package search  | https://www.jetify.com/devbox/docs/devbox_packages/ |
| Nixpkgs package search | https://search.nixos.org/packages                   |
| ws-rust workspace      | ./ws-rust/                                          |

## License

Copyright 2026 TEAM RelicFrog. Licensed under the [Apache License, Version 2.0](./LICENSE).

Author: Patrick Paechnatz <patrick@relicfrog.rocks>
