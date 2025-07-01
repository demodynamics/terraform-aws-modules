variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.cluster_name)) && length(var.cluster_name) <= 100
    error_message = "The EKS cluster name must be 1-100 characters long, contain only letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }

}

variable "nodegroup_name" {
  description = "EKS Node Group Name"
  type        = string
  default     = "main"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.nodegroup_name)) && length(var.nodegroup_name) <= 100
    error_message = "The EKS node group name must be 1-100 characters long, contain only letters, numbers, and hyphens, and cannot start or end with a hyphen."
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

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = null
}

variable "node_ami_type" {
  description = "Type of Amazon Machine Image (AMI) for worker nodes."
  type        = string
  default     = null
}

variable "node_k8s_version" {
  description = "Kubernetes version for the node group."
  type        = string
  default     = null
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during update."
  type        = number
  default     = 1
}

variable "node_labels" {
  description = "Map of Kubernetes labels to apply to the nodes."
  type        = map(string)
  default     = {}
}

variable "taints_enabled" {
  description = "Whether to enable taints on the nodes."
  type        = bool
  default     = false

}

variable "node_taints" {
  description = "List of taints to apply to the nodes. Each taint is an object with key, value, and effect."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "remote_access_enabled" {
  description = "Whether to enable remote access to the nodes via SSH."
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Name of the EC2 SSH key pair to enable SSH access to the nodes."
  type        = string
  default     = null
}

variable "sg_ids" {
  description = "List of security group IDs allowed SSH access to the nodes. Set to null to disable remote_access block."
  type        = list(string)
  default     = null
}

variable "enable_launch_template" {
  description = "Whether to enable the launch_template block for the node group. Set to true to use a custom launch template."
  type        = bool
  default     = false
}

variable "launch_template_id" {
  description = "ID of the launch template to use for the node group. Required if enable_launch_template is true."
  type        = string
  default     = null
}

variable "launch_template_version" {
  description = "Version of the launch template to use. Defaults to $Latest if not set."
  type        = string
  default     = "$Latest"
}
