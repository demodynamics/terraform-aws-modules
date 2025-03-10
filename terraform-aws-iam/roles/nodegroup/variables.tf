variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "node_group_role_policy" {
  description = "List of AWS managed permissions policy(s) for Node Group Role"
  type = set(string)
}