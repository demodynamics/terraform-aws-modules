/*Key Point:
A VPC Name is usually just a tag, so spaces may be fine, but if you're using it as a part of AWS resource names (e.g., in CLI or scripting),
avoiding spaces is safer.
But an attrubute like Security Group name can contain spaces because AWS allows it.*/

variable "vpc_name" {
  type    = string
  default = "main"

  validation {
    condition = can(regex("^[a-zA-Z0-9-_]+$", var.vpc_name)) && length(var.vpc_name) <= 255
    error_message = "The vpc_name must contain only letters, numbers, hyphens (-), or underscores (_) (max 255 characters)."
  }
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition = can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", var.vpc_cidr))
    error_message = "The vpc_cidr must be a valid CIDR block."
  }
}

variable "route_cidr" {
  description = "The CIDR block of the route tables"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition = can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", var.route_cidr))
    error_message = "The route_cidr must be a valid CIDR block."
  }
}
 
variable "az_desired_count" {
  description = "Desired count of AZs to create in. Before adding a count of desired az's be sure that it is not more than the total number of available AZ's in the region"
  type = number
  default = 2

  validation {
    condition     = var.az_desired_count > 0
    error_message = "az_desired_count must be greater than 0"
  }
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
  default = true
}

variable "public_subnets_count" {
  description = "Number of public subnets to create"
  type = number
  default = 3
}

variable "private_subnets_count" {
  description = "Number of private subnets to create"
  type = number
  default = 3
}

variable "subnet_prefix" {
  description = "Prefix of subnets that will be created"
  type = number
  default = 24

  validation {
    condition     = var.subnet_prefix >= 16 && var.subnet_prefix <= 28
    error_message = "The subnet prefix must be between 16 and 28."
  } 
}
/*
Add validation to ensure that the CIDR prefix falls within a valid range. Typically, subnet prefix lengths for IPv4 should be between 0 (full network) and 32 (single IP). If 
you're dealing with subnets, a more reasonable range would be from 16 (large subnet) to 28 (small subnet for private use).
For example A CIDR prefix of /8 is technically valid, but it's not typically used for subnets in private networking. If you want to allow /8 as well, you can adjust the validation range 
like this.
*/

variable "per_public_sub" {
  description = "To allow Create Public Route Table per Public Subnet"
  type        = bool
  default     = false
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
      for v in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag can be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}

/*
Best Practices for Tags in AWS (and General Cloud Resources):
  1.Avoid spaces in tag values if the tags are used for operations (e.g., scripting, automation).
      Spaces in Name tags might cause issues with some automation tools or AWS services that parse tags.
      Instead, use hyphens or underscores for separation, like: Project-VPC-Name.
  2.Consistency in Tagging:
    Tags should be consistent across your resources to make filtering and identifying resources easier.
      For example, using consistent tags like Project, Environment, Owner, CostCenter, etc.
  3.Keep Tags Meaningful and Short:
      AWS has a limit of 128 characters for each tag key and 256 characters for each tag value. Make sure your tag values are concise but descriptive.
  4.Use of Name tag:
      The Name tag is often used to give a user-friendly identifier for the resource. Combining multiple values in Name is fine, but consider if they’re meaningful and concise enough to help identify the resource.

Hyphens (-) instead of spaces: This avoids potential issues with spaces in tag values.
The rest remains the same, maintaining the consistency of your Name tag and leveraging your default tags.

Final Thoughts:
  1.If your tags are for organizational purposes (e.g., identifying the project, environment, or owner), using a Name tag that combines meaningful identifiers like Project-VPC-Name is 
  perfectly fine.
  2.Just avoid spaces in tags to ensure compatibility across AWS services and tools.

*/
