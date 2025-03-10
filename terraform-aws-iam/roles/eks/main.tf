terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Generating JSON of Assume Role policy(trust policy) for EKS Cluster Role
data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"] # Defines that the role with this trust policy can be assumed only by AWS Entity (User, Role, Service).The IAM Role to whom we will attach this trust policy could be assumed by AWS Entity (User, Role, Service)
    principals { 
      type        = "Service" # Defines that the role with this trust policy can be assumed only by AWS Service (One of the AWS Entities)
      identifiers = ["eks.amazonaws.com"] # Defines that the role with this trust policy can be assumed only by EKS (On of AWS Services).
    }
  }
}
resource "aws_iam_role" "eks_cluster_role" {
  count = length(var.cluster_role_policy) > 0 ? 1 : 0
  description = "${var.default_tags["Project"]} EKS Cluster Role"
  name = "${var.default_tags["Project"]}_eks_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

# # Attaching permissions policies to the EKS clusetr role.
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  for_each = length(var.cluster_role_policy) > 0 ? var.cluster_role_policy : toset([]) #for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_cluster_role.name
}
