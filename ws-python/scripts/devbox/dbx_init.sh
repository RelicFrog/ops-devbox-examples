#!/usr/bin/env bash
# ws-python/scripts/devbox/dbx_init.sh
# @copyright 2026 TEAM RelicFrog
# NOTE: no set -euo pipefail — init_hook must never exit non-zero.

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-python}"
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

check_python_toolchain() {
  # python — Nix package, direct binary (NOT system Python)
  if dbx_has python; then
    local py_path; py_path="$(command -v python)"
    local py_ver;  py_ver="$(_version_of python --version)"
    _record "python" ok "${py_ver} (${py_path})"
  else
    _record "python" fail "not found — check devbox.json packages"
    return 0
  fi

  # pytest — Nix package (python313Packages.pytest)
  dbx_has pytest \
    && _record "pytest"   ok "$(_version_of pytest --version)" \
    || _record "pytest"   warn "not found — check devbox.json packages"

  # ruff — Nix package (formatter + linter)
  dbx_has ruff \
    && _record "ruff"     ok "$(_version_of ruff --version)" \
    || _record "ruff"     warn "not found"

  # mypy — Nix package (type checker)
  dbx_has mypy \
    && _record "mypy"     ok "$(_version_of mypy --version)" \
    || _record "mypy"     warn "not found"

  # uv — Nix package (package manager, available for dep management)
  dbx_has uv \
    && _record "uv"       ok "$(_version_of uv --version)" \
    || _record "uv"       warn "not found"
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
  printf '%.0s-' {1..68}; echo
  printf "  ${BLD}%-22s %-4s %s${RST}\n" "Component" "St." "Notes"
  printf '%.0s-' {1..68}; echo
  for key in git curl jq gh python pytest ruff mypy uv make gitleaks; do
    local val; val="$(_get_status "${key}")"
    [[ -z "${val}" ]] && continue
    local code note; IFS='|' read -r code note <<< "${val}"
    case "${code}" in
      ok)   printf "  %-22s ${C_GRN}%-4s${RST} %s\n" "${key}" "$(dbx_icon ok)"   "${note}" ;;
      warn) printf "  %-22s ${C_YLW}%-4s${RST} %s\n" "${key}" "$(dbx_icon warn)" "${note}" ;;
      fail) printf "  %-22s ${C_RED}%-4s${RST} %s\n" "${key}" "$(dbx_icon fail)" "${note}" ;;
    esac
  done
  printf '%.0s-' {1..68}; echo
}

print_help() {
  printf "\n${BLD}${C_BLU}Devbox run commands${RST}\n"
  printf '%.0s-' {1..68}; echo
  printf "  %-14s %s\n" "build"  "make build  — import validation (interpreted)"
  printf "  %-14s %s\n" "check"  "make check  — ruff + mypy + pytest"
  printf "  %-14s %s\n" "fmt"    "make fmt    — ruff format src/ tests/"
  printf "  %-14s %s\n" "lint"   "make lint   — ruff check + mypy"
  printf "  %-14s %s\n" "test"   "make test   — pytest src/ tests/"
  printf "  %-14s %s\n" "audit"  "make audit  — no runtime deps (prints notice)"
  printf "  %-14s %s\n" "clean"  "make clean  — remove __pycache__ etc."
  printf "  %-14s %s\n" "run"    "python -m primes_cli <args>  (direct)"
  printf "  %-14s %s\n" "info"   "print workspace tool versions"
  echo
  printf "  ${DIM}Python path: $(command -v python 2>/dev/null || echo 'not found')${RST}\n\n"
}

dbx_detect_os; dbx_load_os_override
check_core_tools; check_gh
check_python_toolchain; check_build_tools; check_security_tools
print_matrix; print_help
