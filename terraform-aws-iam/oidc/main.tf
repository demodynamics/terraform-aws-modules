# Generating custom AWS OIDC Provider for external system (e.g., GitHub Actions, Google, Okta, Auth0) where AWS STS will make 1 level validity check of Token issued by external system OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc" {
  url             = "https://${var.oidc_provider_url}"  
  client_id_list  = var.oidc_audience                         
  thumbprint_list = var.thumbprint_list

  tags = merge(var.default_tags, { Name = "${var.oidc_service_name} OIDC Identity Provider" })
}

# Generating trust policy for IAM Role That would be aasumed by external system (e.g., GitHub Actions, Google, Okta, Auth0), where AWS STS will make 2 level validity check of Token issued by external system OIDC Provider
data "aws_iam_policy_document" "role_assumption_trust_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

  principals {
      type        = "Federated"                                 # Defines that the role with this trust policy can be assumed only by Federated type Web Identity.
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]  # Defines that the role with this trust policy can be assumed only by external system (Federated type Web Identity) by token issued by external system OIDC provider
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = var.oidc_audience
    }

    condition {
      test     = "StringLike"
      variable = "${var.oidc_provider_url}:sub"
      values   = var.sub_condition
    }
  }

}

# ------------------ Creating IAM Role That would be aasumed by external system (e.g., GitHub Actions, Google, Okta, Auth0) ------------------ #

resource "aws_iam_role" "oidc_role" {
  count = length(var.self_managed_policy_permissions) > 0 || length(var.aws_manged_policies) > 0 ? 1 : 0
  description = "Role That will be Assumed by token provided by OIDC Provider of external system"
  name = "Role-to-be-assumed-by-${var.oidc_service_name}"
  assume_role_policy = data.aws_iam_policy_document.role_assumption_trust_policy.json # Adding generated trust policy into role
  tags = var.default_tags
}


# ------------------ Generating JSON of permissions for for self managed policy ------------------ #

data "aws_iam_policy_document" "self_managed_policy_permissions" {
  statement {
    sid    = "Permissions"
    effect = "Allow"
    actions = length(var.self_managed_policy_permissions) > 0 ? var.self_managed_policy_permissions : toset([])  # Checking if set of permissions for self-managed policy is not empty
    resources = ["*"]
  }
}

# ------------------ Creating self managed policy and adding generated permissions json into policy ------------------ #

resource "aws_iam_policy" "self_managed_policy" {
  count = length(var.self_managed_policy_permissions) > 0 ? 1 : 0 # Checking if set of permissions for self-managed policy is not empty
  name        = "${var.self_managed_policy_name}-for-${var.oidc_service_name}"
  description = "A Policy for EKS access"
  policy      = data.aws_iam_policy_document.self_managed_policy_permissions.json # Adding generated JSON of permissions into self managed policy
  tags = var.default_tags
}

# ------------------ Attaching policies to role ------------------ #

resource "aws_iam_role_policy_attachment" "self_managed_permissions_policy_attachment" {
  count = length(var.self_managed_policy_permissions) > 0 ? 1 : 0 # Checking if set of permissions for self-managed policy is not empty
  role       = aws_iam_role.oidc_role[0].name # The Role Name
  policy_arn = aws_iam_policy.self_managed_policy[0].arn # Self Manged Policy
}

resource "aws_iam_role_policy_attachment" "aws_managed_permissions_policy_attachment" {
  for_each = length(var.aws_manged_policies) > 0 ? var.aws_manged_policies : toset([]) # Checking if set of aws managed policies is not empty
  role       = aws_iam_role.oidc_role[0].name # The Role Name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}" # AWS Managed Policy
}


