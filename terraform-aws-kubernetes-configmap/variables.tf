variable "eks_cluster_dependency" {
  description = "Dependency on the EKS cluster resource"
  type        = any
  default     = null
}

variable "aws_auth_roles" {
  description = "List of IAM roles to map to Kubernetes RBAC roles"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of IAM users to map to Kubernetes RBAC roles"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "aws_auth_accounts" {
  description = "List of AWS accounts to map to Kubernetes RBAC roles"
  type        = list(string)
  default     = []
}
