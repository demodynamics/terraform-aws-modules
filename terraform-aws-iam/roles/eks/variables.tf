variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "cluster_role_policy" {
  description = "List of AWS managed permissions policy() for Cluster Role"
  type = set(string)
}