# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

- `ws-rust`: `RUSTC_WRAPPER=""` set in devbox env to prevent sccache errors when the
  host shell has sccache configured but it is not installed inside the devbox environment.
- `ws-rust`: `set -euo pipefail` removed from `dbx_init.sh` — init hooks must never
  exit non-zero or shell startup is aborted.
- `ws-rust`: All source files formatted with `cargo fmt` (Toolchain rustfmt) to match
  CI behaviour; resolved divergence between Nix standalone rustfmt and cargo fmt.
- `ws-rust`: `clippy::manual_is_multiple_of` — replaced `n % x == 0` with
  `n.is_multiple_of(x)` per Rust 1.96 clippy lint.
- `ws-rust`: `sieve_count_primes_below_100` test assertion corrected from 24 to 25.
- All files: copyright year updated from 2024 to 2026.

### Changed

- `ws-rust`: All devbox packages pinned to explicit versions (no `latest` tags).
- `ws-rust`: `dbx_init.sh` v2 — OS override loaded before checks; rustfmt and
  rust-analyzer moved to toolchain check block (they come from rustup, not Nix).
- `ws-rust`: Removed redundant Nix packages `rustfmt@1.95.0` and `rust-analyzer@2026-06-01`
  — both are provided by the rustup toolchain via `rust-toolchain.toml` components.
  Pre-commit hooks are unaffected: they use `cargo fmt` (rustup proxy), not the Nix binary.
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

[Unreleased]: https://github.com/RelicFrog/ops-devbox-examples/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/RelicFrog/ops-devbox-examples/compare/v0.1.0...v1.0.1
[0.1.0]: https://github.com/RelicFrog/ops-devbox-examples/releases/tag/v0.1.0
