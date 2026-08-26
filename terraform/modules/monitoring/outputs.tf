output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "eks_log_group_name" {
  value = aws_cloudwatch_log_group.eks_cluster.name
}

output "app_log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}
