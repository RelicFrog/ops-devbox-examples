#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-k8s/scripts/devbox/lib/common.sh — Shared library
# @version 1.0.0
# @copyright 2026 TEAM RelicFrog
# -------------------------------------------------------------------
[[ -n "${_DBX_LIB_COMMON_LOADED:-}" ]] && return 0
_DBX_LIB_COMMON_LOADED=1

DBX_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
DBX_SCRIPTS_ROOT="${DBX_REPO_ROOT}/scripts/devbox"

if [[ "${NO_COLOR:-${DBX_NO_COLOR:-0}}" == "1" ]]; then
  RST="" BLD="" DIM=""; C_RED="" C_GRN="" C_YLW="" C_BLU="" C_CYN="" C_GRY=""
else
  RST='\033[0m' BLD='\033[1m' DIM='\033[2m'
  C_RED='\033[31m' C_GRN='\033[32m' C_YLW='\033[33m'
  C_BLU='\033[34m' C_CYN='\033[36m' C_GRY='\033[90m'
fi

: "${DBX_ICON_SET:=ticks}"
dbx_icon() {
  case "${DBX_ICON_SET}:${1}" in
    ticks:ok) printf "+" ;; ticks:fail) printf "x" ;; ticks:warn) printf "!" ;;
    ascii:ok) printf "OK";; ascii:fail) printf "ERR";; ascii:warn) printf "WRN";;
    *)        printf "%s" "$1" ;;
  esac
}

dbx_ok()     { printf "  ${C_GRN}$(dbx_icon ok)${RST}   %-30s %s\n" "$1" "${2:-}"; }
dbx_warn()   { printf "  ${C_YLW}$(dbx_icon warn)${RST}   %-30s %s\n" "$1" "${2:-}"; }
dbx_fail()   { printf "  ${C_RED}$(dbx_icon fail)${RST}   %-30s %s\n" "$1" "${2:-}"; }
dbx_header() { printf "\n${BLD}${C_BLU}%s${RST}\n${DIM}%s${RST}\n" "$1" "$(printf '%.0s-' {1..60})"; }
dbx_die()    { printf "${C_RED}${BLD}ERROR:${RST} %s\n" "$*" >&2; exit 1; }

dbx_detect_os() {
  local u; u="$(uname -a)"
  case "${u}" in
    *Microsoft*|*microsoft*) DBX_OS="wsl"    ;;
    Linux*)                  DBX_OS="linux"  ;;
    Darwin*)                 DBX_OS="darwin" ;;
    *)                       DBX_OS="unknown";;
  esac
  export DBX_OS
}

dbx_load_os_override() {
  local p="${DBX_SCRIPTS_ROOT}/init/os_${DBX_OS}/override.sh"
  [[ -f "${p}" ]] && source "${p}"
}

dbx_has() { command -v "$1" &>/dev/null; }
