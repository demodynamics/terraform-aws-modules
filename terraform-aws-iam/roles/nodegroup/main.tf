terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Generating json of Assume Role policy(trust policy) for EKS Node Group Role
data "aws_iam_policy_document" "node_group_role_assume_role_policy" {
  statement {
    effect = "Allow"
    actions =  ["sts:AssumeRole"]
    principals { 
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  count = length(var.node_group_role_policy) > 0 ? 1 : 0
  description = "${var.default_tags["Project"]} EKS Node group Role"
  name = "${var.default_tags["Project"]}_eks_node_group_role"
  assume_role_policy = data.aws_iam_policy_document.node_group_role_assume_role_policy.json
}

# # Attaching permissions policies to the Node Group role.
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment" {
  for_each = length(var.node_group_role_policy) > 0 ? var.node_group_role_policy : toset([]) # for_each requires a map or set. ❌for_each does not work directly on a list. ✅ Convert a list to a map if needed. ✅ Use each.key and each.value inside the resource.
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_node_group_role[0].name
}