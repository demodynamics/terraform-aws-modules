variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.cluster_name)) && length(var.cluster_name) <= 100
    error_message = "The EKS cluster name must be 1-100 characters long, contain only letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }

}

variable "node_goup_role_arn" {
  description = "ARN of the Node Group role"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet ID's of VPC Where the cluster will be created"
  type        = list(string)
  default     = [""]
}

 variable "node_scale_desired_size" {
   description = "Scaling Config for EKS Node Group: Desired Count of Nodes"
   type        = number
   default     = 1
 }

 variable "node_scale_max_size" {
   description = "Scaling Config for EKS Node Group: Max Count of Nodes"
   type        = number
   default     = 2
 }

 variable "node_scale_min_size" {
   description = "Scaling Config for EKS Node Group: Min Count Of Nodes"
   type        = number
   default     = 1
 }

 variable "node_capacity_type" {
   description = "Pricing and Provisioning Type of AWS EC2 instances` Node(s) : On-Demand: More expensive but reliable, Spot: Cheaper but can be interrupted or terminated by AWS"
   type        = string
   default     = "ON_DEMAND"

  validation {
    condition     = var.node_capacity_type == "ON_DEMAND" || var.node_capacity_type == "SPOT"
    error_message = "The node_capacity_type must be either 'ON_DEMAND' or 'SPOT'."
  }
 }

 variable "node_instance_type" {
   description = "EKS Node(s) Instance Type"
   type        = list(string)
   default     = ["t2.micro"]
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
      for value in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", value)) && length(value) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag can be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}
