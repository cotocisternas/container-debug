# Container Debug Instructions

## Quick Start

1. Connect to the debug pod:

   ```bash
   kubectl exec -it deployment/container-debug -- /bin/bash
   ```

2. Run the demo to see available tools:

   ```bash
   debug-demo
   ```

## Common Debugging Scenarios

### Test Database Connectivity

```bash
test-db-connection postgres db-host 5432 mydb myuser
test-db-connection redis redis-host 6379
test-db-connection mysql mysql-host 3306 mydb myuser
```

### Test Network Connectivity

```bash
test-network google.com
test-network internal-service 8080
```

### Test RabbitMQ

```bash
test-rabbitmq rabbitmq-host 5672 guest guest
```

## Available Tools

- Network: ping, nc, telnet, nslookup, dig, traceroute, nmap, tcpdump
- Database clients: psql, mysql, redis-cli
- HTTP tools: curl, wget
- System: htop, vim, jq, python3, git, nodejs
- Custom scripts: test-network, test-db-connection, test-rabbitmq, debug-demo

## Advanced Usage

### Manual Network Testing

```bash
# DNS resolution
nslookup service-name
dig service-name

# Port connectivity
nc -zv hostname 80
telnet hostname 80

# HTTP services
curl -I http://service-name:8080/health

# Network path analysis
traceroute service-name
```

### SSL/TLS Testing

```bash
# Test SSL certificate
openssl s_client -connect hostname:443 -servername hostname

# Check certificate details
openssl s_client -connect hostname:443 -servername hostname 2>/dev/null | openssl x509 -noout -text
```

### System Information

```bash
# Process monitoring
htop

# Network interfaces
ip addr show

# Routing table
ip route show

# DNS configuration
cat /etc/resolv.conf
```
