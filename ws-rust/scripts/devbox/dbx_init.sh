#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-rust/scripts/devbox/dbx_init.sh — DevBox initialization
# @version 2
# @copyright 2026 TEAM RelicFrog
# @author Patrick Paechnatz <patrick@relicfrog.rocks>
# @purpose Detect environment, validate Rust tooling, load OS overrides,
#          display preflight status matrix.
# -------------------------------------------------------------------
# NOTE: intentionally NO 'set -euo pipefail' here.
#
# This script runs as the devbox init_hook, which means it is sourced
# into the interactive shell startup sequence. Any non-zero exit from a
# subcommand would abort the shell initialization entirely — the user
# would be left with a broken, unusable devbox shell.
#
# All error handling is done explicitly per check: unknown / missing
# tools are recorded as warn/fail in the status matrix and reported
# to the user, but never cause the hook to exit non-zero.
# -------------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# -------------------------------------------------------------------
# Metadata (injected from devbox.json env vars)
# -------------------------------------------------------------------
: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-rust}"
: "${C_DBX_META_VERSION:=2}"

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

# Safe version query: returns the version string or "?" — never exits non-zero.
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
  # gh auth status exits 1 when unauthenticated — that is expected and not an error.
  if gh auth status &>/dev/null; then
    _record "gh" ok "authenticated"
  else
    _record "gh" warn "unauthenticated — run: gh auth login"
  fi
}

check_rust_toolchain() {
  # --- rustup (Nix package) ---
  # rustup is present as a Nix package as soon as devbox packages are installed.
  if ! dbx_has rustup; then
    _record "rustup" fail "not found — missing from devbox.json packages"
    _record "rustc"  warn "skipped (rustup missing)"
    _record "cargo"  warn "skipped (rustup missing)"
    return 0
  fi
  _record "rustup" ok "$(_version_of rustup --version)"

  # --- rustc / cargo ---
  # Important: rustup (Nix) only provides the rustup binary itself.
  # The actual toolchain (rustc, cargo) is installed by rustup into
  # ~/.rustup/toolchains/ and is NOT part of the Nix store.
  #
  # On a fresh checkout the toolchain may not be installed yet.
  # rust-toolchain.toml triggers automatic installation when cargo/rustc
  # is first invoked — but NOT during the devbox init_hook itself.
  #
  # Therefore: treat missing rustc/cargo as a warn (not fail) and give
  # the user an actionable hint.
  if dbx_has rustc; then
    _record "rustc" ok "$(_version_of rustc --version)"
  else
    _record "rustc" warn "toolchain not yet active — will install on first 'cargo build'"
  fi

  if dbx_has cargo; then
    _record "cargo" ok "$(_version_of cargo --version)"
  else
    _record "cargo" warn "toolchain not yet active — will install on first 'cargo build'"
  fi
}

check_cargo_tools() {
  # cargo-nextest   → binary: cargo-nextest
  # cargo-audit     → binary: cargo-audit
  # cargo-deny      → binary: cargo-deny
  # grcov           → binary: grcov
  # rust-analyzer   → binary: rust-analyzer
  # rustfmt         → binary: rustfmt  (Nix package, standalone)
  #
  # All are Nix packages and should be present once devbox packages are
  # installed. A missing entry here indicates a devbox.json mismatch.
  local tool
  for tool in rustfmt cargo-nextest cargo-audit cargo-deny grcov rust-analyzer; do
    if dbx_has "${tool}"; then
      _record "${tool}" ok "$(command -v "${tool}")"
    else
      _record "${tool}" warn "not found — check devbox.json packages"
    fi
  done
}

check_build_tools() {
  # gnumake — Nix package; should always be present inside devbox shell.
  if dbx_has make; then
    _record "make" ok "$(_version_of make --version)"
  else
    _record "make" fail "not found — add gnumake to devbox.json packages"
  fi

  # mold — Linux-only linker; explicitly excluded on Darwin via devbox.json
  # platforms field. Report that exclusion as informational (ok), not a warning.
  if [[ "${DBX_OS}" == "darwin" ]]; then
    _record "mold" ok "platform-excluded on Darwin (expected)"
  elif dbx_has mold; then
    _record "mold" ok "$(_version_of mold --version)"
  else
    _record "mold" warn "not found on Linux — check devbox.json packages"
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
    rustup rustc cargo
    rustfmt cargo-nextest cargo-audit cargo-deny grcov rust-analyzer
    make mold
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
  printf "  %-14s %s\n" "build"  "make build  — cargo build --release"
  printf "  %-14s %s\n" "check"  "make check  — fmt-check + clippy + nextest"
  printf "  %-14s %s\n" "fmt"    "make fmt    — cargo fmt --all"
  printf "  %-14s %s\n" "lint"   "make lint   — cargo clippy -D warnings"
  printf "  %-14s %s\n" "test"   "make test   — cargo nextest run --all"
  printf "  %-14s %s\n" "audit"  "make audit  — cargo audit + cargo deny check"
  printf "  %-14s %s\n" "clean"  "make clean  — cargo clean"
  printf "  %-14s %s\n" "run"    "cargo run -- <args>   (direct, no make)"
  printf "  %-14s %s\n" "info"   "print workspace tool versions (no make)"
  echo
  printf "  ${DIM}Usage: devbox run <command>${RST}\n\n"
}

# -------------------------------------------------------------------
# Main — order matters:
#   1. detect OS first (needed by check_build_tools and os_override)
#   2. load OS override (sets RUSTFLAGS etc. before checks run)
#   3. run checks
#   4. render output
# -------------------------------------------------------------------
dbx_detect_os
dbx_load_os_override

check_core_tools
check_gh
check_rust_toolchain
check_cargo_tools
check_build_tools
check_security_tools

print_matrix
print_help
