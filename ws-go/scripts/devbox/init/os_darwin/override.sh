#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-go/scripts/devbox/init/os_darwin/override.sh
# @purpose macOS-specific environment adjustments for the ws-go workspace.
# -------------------------------------------------------------------

# On Darwin, CGO is disabled by default (set in devbox.json env).
# No additional overrides needed for pure Go builds.
: # no-op
