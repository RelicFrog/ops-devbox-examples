# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-go/Dockerfile
#
# Multi-stage build:
#   builder  — go build on golang:1.24-alpine
#   runtime  — scratch (static binary, CGO_ENABLED=0)
#
# Build: docker buildx build -t primes-go:latest .
# Run:   docker run --rm primes-go:latest check 97

# ---------------------------------------------------------------------------
# Stage 1: builder
# ---------------------------------------------------------------------------
FROM golang:1.24-alpine AS builder

WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY src ./src
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -o /primes-cli ./src/cmd/...

# ---------------------------------------------------------------------------
# Stage 2: runtime — busybox:static für Shell + sleep Loop
# ---------------------------------------------------------------------------
FROM busybox:stable-musl AS runtime

LABEL org.opencontainers.image.title="primes-cli (Go)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-go devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

COPY --from=builder /primes-cli /primes-cli

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo 'primes-go ready'; while true; do sleep 3600; done"]
