# Container Debug

Container Debug is a comprehensive Kubernetes debugging container that provides a complete toolkit for testing connectivity to databases, message queues, and other services commonly used in containerized environments. The project builds a Docker container with pre-installed debugging tools and custom scripts for common troubleshooting scenarios.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Commit Message Guidelines

**ALWAYS use semantic commit conventions** when creating commit messages. This ensures consistent and meaningful commit history.

### Semantic Commit Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Commit Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

### Examples
```
feat(scripts): add database connection retry logic
fix(dockerfile): resolve MongoDB repository key issue
docs(readme): update installation instructions
chore(ci): update GitHub Actions workflow timeout
test(scripts): add comprehensive validation for network tools
```

## Working Effectively

- **Bootstrap and build the container:**
  - `make build` -- optimized single-layer build, takes 2-3 minutes. NEVER CANCEL. Set timeout to 300+ seconds.
  - Direct Docker: `docker build -t container-debug .` -- same as make build but may need full Docker path on macOS.
  - Multi-platform build: `docker buildx build --platform linux/amd64,linux/arm64 -t container-debug .` -- takes 3-5 minutes. NEVER CANCEL. Set timeout to 600+ seconds.
  
- **Test the container:**
  - `make test` -- run comprehensive smoke tests for all tools (database clients, network tools, development tools, system tools, custom scripts).
  - `make full-test` -- validate Kustomize manifests, build container, and run tests.
  - Run interactive shell: `docker run -it container-debug` -- for manual testing and validation.

- **Kustomize manifests management:**
  - `make validate-manifests` -- validate all base and overlay manifests with configMapGenerator.
  - `make preview-dev/staging/prod` -- preview rendered manifests for each environment.
  - `kustomize build manifests/overlays/development` -- render development environment.

- **GitHub Actions CI/CD:**
  - The workflow at `.github/workflows/build-and-publish.yml` automatically builds and publishes to GitHub Container Registry.
  - Smoke tests run automatically on pull requests -- takes 3-5 minutes. NEVER CANCEL. Set timeout to 600+ seconds.
  - Multi-platform builds (AMD64/ARM64) run on main branch pushes -- takes 5-10 minutes. NEVER CANCEL. Set timeout to 900+ seconds.

## Validation

- **ALWAYS validate container functionality after making changes:**
  - Build and test: `make full-test` (validates manifests + builds + tests)
  - Build only: `make build`
  - Test only: `make test` (comprehensive validation of all tools: database clients, network tools, development tools, system tools, custom scripts)
  - Manual smoke test: `docker run --rm container-debug /bin/bash -c "psql --version && mysql --version && redis-cli --version && mongosh --version && test-network --help"`
  - Test network functionality: `docker run --rm container-debug test-network github.com 443`
  - Test database scripts: `docker run --rm container-debug test-db-connection mongo localhost 27017` (expect connection refused)

- **ALWAYS validate Kustomize manifests:**
  - `make validate-manifests` -- validates all environments and configMapGenerator
  - `make preview-dev` -- preview rendered development manifests
  - Test specific overlay: `kustomize build manifests/overlays/staging`

- **ALWAYS test all custom scripts individually:**
  - `chmod +x scripts/*` -- ensure scripts are executable
  - Test each script help: `./scripts/debug-demo`, `./scripts/test-network --help`, `./scripts/test-db-connection --help`, `./scripts/test-rabbitmq --help`

- **Manual validation scenarios:**
  - Deploy as Kubernetes debug pod and test connectivity to real services
  - Test database connectivity to PostgreSQL, MySQL, Redis with actual credentials
  - Validate network troubleshooting with DNS resolution, ping, traceroute
  - Test RabbitMQ connectivity and management interface access

## Common Tasks

The following are validated commands and their expected outputs:

### Repository Structure
```
ls -la
total 40
drwxr-xr-x 6 user user 4096 date .
drwxr-xr-x 3 user user 4096 date ..
-rw-r--r-- 1 user user  180 date .dockerignore
drwxr-xr-x 3 user user 4096 date .github
-rw-r--r-- 1 user user 2294 date Dockerfile
-rw-r--r-- 1 user user 1071 date LICENSE
-rw-r--r-- 1 user user 1680 date Makefile
drwxr-xr-x 4 user user 4096 date manifests
-rw-r--r-- 1 user user 5426 date README.md
drwxr-xr-x 2 user user 4096 date scripts
```

### Docker Build Process
```
# Optimized single-layer build takes 2-3 minutes, includes:
# - Ubuntu 22.04 base image
# - MongoDB repository setup (separate layer for GPG key and repository)
# - Network tools: ping, nc, telnet, nslookup, dig, traceroute, nmap, tcpdump
# - Database clients: psql, mysql, redis-cli, mongodb-mongosh
# - Development tools: python3, nodejs, git, vim, nano, jq, curl, wget
# - System tools: htop, procps, openssl, sudo
# - Custom debugging scripts in /usr/local/bin/
# - Non-root user 'debugger' with sudo access
```

### Container Tools Verification
```
# Use make test for comprehensive validation or run manually:
docker run --rm container-debug /bin/bash -c "
  psql --version            # PostgreSQL 14.19
  mysql --version           # MySQL 8.0.43
  redis-cli --version       # Redis 6.0.16
  mongosh --version         # MongoDB Shell 2.5.8
  python3 --version         # Python 3.10.12
  git --version             # Git 2.34.x
  nodejs --version          # Node.js 12.22.x
  jq --version              # jq-1.6
  curl --version | head -1  # curl 7.81.x
"```
```
docker run --rm container-debug /bin/bash -c "
  psql --version            # PostgreSQL 14.x
  mysql --version           # MySQL 8.0.x  
  redis-cli --version       # Redis 6.0.x
  python3 --version         # Python 3.10.x
  git --version             # Git 2.34.x
  nodejs --version          # Node.js 12.22.x
  jq --version              # jq-1.6
  curl --version | head -1  # curl 7.81.x
"
```

### Custom Scripts Usage
```
# Show all available tools and examples
debug-demo

# Network connectivity testing
test-network google.com           # DNS + ping + traceroute
test-network myservice 8080       # Include port connectivity

# Database connectivity testing  
test-db-connection redis localhost 6379
test-db-connection postgres dbhost 5432 mydb myuser
test-db-connection mysql dbhost 3306 mydb myuser
test-db-connection mongo localhost 27017 mydb myuser  # MongoDB with mongosh

# RabbitMQ connectivity testing
test-rabbitmq rabbitmq-host 5672 guest guest
```

### GitHub Actions Workflow
The CI/CD pipeline:
1. **Build stage** (3-5 minutes): Multi-platform Docker build for AMD64/ARM64
2. **Test stage** (30-60 seconds): Smoke tests validate all tools and scripts
3. **Publish stage** (1-2 minutes): Push to ghcr.io/cotocisternas/container-debug

### Kustomize Build Validation

**Validate all manifests:**
```bash
# Validate all environments at once
make validate-manifests

# Validate individual environments
kustomize build manifests/base                     # Base configuration
kustomize build manifests/overlays/development     # Development overlay
kustomize build manifests/overlays/staging         # Staging overlay  
kustomize build manifests/overlays/production      # Production overlay
```

**Preview rendered manifests:**
```bash
# Preview specific environments
make preview-dev        # Development environment
make preview-staging    # Staging environment
make preview-prod       # Production environment

# Or use kustomize directly
kustomize build manifests/overlays/development | less
```

**Common validation patterns:**
```bash
# Check configMapGenerator output
kustomize build manifests/base | grep -A 10 "kind: ConfigMap"

# Validate environment-specific patches
kustomize build manifests/overlays/production | grep -A 5 "resources:"

# Test manifest syntax
kustomize build manifests/overlays/development > /dev/null && echo "Valid"
```

## Key Project Components

- **Dockerfile**: Optimized Ubuntu 22.04 container with single-layer package installation and comprehensive debugging tools
- **Makefile**: Build automation with Docker path detection, testing, and Kustomize validation
- **manifests/**: Complete Kustomize structure with base configuration and environment overlays
  - **manifests/base/**: Core Kubernetes resources with configMapGenerator for debug scripts
  - **manifests/overlays/**: Environment-specific configurations (development, staging, production)
  - **manifests/gitops-examples/**: FluxCD and ArgoCD integration examples
- **scripts/debug-demo**: Interactive guide showing available tools and usage examples
- **scripts/test-network**: Network connectivity testing with DNS, ping, port checks, traceroute
- **scripts/test-db-connection**: Unified database connectivity testing for PostgreSQL, MySQL, MongoDB, Redis
- **scripts/test-rabbitmq**: RabbitMQ connectivity and management interface testing
- **.github/workflows/build-and-publish.yml**: CI/CD pipeline for automated building and publishing
- **.dockerignore**: Optimizes Docker build by excluding unnecessary files

## Build Timing Expectations

- **Local Docker build**: 2-3 minutes (set timeout 300+ seconds)
- **Multi-platform build**: 5-10 minutes (set timeout 900+ seconds)
- **Container smoke tests**: 5-10 seconds
- **Full functionality tests**: 15-30 seconds
- **GitHub Actions full pipeline**: 8-15 minutes (NEVER CANCEL - set timeout 1200+ seconds)

## Troubleshooting

- **Build failures**: Usually due to network timeouts during apt-get updates. Retry the build.
- **Script permission errors**: Ensure `chmod +x scripts/*` before building container
- **Network connectivity issues**: Some external hosts may be blocked by firewalls during testing
- **Database connection failures**: Expected when no actual database servers are running - scripts handle this gracefully
- **Container registry push failures**: Requires proper GitHub token permissions for ghcr.io

Always run comprehensive validation after any changes to ensure the container remains functional for debugging scenarios.