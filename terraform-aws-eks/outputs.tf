output "output_data" {
  description = "EKS Cluster details "
  value = {
    name = aws_eks_cluster.this.name
  }
}
