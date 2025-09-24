# Container Debug Kustomize Manifests

This directory contains Kustomize manifests for deploying the Container Debug tool in Kubernetes environments using GitOps practices.

## Directory Structure

```
manifests/
├── base/                           # Base Kustomize configuration
│   ├── deployment.yaml             # Base deployment manifest
│   ├── service.yaml               # Service definition
│   ├── configmap.yaml             # Configuration and documentation
│   └── kustomization.yaml         # Base kustomization
├── overlays/                      # Environment-specific overlays
│   ├── development/               # Development environment
│   │   ├── kustomization.yaml
│   │   └── deployment-patch.yaml
│   ├── staging/                   # Staging environment
│   │   ├── kustomization.yaml
│   │   └── deployment-patch.yaml
│   └── production/                # Production environment
│       ├── kustomization.yaml
│       └── deployment-patch.yaml
└── gitops-examples/               # GitOps tool examples
    ├── fluxcd/                    # FluxCD configuration
    │   └── container-debug-flux.yaml
    └── argocd/                    # ArgoCD configuration
        └── container-debug-apps.yaml
```

## Quick Usage

### Deploy with kubectl and Kustomize

```bash
# Deploy to development
kubectl apply -k manifests/overlays/development

# Deploy to staging
kubectl apply -k manifests/overlays/staging

# Deploy to production
kubectl apply -k manifests/overlays/production
```

### Connect to debug pod

```bash
# Development
kubectl exec -it -n development deployment/dev-container-debug -- /bin/bash

# Staging
kubectl exec -it -n staging deployment/staging-container-debug -- /bin/bash

# Production
kubectl exec -it -n production deployment/prod-container-debug -- /bin/bash
```

## Environment Differences

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| Replicas | 1 | 1 | 2 |
| Resources | Higher limits for testing | Moderate | Conservative |
| Log Level | debug | info | warn |
| Namespace | development | staging | production |
| Prefix | dev- | staging- | prod- |

## GitOps Integration

### FluxCD

1. **Install FluxCD** in your cluster
2. **Apply the FluxCD configuration**:
   ```bash
   kubectl apply -f manifests/gitops-examples/fluxcd/container-debug-flux.yaml
   ```
3. **Monitor deployment**:
   ```bash
   flux get kustomizations
   flux logs
   ```

**Features:**
- Automatic sync every 5 minutes
- Staging deployment followed by production
- Dependency management (production waits for staging)
- Automatic pruning of removed resources

### ArgoCD

1. **Install ArgoCD** in your cluster
2. **Apply the ArgoCD applications**:
   ```bash
   kubectl apply -f manifests/gitops-examples/argocd/container-debug-apps.yaml
   ```
3. **Monitor in ArgoCD UI** or CLI:
   ```bash
   argocd app list
   argocd app sync container-debug-staging
   ```

**Features:**
- Staging has automatic sync enabled
- Production requires manual sync for safety
- Self-healing enabled for staging
- Automatic namespace creation

## Customization

### Override Image Tag

Create a patch file or modify the kustomization.yaml:

```yaml
images:
- name: ghcr.io/cotocisternas/container-debug
  newTag: v1.2.3
```

### Add Custom Environment Variables

Extend the configMapGenerator in your overlay:

```yaml
configMapGenerator:
- name: debug-env-config
  literals:
  - CUSTOM_VAR=value
  - ANOTHER_VAR=another_value
```

### Modify Resources

Update the deployment-patch.yaml in your overlay:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-debug
spec:
  template:
    spec:
      containers:
      - name: debug
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

## Security Considerations

The deployment includes several security best practices:

- **Non-root user**: Runs as user ID 1000 (debugger)
- **Read-only root filesystem**: Prevents tampering
- **Dropped capabilities**: Only NET_RAW and NET_ADMIN for network debugging
- **Security context**: Includes seccomp profile and prevents privilege escalation
- **Pod anti-affinity**: Production spread across nodes

## Monitoring and Observability

The production overlay includes annotations for:
- Prometheus monitoring (`monitoring.coreos.com/enabled: "true"`)
- Alerting (`alerting.coreos.com/enabled: "true"`)

## Troubleshooting

### Common Issues

1. **Permission Denied for Network Tools**:
   - Ensure NET_RAW capability is enabled
   - Check if security policies allow the capabilities

2. **Pod Scheduling Issues**:
   - Check node resources and constraints
   - Verify namespace exists and has proper RBAC

3. **GitOps Sync Issues**:
   - Verify repository access and branch permissions
   - Check Flux/ArgoCD controller logs

### Debug Commands

```bash
# Check pod status
kubectl get pods -n <namespace> -l app=container-debug

# Check pod logs
kubectl logs -n <namespace> deployment/<prefix>container-debug

# Describe pod for events
kubectl describe pod -n <namespace> -l app=container-debug

# Test kustomization locally
kustomize build manifests/overlays/staging
```

## Contributing

To add new environments or modify configurations:

1. Create a new overlay directory under `manifests/overlays/`
2. Add appropriate `kustomization.yaml` and patch files
3. Test with `kustomize build` before committing
4. Update this README with the new environment details