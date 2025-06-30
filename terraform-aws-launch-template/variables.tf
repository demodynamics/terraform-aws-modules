variable "prefix" {
  description = "Prefix for the launch template name"
  type        = string
  default     = "eks-ng-"

}

variable "description" {
  description = "Description for the launch template"
  type        = string
  default     = "Launch template for EKS node group"

}

variable "instance_type" {
  description = "Launch Template Instance Type"
  type        = list(string)
  default     = ["t2.micro"]

}

variable "sg_ids" {
  description = "List of additional security group IDs to attach to the node group."
  type        = list(string)
  default     = []
}

variable "image_id" {
  description = "AMI ID for the launch template. If null, EKS will pick the AMI."
  type        = string
  default     = null

}
