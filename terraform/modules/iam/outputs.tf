output "app_role_arn" {
  value = aws_iam_role.app_role.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}

output "autoscaler_role_arn" {
  value = aws_iam_role.autoscaler_role.arn
}
