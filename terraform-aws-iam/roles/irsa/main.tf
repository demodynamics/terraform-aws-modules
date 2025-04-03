data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"] # Defines that the role with this trust policy can be assumed only by Web Identity.

    principals {
      type        = "Federated" # Defines that the role with this trust policy can be assumed only by Federated type Web Identity.
      identifiers = [var.oidc_provider_arn] # Defines that the role with this trust policy can be assumed only by OIDC identity provider (Federated type Web Identity)
    }

    condition {
      test     = "StringLike" # Ensures the condition must exactly match the provided values.
      variable = "${replace(var.oidc_provider_arn, "/^(.*provider\\/)/", "")}:sub" # Specifies the iss (issuer) claim from the OIDC token (It is the URL of specific Kubernetes cluster OIDC Provider, which (OIDC Provider) issued token, which (token) specific service account of that specific cluster use to assume the role with access permissions)
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"] # Specifies the sub (subject) claim from the OIDC token: It is a specific Kubernetes cluster's specific service account which can assume the role with this trust policy using the identity token isued by OIDC Provider of the cluster wher this service account was created)

    }

    condition {
        test     = "StringEquals" # Ensures the condition must match the provided values.
        variable = "${replace(var.oidc_provider_arn, "/^(.*provider\\/)/", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }
  }
}

resource "aws_iam_role" "irsa" {
  description        = "IAM Role for Service Accounts"
  name               = substr("${var.cluster_name}-${var.namespace}-${var.service_account}-role", 0, 64) # IAM role name must be less than 64 characters
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json 
  tags               = var.default_tags

  lifecycle {
    precondition {
      condition     = length(var.policies) > 0
      error_message = "IAM policy or policies must be provided"
    }
  }
}

resource "aws_iam_role_policy_attachment" "irsa_attachement" {
  for_each   = var.policies # for_each automatically skips iteration if var.policies is an empty set and will not create attachement.
  policy_arn = each.value
  role       = aws_iam_role.irsa.name
}






