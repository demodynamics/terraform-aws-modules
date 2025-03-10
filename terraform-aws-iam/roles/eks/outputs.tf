output "eks_cluster_role_data" {
  value = {
    "EKS Cluster Role Name"                    = aws_iam_role.eks_cluster_role[*].name
    "EKS Cluster Role Arn"                     = aws_iam_role.eks_cluster_role[*].arn
  }
}

# output "eks_cluster_role" {
#   description = "Name and Arn of EKS Cluster Role"
#   value = {
#   name = aws_iam_role.eks_cluster_role.name
#   arn  = aws_iam_role.eks_cluster_role.arn
#   }
# }