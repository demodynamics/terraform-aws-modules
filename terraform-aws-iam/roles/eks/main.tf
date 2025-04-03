# Generating JSON of Assume Role policy(trust policy) for EKS Cluster Role
data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"] # Defines that the role with this trust policy can be assumed only by AWS Entity (User, Role, Service).The IAM Role to whom we will attach this trust policy could be assumed by AWS Entity (User, Role, Service)
    principals { 
      type        = "Service" # Defines that the role with this trust policy can be assumed only by AWS Service (AWS Service `One of the AWS Entities)
      identifiers = ["eks.amazonaws.com"] # Defines that the role with this trust policy can be assumed only by EKS AWS Service.
    }
  }
}
resource "aws_iam_role" "eks_cluster_role" {
  name               = join("-", compact([var.default_tags["Project"], "eks-cluster-role" ]) )  
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
  tags               = var.default_tags

    lifecycle {
    precondition {
      condition = length(var.policies) > 0
      error_message  = "Policy or policies for cluster role must be provided." 
    }
  }
}

# # Attaching permissions policies to the EKS clusetr role.
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  for_each   = var.policies # for_each automatically skips iteration if aws_manged_policies is an empty set and will not create attachement
  policy_arn = each.value
  role       = aws_iam_role.eks_cluster_role.name
}
