variable "default_tags" {
  description = "Tags that are the same for all resources"
  type = map(string)
}

variable "cluster_role_arn" {
  description = "ARN of the EKS Cluster role that will be fetched from EKS Cluster role remote state"
  type = string
}

variable "node_goup_role_arn" {
  description = "ARN of the Node Group role that will be fetched from Node Group role remote state"
  type = string
}

variable "subnet_ids" {
  description = "Subnet ID's of VPC Where the cluster and it's nodes will be created. Will be fetched from VPC's remote state"
  type = list(string)
}

 variable "node_scale_desired_size" {
   description = "Scaling Config for EKS Node Group: Desired Count of Nodes"
   type = number
 }

 variable "node_scale_max_size" {
   description = "Scaling Config for EKS Node Group: Max Count of Nodes"
   type = number
 }

 variable "node_scale_min_size" {
   description = "Scaling Config for EKS Node Group: Min Count Of Nodes"
   type = number
 }

 variable "node_capacity_type" {
   description = "Pricing and Provisioning Type of AWS EC2 instances` Node(s) : On-Demand: More expensive but reliable or Spot: Cheaper but can be interrupted or terminated by AWS"
   type = string
 }

 variable "node_instance_type" {
   description = "EKS Node(s) Instance Type"
   type = list(string)
 }

 