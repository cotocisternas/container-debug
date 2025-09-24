# Container Debug

A comprehensive debugging container for testing connectivity to databases, message queues, and other services commonly used in Kubernetes environments.

## Features

This container includes tools for debugging connectivity issues with:

- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Message Queues**: RabbitMQ, Redis Pub/Sub
- **Network Services**: HTTP/HTTPS, TCP/UDP connections
- **Kubernetes**: kubectl for cluster debugging
- **General Network**: DNS resolution, ping, traceroute, port scanning

## Included Tools

### Network Utilities

- `ping` - Test network connectivity
- `dig`, `nslookup` - DNS troubleshooting
- `netcat` (`nc`) - Port connectivity testing
- `telnet` - Interactive protocol testing
- `traceroute` - Network path analysis
- `nmap` - Network and port scanning
- `tcpdump` - Network packet analysis

### Database Clients

- `psql` - PostgreSQL client
- `mysql` - MySQL/MariaDB client
- `redis-cli` - Redis client
- MongoDB client can be installed manually if needed

### Messaging Tools

- Basic connectivity testing for RabbitMQ
- Custom RabbitMQ testing scripts (for full AMQP testing, install pika manually)

### Kubernetes Tools

- `kubectl` can be installed manually if needed

### System Utilities

- `curl`, `wget` - HTTP clients
- `jq` - JSON processor
- `htop` - Process monitoring
- `vim`, `nano` - Text editors
- `openssl` - SSL/TLS utilities

### Custom Scripts

- `test-db-connection` - Database connectivity testing
- `test-network` - Network connectivity testing
- `test-rabbitmq` - RabbitMQ connectivity testing
- `debug-demo` - Shows available tools and examples

## Usage

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/cotocisternas/container-debug:latest
```

### Run Interactive Shell

```bash
docker run -it ghcr.io/cotocisternas/container-debug:latest
```

Once inside the container, run `debug-demo` to see available tools and examples.

### Use in Kubernetes

#### Quick Deploy with Kustomize (Recommended)

```bash
# Deploy to development environment
kubectl apply -k manifests/overlays/development

# Deploy to staging environment
kubectl apply -k manifests/overlays/staging

# Deploy to production environment
kubectl apply -k manifests/overlays/production

# Connect to the debug pod
kubectl exec -it -n development deployment/dev-container-debug -- /bin/bash
```

**Note:** When you connect to the debug pod, comprehensive debugging instructions will be automatically displayed to help you get started quickly.

#### GitOps Deployment

For FluxCD or ArgoCD integration, see the [manifests documentation](./manifests/README.md) and examples in the `manifests/gitops-examples/` directory.

#### Manual Pod Creation

Create a debug pod:

```yaml
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

Apply and connect:

```bash
kubectl apply -f debug-pod.yaml
kubectl exec -it debug-pod -- /bin/bash
```

### Testing Database Connectivity

#### PostgreSQL

```bash
test-db-connection postgres db-host 5432 mydb myuser
# or manually:
psql -h db-host -p 5432 -U myuser -d mydb
```

#### MySQL

```bash
test-db-connection mysql db-host 3306 mydb myuser
# or manually:
mysql -h db-host -P 3306 -u myuser -p mydb
```

#### MongoDB

```bash
test-db-connection mongo db-host 27017
# Note: MongoDB client not included by default, will test basic connectivity
# To install MongoDB client manually:
# curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc |  gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
# echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
# apt-get update && apt-get install -y mongodb-mongosh
```

#### Redis

```bash
test-db-connection redis db-host 6379
# or manually:
redis-cli -h db-host -p 6379
```

### Testing Network Connectivity

#### Basic connectivity

```bash
test-network google.com
test-network internal-service 8080
```

#### Manual network testing

```bash
# Test DNS resolution
nslookup service-name
dig service-name

# Test port connectivity
nc -zv hostname 80
telnet hostname 80

# Test HTTP services
curl -I http://service-name:8080/health

# Network path analysis
traceroute service-name
```

### Testing RabbitMQ

```bash
test-rabbitmq rabbitmq-host 5672 guest guest
```

### Kubernetes Debugging

```bash
# Install kubectl first (if needed)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# Check cluster info
kubectl cluster-info

# List services
kubectl get services

# Check pod logs
kubectl logs pod-name

# Describe resources
kubectl describe service service-name
```

## Examples

### Debug Database Connection Issues

```bash
# Test if PostgreSQL is reachable
test-network postgres-service 5432

# Test PostgreSQL authentication
test-db-connection postgres postgres-service 5432 myapp appuser

# Check if service exists in Kubernetes
kubectl get service postgres-service
kubectl describe service postgres-service
```

### Debug RabbitMQ Issues

```bash
# Test network connectivity to RabbitMQ
test-network rabbitmq-service 5672

# Test RabbitMQ authentication and connection
test-rabbitmq rabbitmq-service 5672 myuser mypass

# Check RabbitMQ management interface
curl -u myuser:mypass http://rabbitmq-service:15672/api/overview
```

### Debug DNS Issues

```bash
# Test DNS resolution
nslookup my-service
dig my-service

nslookup my-service.my-namespace.svc.cluster.local
```

## GitOps and Kubernetes Manifests

This project includes comprehensive Kustomize manifests for GitOps deployment:

- **Base configuration**: Core deployment, service, and configuration files
- **Environment overlays**: Development, staging, and production configurations
- **GitOps examples**: Ready-to-use FluxCD and ArgoCD configurations

### Directory Structure

```text
manifests/
├── base/                    # Base Kustomize configuration
├── overlays/               # Environment-specific configurations
│   ├── development/
│   ├── staging/
│   └── production/
└── gitops-examples/        # FluxCD and ArgoCD examples
    ├── fluxcd/
    └── argocd/
```

### Quick Deployment

```bash
# Deploy to different environments
kubectl apply -k manifests/overlays/development
kubectl apply -k manifests/overlays/staging  
kubectl apply -k manifests/overlays/production
```

For detailed GitOps setup instructions and customization options, see the [manifests documentation](./manifests/README.md).

## Building Locally

```bash
git clone https://github.com/cotocisternas/container-debug.git
cd container-debug
docker build -t container-debug .
docker run -it container-debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the container builds and works correctly
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.
