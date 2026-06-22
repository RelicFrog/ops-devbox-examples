#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-rust/scripts/devbox/init/os_darwin/override.sh
# @purpose macOS-specific environment adjustments for the ws-rust workspace.
# -------------------------------------------------------------------

# mold is not available on Darwin — use the default macOS linker (ld).
# Ensure RUSTFLAGS does not contain a mold reference if set from a parent shell.
if [[ "${RUSTFLAGS:-}" == *mold* ]]; then
  unset RUSTFLAGS
fi

# On Apple Silicon the sccache compiler cache may be useful but is optional.
# Enable it only if sccache is present and not already configured.
if command -v sccache &>/dev/null && [[ -z "${RUSTC_WRAPPER:-}" ]]; then
  export RUSTC_WRAPPER=sccache
fi
