variable "service_account_name" {
  description = "Service Account Name fetching from remote state of IRSA in root module"
  type = string

}
variable "service_account_namespace" {
  description = "Service Account Namespace fetching from remote state of IRSA in root module"
  type = string
}

variable "irsa_arn" {
  description = "Arn of IRSA fetching from remote state of IRSA in root module"
  type = string
}

variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}