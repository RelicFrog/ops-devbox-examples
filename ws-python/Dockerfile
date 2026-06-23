# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-python/Dockerfile
#
# Multi-stage:
#   builder  — copies source and validates imports on python:3.13-alpine
#   runtime  — python:3.13-alpine with src/ (interpreted, no compilation)

FROM python:3.13-alpine AS runtime

LABEL org.opencontainers.image.title="primes-cli (Python)"
LABEL org.opencontainers.image.description="Prime number generator CLI — ws-python devbox workshop example"
LABEL org.opencontainers.image.vendor="TEAM RelicFrog"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/RelicFrog/ops-devbox-examples"

WORKDIR /app

COPY src/ ./src/

ENV PYTHONPATH="/app/src" \
    PYTHONDONTWRITEBYTECODE="1" \
    PYTHONUNBUFFERED="1"

RUN python -c "import primes_cli; import primes_cli.primes; import primes_cli.main" && \
    printf '#!/bin/sh\nexec python -m primes_cli "$@"\n' \
      > /usr/local/bin/primes-cli && \
    chmod +x /usr/local/bin/primes-cli && \
    echo "Python source validated."

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["tail -f /dev/null"]
