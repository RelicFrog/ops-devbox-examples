# Contributing

Thank you for considering a contribution to this project.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).
By participating you agree to abide by its terms.

## How to contribute

1. **Open an issue** before starting significant work. This avoids duplicate
   effort and allows discussion of the approach.

2. **Fork the repository** and create a feature branch from `main`.

3. **Follow the conventions** established in each workspace:
   - Rust: `cargo fmt --all` and `cargo clippy --all -- -D warnings` must pass.
   - All workspaces: `make check` must pass before submitting a PR.

4. **Write tests** for new functionality. Unit tests live alongside the source;
   integration tests in the `tests/` directory.

5. **Commit style**: use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).

6. **Open a pull request** against `main`. Fill in the PR template and link
   the related issue.

## Development environment

Each workspace is self-contained. Enter a workspace shell with:

```bash
cd ws-rust   # or another workspace
devbox shell
```

All tooling required for development is provided by the Devbox environment.
No system-level tool installation is required beyond Devbox itself.

## Reporting bugs

Open a GitHub issue with:
- A minimal reproducible example.
- The workspace and operating system version (`uname -a`).
- The Devbox version (`devbox version`).

## Security issues

Do not open a public issue for security vulnerabilities.
See [SECURITY.md](./SECURITY.md) for the responsible disclosure process.
