output "output_data" {
  description = "EKS Cluster details "
  value = {
    name                       = aws_eks_cluster.this.name
    endpoint                   = aws_eks_cluster.this.endpoint
    certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
  }
}
