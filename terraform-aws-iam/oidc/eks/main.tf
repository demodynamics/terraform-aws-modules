# Obtaining data of EKS clusters
data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

# Obtaining EKS cluster's OIDC Providers TLS Certificate
data "tls_certificate" "eks_cluster_oidc_provider" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

#Enabling (creating) OIDC Identity Provider (idP) in IAM for EKS cluster
resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [ data.tls_certificate.eks_cluster_oidc_provider.certificates[0].sha1_fingerprint ]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  tags            = var.default_tags
}

