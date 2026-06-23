# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-lua/Dockerfile — Multi-stage: luajit builder check + luajit:alpine runtime

FROM alpine:3.21 AS runtime

LABEL org.opencontainers.image.title="primes-cli (Lua)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-lua devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

RUN apk add --no-cache luajit

WORKDIR /app
COPY src/ ./src/

RUN printf '#!/bin/sh\nexec luajit /app/src/main.lua "$@"\n' \
      > /usr/local/bin/primes-cli && \
    chmod +x /usr/local/bin/primes-cli && \
    LUA_PATH="/app/src/?.lua;;" luajit -e "require('primes')" && \
    echo "Lua source validated."

ENV LUA_PATH="/app/src/?.lua;;"

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["tail -f /dev/null"]
