variable "ami_owner" {
  description = "ami Image owner"
  type        = list(string)
  default     = ["099720109477"] # This is the owner ID for Canonical, the publisher of Ubuntu images

}

variable "most_recent" {
  description = "Use or not most recent Image"
  type        = bool
  default     = true
}

variable "iamge_filter_type" {
  description = "AMI image filter type"
  type        = string
  default     = "name"
}

variable "image_filter_value" {
  description = "AMI image filter value"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]

}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the EC2 instance"
  type        = list(string)
  default     = []

}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = ""

}

variable "use_ssh" {
  description = "Whether to use SSH to connect to the EC2 instance"
  type        = bool
  default     = false
}

variable "ssh_key_pair_name" {
  description = "SSH key pair name for EC2 instance"
  type        = string
  default     = ""
  validation {
    condition     = var.use_ssh ? length(var.ssh_key_pair_name) > 0 : true
    error_message = "ssh_key_pair_name must be provided if use_ssh is true."
  }
}

variable "volume_type" {
  description = "Type of the root block device volume"
  type        = string
  default     = "gp3"

}

variable "volume_size" {
  description = "Size of the root block device volume in GB"
  type        = number
  default     = 8
}

variable "delete_on_termination" {
  description = "Whether to delete the root block device volume on instance termination"
  type        = bool
  default     = true

}

variable "default_tags" {
  description = "value"
  type        = map(string)
  default = {
    Name        = "insatance-name"
    Environment = "dev"
    Project     = "project-name"
    ServerGroup = "server-group"
    Owner       = "karen-grigoryan"
  }
}


