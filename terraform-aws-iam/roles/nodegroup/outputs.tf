output "output_data" {
  value = {
    arn = aws_iam_role.eks_node_group_role.arn
  }
}
