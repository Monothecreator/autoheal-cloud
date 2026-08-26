output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "eks_control_plane_sg_id" {
  value = aws_security_group.eks_control_plane.id
}

output "eks_worker_nodes_sg_id" {
  value = aws_security_group.eks_worker_nodes.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
