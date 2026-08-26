terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # Configure this per environment
    # bucket         = "autoheal-cloud-tf-state"
    # key            = "dev/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "autoheal-cloud"
    }
  }
}

# Network Module
module "network" {
  source = "./modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
}

# EKS Cluster Module
module "eks_cluster" {
  source = "./modules/eks-cluster"

  environment                = var.environment
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  eks_control_plane_sg_id    = module.network.eks_control_plane_sg_id
  kubernetes_version         = var.kubernetes_version
  node_instance_types        = var.node_instance_types
  desired_node_count         = var.desired_node_count
  min_node_count             = var.min_node_count
  max_node_count             = var.max_node_count
  node_disk_size             = var.node_disk_size
  allowed_cidr_blocks        = var.allowed_cidr_blocks
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  environment        = var.environment
  oidc_provider_arn  = module.eks_cluster.oidc_provider_arn
  aws_region         = var.aws_region
  account_id         = data.aws_caller_identity.current.account_id
  app_namespace      = var.app_namespace
  app_service_account = var.app_service_account
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  environment     = var.environment
  aws_region      = var.aws_region
  log_retention_days = var.log_retention_days
  alert_email     = var.alert_email
}

# Secrets Module (only if secrets should be managed)
module "secrets" {
  source = "./modules/secrets"

  environment      = var.environment
  app_role_arn     = module.iam.app_role_arn
  db_host          = var.db_host
  db_port          = var.db_port
  db_username      = var.db_username
  db_password      = var.db_password
  db_name          = var.db_name
  api_key          = var.api_key
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
