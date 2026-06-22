# ops-devbox-examples

[![CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](./LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)

Reference workspace collection demonstrating reproducible, hermetic developer
environments using [Devbox](https://www.jetify.com/devbox) across multiple
language ecosystems. Each workspace is fully self-contained with its own
toolchain, build system, CI pipeline, and example application.

**Primary target platform:** macOS Apple Silicon (`aarch64-darwin`).

---

## Workspaces

| Workspace | Language | Application | CI | Status |
|-----------|----------|-------------|-----|--------|
| [`ws-rust`](./ws-rust/) | Rust 2024 | [`primes-cli`](./ws-rust/src/main.rs) — prime number generator | [![ws-rust CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml) | active |
| `ws-go` | Go | TBD | — | planned |
| `ws-node` | Node.js | TBD | — | planned |

---

## Getting started

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| [Devbox](https://www.jetify.com/devbox) | >= 0.13 | `curl -fsSL https://get.jetify.com/devbox \| bash` |
| [Nix](https://nixos.org/download) | any | installed automatically by Devbox |
| macOS + Apple Silicon | — | primary development platform |

### Quick start

```bash
# Clone the repository
git clone https://github.com/RelicFrog/ops-devbox-examples.git
cd ops-devbox-examples

# Enter a workspace — Devbox installs all tooling on first run
cd ws-rust
devbox shell

# Run tasks directly without entering the shell
devbox run build    # cargo build --release
devbox run test     # cargo nextest run --all
devbox run check    # fmt-check + clippy + tests
devbox run lint     # cargo clippy -D warnings
devbox run clean    # cargo clean
```

---

## Repository structure

```
ops-devbox-examples/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Root pipeline — delegates to workspace sub-workflows
│       └── ci-ws-rust.yml      # Reusable workflow: ws-rust lint + test
├── ws-rust/                    # Rust 2024 workspace (active)
│   ├── devbox.json             # Pinned Nix packages, devbox run scripts
│   ├── Makefile                # Build targets via gnumake (Nix, not system make)
│   ├── rust-toolchain.toml     # Stable toolchain, aarch64-apple-darwin
│   ├── src/                    # primes-cli source
│   ├── tests/                  # Integration tests
│   └── scripts/devbox/         # Init hook, preflight checks, OS overrides
├── ws-go/                      # Go workspace (planned)
├── ws-node/                    # Node.js workspace (planned)
├── LICENSE                     # Apache-2.0
└── README.md
```

---

## Workspace conventions

### devbox run ↔ make

All `devbox run` targets that correspond to a Makefile target delegate directly
to `make <target>`. Both invocation styles are equivalent:

```bash
devbox run build   # == make build
devbox run check   # == make check
devbox run fmt     # == make fmt
devbox run lint    # == make lint
devbox run test    # == make test
devbox run audit   # == make audit
devbox run clean   # == make clean
```

Targets without a Makefile equivalent (e.g. `run`, `info`) are devbox-only
scripts defined directly in `devbox.json`.

### Platform package exclusions

Packages unavailable on macOS are excluded via the `platforms` field in
`devbox.json`. Example: `mold` (Linux-only fast linker) is listed with
`"platforms": ["x86_64-linux", "aarch64-linux"]` so it is never installed
on Darwin.

### Devbox init hook

Each workspace runs `scripts/devbox/dbx_init.sh` on `devbox shell` entry.
The script performs preflight checks and renders a status matrix covering all
toolchain components, build tools, and security utilities. OS-specific
environment adjustments (linker flags, compiler cache) are loaded from
`scripts/devbox/init/os_<platform>/override.sh`.

---

## CI pipeline

The root workflow (`.github/workflows/ci.yml`) calls each workspace's
sub-workflow as a reusable job. Matrix: `ubuntu-latest` + `macos-latest`.

```
Push / PR to main
  └── CI (ci.yml)
        └── ws-rust (ci-ws-rust.yml)
              ├── lint  — cargo fmt --check + cargo clippy -D warnings
              └── test  — cargo build + cargo nextest run --all
```

Adding a new workspace requires only registering its reusable workflow in
`ci.yml`. No changes to existing workflows needed.

---

## Reference links

| Resource | URL |
|----------|-----|
| Devbox documentation | <https://www.jetify.com/devbox/docs/> |
| Devbox package search | <https://www.jetify.com/devbox/docs/devbox_packages/> |
| Nixpkgs package search | <https://search.nixos.org/packages> |
| ws-rust workspace | [./ws-rust/](./ws-rust/) |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines. All contributions
must pass `make check` in the relevant workspace before submitting a PR.

## Security

See [SECURITY.md](./SECURITY.md) for the vulnerability reporting process.

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](./LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
