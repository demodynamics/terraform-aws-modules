variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = null

}

variable "principal_arn" {
  description = "ARN of the IAM principal (user or role) to associate with the access entry"
  type        = string
  default     = null

}

variable "policy_arns" {
  description = "A map of EKS access policies to associate with a principal."
  type        = map(string)
  default     = {}
}


variable "access_scope_type" {
  description = "Type of access scope (e.g., cluster, namespace)"
  type        = string
  default     = "cluster"

}


