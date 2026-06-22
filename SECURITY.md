# Security Policy

## Supported versions

| Workspace        | Supported |
|------------------|-----------|
| ws-rust (latest) | yes       |

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Please report security issues by email to:
**patrick@relicfrog.rocks**

Include in your report:
- A description of the vulnerability.
- Steps to reproduce.
- Potential impact.
- Any suggested mitigations.

You will receive an acknowledgment within 48 hours and a resolution
timeline within 7 days.

## Security considerations for this repository

This repository contains example code for educational purposes.
The applications are not intended for production deployment without
a thorough security review.

- No secrets, credentials, or API keys are committed to this repository.
- Dependencies are audited via `cargo audit` / `make audit` in the Rust workspace.
- The CI pipeline runs `gitleaks` on every push to detect accidental secret commits.
