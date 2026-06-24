# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] — 2026-06-23

### Added

- `make info` target in all six language workspaces — shows tool versions,
  Nix origin check ("From Nix? yes/no"), and platform in a consistent
  styled format with section dividers.
- `ws-rust`: `bin/primes-cli` wrapper and `PATH=$PWD/bin` in `devbox.json`
  so `primes-cli` is directly callable inside `devbox shell`.

### Fixed

- `ws-go`, `ws-lua`: missing `PATH=$PATH:$PWD/bin` in `devbox.json` —
  `primes-cli` required explicit `bin/primes-cli` prefix; now callable directly
  in all six workspaces without path prefix.
- `ws-zig` CI: `macos-latest` upgraded to macOS 26 arm64 — Zig 0.14.1 build
  runner fails with undefined symbols against macOS 26 SDK. Split CI steps:
  Linux uses `zig build`, macOS uses direct `zig build-exe` / `zig test` with
  `-target aarch64-macos.15.0`.
- `ws-zig` Dockerfile: `ghcr.io/euantorano/zig:0.13.0` no longer accessible —
  replaced with `debian:bookworm-slim` + direct download from `ziglang.org`.
- `make info` all workspaces: tool version fields were empty due to `$(cmd)`
  instead of `$$(cmd)` in make recipes (expanded at parse time, not runtime).
  Also fixed: `luajit -v` writes to stderr (needs `2>&1`); `awk $1` inside make
  recipes requires `$$1` escaping.

## [1.1.0] — 2026-06-23

### Added

- `ws-go`: Go 1.24.13 workspace — `primes-cli` with `golangci-lint`, `gofumpt`,
  `govulncheck`, race-detector tests, Dockerfile (golang:alpine → busybox:musl).
- `ws-node`: Node.js 22 / TypeScript workspace — `primes-cli` with Biome formatter,
  `tsx` test runner, `bin/primes-cli` wrapper, Dockerfile (node:22-alpine).
- `ws-zig`: Zig 0.14.1 workspace — `primes-cli` with `comptime` Sieve of Eratosthenes
  embedding 1000 primes in the binary at compile time; O(log N) lookup for nth/isPrime.
- `ws-lua`: LuaJIT 2.1 workspace — `primes-cli` interpreted (no build step), `stylua`,
  `luacheck`, inline test harness (72 tests), Dockerfile (alpine:3.21 + luajit).
- `ws-python`: Python 3.13 workspace — `primes-cli` with all tooling (python, pytest,
  ruff, mypy, uv) sourced directly from the Nix package store; no pip/venv/requirements.
- `ws-k8s`: Kubernetes workspace — containerised `primes-cli` for all six languages,
  deployed to local OrbStack cluster; `kubectl exec` wrappers for each language;
  `bin/primes-{rust,go,node,zig,lua,python}` on PATH inside devbox shell.
- Dockerfiles in each language workspace: multi-stage builds, `tail -f /dev/null`
  keep-alive pattern for kubectl exec targets.
- `make docker-build` / `make docker-run` targets in all language workspaces.
- `make help` as `.DEFAULT_GOAL` with `awk`-generated output in all workspaces.
- `bin/primes-cli` PATH wrappers in all language workspaces (auto-build where needed).
- `POWERLEVEL9K_INSTANT_PROMPT=quiet` in all `devbox.json` env blocks.
- Pre-commit hooks in all language workspaces (file hygiene + language-specific hooks).
- CI sub-workflows for ws-go, ws-node, ws-zig, ws-lua, ws-python registered in root CI.
- Workspace READMEs with CI badges, CLI usage, pinned package tables, toolchain origin
  sections, environment variable tables, pre-commit and CI pipeline documentation.
- Root README: workspace table with per-workspace CI badges; full repository structure
  tree; container images table; `ws-k8s` quick-start section.

### Fixed

- `ws-go`: Go 1.22.5 → 1.24.13, gofumpt 0.6.0 → 0.10.0, golangci-lint 1.59.1 → 1.64.8
  to resolve `govulncheck` GO-2025-3750 vulnerability and toolchain compatibility.
- `ws-go`: `CGO_ENABLED=1` override on CI test step — Go race detector requires CGO.
- `ws-node`: `typescript` added as explicit `package.json` devDependency.
- `ws-node`: `useLiteralKeys` biome lint — `flags["to"]` → `flags.to`.
- `ws-k8s`: namespace race condition fixed with dedicated `namespace` target.
- `ws-k8s`: `tail -f /dev/null` replaces `sleep 3600`; `--grace-period=0 --force`
  on teardown to avoid 30s hang.
- `ws-k8s`: primes-rust runtime: `busybox:stable-musl` → `alpine:3.21`.
- `ws-python`: `PYTHONPATH=$PWD/src` added to `devbox.json` env.
- `ws-zig`: `build.zig` integration test path corrected.

### Changed

- `ws-k8s`: extended from 3 languages (rust/go/node) to 6 (+ zig/lua/python).
- All workspace READMEs aligned to canonical structure.
- Root `README.md`: Repository structure fully updated.

## [1.0.1] — 2026-06-22

### Added

- `ws-rust`: `deny.toml` — cargo-deny policy: allow Apache-2.0, MIT, Unicode-3.0
  licenses; deny unknown registries and git sources; warn on duplicate crate versions.
- `ws-rust`: `make help` as default target with auto-generated output from `##` comments.
- `ws-rust`: Pre-commit hooks — file hygiene (pre-commit/pre-commit-hooks@v6.0.0) and
  local Rust hooks for `cargo fmt`, `cargo check`, `cargo clippy`.
- `ws-rust`: `glow@2.1.2` and `bat@0.24.0` packages; `devbox run docs` command.
- `ws-rust`: `devbox.lock` committed for reproducible package resolution.
- Root and workspace READMEs with CI, licence, platform, and Rust edition badges.

### Fixed

- `ws-rust`: `RUSTC_WRAPPER=""` set in devbox env to prevent sccache errors.
- `ws-rust`: `set -euo pipefail` removed from `dbx_init.sh`.
- `ws-rust`: All source files formatted with `cargo fmt` (Toolchain rustfmt).
- `ws-rust`: `clippy::manual_is_multiple_of` — `n % x == 0` → `n.is_multiple_of(x)`.
- `ws-rust`: `sieve_count_primes_below_100` test assertion corrected from 24 to 25.
- All files: copyright year updated from 2024 to 2026.

### Changed

- `ws-rust`: All devbox packages pinned to explicit versions (no `latest` tags).
- `ws-rust`: `dbx_init.sh` v2 — rustfmt and rust-analyzer moved to toolchain block.
- `ws-rust`: Removed redundant Nix packages `rustfmt@1.95.0` and `rust-analyzer`.
- `ws-rust`: `primes-cli` version bumped to 1.0.1.

## [0.1.0] — 2026-06-22

### Added

- `ws-rust`: Initial Rust workspace with `primes-cli` example application.
- `ws-rust`: Devbox environment with pinned nixpkgs revision, gnumake, Rust toolchain,
  cargo-nextest, cargo-audit, cargo-deny, gitleaks, git, gh, ripgrep.
- `ws-rust`: Makefile with `build`, `check`, `fmt`, `lint`, `test`, `audit`, `clean` targets.
- `ws-rust`: Devbox run scripts bridging to Makefile targets.
- `ws-rust`: CI sub-workflow (fmt check, clippy, nextest).
- `ws-rust`: `dbx_init.sh` preflight check with status matrix.
- `ws-rust`: Platform exclude example (linux-only package excluded on Darwin).
- Root CI workflow referencing workspace sub-workflows.
- Community files: LICENSE (Apache-2.0), AUTHORS.md, CONTRIBUTING.md, SECURITY.md,
  CODE_OF_CONDUCT.md.

[Unreleased]: https://github.com/RelicFrog/ops-devbox-examples/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/RelicFrog/ops-devbox-examples/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/RelicFrog/ops-devbox-examples/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/RelicFrog/ops-devbox-examples/compare/v0.1.0...v1.0.1
[0.1.0]: https://github.com/RelicFrog/ops-devbox-examples/releases/tag/v0.1.0
