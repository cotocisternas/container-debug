# Container Debug Makefile
.PHONY: help build test validate-manifests deploy-dev deploy-staging deploy-prod clean

# Docker command (use full path if needed)
DOCKER := $(shell which docker || echo "/usr/local/bin/docker")

# Default target
help: ## Show this help message
	@echo "Container Debug Makefile Commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Docker operations
build: ## Build the optimized container image (single apt layer)
	$(DOCKER) build -t container-debug .

test: ## Run comprehensive container smoke tests for all tools
	@echo "Running comprehensive container smoke tests..."
	@echo "Testing database clients..."
	@$(DOCKER) run --rm container-debug /bin/bash -c "psql --version && mysql --version && redis-cli --version && mongosh --version"
	@echo "Testing network tools..."
	@$(DOCKER) run --rm container-debug /bin/bash -c "ping -c 1 127.0.0.1 > /dev/null && echo 'ping: OK' && nc -h 2>&1 | head -1 && dig -v 2>&1 | head -1"
	@echo "Testing development tools..."
	@$(DOCKER) run --rm container-debug /bin/bash -c "python3 --version && git --version && nodejs --version && jq --version"
	@echo "Testing system tools..."
	@$(DOCKER) run --rm container-debug /bin/bash -c "htop --version 2>&1 | head -1 && curl --version | head -1 && wget --version | head -1"
	@echo "Testing custom scripts..."
	@$(DOCKER) run --rm container-debug /bin/bash -c "test-network --help && test-db-connection --help && test-rabbitmq --help && debug-demo | head -3"
	@echo "All container tools validated successfully!"

# Kubernetes manifest validation
validate-manifests: ## Validate all Kustomize manifests (includes configMapGenerator)
	@echo "Validating Kustomize manifests with configMapGenerator..."
	@echo "Checking base configuration..."
	kustomize build manifests/base > /dev/null
	@echo "Checking development overlay..."
	kustomize build manifests/overlays/development > /dev/null
	@echo "Checking staging overlay..."
	kustomize build manifests/overlays/staging > /dev/null
	@echo "Checking production overlay..."
	kustomize build manifests/overlays/production > /dev/null
	@echo "All manifests are valid!"

# Manifest previews
preview-base: ## Preview base manifests
	kustomize build manifests/base

preview-dev: ## Preview development manifests
	kustomize build manifests/overlays/development

preview-staging: ## Preview staging manifests
	kustomize build manifests/overlays/staging

preview-prod: ## Preview production manifests
	kustomize build manifests/overlays/production

# Full pipeline simulation
full-test: validate-manifests build test ## Run full validation pipeline
	@echo "Full test pipeline completed successfully!"