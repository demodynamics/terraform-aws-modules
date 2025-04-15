variable "cluster_name" {
  description = "Name Of already created EKS Cluster for whom enabling (crating) IAM OIDC Identity Provider (idP)"
  type        = string
  default     = ""
}

variable "default_tags" {      
  description = "Tags that are same for all resources"
  type        = map(string)
  default     = {
    Project     = ""
    Owner       = ""
    Enviornment = ""
  }
}