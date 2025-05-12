output "output_data" {
  description = "EKS cluster node group dtetails"
  value = {
    arn = aws_eks_node_group.this.arn
  }
}