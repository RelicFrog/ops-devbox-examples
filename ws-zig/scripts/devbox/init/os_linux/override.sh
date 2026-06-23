#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-go/scripts/devbox/init/os_linux/override.sh
# @purpose Linux-specific environment adjustments for the ws-go workspace.
# -------------------------------------------------------------------

# On Linux CI runners CGO is disabled by default (set in devbox.json env).
# No additional overrides needed for pure Go builds.
: # no-op
