variable "vpc_name" {
  type = string
  default = "Main"
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type  = string
  default = "10.0.0.0/16"
}

variable "route_cidr" {
  description = "The CIDR block of the route tables"
  type = string
  default = "0.0.0.0/0"  
}

variable "az_desired_count" {
  description = "Desired count of AZs to create in. Before adding a count of desired az's be sure that it is not more than the total number of available AZ's in the region"
  type = number
  default = 2
  
}

variable "vpc_dns" {
  description = "VPC DNS Support Status"
  type = bool
  default = true
}

variable "map_public_ip_on_launch" {
  description = "Public IP on auto creation status"
  type = bool
  default = true
  
}

variable "single_natgw" {
  description = "Creae single Nat Gateway for all Private Subnets"
  type = bool
  default = false
}

variable "natgw_per_az" {
  description = "Creae Nat Gateway for Private Subnets per AZs count"
  type = bool
  default = false
}

variable "natgw_per_subnet" {
  description = "Creae Nat Gateway for each Private Subnet"
  type = bool
  default = false
  
}

variable "public_subnets_count" {
  description = "Number of public subnets to create"
  type = number
  default = 2
}

variable "private_subnets_count" {
  description = "Number of private subnets to create"
  type = number
  default = 2
}

variable "subnet_prefix" {
  description = "Prefix for subnet creation"
  type = number
  default = 24
  
}

variable "sg_ports" {
  description = "Ports to open for ingress on Security Group"
  type = list(number)
  default = [80, 443]
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type = map(string)
  default = {
    Owner = "Owner"
    Environment = "Environment"
    Project = "Project"
 }
  
}

variable "public_route_per_sub" {
  description = "Create Public Route Table per Public Subnet"
  type = bool
  default = false
}