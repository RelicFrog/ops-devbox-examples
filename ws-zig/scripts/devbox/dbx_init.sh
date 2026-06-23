#!/usr/bin/env bash
# ws-zig/scripts/devbox/dbx_init.sh — DevBox initialization
# @copyright 2026 TEAM RelicFrog
# NOTE: no set -euo pipefail — init_hook must never exit non-zero.

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-zig}"
: "${C_DBX_META_VERSION:=1}"

_STATUS_KEYS=(); _STATUS_VALS=()
_record() { _STATUS_KEYS+=("$1"); _STATUS_VALS+=("${2}|${3}"); }
_get_status() { local i; for i in "${!_STATUS_KEYS[@]}"; do [[ "${_STATUS_KEYS[$i]}" == "$1" ]] && { echo "${_STATUS_VALS[$i]}"; return; }; done; }
_version_of() { "$@" 2>/dev/null | head -1 || echo "?"; }

check_core_tools() {
  for tool in git curl jq; do
    dbx_has "${tool}" && _record "${tool}" ok "$(command -v "${tool}")" || _record "${tool}" fail "not found"
  done
}

check_gh() {
  if ! dbx_has gh; then _record "gh" warn "not found"; return 0; fi
  gh auth status &>/dev/null && _record "gh" ok "authenticated" || _record "gh" warn "unauthenticated"
}

check_zig_toolchain() {
  if dbx_has zig; then
    _record "zig" ok "$(_version_of zig version)"
  else
    _record "zig" fail "not found — check devbox.json packages"
    return 0
  fi
  if dbx_has zls; then
    _record "zls" ok "$(command -v zls)"
  else
    _record "zls" warn "not found"
  fi
}

check_build_tools() {
  dbx_has make && _record "make" ok "$(_version_of make --version)" || _record "make" fail "not found"
}

check_security_tools() {
  dbx_has gitleaks && _record "gitleaks" ok "$(command -v gitleaks)" || _record "gitleaks" warn "not found"
}

print_matrix() {
  echo
  printf "${BLD}DevBox — %s [%s] v%s${RST} | platform: %s\n" \
    "${C_DBX_META_TEAM}" "${C_DBX_META_PROJECT_ID}" "${C_DBX_META_VERSION}" "${DBX_OS}"
  printf '%.0s-' {1..64}; echo
  printf "  ${BLD}%-22s %-4s %s${RST}\n" "Component" "St." "Notes"
  printf '%.0s-' {1..64}; echo
  for key in git curl jq gh zig zls make gitleaks; do
    local val; val="$(_get_status "${key}")"
    [[ -z "${val}" ]] && continue
    local code note; IFS='|' read -r code note <<< "${val}"
    case "${code}" in
      ok)   printf "  %-22s ${C_GRN}%-4s${RST} %s\n" "${key}" "$(dbx_icon ok)"   "${note}" ;;
      warn) printf "  %-22s ${C_YLW}%-4s${RST} %s\n" "${key}" "$(dbx_icon warn)" "${note}" ;;
      fail) printf "  %-22s ${C_RED}%-4s${RST} %s\n" "${key}" "$(dbx_icon fail)" "${note}" ;;
    esac
  done
  printf '%.0s-' {1..64}; echo
}

print_help() {
  printf "\n${BLD}${C_BLU}Devbox run commands${RST}\n"
  printf '%.0s-' {1..64}; echo
  printf "  %-14s %s\n" "build"  "make build  — zig build-exe -O ReleaseSafe"
  printf "  %-14s %s\n" "check"  "make check  — fmt-check + build + test"
  printf "  %-14s %s\n" "fmt"    "make fmt    — zig fmt src/"
  printf "  %-14s %s\n" "lint"   "make lint   — zig fmt --check src/"
  printf "  %-14s %s\n" "test"   "make test   — zig test (unit + integration)"
  printf "  %-14s %s\n" "clean"  "make clean  — remove zig-out/ zig-cache/"
  printf "  %-14s %s\n" "run"    "zig-out/bin/primes-cli <args>  (no make)"
  printf "  %-14s %s\n" "info"   "print workspace tool versions (no make)"
  echo
  printf "  ${DIM}Usage: devbox run <command>${RST}\n\n"
  printf "  ${DIM}Note: macOS + Nix requires -target aarch64-macos.15.0${RST}\n"
  printf "  ${DIM}       (auto-detected by Makefile; see ZIG_TARGET)${RST}\n\n"
}

dbx_detect_os
dbx_load_os_override
check_core_tools
check_gh
check_zig_toolchain
check_build_tools
check_security_tools
print_matrix
print_help
