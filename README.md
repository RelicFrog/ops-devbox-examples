# ops-devbox-examples

[![CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](./LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64-lightgrey?logo=apple)](https://developer.apple.com/silicon/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-OrbStack-326CE5?logo=kubernetes&logoColor=white)](https://orbstack.dev/kubernetes)

Reference workspace collection demonstrating reproducible, hermetic developer
environments using [Devbox](https://www.jetify.com/devbox) across multiple
language ecosystems and runtimes. Each workspace is fully self-contained with
its own toolchain, build system, CI pipeline, and example application.

The fourth workspace (`ws-k8s`) goes one step further: it containerises all
three CLI applications and deploys them to a local Kubernetes cluster
(OrbStack), providing `kubectl exec` wrappers that make in-pod binaries
callable like local commands.

**Primary target platform:** macOS Apple Silicon (`aarch64-darwin`).

---

## Workspaces

| Workspace | Language / Stack | Application | CI | Status |
|-----------|-----------------|-------------|-----|--------|
| [`ws-rust`](./ws-rust/) | Rust 2024 | [`primes-cli`](./ws-rust/src/main.rs) — prime number generator | [![ws-rust CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-rust.yml) | active |
| [`ws-go`](./ws-go/) | Go 1.24.13 | [`primes-cli`](./ws-go/src/cmd/main.go) — prime number generator | [![ws-go CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-go.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-go.yml) | active |
| [`ws-node`](./ws-node/) | Node.js 22 / TypeScript | [`primes-cli`](./ws-node/src/main.ts) — prime number generator | [![ws-node CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-node.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-node.yml) | active |
| [`ws-zig`](./ws-zig/) | Zig 0.14.1 | [`primes-cli`](./ws-zig/src/main.zig) — comptime sieve + prime generator | [![ws-zig CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-zig.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-zig.yml) | active |
| [`ws-lua`](./ws-lua/) | LuaJIT 2.1 | [`primes-cli`](./ws-lua/src/main.lua) — prime number generator | [![ws-lua CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-lua.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-lua.yml) | active |
| [`ws-python`](./ws-python/) | Python 3.13 | [`primes-cli`](./ws-python/src/primes_cli/main.py) — prime number generator | [![ws-python CI](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-python.yml/badge.svg?branch=main)](https://github.com/RelicFrog/ops-devbox-examples/actions/workflows/ci-ws-python.yml) | active |
| [`ws-k8s`](./ws-k8s/) | Kubernetes / OrbStack | Containerised `primes-cli` for all six languages + `kubectl exec` wrappers | — | active |

---

## Getting started

### Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Devbox](https://www.jetify.com/devbox) >= 0.13 | all workspaces | `curl -fsSL https://get.jetify.com/devbox \| bash` |
| [Nix](https://nixos.org/download) | all workspaces | installed automatically by Devbox |
| macOS + Apple Silicon | primary platform | — |
| [OrbStack](https://orbstack.dev) | `ws-k8s` only | download from orbstack.dev |
| Kubernetes enabled in OrbStack | `ws-k8s` only | Settings → Kubernetes → Enable |

### Quick start — language workspaces

```bash
git clone https://github.com/RelicFrog/ops-devbox-examples.git
cd ops-devbox-examples

# Enter any workspace — Devbox installs all tooling on first run
cd ws-rust        # or ws-go / ws-node
devbox shell

# Common tasks (identical across all three workspaces)
make              # show available targets
make build        # compile the application
make check        # full quality gate (fmt + lint + test)
make test         # run tests only
make audit        # dependency security scan
```

### Quick start — Kubernetes workspace

```bash
cd ws-k8s
devbox shell

# 1. Build all three container images (requires Docker / OrbStack)
make build-all

# 2. Deploy to local OrbStack cluster
make deploy-all

# 3. Call the in-pod CLIs via kubectl exec wrappers (on PATH in devbox shell)
primes-rust check 97
primes-go   nth 100
primes-node list --to 20

# 4. Tear down
make teardown
```

---

## Repository structure

```
ops-devbox-examples/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Root pipeline — calls all workspace sub-workflows
│       ├── ci-ws-rust.yml      # Reusable: ws-rust lint + test
│       ├── ci-ws-go.yml        # Reusable: ws-go lint + test
│       ├── ci-ws-node.yml      # Reusable: ws-node lint + test
│       ├── ci-ws-zig.yml       # Reusable: ws-zig fmt-check + build + test
│       ├── ci-ws-lua.yml       # Reusable: ws-lua lint + test
│       └── ci-ws-python.yml    # Reusable: ws-python lint + test
├── ws-rust/                    # Rust 2024 workspace
│   ├── devbox.json             # Pinned Nix packages + devbox run scripts
│   ├── Makefile                # build / check / fmt / lint / test / audit / clean / docker-build
│   ├── Dockerfile              # Multi-stage: rust:alpine builder → alpine:3.21 runtime
│   ├── deny.toml               # cargo-deny licence + vulnerability policy
│   ├── rust-toolchain.toml     # Stable toolchain, aarch64-apple-darwin
│   ├── bin/primes-cli          # Shell wrapper — auto-builds if needed
│   ├── src/                    # primes-cli source (lib.rs + main.rs + primes.rs)
│   ├── tests/                  # Integration tests
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-go/                      # Go 1.24.13 workspace
│   ├── devbox.json             # Pinned Nix packages (go, gofumpt, golangci-lint, …)
│   ├── Makefile                # build / check / fmt / lint / test / audit / clean / docker-build
│   ├── Dockerfile              # Multi-stage: golang:alpine builder → busybox:musl runtime
│   ├── go.mod                  # Module: github.com/RelicFrog/ops-devbox-examples/ws-go
│   ├── bin/primes-cli          # Shell wrapper — runs go binary directly
│   ├── src/                    # primes-cli source (primes.go + cmd/main.go)
│   ├── tests/                  # Integration tests
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-node/                    # Node.js 22 / TypeScript workspace
│   ├── devbox.json             # Pinned Nix packages (nodejs, typescript, tsx, biome, …)
│   ├── Makefile                # build / check / fmt / lint / test / audit / clean / docker-build
│   ├── Dockerfile              # Multi-stage: node:22-alpine builder → node:22-alpine runtime
│   ├── tsconfig.json           # Strict TypeScript, ES2022, NodeNext
│   ├── biome.json              # Formatter + linter configuration
│   ├── bin/primes-cli          # Shell wrapper — runs tsx src/main.ts directly (no build needed)
│   ├── src/                    # primes-cli source (primes.ts + main.ts)
│   ├── tests/                  # Integration tests
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-zig/                     # Zig 0.14.1 workspace — comptime prime sieve
│   ├── devbox.json             # Pinned Nix packages (zig, zls, …)
│   ├── Makefile                # build / check / fmt / lint / test / clean / docker-build
│   ├── Dockerfile              # zig:0.13 builder → alpine:3.21 runtime
│   ├── build.zig               # Zig build script (used in CI / Linux)
│   ├── bin/primes-cli          # Shell wrapper — auto-builds if needed
│   ├── src/                    # primes.zig (comptime sieve) + main.zig + integration_test.zig
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-lua/                     # LuaJIT 2.1 workspace — interpreted, no build step
│   ├── devbox.json             # Pinned Nix packages (luajit, luacheck, stylua, …)
│   ├── Makefile                # check / fmt / lint / test / docker-build
│   ├── Dockerfile              # alpine:3.21 + apk luajit + src/
│   ├── bin/primes-cli          # Shell wrapper — LUA_PATH + luajit src/main.lua
│   ├── src/                    # primes.lua + main.lua + primes_test.lua
│   ├── tests/                  # integration_test.lua
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-python/                  # Python 3.13 workspace — all tooling from Nix
│   ├── devbox.json             # Pinned Nix packages (python, pytest, ruff, mypy, uv, …)
│   ├── Makefile                # check / fmt / lint / test / audit / clean / docker-build
│   ├── Dockerfile              # python:3.13-alpine + src/ (no compilation)
│   ├── pyproject.toml          # ruff + mypy + pytest configuration
│   ├── bin/primes-cli          # Shell wrapper — PYTHONPATH + python -m primes_cli
│   ├── src/primes_cli/         # primes.py + main.py + __main__.py
│   ├── tests/                  # integration_test.py
│   └── scripts/devbox/         # Init hook, preflight matrix, OS overrides
├── ws-k8s/                     # Kubernetes workspace (requires OrbStack)
│   ├── devbox.json             # kubectl, k9s, helm, kustomize, stern, trivy, yq-go, …
│   ├── Makefile                # build-all / deploy-all / exec-* / logs-* / teardown / info
│   ├── bin/                    # kubectl exec wrappers: primes-{rust,go,node,zig,lua,python}
│   ├── manifests/              # Raw YAML: namespace + Deployments (imagePullPolicy: Never)
│   │   ├── rust/ go/ node/     # deployment.yaml per language
│   │   ├── zig/ lua/ python/   # deployment.yaml per language
│   └── scripts/devbox/         # Init hook, cluster + Docker daemon check
├── LICENSE                     # Apache-2.0
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── README.md
```

---

## Workspace conventions

### devbox run ↔ make

All `devbox run` targets in the language workspaces delegate directly
to `make <target>`. Both invocation styles are equivalent:

```bash
devbox run build   # == make build
devbox run check   # == make check
devbox run fmt     # == make fmt
devbox run lint    # == make lint
devbox run test    # == make test
devbox run audit   # == make audit
devbox run clean   # == make clean
devbox run docs    # glow --pager README.md  (no make equivalent)
devbox run info    # print tool versions     (no make equivalent)
devbox run run     # run binary directly     (no make equivalent)
```

The `ws-k8s` workspace follows the same `make <target>` pattern but
exposes a different set of targets (`build-all`, `deploy-all`, `exec-*`,
`teardown`, …) that operate at the cluster level rather than the source level.

### make without arguments

Every workspace defines `.DEFAULT_GOAL := help`. Running `make` without
arguments prints the self-documenting help derived from `##` comments:

```bash
make        # shows all targets with descriptions
make info   # prints tool versions for the current workspace
```

### Container images

Each language workspace produces a container image via `make docker-build`.
Images use multi-stage builds and are loaded directly into the local
OrbStack Docker context (`--load`). No registry push is required.

| Image | Base (runtime) | Binary |
|-------|---------------|--------|
| `primes-rust:latest` | `alpine:3.21` | `/primes-cli` |
| `primes-go:latest` | `busybox:stable-musl` | `/primes-cli` |
| `primes-node:latest` | `node:22-alpine` | `/usr/local/bin/primes-cli` |

All containers use `tail -f /dev/null` as their keep-alive mechanism so
they remain running for `kubectl exec` invocations without CPU overhead.

### Platform package exclusions

Packages unavailable on macOS are excluded via the `platforms` field in
`devbox.json`. Example: `mold` (Linux-only fast linker):

```json
"mold": {
  "version": "2.41.0",
  "platforms": ["x86_64-linux", "aarch64-linux"]
}
```

### Devbox init hook

Each workspace runs `scripts/devbox/dbx_init.sh` on `devbox shell` entry
and displays a preflight status matrix. The `ws-k8s` init hook additionally
checks Docker daemon reachability and cluster connectivity.

---

## CI pipeline

The root workflow (`.github/workflows/ci.yml`) calls each language workspace
sub-workflow as a reusable job. Matrix: `ubuntu-latest` + `macos-latest`.

```
Push / PR to main
  └── CI (ci.yml)
        ├── ws-rust (ci-ws-rust.yml)
        │     ├── lint  — cargo fmt --check + cargo clippy -D warnings
        │     └── test  — cargo build + cargo nextest run --all
        ├── ws-go (ci-ws-go.yml)
        │     ├── lint  — gofumpt -l + golangci-lint run
        │     └── test  — go build + go test -race
        └── ws-node (ci-ws-node.yml)
              ├── lint  — biome check + tsc --noEmit
              └── test  — tsx --test
        ├── ws-zig (ci-ws-zig.yml)
        │     ├── lint  — zig fmt --check src/
        │     └── test  — zig build + zig build test
        └── ws-lua (ci-ws-lua.yml)
              ├── lint  — stylua --check + luacheck
              └── test  — luajit primes_test.lua + integration_test.lua
        └── ws-python (ci-ws-python.yml)
              ├── lint  — ruff format-check + ruff lint + mypy
              └── test  — pytest src/ tests/
```

> `ws-k8s` has no CI workflow — it requires a live OrbStack cluster and
> locally built images, which are not available in standard GitHub Actions
> runners. Validation is done locally via `make build-all && make deploy-all`.

---

## Reference links

| Resource | URL |
|----------|-----|
| Devbox documentation | <https://www.jetify.com/devbox/docs/> |
| Devbox package search | <https://www.jetify.com/devbox/docs/devbox_packages/> |
| Nixpkgs package search | <https://search.nixos.org/packages> |
| OrbStack (local k8s) | <https://orbstack.dev> |
| ws-rust workspace | [./ws-rust/](./ws-rust/) |
| ws-go workspace | [./ws-go/](./ws-go/) |
| ws-node workspace | [./ws-node/](./ws-node/) |
| ws-zig workspace | [./ws-zig/](./ws-zig/) |
| ws-lua workspace | [./ws-lua/](./ws-lua/) |
| ws-python workspace | [./ws-python/](./ws-python/) |
| ws-k8s workspace | [./ws-k8s/](./ws-k8s/) |

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
