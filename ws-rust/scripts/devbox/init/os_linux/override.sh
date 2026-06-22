#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-rust/scripts/devbox/init/os_linux/override.sh
# @purpose Linux-specific environment adjustments for the ws-rust workspace.
# -------------------------------------------------------------------

# On Linux (including CI runners), use mold for faster linking if available.
if command -v mold &>/dev/null && [[ -z "${RUSTFLAGS:-}" ]]; then
  export RUSTFLAGS="-C link-arg=-fuse-ld=mold"
fi

# Enable sccache if present and not already configured.
if command -v sccache &>/dev/null && [[ -z "${RUSTC_WRAPPER:-}" ]]; then
  export RUSTC_WRAPPER=sccache
fi
