variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "oidc_service_name" {
  description = "Name of service for which (e.g., GitHub Actions, Google, Okta, Auth0) we manually create the custom OIDC Identity Provider in IAM"
  type = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL of external system that generates the identity token (e.g., GitHub Actions, Google, Okta, Auth0)"
  type        = string
}

variable "oidc_audience" {
  description = "Audience claim for OIDC (ex: sts.amazonaws.com)"
  type        = set(string)
}

variable "thumbprint_list" {
  description = "OIDC provider's certificate thumbprints"
  type        = set(string)
}

variable "self_managed_policy_name" {
  description = "Policy name that we create manually"
  type = string
}

variable "sub_condition" {
  description = "OIDC Subject (sub) claim condition"
  type        = set(string)
}

variable "aws_manged_policies" {
  description = "AWS managed policy to attach to the role assumed by external system (e.g., GitHub Actions, Google, Okta, Auth0)"
  type = set(string)
 }

variable "self_managed_policy_permissions" {
  description = "Permissions set for Self Managed Policy"
  type = set(string)
 }

