# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-zig/Dockerfile
#
# Multi-stage build:
#   builder  — zig build-exe on zig:0.13 (Alpine, arm64-native, no SDK issue)
#   runtime  — alpine:3.21 (musl libc for the Zig binary)
#
# Note: uses zig:0.13 official image which resolves the macOS SDK issue
# by building on Linux where the issue does not exist.

# ---------------------------------------------------------------------------
# Stage 1: builder
# ---------------------------------------------------------------------------
FROM ghcr.io/euantorano/zig:0.13.0 AS builder

WORKDIR /build

COPY src/ ./src/
COPY build.zig ./

RUN zig build -Doptimize=ReleaseSafe -Dtarget=aarch64-linux-musl

# ---------------------------------------------------------------------------
# Stage 2: runtime — alpine (provides musl libc)
# ---------------------------------------------------------------------------
FROM alpine:3.21 AS runtime

LABEL org.opencontainers.image.title="primes-cli (Zig)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-zig devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

COPY --from=builder /build/zig-out/bin/primes-cli /primes-cli

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["tail -f /dev/null"]
