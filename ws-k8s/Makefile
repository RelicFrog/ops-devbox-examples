# Copyright 2026 TEAM RelicFrog
# SPDX-License-Identifier: Apache-2.0
#
# ws-k8s/Makefile
#
# All k8s tooling (kubectl, helm, kustomize, stern) comes from Nix via devbox.
# Docker is a host-level prerequisite (OrbStack / Docker Desktop) — not from Nix.
#
# Image naming convention: primes-<lang>:latest  (local OrbStack registry)
# Namespace: primes-workshop

.DEFAULT_GOAL := help

.PHONY: help build-all build-rust build-go build-node \
        namespace deploy-all deploy-rust deploy-go deploy-node \
        teardown status logs-rust logs-go logs-node \
        exec-rust exec-go exec-node \
        audit-images info clean

NS        := primes-workshop
IMG_RUST  := primes-rust:latest
IMG_GO    := primes-go:latest
IMG_NODE  := primes-node:latest
ROOT      := $(shell cd .. && pwd)

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

help: ## Show this help message
	@printf '\nUsage: make <target>\n\n'
	@printf 'Targets:\n'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "  %-18s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf '\nAll build targets require Docker on the host PATH (OrbStack / Docker Desktop).\n\n'

# ---------------------------------------------------------------------------
# Build container images (calls make docker-build in each ws-*)
# ---------------------------------------------------------------------------

build-rust: ## docker buildx build — primes-rust:latest
	$(MAKE) -C $(ROOT)/ws-rust docker-build

build-go: ## docker buildx build — primes-go:latest
	$(MAKE) -C $(ROOT)/ws-go docker-build

build-node: ## docker buildx build — primes-node:latest
	$(MAKE) -C $(ROOT)/ws-node docker-build

build-all: build-rust build-go build-node ## build all three images

# ---------------------------------------------------------------------------
# Deploy to local OrbStack k8s cluster
# ---------------------------------------------------------------------------

namespace: ## create the primes-workshop namespace (idempotent)
	kubectl apply -f manifests/rust/namespace.yaml
	kubectl wait --for=jsonpath='{.status.phase}'=Active \
	  namespace/$(NS) --timeout=15s

deploy-rust: namespace ## kubectl apply — primes-rust deployment
	kubectl apply -f manifests/rust/deployment.yaml

deploy-go: namespace ## kubectl apply — primes-go deployment
	kubectl apply -f manifests/go/deployment.yaml

deploy-node: namespace ## kubectl apply — primes-node deployment
	kubectl apply -f manifests/node/deployment.yaml

deploy-all: namespace ## deploy all three apps and wait for Ready
	kubectl apply -f manifests/rust/deployment.yaml
	kubectl apply -f manifests/go/deployment.yaml
	kubectl apply -f manifests/node/deployment.yaml
	@echo ""
	@echo "Waiting for pods to be ready..."
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-rust --timeout=90s || true
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-go   --timeout=90s || true
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-node --timeout=90s || true
	@echo ""
	$(MAKE) status

# ---------------------------------------------------------------------------
# Teardown
# ---------------------------------------------------------------------------

teardown: ## delete all primes-* deployments and the namespace
	kubectl delete namespace $(NS) --ignore-not-found

# ---------------------------------------------------------------------------
# Status
# ---------------------------------------------------------------------------

status: ## show pods, deployments, and services in the primes-workshop namespace
	@echo ""
	@echo "=== Namespace: $(NS) ==="
	kubectl get pods,deployments,services --namespace $(NS) 2>/dev/null || \
	  echo "Namespace $(NS) not found — run 'make deploy-all' first."

# ---------------------------------------------------------------------------
# Logs
# ---------------------------------------------------------------------------

logs-rust: ## stern logs — primes-rust pods
	stern --namespace $(NS) --selector app=primes-rust --tail 50

logs-go: ## stern logs — primes-go pods
	stern --namespace $(NS) --selector app=primes-go --tail 50

logs-node: ## stern logs — primes-node pods
	stern --namespace $(NS) --selector app=primes-node --tail 50

# ---------------------------------------------------------------------------
# kubectl exec wrappers — run primes-cli inside the running pods
# ---------------------------------------------------------------------------

exec-rust: ## kubectl exec — run primes-rust pod (ARGS='check 97')
	kubectl exec --namespace $(NS) \
	  $$(kubectl get pod --namespace $(NS) -l app=primes-rust -o jsonpath='{.items[0].metadata.name}') \
	  -- /primes-cli $(ARGS)

exec-go: ## kubectl exec — run primes-go pod (ARGS='nth 100')
	kubectl exec --namespace $(NS) \
	  $$(kubectl get pod --namespace $(NS) -l app=primes-go -o jsonpath='{.items[0].metadata.name}') \
	  -- /primes-cli $(ARGS)

exec-node: ## kubectl exec — run primes-node pod (ARGS='list --to 20')
	kubectl exec --namespace $(NS) \
	  $$(kubectl get pod --namespace $(NS) -l app=primes-node -o jsonpath='{.items[0].metadata.name}') \
	  -- /usr/local/bin/primes-cli $(ARGS)

# ---------------------------------------------------------------------------
# Security scan
# ---------------------------------------------------------------------------

audit-images: ## trivy image scan — all three primes images
	trivy image --severity HIGH,CRITICAL $(IMG_RUST)
	trivy image --severity HIGH,CRITICAL $(IMG_GO)
	trivy image --severity HIGH,CRITICAL $(IMG_NODE)

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean: teardown ## teardown k8s resources (alias)

# ---------------------------------------------------------------------------
# Info
# ---------------------------------------------------------------------------

info: ## print workspace tool versions
	@echo '--- ws-k8s devbox workspace ---'
	@echo "kubectl:    $$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"
	@echo "k9s:        $$(k9s version --short 2>/dev/null | head -1 || echo 'n/a')"
	@echo "helm:       $$(helm version --short 2>/dev/null || echo 'n/a')"
	@echo "kustomize:  $$(kustomize version 2>/dev/null | head -1 || echo 'n/a')"
	@echo "stern:      $$(stern --version 2>/dev/null | head -1 || echo 'n/a')"
	@echo "trivy:      $$(trivy --version 2>/dev/null | head -1 || echo 'n/a')"
	@echo "docker:     $$(docker version --format '{{.Client.Version}}' 2>/dev/null || echo 'n/a (host service)')"
	@echo "context:    $$(kubectl config current-context 2>/dev/null || echo 'none')"
	@echo "Platform:   $$(uname -ms)"
