resource "aws_eks_access_entry" "this" {
  cluster_name  = var.cluster_name
  principal_arn = var.principal_arn
}

# Define an EKS Admin access policy association
resource "aws_eks_access_policy_association" "policies" { # Renamed for clarity
  for_each = var.policy_arns

  cluster_name  = var.cluster_name
  principal_arn = var.principal_arn
  policy_arn    = each.value # Use the policy ARN from the current map item

  access_scope {
    type = var.access_scope_type
  }
}
