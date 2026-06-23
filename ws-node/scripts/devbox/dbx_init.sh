#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-node/scripts/devbox/dbx_init.sh — DevBox initialization
# @version 1
# @copyright 2026 TEAM RelicFrog
# @author Patrick Paechnatz <patrick@relicfrog.rocks>
# @purpose Detect environment, validate Node.js tooling, load OS overrides,
#          display preflight status matrix.
# -------------------------------------------------------------------
# NOTE: intentionally NO 'set -euo pipefail' here.
# This script runs as the devbox init_hook; any non-zero exit aborts
# shell startup. All error handling is done explicitly per check.
# -------------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-node}"
: "${C_DBX_META_VERSION:=1}"

_STATUS_KEYS=()
_STATUS_VALS=()

_record() { _STATUS_KEYS+=("$1"); _STATUS_VALS+=("${2}|${3}"); }

_get_status() {
  local i
  for i in "${!_STATUS_KEYS[@]}"; do
    [[ "${_STATUS_KEYS[$i]}" == "$1" ]] && { echo "${_STATUS_VALS[$i]}"; return; }
  done
}

_version_of() {
  local out
  out="$("$@" 2>/dev/null | head -1)" && echo "${out}" || echo "?"
}

# -------------------------------------------------------------------
# Checks
# -------------------------------------------------------------------

check_core_tools() {
  local tool path
  for tool in git curl jq; do
    if dbx_has "${tool}"; then
      path="$(command -v "${tool}")"
      _record "${tool}" ok "${path}"
    else
      _record "${tool}" fail "not found — check devbox.json packages"
    fi
  done
}

check_gh() {
  if ! dbx_has gh; then
    _record "gh" warn "not found"
    return 0
  fi
  if gh auth status &>/dev/null; then
    _record "gh" ok "authenticated"
  else
    _record "gh" warn "unauthenticated — run: gh auth login"
  fi
}

check_node_toolchain() {
  # node — Nix package, direct binary
  if dbx_has node; then
    _record "node" ok "$(_version_of node --version)"
  else
    _record "node" fail "not found — check devbox.json packages"
    return 0
  fi

  # npm ships with nodejs Nix package
  if dbx_has npm; then
    _record "npm" ok "$(_version_of npm --version)"
  else
    _record "npm" warn "not found (should ship with nodejs package)"
  fi
}

check_node_tools() {
  # tsx — TypeScript executor, Nix package
  if dbx_has tsx; then
    _record "tsx" ok "$(_version_of tsx --version)"
  else
    _record "tsx" warn "not found — check devbox.json packages"
  fi

  # tsc — TypeScript compiler, Nix package
  if dbx_has tsc; then
    _record "tsc" ok "$(_version_of tsc --version)"
  else
    _record "tsc" warn "not found — check devbox.json packages"
  fi

  # biome — formatter + linter, Nix package
  if dbx_has biome; then
    _record "biome" ok "$(_version_of biome --version)"
  else
    _record "biome" warn "not found — check devbox.json packages"
  fi
}

check_build_tools() {
  if dbx_has make; then
    _record "make" ok "$(_version_of make --version)"
  else
    _record "make" fail "not found — add gnumake to devbox.json packages"
  fi
}

check_security_tools() {
  if dbx_has gitleaks; then
    _record "gitleaks" ok "$(command -v gitleaks)"
  else
    _record "gitleaks" warn "not found — check devbox.json packages"
  fi
}

# -------------------------------------------------------------------
# Matrix renderer
# -------------------------------------------------------------------

print_matrix() {
  echo
  printf "${BLD}DevBox — %s [%s] v%s${RST} | platform: %s\n" \
    "${C_DBX_META_TEAM}" "${C_DBX_META_PROJECT_ID}" "${C_DBX_META_VERSION}" "${DBX_OS}"
  printf '%.0s-' {1..64}; echo
  printf "  ${BLD}%-22s %-4s %s${RST}\n" "Component" "St." "Notes"
  printf '%.0s-' {1..64}; echo

  local ordered_keys=(
    git curl jq gh
    node npm
    tsx tsc biome
    make
    gitleaks
  )

  local key val code note
  for key in "${ordered_keys[@]}"; do
    val="$(_get_status "${key}")"
    [[ -z "${val}" ]] && continue
    IFS='|' read -r code note <<< "${val}"
    case "${code}" in
      ok)   printf "  %-22s ${C_GRN}%-4s${RST} %s\n" "${key}" "$(dbx_icon ok)"   "${note}" ;;
      warn) printf "  %-22s ${C_YLW}%-4s${RST} %s\n" "${key}" "$(dbx_icon warn)" "${note}" ;;
      fail) printf "  %-22s ${C_RED}%-4s${RST} %s\n" "${key}" "$(dbx_icon fail)" "${note}" ;;
    esac
  done

  printf '%.0s-' {1..64}; echo
}

# -------------------------------------------------------------------
# Help
# -------------------------------------------------------------------

print_help() {
  printf "\n${BLD}${C_BLU}Devbox run commands${RST}\n"
  printf '%.0s-' {1..64}; echo
  printf "  %-14s %s\n" "build"  "make build  — tsc --project tsconfig.json"
  printf "  %-14s %s\n" "check"  "make check  — biome check + tsc + node:test"
  printf "  %-14s %s\n" "fmt"    "make fmt    — biome format --write"
  printf "  %-14s %s\n" "lint"   "make lint   — biome lint + tsc --noEmit"
  printf "  %-14s %s\n" "test"   "make test   — node --test (node:test built-in)"
  printf "  %-14s %s\n" "audit"  "make audit  — no npm deps, prints notice"
  printf "  %-14s %s\n" "clean"  "make clean  — remove dist/"
  printf "  %-14s %s\n" "run"    "tsx src/main.ts <args>   (direct, no make)"
  printf "  %-14s %s\n" "info"   "print workspace tool versions (no make)"
  echo
  printf "  ${DIM}Usage: devbox run <command>${RST}\n\n"
}

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------
dbx_detect_os
dbx_load_os_override

check_core_tools
check_gh
check_node_toolchain
check_node_tools
check_build_tools
check_security_tools

print_matrix
print_help
