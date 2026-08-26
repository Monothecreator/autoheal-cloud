# IAM Roles for Service Accounts (IRSA) - least privilege per service

# IRSA for autoheal-cloud app
resource "aws_iam_role" "app_role" {
  name = "${var.environment}-autoheal-cloud-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:${var.app_namespace}:${var.app_service_account}"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-autoheal-cloud-role"
  }
}

# Policy for accessing Secrets Manager (app secrets)
resource "aws_iam_role_policy" "app_secrets_policy" {
  name = "${var.environment}-app-secrets-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:${var.environment}/autoheal-cloud/*"
      }
    ]
  })
}

# Policy for CloudWatch Logs (monitoring/debugging)
resource "aws_iam_role_policy" "app_logs_policy" {
  name = "${var.environment}-app-logs-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/eks/${var.environment}-eks-cluster/app/*"
      }
    ]
  })
}

# IRSA for AWS Load Balancer Controller
resource "aws_iam_role" "alb_controller_role" {
  name = "${var.environment}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-alb-controller-role"
  }
}

resource "aws_iam_role_policy" "alb_controller_policy" {
  name = "${var.environment}-alb-controller-policy"
  role = aws_iam_role.alb_controller_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elbv2:CreateLoadBalancer",
          "elbv2:DeleteLoadBalancer",
          "elbv2:DescribeLoadBalancers",
          "elbv2:DescribeTargetGroups",
          "elbv2:CreateTargetGroup",
          "elbv2:DeleteTargetGroup",
          "elbv2:RegisterTargets",
          "elbv2:DeregisterTargets",
          "elbv2:CreateListener",
          "elbv2:DeleteListener",
          "elbv2:DescribeListeners",
          "elbv2:ModifyLoadBalancerAttributes",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstances",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "*"
      }
    ]
  })
}

# IRSA for Cluster Autoscaler
resource "aws_iam_role" "autoscaler_role" {
  name = "${var.environment}-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-autoscaler-role"
  }
}

resource "aws_iam_role_policy" "autoscaler_policy" {
  name = "${var.environment}-autoscaler-policy"
  role = aws_iam_role.autoscaler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = "*"
      }
    ]
  })
}
