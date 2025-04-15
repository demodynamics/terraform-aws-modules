output "output_data" {
  value = {
    arn = aws_iam_role.eks_nodegroup_role.arn
  }
}
