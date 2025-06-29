/*
length(var.gitlab_oidc_arn) > 0: Ensures the ARN is not an empty string.
can(regex("^arn:aws:iam::\\d{12}:oidc-provider/.+", var.gitlab_oidc_arn)): Checks that the ARN follows the pattern of an AWS IAM OIDC provider ARN.
\d{12} ensures the AWS account ID is exactly 12 digits.
oidc-provider/.+ ensures the ARN points to an OIDC provider.
*/

variable "gitlab_oidc_arn" {
  description = "The ARN of the Gitlab IAM OIDC Identity Provider (idP)"
  type        = string
  default     = ""

  validation {
    condition     = length(var.gitlab_oidc_arn) > 0 && can(regex("^arn:aws:iam::\\d{12}:oidc-provider/.+", var.gitlab_oidc_arn))
    error_message = "The gitlab_oidc_arn must be a valid AWS IAM OIDC provider ARN (e.g., arn:aws:iam::123456789012:oidc-provider/gitlab.com)."
  }
}

variable "gitlab_oidc_issuer_url" {
  description = "Gitlab OIDC Provider URL"
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_oidc_thumbprint_list" {
  description = "Gitlab OIDC Provider's certificate thumbprints"
  type        = set(string)
  default     = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

variable "gitlab_group" {
  description = "Gitlab account group which selected branch(es) from seletced project will assume the role"
  type        = string
  default     = "demodynamics"
  validation {
    condition     = length(var.gitlab_group) > 0
    error_message = "Please provide a valid Gitlab group."
  }
}

variable "gitlab_project" {
  description = "project of selected Gitlab account which branch(es) will assume the role"
  type        = string
  default     = "*"

  validation {
    condition     = length(var.gitlab_project) > 0
    error_message = "Please provide a valid Gitlab project name."
  }
}

variable "gitlab_branch" {
  description = "Branch(es) of selected Gitlab account's project that will assume the role"
  type        = string
  default     = "*" # all branches of ${var.gitlab_repo} repository can assume the role

  validation {
    condition     = length(var.gitlab_branch) > 0
    error_message = "Please provide a valid Gitlab branch name."
  }
}

variable "self_managed_policy_name" {
  description = "Custom Policy name that we create manually"
  type        = string
  default     = "eks-access-policy"

  validation {
    condition     = length(var.self_managed_policy_name) > 0
    error_message = "Please provide a self managed policy name."
  }

}

variable "aws_manged_policies" {
  description = "AWS managed policy to attach to the role assumed by Gitlab CI"
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]

  validation {
    condition = alltrue([
      for policy in var.aws_manged_policies :
      can(regex("^arn:aws:iam::aws:policy/[a-zA-Z0-9_+=,.@-]+$", policy)) # Ensure correct AWS managed policy format
    ])
    error_message = "aws_manged_policies must follow the valid AWS managed IAM policy ARN format (e.g., arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser)."
  }
}


variable "self_managed_policy_permissions" {
  description = "Permissions set for Self Managed Policy"
  type        = set(string)
  default     = ["eks:DescribeCluster", "eks:ListClusters", "eks:AccessKubernetesApi"]

  validation {
    condition = alltrue([
      for perm in var.self_managed_policy_permissions :
      can(regex("^[a-zA-Z0-9-]+:[a-zA-Z0-9-*]+$", perm)) # Ensure correct IAM action format
    ])
    error_message = "self_managed_policy_permissions must follow the IAM action format (e.g., eks:DescribeCluster, s3:PutObject)."
  }
}



variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type        = map(string)
  default = {
    Owner       = ""
    Environment = ""
    Project     = ""
  }

  validation {
    condition = alltrue([
      for v in values(var.default_tags) :
      can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag can be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}

