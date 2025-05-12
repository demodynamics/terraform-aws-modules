# Generating JSON of Assume Role policy(trust policy) for EKS Cluster Role
data "aws_iam_policy_document" "fargate_profile_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"] 
    principals { 
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"] 
    }
  }
}
resource "aws_iam_role" "eks_fargate_profile_role" {
  name               = join("-", compact([var.default_tags["Project"], var.fargate_profile_name, "eks-fargate-role" ]) )  
  assume_role_policy = data.aws_iam_policy_document.fargate_profile_role_assume_role_policy.json
  tags               = var.default_tags

    lifecycle {
    precondition {
      condition = length(var.policies) > 0
      error_message  = "Policy or policies for fargate profile role must be provided." 
    }
  }
}

# # Attaching permissions policies to the EKS clusetr role.
resource "aws_iam_role_policy_attachment" "eks_fargate_profile_role_attachment" {
  for_each   = var.policies # for_each automatically skips iteration if aws_manged_policies is an empty set and will not create attachement
  policy_arn = each.value
  role       = aws_iam_role.eks_fargate_profile_role.name
}
