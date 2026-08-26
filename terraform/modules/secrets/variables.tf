variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_role_arn" {
  description = "ARN of the app IAM role (IRSA)"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for the app"
  type        = string
  sensitive   = true
}
