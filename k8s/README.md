# Kubernetes Manifests for autoheal-cloud

Production-ready Kubernetes YAML manifests for deploying autoheal-cloud to EKS.

## File Structure

```
k8s/
├── 00-namespace.yaml      # Create autoheal namespace
├── 01-serviceaccount.yaml # ServiceAccount with IRSA annotation
├── 02-configmap.yaml      # App configuration
├── 03-secrets.yaml        # App secrets (DB connection, API keys)
├── 04-deployment.yaml     # Main app deployment
├── 05-service.yaml        # ClusterIP service
├── 06-ingress.yaml        # ALB ingress with SSL
├── 07-hpa.yaml            # Horizontal Pod Autoscaler
├── 08-pdb.yaml            # Pod Disruption Budget
├── 09-rbac.yaml           # Role-based access control
└── README.md
```

## Prerequisites

1. **EKS cluster** running (from Terraform)
2. **kubectl** configured
3. **AWS Load Balancer Controller** installed on cluster
4. **Docker Hub credentials** for pulling images
5. **AWS Secrets Manager** with DB secrets (optional, for advanced setup)

## Quick Deploy

### 1. Create Docker Hub secret

```bash
kubectl create secret docker-registry docker-registry \
  --docker-server=docker.io \
  --docker-username=monothecreator \
  --docker-password=YOUR_DOCKER_TOKEN \
  -n autoheal
```

### 2. Update manifest placeholders

Before applying, edit the files:

- **01-serviceaccount.yaml**: Replace `ACCOUNT_ID` and `ENVIRONMENT` with your AWS values
- **03-secrets.yaml**: Add your actual DB connection string and API key
- **06-ingress.yaml**: Replace `autoheal.example.com` with your domain, add ACM certificate ARN

### 3. Apply manifests

```bash
kubectl apply -f k8s/
```

Verify:

```bash
kubectl get ns autoheal
kubectl get pods -n autoheal
kubectl get svc -n autoheal
kubectl get ingress -n autoheal
```

### 4. Check app status

```bash
# Pods
kubectl get pods -n autoheal -w

# Logs
kubectl logs -n autoheal -l app=autoheal-cloud --tail=50 -f

# Describe deployment
kubectl describe deployment autoheal-cloud -n autoheal

# Test endpoint
kubectl port-forward svc/autoheal-cloud -n autoheal 3000:80 &
curl http://localhost:3000/health
```

## Accessing the App

### Via port-forward (development)

```bash
kubectl port-forward svc/autoheal-cloud -n autoheal 3000:80
curl http://localhost:3000/health
```

### Via ingress (production)

```bash
# Get ALB DNS
kubectl get ingress -n autoheal
# Use the ADDRESS column in your browser or API calls
```

## Updating the App

To deploy a new version:

```bash
kubectl set image deployment/autoheal-cloud \
  autoheal-cloud=monothecreator/app:v1.0.1 \
  -n autoheal

# Monitor rollout
kubectl rollout status deployment/autoheal-cloud -n autoheal
```

Or edit the manifest and reapply:

```bash
kubectl set image deployment/autoheal-cloud \
  autoheal-cloud=monothecreator/app:latest \
  -n autoheal --record
```

## Scaling

### Manual scaling

```bash
kubectl scale deployment autoheal-cloud --replicas=5 -n autoheal
```

### Auto-scaling (HPA)

HPA is configured to scale 3-10 replicas based on CPU/memory usage. View status:

```bash
kubectl get hpa -n autoheal -w
```

## Debugging

### Pod not starting

```bash
kubectl describe pod <pod-name> -n autoheal
kubectl logs <pod-name> -n autoheal
```

### Service not accessible

```bash
kubectl get svc -n autoheal
kubectl get endpoints autoheal-cloud -n autoheal
```

### Ingress not working

```bash
kubectl describe ingress autoheal-cloud -n autoheal
kubectl get events -n autoheal --sort-by='.lastTimestamp'
```

### Check IRSA (IAM role attachment)

```bash
kubectl describe sa autoheal-cloud -n autoheal
aws iam get-role --role-name dev-autoheal-cloud-role
```

## Security Features

✅ **Non-root user** (UID 65532)
✅ **Read-only root filesystem**
✅ **SecurityContext** enforced
✅ **Pod Disruption Budget** for HA
✅ **Resource limits** (prevent resource starvation)
✅ **Liveness & readiness probes** (self-healing)
✅ **RBAC** (least privilege)
✅ **Secrets encryption** (in transit & at rest)
✅ **ALB with WAF** (ingress protection)
✅ **Pod anti-affinity** (spread across nodes)

## Next Steps

1. **Set up monitoring**: Deploy Prometheus & Grafana
2. **Configure logging**: Set up ELK or CloudWatch Container Insights
3. **Add ArgoCD**: GitOps-based deployments
4. **Enable backup**: Velero for cluster backup
5. **Add canary deployments**: Flagger for gradual rollouts

## Troubleshooting Commands

```bash
# View all resources in namespace
kubectl get all -n autoheal

# View events
kubectl get events -n autoheal --sort-by='.lastTimestamp'

# Exec into pod
kubectl exec -it <pod-name> -n autoheal -- /bin/bash

# View pod logs
kubectl logs <pod-name> -n autoheal
kubectl logs <pod-name> -n autoheal -c <container-name> --previous

# Describe resources
kubectl describe pod <pod-name> -n autoheal
kubectl describe svc autoheal-cloud -n autoheal
kubectl describe ingress autoheal-cloud -n autoheal

# Port forward for debugging
kubectl port-forward pod/<pod-name> 3000:3000 -n autoheal
```
