#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-go/scripts/devbox/dbx_init.sh — DevBox initialization
# @version 1
# @copyright 2026 TEAM RelicFrog
# @author Patrick Paechnatz <patrick@relicfrog.rocks>
# @purpose Detect environment, validate Go tooling, load OS overrides,
#          display preflight status matrix.
# -------------------------------------------------------------------
# NOTE: intentionally NO 'set -euo pipefail' here.
#
# This script runs as the devbox init_hook, which means it is sourced
# into the interactive shell startup sequence. Any non-zero exit from a
# subcommand would abort the shell initialization entirely.
# All error handling is done explicitly per check.
# -------------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# -------------------------------------------------------------------
# Metadata (injected from devbox.json env vars)
# -------------------------------------------------------------------
: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-go}"
: "${C_DBX_META_VERSION:=1}"

# -------------------------------------------------------------------
# Status registry (bash 3.x compatible — parallel arrays)
# -------------------------------------------------------------------
_STATUS_KEYS=()
_STATUS_VALS=()

_record() { _STATUS_KEYS+=("$1"); _STATUS_VALS+=("${2}|${3}"); }

_get_status() {
  local i
  for i in "${!_STATUS_KEYS[@]}"; do
    [[ "${_STATUS_KEYS[$i]}" == "$1" ]] && { echo "${_STATUS_VALS[$i]}"; return; }
  done
}

# Safe version query — never exits non-zero.
_version_of() {
  local out
  out="$("$@" 2>/dev/null | head -1)" && echo "${out}" || echo "?"
}

# -------------------------------------------------------------------
# Preflight checks
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

check_go_toolchain() {
  # go — Nix package; version pinned in devbox.json
  if dbx_has go; then
    _record "go" ok "$(_version_of go version)"
  else
    _record "go" fail "not found — check devbox.json packages"
    return 0
  fi

  # gofmt ships with the Go distribution itself (same Nix package)
  if dbx_has gofmt; then
    _record "gofmt" ok "$(command -v gofmt)"
  else
    _record "gofmt" warn "not found (should ship with go package)"
  fi
}

check_go_tools() {
  # gofumpt — stricter gofmt superset, Nix package
  if dbx_has gofumpt; then
    _record "gofumpt" ok "$(_version_of gofumpt --version)"
  else
    _record "gofumpt" warn "not found — check devbox.json packages"
  fi

  # golangci-lint — meta-linter, Nix package
  if dbx_has golangci-lint; then
    _record "golangci-lint" ok "$(_version_of golangci-lint --version)"
  else
    _record "golangci-lint" warn "not found — check devbox.json packages"
  fi

  # govulncheck — vulnerability scanner, Nix package
  if dbx_has govulncheck; then
    _record "govulncheck" ok "$(command -v govulncheck)"
  else
    _record "govulncheck" warn "not found — check devbox.json packages"
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
    go gofmt
    gofumpt golangci-lint govulncheck
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
  printf "  %-14s %s\n" "build"  "make build  — go build -trimpath"
  printf "  %-14s %s\n" "check"  "make check  — fmt-check + lint + test"
  printf "  %-14s %s\n" "fmt"    "make fmt    — gofumpt -w ./src"
  printf "  %-14s %s\n" "lint"   "make lint   — golangci-lint run"
  printf "  %-14s %s\n" "test"   "make test   — go test -race -count=1"
  printf "  %-14s %s\n" "audit"  "make audit  — go mod verify + govulncheck"
  printf "  %-14s %s\n" "clean"  "make clean  — remove bin/ + test cache"
  printf "  %-14s %s\n" "run"    "go run ./src/... <args>   (direct, no make)"
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
check_go_toolchain
check_go_tools
check_build_tools
check_security_tools

print_matrix
print_help
