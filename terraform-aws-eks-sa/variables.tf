variable "service_account_name" {
  description = "Service Account Name from IRSA"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.service_account)) && length(var.service_account) <= 253
    error_message = "The service account name must be 1-253 characters long, contain only lowercase letters, numbers, and dashes, and cannot start or end with a dash."
  }

}
variable "service_account_namespace" {
  description = "Service Account Namespace from IRSA"
  type        = string
  default     = ""
  
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace)) && length(var.namespace) <= 63
    error_message = "The namespace must be a valid Kubernetes namespace name: 1-63 characters, lowercase letters, numbers, and dashes, but cannot start or end with a dash."
  }
}

variable "irsa_arn" {
  description = "Arn of IRSA"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.irsa_arn))
    error_message = "The irsa_arn must be a valid IAM Role ARN in the format arn:aws:iam::<account-id>:role/<role-name>."
  }
}