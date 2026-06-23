#!/usr/bin/env bash
# -------------------------------------------------------------------
# ws-k8s/scripts/devbox/dbx_init.sh — DevBox initialization
# @version 1
# @copyright 2026 TEAM RelicFrog
# @author Patrick Paechnatz <patrick@relicfrog.rocks>
# @purpose Validate k8s tooling, check Docker host service, check
#          OrbStack cluster reachability, display preflight matrix.
# -------------------------------------------------------------------
# NOTE: no set -euo pipefail — init_hook must never exit non-zero.
# -------------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

: "${C_DBX_META_TEAM:=RelicFrog}"
: "${C_DBX_META_PROJECT_ID:=ops-devbox-examples/ws-k8s}"
: "${C_DBX_META_VERSION:=1}"

_STATUS_KEYS=(); _STATUS_VALS=()
_record() { _STATUS_KEYS+=("$1"); _STATUS_VALS+=("${2}|${3}"); }
_get_status() {
  local i
  for i in "${!_STATUS_KEYS[@]}"; do
    [[ "${_STATUS_KEYS[$i]}" == "$1" ]] && { echo "${_STATUS_VALS[$i]}"; return; }
  done
}
_version_of() { "$@" 2>/dev/null | head -1 || echo "?"; }

# -------------------------------------------------------------------
# Checks
# -------------------------------------------------------------------

check_core_tools() {
  for tool in git curl jq; do
    dbx_has "${tool}" \
      && _record "${tool}" ok "$(command -v "${tool}")" \
      || _record "${tool}" fail "not found"
  done
}

check_gh() {
  if ! dbx_has gh; then _record "gh" warn "not found"; return 0; fi
  gh auth status &>/dev/null \
    && _record "gh" ok "authenticated" \
    || _record "gh" warn "unauthenticated — run: gh auth login"
}

check_k8s_tools() {
  # kubectl — Nix package
  if dbx_has kubectl; then
    local ver; ver="$(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' 2>/dev/null || echo '?')"
    _record "kubectl" ok "${ver}"
  else
    _record "kubectl" fail "not found — check devbox.json"
  fi

  # k9s — Nix package
  dbx_has k9s \
    && _record "k9s" ok "$(_version_of k9s version --short)" \
    || _record "k9s" warn "not found"

  # kubectx / kubens — same Nix package
  dbx_has kubectx \
    && _record "kubectx" ok "$(command -v kubectx)" \
    || _record "kubectx" warn "not found"

  dbx_has kubens \
    && _record "kubens" ok "$(command -v kubens)" \
    || _record "kubens" warn "not found"

  # kustomize — Nix package
  dbx_has kustomize \
    && _record "kustomize" ok "$(_version_of kustomize version)" \
    || _record "kustomize" warn "not found"

  # helm — Nix package (kubernetes-helm)
  dbx_has helm \
    && _record "helm" ok "$(_version_of helm version --short)" \
    || _record "helm" warn "not found"

  # stern — Nix package
  dbx_has stern \
    && _record "stern" ok "$(_version_of stern --version)" \
    || _record "stern" warn "not found"

  # yq — Nix package (yq-go)
  dbx_has yq \
    && _record "yq" ok "$(_version_of yq --version)" \
    || _record "yq" warn "not found"

  # trivy — Nix package
  dbx_has trivy \
    && _record "trivy" ok "$(_version_of trivy --version)" \
    || _record "trivy" warn "not found"
}

check_docker() {
  # Docker is a HOST-level service (OrbStack / Docker Desktop).
  # It is NOT installed by devbox. We check for it as a prerequisite.
  if ! dbx_has docker; then
    _record "docker" warn "not in PATH — start OrbStack or Docker Desktop"
    return 0
  fi

  # Daemon reachability check (does not require sudo on macOS with OrbStack)
  if docker info &>/dev/null; then
    local ver; ver="$(docker version --format '{{.Client.Version}}' 2>/dev/null || echo '?')"
    _record "docker" ok "v${ver} (host service)"
  else
    _record "docker" warn "CLI found but daemon unreachable — is OrbStack running?"
  fi
}

check_cluster() {
  # Check if a k8s cluster is reachable via the current kubeconfig context.
  if ! dbx_has kubectl; then
    _record "cluster" warn "kubectl missing — skipped"
    return 0
  fi

  local ctx; ctx="$(kubectl config current-context 2>/dev/null || echo '')"
  if [[ -z "${ctx}" ]]; then
    _record "cluster" warn "no kubeconfig context — run OrbStack or set KUBECONFIG"
    return 0
  fi

  if kubectl cluster-info &>/dev/null; then
    _record "cluster" ok "context: ${ctx}"
  else
    _record "cluster" warn "context '${ctx}' set but cluster unreachable"
  fi
}

# -------------------------------------------------------------------
# Matrix renderer
# -------------------------------------------------------------------

print_matrix() {
  echo
  printf "${BLD}DevBox — %s [%s] v%s${RST} | platform: %s\n" \
    "${C_DBX_META_TEAM}" "${C_DBX_META_PROJECT_ID}" "${C_DBX_META_VERSION}" "${DBX_OS}"
  printf '%.0s-' {1..68}; echo
  printf "  ${BLD}%-22s %-4s %s${RST}\n" "Component" "St." "Notes"
  printf '%.0s-' {1..68}; echo

  local ordered_keys=(
    git curl jq gh
    kubectl k9s kubectx kubens
    kustomize helm stern yq trivy
    docker
    cluster
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

  printf '%.0s-' {1..68}; echo
}

# -------------------------------------------------------------------
# Help
# -------------------------------------------------------------------

print_help() {
  printf "\n${BLD}${C_BLU}Devbox run commands${RST}\n"
  printf '%.0s-' {1..68}; echo
  printf "  %-18s %s\n" "build-all"   "docker buildx build all three primes images"
  printf "  %-18s %s\n" "deploy-all"  "kubectl apply all manifests + wait for Ready"
  printf "  %-18s %s\n" "status"      "kubectl get pods/services in primes-workshop ns"
  printf "  %-18s %s\n" "logs-rust"   "stern logs — primes-rust pods"
  printf "  %-18s %s\n" "logs-go"     "stern logs — primes-go pods"
  printf "  %-18s %s\n" "logs-node"   "stern logs — primes-node pods"
  printf "  %-18s %s\n" "teardown"    "delete namespace + all primes-* resources"
  printf "  %-18s %s\n" "info"        "print workspace tool versions"
  printf "  %-18s %s\n" "docs"        "glow --pager README.md"
  echo
  printf "  ${DIM}Direct kubectl exec wrappers (inside devbox shell):${RST}\n"
  printf "  %-18s %s\n" "bin/primes-rust"  "primes-rust check 97"
  printf "  %-18s %s\n" "bin/primes-go"    "primes-go nth 100"
  printf "  %-18s %s\n" "bin/primes-node"  "primes-node list --to 20"
  echo
  printf "  ${DIM}Usage: devbox run <command> | make <target>${RST}\n\n"
}

# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------
dbx_detect_os
dbx_load_os_override

check_core_tools
check_gh
check_k8s_tools
check_docker
check_cluster

print_matrix
print_help
