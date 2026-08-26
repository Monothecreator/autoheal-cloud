output "vpc_id" {
  value = module.network.vpc_id
}

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "app_role_arn" {
  value = module.iam.app_role_arn
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

output "db_secret_arn" {
  value = module.secrets.db_secret_arn
}
