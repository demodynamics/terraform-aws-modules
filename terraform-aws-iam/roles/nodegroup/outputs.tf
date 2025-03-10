output "node_group_role_data" {
  value = {
    "EKS Cluster Node Group Role Name"         = aws_iam_role.eks_node_group_role[*].name
    "EKS Cluster Node Group Role Arn"          = aws_iam_role.eks_node_group_role[*].arn
  }
}

# output "eks_node_group_role" {
#   description = "Name and Arn of EKS Node Group Role"
#   value = {
#   name = aws_iam_role.eks_node_group_role.name
#   arn  = aws_iam_role.eks_node_group_role.arn
#   }
# }