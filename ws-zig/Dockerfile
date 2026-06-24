# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-zig/Dockerfile
#
# Multi-stage build:
#   builder  — debian:bookworm-slim + zig 0.13.0 from ziglang.org (arm64)
#   runtime  — alpine:3.21 (musl libc for the Zig binary)
#
# No unofficial third-party Zig images — downloads directly from ziglang.org.

ARG ZIG_VERSION=0.13.0
ARG ZIG_ARCH=aarch64

# ---------------------------------------------------------------------------
# Stage 1: builder
# ---------------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

ARG ZIG_VERSION
ARG ZIG_ARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
      "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz" \
      -o /tmp/zig.tar.xz \
    && tar -xJf /tmp/zig.tar.xz -C /usr/local \
    && ln -s "/usr/local/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}/zig" /usr/local/bin/zig \
    && rm /tmp/zig.tar.xz \
    && zig version

WORKDIR /build

COPY src/ ./src/
COPY build.zig ./

RUN zig build -Doptimize=ReleaseSafe -Dtarget=${ZIG_ARCH}-linux-musl

# ---------------------------------------------------------------------------
# Stage 2: runtime — alpine:3.21 (musl libc)
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
