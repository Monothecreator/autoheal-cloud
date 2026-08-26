# CloudWatch Logs, SNS for alerting, and dashboard

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.environment}-eks-cluster"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.environment}-eks-logs"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/eks/${var.environment}-eks-cluster/app"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.environment}-app-logs"
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-autoheal-cloud-alerts"

  tags = {
    Name = "${var.environment}-alerts"
  }
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.environment}-high-cpu-alarm"
  }
}

# CloudWatch Alarm for High Memory (via custom metric)
resource "aws_cloudwatch_metric_alarm" "pod_memory" {
  alarm_name          = "${var.environment}-high-pod-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "PodMemoryUsage"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when pod memory usage is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.environment}-high-memory-alarm"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-autoheal-cloud"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_node_count", { stat = "Average" }],
            [".", "cluster_failed_node_count", { stat = "Sum" }],
            ["ContainerInsights", "PodCount", { stat = "Average" }],
            [".", "ContainerRestartCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Health"
        }
      }
    ]
  })
}
