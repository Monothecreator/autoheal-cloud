variable "environment" {
  description = "Environment name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace for the app"
  type        = string
  default     = "default"
}

variable "app_service_account" {
  description = "Kubernetes service account name for the app"
  type        = string
  default     = "autoheal-cloud"
}
