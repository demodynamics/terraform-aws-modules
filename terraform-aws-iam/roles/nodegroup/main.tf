# Generating json of Assume Role policy(trust policy) for EKS Node Group Role
data "aws_iam_policy_document" "node_group_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { 
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name               = join("-", compact([var.default_tags["Project"], var.cluster_name, "eks-cluster-nodegroup-role" ]) ) 
  assume_role_policy = data.aws_iam_policy_document.node_group_role_assume_role_policy.json
  tags               = var.default_tags

  lifecycle {
    precondition {
      condition = length(var.policies) > 0
      error_message  = "Policy or policies for role must be provided." 
    }
  }
}


# # Attaching permissions policies to the Node Group role.
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment" {
  for_each   = var.policies # for_each automatically skips iteration if var.policies is an empty set and will not create attachement.
  policy_arn = each.value
  role       = aws_iam_role.eks_node_group_role.name
}