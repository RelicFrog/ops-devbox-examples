# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-rust/Dockerfile
#
# Multi-stage build:
#   builder  — cargo build --release on rust:slim
#   runtime  — scratch (zero OS, pure static binary)
#
# Build: docker buildx build -t primes-rust:latest .
# Run:   docker run --rm primes-rust:latest check 97

# ---------------------------------------------------------------------------
# Stage 1: builder
# ---------------------------------------------------------------------------
FROM rust:1.96-slim AS builder

WORKDIR /build

# Cache dependencies separately from source
COPY Cargo.toml ./
RUN mkdir -p src && \
    echo 'fn main() {}' > src/main.rs && \
    echo 'pub fn placeholder() {}' > src/lib.rs && \
    cargo build --release && \
    rm -rf src

# Build actual source
COPY src ./src
RUN touch src/main.rs src/lib.rs && \
    cargo build --release

# ---------------------------------------------------------------------------
# Stage 2: runtime — busybox:static für Shell + sleep Loop
# ---------------------------------------------------------------------------
FROM busybox:stable-musl AS runtime

LABEL org.opencontainers.image.title="primes-cli (Rust)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-rust devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

COPY --from=builder /build/target/release/primes-cli /primes-cli

# Default: keep the container alive for kubectl exec invocations.
# Override ENTRYPOINT to run the CLI directly in one-shot mode.
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo 'primes-rust ready'; while true; do sleep 3600; done"]
