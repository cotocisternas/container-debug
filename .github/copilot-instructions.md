# Container Debug

Container Debug is a comprehensive Kubernetes debugging container that provides a complete toolkit for testing connectivity to databases, message queues, and other services commonly used in containerized environments. The project builds a Docker container with pre-installed debugging tools and custom scripts for common troubleshooting scenarios.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

- **Bootstrap and build the container:**
  - `docker build -t container-debug .` -- takes 2-3 minutes. NEVER CANCEL. Set timeout to 300+ seconds.
  - Multi-platform build: `docker buildx build --platform linux/amd64,linux/arm64 -t container-debug .` -- takes 3-5 minutes. NEVER CANCEL. Set timeout to 600+ seconds.
  
- **Test the container:**
  - Run basic smoke tests: `docker run --rm container-debug /bin/bash -c "psql --version && mysql --version && redis-cli --version && test-network --help && debug-demo | head -10"` -- takes 5-10 seconds.
  - Run interactive shell: `docker run -it container-debug` -- for manual testing and validation.

- **GitHub Actions CI/CD:**
  - The workflow at `.github/workflows/build-and-publish.yml` automatically builds and publishes to GitHub Container Registry.
  - Smoke tests run automatically on pull requests -- takes 3-5 minutes. NEVER CANCEL. Set timeout to 600+ seconds.
  - Multi-platform builds (AMD64/ARM64) run on main branch pushes -- takes 5-10 minutes. NEVER CANCEL. Set timeout to 900+ seconds.

## Validation

- **ALWAYS validate container functionality after making changes:**
  - Build the container: `docker build -t test-container .`
  - Run smoke test: `docker run --rm test-container /bin/bash -c "psql --version && mysql --version && redis-cli --version && python3 --version && test-network --help && debug-demo | head -10"`
  - Test network functionality: `docker run --rm test-container test-network github.com 443`
  - Test database scripts: `docker run --rm test-container test-db-connection redis localhost 6379` (expect failure - no server)

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
total 32
drwxr-xr-x 5 user user 4096 date .
drwxr-xr-x 3 user user 4096 date ..
-rw-r--r-- 1 user user  180 date .dockerignore
drwxr-xr-x 3 user user 4096 date .github
-rw-r--r-- 1 user user 2294 date Dockerfile
-rw-r--r-- 1 user user 1071 date LICENSE
-rw-r--r-- 1 user user 5426 date README.md
drwxr-xr-x 2 user user 4096 date scripts
```

### Docker Build Process
```
# Build takes 2-3 minutes, includes:
# - Ubuntu 22.04 base image
# - Network tools: ping, nc, telnet, nslookup, dig, traceroute, nmap, tcpdump
# - Database clients: psql, mysql, redis-cli
# - Development tools: python3, nodejs, git, vim, jq, curl, wget
# - Custom debugging scripts in /usr/local/bin/
```

### Container Tools Verification
```
docker run --rm container-debug /bin/bash -c "
  psql --version          # PostgreSQL 14.x
  mysql --version         # MySQL 8.0.x  
  redis-cli --version     # Redis 6.0.x
  python3 --version       # Python 3.10.x
  git --version          # Git 2.34.x
  nodejs --version       # Node.js 12.22.x
  jq --version           # jq-1.6
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

# RabbitMQ connectivity testing
test-rabbitmq rabbitmq-host 5672 guest guest
```

### GitHub Actions Workflow
The CI/CD pipeline:
1. **Build stage** (3-5 minutes): Multi-platform Docker build for AMD64/ARM64
2. **Test stage** (30-60 seconds): Smoke tests validate all tools and scripts
3. **Publish stage** (1-2 minutes): Push to ghcr.io/cotocisternas/container-debug

### Kubernetes Deployment
```yaml
# Debug pod for troubleshooting
apiVersion: v1
kind: Pod
metadata:
  name: debug-pod
spec:
  containers:
  - name: debug
    image: ghcr.io/cotocisternas/container-debug:latest
    command: ["/bin/bash"]
    stdin: true
    tty: true
  restartPolicy: Never
```

## Key Project Components

- **Dockerfile**: Multi-stage Ubuntu 22.04 container with comprehensive debugging tools
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