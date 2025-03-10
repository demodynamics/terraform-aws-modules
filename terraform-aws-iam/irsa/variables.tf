variable "cluster_name" {
  type = string
}

variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "irsa_policy" {
  description = "An AWS managed policy that wiill give IRSA permissions defined in policy"
  type = string
}

variable "irsa_name" {
  type = string
}

variable "service_account_name" {
  description = "Service Account Name for IRSA that pull images from ECR Private Repository"
  type = string

}
variable "service_account_namespace" {
  description = "Service Account Namespace for IRSA that pull images from ECR Private Repository"
  type = string
}
