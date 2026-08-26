# Infrastructure as Code (Terraform)

Production-ready AWS infrastructure for autoheal-cloud with security hardening.

## Architecture

- **Network**: VPC with public/private subnets, NAT gateway, security groups (least privilege)
- **EKS Cluster**: Managed Kubernetes with IMDSv2, disk encryption, logging
- **IAM**: IRSA (IAM Roles for Service Accounts) with least-privilege policies
- **Monitoring**: CloudWatch logs, SNS alerts, dashboards
- **Secrets**: AWS Secrets Manager for API keys and DB credentials

## Directory Structure

```
terraform/
├── modules/
│   ├── network/           # VPC, subnets, security groups
│   ├── eks-cluster/       # Kubernetes cluster
│   ├── iam/               # IRSA and least-privilege roles
│   ├── monitoring/        # CloudWatch, SNS, alarms
│   └── secrets/           # AWS Secrets Manager
├── environments/
│   ├── dev/               # Development environment
│   └── prod/              # Production environment
└── .gitignore
```

## Prerequisites

1. **Terraform** >= 1.0
2. **AWS CLI** configured with credentials
3. **kubectl** for Kubernetes access

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform/environments/dev
terraform init
```

### 2. Configure Environment

Copy and fill in `terraform.tfvars.example`:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Plan & Apply

```bash
# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Confirm: type "yes"
```

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
kubectl get nodes
```

## Features

### Security Hardening

✅ **Network**: Private subnets, NAT gateway, least-privilege security groups
✅ **EKS**: IMDSv2-only, disk encryption with KMS, audit logging enabled
✅ **IAM**: IRSA for fine-grained pod permissions, no wildcard policies
✅ **Secrets**: AWS Secrets Manager with encryption, resource policies
✅ **Monitoring**: CloudWatch logs, SNS alerts for high CPU/memory

### Auto-scaling

- **Cluster Autoscaler**: Automatically scales nodes based on pod requirements
- **Horizontal Pod Autoscaler**: Scales app replicas based on metrics

### Monitoring & Alerting

- CloudWatch logs for EKS control plane and app
- SNS email alerts for high resource usage
- Custom dashboards

## Deploying the App

After infrastructure is ready, deploy autoheal-cloud:

```bash
# Create app namespace
kubectl create namespace autoheal

# Apply Kubernetes manifests (see k8s/ directory)
kubectl apply -f ../k8s/
```

## Outputs

After `terraform apply`, view outputs:

```bash
terraform output

# Specific outputs
terraform output cluster_endpoint
terraform output app_role_arn
```

## Destroying Infrastructure

⚠️ **Production**: Be careful with this!

```bash
terraform destroy
# Confirm: type "yes"
```

## Environment Variables (for secrets)

Instead of hardcoding secrets in `terraform.tfvars`:

```bash
export TF_VAR_db_password="your-password"
export TF_VAR_api_key="your-key"
terraform apply
```

## Cost Estimation

```bash
terraform plan -out=tfplan
# Or use: https://www.infracost.io/
```

## Troubleshooting

### EKS cluster not accessible
```bash
aws eks describe-cluster --name dev-eks-cluster
aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
kubectl auth can-i get nodes --as=system:serviceaccount:default:autoheal-cloud
```

### Secrets not accessible from pods
```bash
# Check IRSA role
kubectl describe sa autoheal-cloud
aws iam get-role --role-name dev-autoheal-cloud-role
```

### Monitoring alerts not working
```bash
# Verify SNS topic
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>
```

## Next Steps

1. Set up Terraform state backend (S3 + DynamoDB)
2. Add CI/CD pipeline for Terraform (`terraform apply` on merge)
3. Configure AWS WAF for ingress protection
4. Add VPN access instead of public API endpoint
5. Set up GitOps (ArgoCD) for app deployments

## Documentation

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.amazon.com/eks/best-practices/)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
