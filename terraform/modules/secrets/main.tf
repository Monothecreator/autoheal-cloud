# AWS Secrets Manager for app secrets (never hardcode)

resource "aws_secretsmanager_secret" "db_connection" {
  name_prefix             = "${var.environment}/autoheal-cloud/db-"
  description             = "Database connection string for autoheal-cloud"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.environment}-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_connection" {
  secret_id = aws_secretsmanager_secret.db_connection.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = var.db_host
    port     = var.db_port
    username = var.db_username
    password = var.db_password
    dbname   = var.db_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "api_key" {
  name_prefix             = "${var.environment}/autoheal-cloud/api-key-"
  description             = "API key for autoheal-cloud"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.environment}-api-key-secret"
  }
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Resource policy to allow EKS pods to access secrets
resource "aws_secretsmanager_secret_policy" "db_connection_policy" {
  secret_arn = aws_secretsmanager_secret.db_connection.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.app_role_arn
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret_policy" "api_key_policy" {
  secret_arn = aws_secretsmanager_secret.api_key.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.app_role_arn
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}
