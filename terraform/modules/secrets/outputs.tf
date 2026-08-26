output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_connection.arn
}

output "api_key_secret_arn" {
  value = aws_secretsmanager_secret.api_key.arn
}
