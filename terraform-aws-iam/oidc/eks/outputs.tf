output "output_data" {
  description = "EKS cluster OIDC Identity Provider details"
  value = {
    arn = aws_iam_openid_connect_provider.eks_cluster.arn
  }
}