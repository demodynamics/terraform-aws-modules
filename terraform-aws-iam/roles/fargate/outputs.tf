output "output_data" {
  value = {
    arn  = aws_iam_role.eks_fargate_profile_role.arn
    name = aws_iam_role.eks_fargate_profile_role.name
  }
}
