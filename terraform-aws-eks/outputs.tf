output "eks_cluster_data" {
  value = {
    "EKS Cluster Name" = aws_eks_cluster.eks_cluster.name
  }
}

# output "eks_cluster_name" {
#   description = "Name of EKS Cluster"
#   value = aws_eks_cluster.eks_cluster.name
# }

