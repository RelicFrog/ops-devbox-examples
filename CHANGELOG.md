# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/RelicFrog/ops-devbox-examples/compare/HEAD
