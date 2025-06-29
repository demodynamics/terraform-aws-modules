# Generating trust policy for IAM Role That would be aasumed by GitHub Actions

data "aws_iam_policy_document" "github_actions_trust_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"           # Defines that the role with this trust policy can be assumed only by Federated type Web Identity.
      identifiers = [var.github_oidc_arn] # Defines that the role with this trust policy can be assumed only by external system (Federated type Web Identity) by token issued by external system OIDC provider
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.github_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(var.github_oidc_issuer_url, "https://", "")}:sub"
      values   = ["repo:${var.github_username}/${var.github_repo}:${var.github_branch == "*" ? "*" : var.github_branch}"] # Allows to assume the role only if the token is issued for the specified GitHub username, repository and branch. If branch is "*", then all branches of the repository can assume the role.
    }
  }
}

# ------------------ Creating IAM Role That would be aasumed by external system (e.g., GitHub Actions, Google, Okta, Auth0) ------------------ #

resource "aws_iam_role" "github_actions_role" {
  description        = "Role That will be Assumed by token provided by Github OIDC Provider"
  name               = "Github-${var.github_username}-${replace(var.github_repo, "*", "any")}-repo-${replace(var.github_branch, "*", "any")}-branch-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust_policy.json # Adding generated trust policy into role
  tags               = var.default_tags

  lifecycle {
    precondition {
      condition     = length(var.aws_manged_policies) > 0 || length(var.self_managed_policy_permissions) > 0
      error_message = "Either aws_manged_policies or self_managed_policy_permissions must be provided."
    }
  }
}


# ------------------ Generating permissions JSON for for self managed policy ------------------ #

data "aws_iam_policy_document" "self_managed_policy_permissions" {
  statement {
    sid       = "Permissions"
    effect    = "Allow"
    actions   = var.self_managed_policy_permissions
    resources = ["*"]
  }
}


# ------------------ Creating self managed policy and adding generated permissions json into policy ------------------ #

resource "aws_iam_policy" "self_managed_policy" {
  count  = length(var.self_managed_policy_permissions) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.self_managed_policy_permissions.json # Adding generated JSON of permissions into self managed policy
  tags   = var.default_tags
}

# ------------------ Attaching policies to role ------------------ #

resource "aws_iam_role_policy_attachment" "self_managed_permissions_policy_attachment" {
  count      = length(var.self_managed_policy_permissions) > 0 ? 1 : 0
  role       = aws_iam_role.github_actions_role.name     # The Role Name
  policy_arn = aws_iam_policy.self_managed_policy[0].arn # Self Manged Policy
}

resource "aws_iam_role_policy_attachment" "aws_managed_permissions_policy_attachment" {
  for_each   = var.aws_manged_policies               # for_each automatically skips iteration if aws_manged_policies is an empty set and will not create attachement. No need for length(...) > 0 ? ... : toset([]) because toset([]) is redundant.
  role       = aws_iam_role.github_actions_role.name # The Role Name
  policy_arn = each.value                            # AWS Managed Policy
}
