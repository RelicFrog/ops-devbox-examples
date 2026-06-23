# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-node/Dockerfile
#
# Multi-stage build:
#   builder  — tsc compile on node:22-alpine
#   runtime  — node:22-alpine (minimal, no build tools)
#
# Build: docker buildx build -t primes-node:latest .
# Run:   docker run --rm primes-node:latest check 97

# ---------------------------------------------------------------------------
# Stage 1: builder — compile TypeScript to JavaScript
# ---------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /build

COPY package.json package-lock.json tsconfig.json ./
RUN npm ci --ignore-scripts 2>/dev/null || npm install --save-dev @types/node typescript

COPY src ./src
RUN ./node_modules/.bin/tsc --project tsconfig.json

# ---------------------------------------------------------------------------
# Stage 2: runtime — lean node:22-alpine with compiled JS only
# ---------------------------------------------------------------------------
FROM node:22-alpine AS runtime

LABEL org.opencontainers.image.title="primes-cli (Node.js)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-node devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

WORKDIR /app

COPY --from=builder /build/dist ./dist

# Thin wrapper so the container behaves like a native CLI
COPY --from=builder /build/package.json ./

RUN printf '#!/bin/sh\nexec node /app/dist/main.js "$@"\n' > /usr/local/bin/primes-cli && \
    chmod +x /usr/local/bin/primes-cli

ENTRYPOINT ["/usr/local/bin/primes-cli"]
CMD ["help"]
