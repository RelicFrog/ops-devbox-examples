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
        deploy-all deploy-rust deploy-go deploy-node \
        teardown status logs-rust logs-go logs-node \
        exec-rust exec-go exec-node \
        images-load audit-images clean

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

deploy-rust: ## kubectl apply — primes-rust deployment + service
	kubectl apply -f manifests/rust/

deploy-go: ## kubectl apply — primes-go deployment + service
	kubectl apply -f manifests/go/

deploy-node: ## kubectl apply — primes-node deployment + service
	kubectl apply -f manifests/node/

deploy-all: deploy-rust deploy-go deploy-node ## deploy all three apps
	@echo ""
	@echo "Waiting for pods to be ready..."
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-rust --timeout=60s || true
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-go   --timeout=60s || true
	kubectl wait --namespace $(NS) --for=condition=Ready pod --selector=app=primes-node --timeout=60s || true
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
