# Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.
#This retrieves the current AWS account information, including the account_id dynamically.
data "aws_caller_identity" "current" {}

# Obtain the name of the AWS region configured on the provider.
/*
As well as validating a given region name this resource can be used to discover the name of the region configured within the provider. The latter can be 
useful in a child module which is inheriting an AWS provider configuration from its parent module.
Obtais the name of the AWS region configured on the provider.*/
data "aws_region" "current" {}



data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

/* Obtaining EKS Cluster's OIDC Provider URL` tokken issuer URL from default OIDC Identity Provider, which (default OIDC Identity Provider) automatically 
created in IAM for the EKS Cluster along with EKS Cluster's creation */
data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer 
}

# Generating json of Assume Role policy(trust policy) for IRSA
data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]                                                               # Defines that the role with this trust policy can be assumed only by Web Identity.

    principals {
      type        = "Federated"                                                                               # Defines that the role with this trust policy can be assumed only by Federated type Web Identity.
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]                                           # Defines that the role with this trust policy can be assumed only by OIDC identity provider (Federated type Web Identity)
    }

    condition {
      test     = "StringEquals"                                                                                # Ensures the condition must exactly match the provided values.
      variable = "oidc.eks.${data.aws_region.current.name}.${data.aws_caller_identity.current.account_id}:sub" # Specifies the iss (issuer) claim from the OIDC token (It is the URL of specific Kubernetes cluster OIDC Provider, which (OIDC Provider) issued token, which (token) specific service account of that specific cluster use to assume the role with access permissions)
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]        # Specifies the sub (subject) claim from the OIDC token: It is a specific Kubernetes cluster's specific service account which can assume the role with this trust policy using the identity token isued by OIDC Provider of the cluster wher this service account was created)

    }
  }
}


# Creating IRSA (IAM Role for Service Accounts)
resource "aws_iam_role" "irsa" {
   description = "IAM Role for Service Accounts"
   name = "${var.irsa_name}"
   assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json # Generated Assume Role Policy JSON for IRSA
   tags = var.default_tags
 }

# Attaching  policy to the IRSA to give permissions defined in policy to IRSA.
resource "aws_iam_role_policy_attachment" "attachement" {
  role       = aws_iam_role.irsa.name # IRSA name
  policy_arn = "arn:aws:iam::aws:policy/${var.irsa_policy}" # Permissions Policy Arn
}