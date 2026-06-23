# ws-k8s — Kubernetes Workshop

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../LICENSE)
[![Devbox](https://img.shields.io/badge/devbox-ready-5C5CFF?logo=nixos&logoColor=white)](https://www.jetify.com/devbox)
[![Platform](https://img.shields.io/badge/platform-macOS%20ARM64%20%2F%20OrbStack-lightgrey?logo=apple)](https://orbstack.dev)
[![Kubernetes](https://img.shields.io/badge/kubernetes-local%20OrbStack-326CE5?logo=kubernetes&logoColor=white)](https://orbstack.dev/kubernetes)

Kubernetes workspace for the [ops-devbox-examples](../) repository.
Demonstrates a reproducible devbox environment with a full k8s toolchain,
containerised versions of the three `primes-cli` applications (Rust, Go,
Node.js), and `kubectl exec` wrappers that let you call each CLI from inside
its running pod — as if it were a local binary.

**Target:** local single-node Kubernetes cluster provided by OrbStack.
No cloud account, no registry push — images are built and loaded directly
into the local Docker context.

---

## Table of contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
- [Workflow: build → deploy → exec](#workflow-build--deploy--exec)
- [kubectl exec wrappers](#kubectl-exec-wrappers)
- [Project structure](#project-structure)
- [Devbox environment](#devbox-environment)
- [Makefile targets](#makefile-targets)

---

## Architecture

```
OrbStack (1-node k8s)
  └── namespace: primes-workshop
        ├── deployment/primes-rust   ← busybox + /primes-cli  (Rust static binary)
        ├── deployment/primes-go     ← busybox + /primes-cli  (Go static binary)
        └── deployment/primes-node   ← node:22-alpine + /usr/local/bin/primes-cli

ws-k8s/bin/
  ├── primes-rust   ← kubectl exec → pod → /primes-cli $@
  ├── primes-go     ← kubectl exec → pod → /primes-cli $@
  └── primes-node   ← kubectl exec → pod → /usr/local/bin/primes-cli $@
```

Each pod runs a long-lived `sleep` loop (via the image's default CMD)
so it stays alive between exec calls. The `primes-cli` binary is
invoked on demand via `kubectl exec` — no HTTP server, no port, no
service endpoint. Pure CLI-in-a-box.

### Container images

| Image | Base | Binary path | Build |
|-------|------|------------|-------|
| `primes-rust:latest` | `busybox:stable-musl` | `/primes-cli` | `make docker-build` in `ws-rust/` |
| `primes-go:latest` | `busybox:stable-musl` | `/primes-cli` | `make docker-build` in `ws-go/` |
| `primes-node:latest` | `node:22-alpine` | `/usr/local/bin/primes-cli` | `make docker-build` in `ws-node/` |

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| [OrbStack](https://orbstack.dev) | Provides Docker daemon + local k8s cluster |
| Kubernetes enabled in OrbStack | Settings → Kubernetes → Enable |
| `docker` in PATH | Provided by OrbStack (host service, not Nix) |
| [Devbox](https://www.jetify.com/devbox) >= 0.13 | k8s toolchain management |

> Docker is a **host-level prerequisite**. It is not installed by devbox
> because OrbStack already provides the daemon and CLI. The devbox init
> script checks for `docker` in PATH and reports its status.

---

## Getting started

```bash
cd ws-k8s
devbox shell
```

The init hook displays a preflight matrix covering all k8s tools, Docker
daemon reachability, and the current cluster context.

---

## Workflow: build → deploy → exec

### 1. Build all container images

```bash
# From ws-k8s/ (calls make docker-build in each ws-*)
make build-all

# Or build individually
make build-rust
make build-go
make build-node
```

### 2. Deploy to local OrbStack cluster

```bash
make deploy-all
# Creates namespace primes-workshop, applies all deployments,
# waits for pods to become Ready.
```

### 3. Check status

```bash
make status
# kubectl get pods,deployments,services -n primes-workshop
```

### 4. Execute CLI commands inside pods

```bash
# Via make exec-* (set ARGS to pass arguments)
make exec-rust ARGS="check 97"
make exec-go   ARGS="nth 100"
make exec-node ARGS="list --to 20"

# Or use the bin/ wrappers directly (added to PATH by devbox.json)
primes-rust check 97
primes-go   range --from 10 --to 50
primes-node nth 100
```

### 5. View logs

```bash
make logs-rust    # stern --selector app=primes-rust
make logs-go
make logs-node
```

### 6. Teardown

```bash
make teardown
# kubectl delete namespace primes-workshop
```

---

## kubectl exec wrappers

The scripts in `bin/` make the in-pod CLIs feel like local commands.
All are added to `PATH` by `devbox.json`:

```bash
primes-rust check 97
# → kubectl exec <primes-rust-pod> -- /primes-cli check 97
# → 97 is prime

primes-go nth 100
# → kubectl exec <primes-go-pod> -- /primes-cli nth 100
# → 541

primes-node list --to 20
# → kubectl exec <primes-node-pod> -- /usr/local/bin/primes-cli list --to 20
# → 2 3 5 7 11 13 17 19
```

Each wrapper:
1. Looks up the running pod name via `kubectl get pod --selector app=primes-<lang>`
2. Fails with a clear error if no pod is running
3. Forwards all arguments verbatim via `kubectl exec`

---

## Project structure

```
ws-k8s/
├── devbox.json                  # Pinned k8s tools (kubectl, k9s, helm, …)
├── Makefile                     # build-all / deploy-all / exec-* / teardown
├── bin/
│   ├── primes-rust              # kubectl exec wrapper → primes-rust pod
│   ├── primes-go                # kubectl exec wrapper → primes-go pod
│   └── primes-node              # kubectl exec wrapper → primes-node pod
├── manifests/
│   ├── rust/
│   │   ├── namespace.yaml       # primes-workshop namespace
│   │   └── deployment.yaml      # primes-rust Deployment
│   ├── go/
│   │   └── deployment.yaml      # primes-go Deployment
│   └── node/
│       └── deployment.yaml      # primes-node Deployment
└── scripts/devbox/
    ├── dbx_init.sh              # Preflight: k8s tools, Docker, cluster
    ├── lib/common.sh
    └── init/os_{darwin,linux}/override.sh

# Dockerfiles live in their respective workspaces:
ws-rust/Dockerfile               # busybox + Rust static binary
ws-go/Dockerfile                 # busybox + Go static binary
ws-node/Dockerfile               # node:22-alpine + compiled JS
```

---

## Devbox environment

All k8s tooling comes directly from the Nix store. Docker is explicitly
**not** in the Nix packages — it is provided by OrbStack on the host.

### Pinned packages

| Package | Version | Purpose |
|---------|---------|---------|
| `kubectl` | 1.36.1 | Kubernetes CLI |
| `k9s` | 0.51.0 | Terminal cluster UI |
| `kubectx` | 0.11.0 | Context switcher (`kubectx` + `kubens`) |
| `kustomize` | 5.8.1 | YAML patching and overlays |
| `kubernetes-helm` | 3.20.2 | Helm v3 package manager |
| `stern` | 1.34.0 | Multi-pod log aggregation |
| `yq-go` | 4.53.3 | YAML processor (`yq`) |
| `trivy` | 0.71.1 | Container image vulnerability scanner |
| `git` | 2.54.0 | Version control |
| `gh` | 2.52.0 | GitHub CLI |
| `jq` | 1.8.1 | JSON processor |
| `glow` | 2.1.2 | Terminal Markdown renderer (`devbox run docs`) |
| `gnumake` | 4.4.1 | Build system |

### Environment variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `KUBECONFIG` | `$HOME/.kube/config` | Standard kubeconfig location |
| `PATH` | `$PATH:$PWD/bin` | Adds `primes-{rust,go,node}` wrappers |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Suppress Powerlevel10k warning |

---

## Makefile targets

| Target | Description |
|--------|-------------|
| `build-all` | docker buildx build all three images |
| `build-rust/go/node` | build individual image |
| `deploy-all` | apply all manifests + wait for Ready |
| `deploy-rust/go/node` | apply individual deployment |
| `status` | kubectl get pods/deployments/services |
| `logs-rust/go/node` | stern log tail |
| `exec-rust/go/node` | kubectl exec (set ARGS='check 97') |
| `audit-images` | trivy HIGH/CRITICAL scan on all images |
| `teardown` | delete namespace + all resources |

---

## License

Copyright 2026 TEAM RelicFrog.
Licensed under the [Apache License, Version 2.0](../LICENSE).

**Author:** Patrick Paechnatz &lt;patrick@relicfrog.rocks&gt;
