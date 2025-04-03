variable "vpc_id" {
  description = "The ID of the VPC in which the Security Group will be created"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^vpc-[a-f0-9]{8,}$", var.vpc_id))
    error_message = "The vpc_id must be a valid AWS VPC ID (e.g., 'vpc-xxxxxxxx' or 'vpc-xxxxxxxxxxxxxxxx') and cannot be empty."
  }
}

variable "security_group_name" {
  description = "The name of the Security Group"
  type = string
  default = "main"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9-_ ]+$", var.security_group_name)) && length(var.security_group_name) <= 255
    error_message = "The security_group_name must contain only letters, numbers, spaces, hyphens, or underscores (max 255 characters)."
  }
}

variable "vpc_name" {
  description = "The name of the VPC in which the Security Group will be created"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_ ]*$", var.vpc_name))
    error_message = "The vpc_name can be empty string or must contain only letters, numbers, spaces, hyphens, or underscores."
  }
}



variable "ingress_rules" {
   description = "A list of ingress rules to be added to the Security Group."

    type = list(object({
    cidr_ipv4       = optional(string, null) # VPC CIDR, or If you are using a custom CIDR or custom IP address in an ingress rule, that CIDR or IP addres must fall within the VPC CIDR block where the security group is defined.
    from_port       = optional(number, null)
    ip_protocol     = string
    to_port         = optional(number, null)
    description     = optional(string, null)
    cidr_ipv6       = optional(string, null)
    prefix_list_id  = optional(string, null)
    tags            = optional(map(string), null)
  }))
  default = [ 
    {
    cidr_ipv4   = "0.0.0.0/16"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
    } 
  ]
  
  validation {
    condition = anytrue([
      for rule in var.ingress_rules :
        (
          (
           can(regex("^(tcp|udp|icmp|icmpv6)$", rule.ip_protocol)) ||
           can(tonumber(rule.ip_protocol) >= 0 && tonumber(rule.ip_protocol) <= 255)
          ) &&

          (
          can( (tonumber(rule.from_port) <= tonumber(rule.to_port))) || 
          (rule.from_port == null && rule.to_port == null) 
          ) &&

          can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", rule.cidr_ipv4))
        ) ||

        ( 
          rule.ip_protocol == "-1" && rule.from_port == null && rule.to_port == null &&
          can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", rule.cidr_ipv4))
        )
    ])
    error_message = <<EOT
      Invalid ingress rule: 
      - 'ip_protocol' must be one of 'tcp', 'udp', 'icmp', 'icmpv6', '-1' (all protocols), or a number between 0-255.
      - If 'ip_protocol' is '-1', both 'from_port' and 'to_port' should not be defined.
      - Ensure that 'from_port' is less or equal 'to_port'if the protocol is not '-1.
      - 'cidr_ipv4' must be a valid CIDR block (e.g., '192.168.1.0/24').
      EOT
  }
}

variable "egress_rules" {
  description = "A list of egress rules to be added to the Security Group"

  type = list(object({
    cidr_ipv4       = optional(string, null)
    from_port       = optional(number, null)
    ip_protocol     = optional(string, null)
    to_port         = optional(number, null)
    description     = optional(string, null)
    cidr_ipv6       = optional(string, null)
    prefix_list_id  = optional(string, null)
    tags            = optional(map(string), null)
  }))
  default = [ 
    {
    
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "-1"
    } 
  ]

  validation {
    condition = anytrue([
      for rule in var.egress_rules :
        (
          (
           can(regex("^(tcp|udp|icmp|icmpv6)$", rule.ip_protocol)) ||
           can(tonumber(rule.ip_protocol) >= 0 && tonumber(rule.ip_protocol) <= 255)
          ) &&

          (
          can( (tonumber(rule.from_port) <= tonumber(rule.to_port))) || 
          (rule.from_port == null && rule.to_port == null) 
          ) &&

          can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", rule.cidr_ipv4))
        ) ||

        (  
          rule.ip_protocol == "-1" && rule.from_port == null && rule.to_port == null &&
          #The regex checks cidr_ipv4 for valid IP address format and valid CIDR notation (x.x.x.x/n).
          can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))/(3[0-2]|[12]?[0-9])$", rule.cidr_ipv4))
        )
    ])   
    error_message = <<EOT
      Invalid egress rule: 
      - 'ip_protocol' must be one of 'tcp', 'udp', 'icmp', 'icmpv6', '-1' (all protocols), or a number between 0-255.
      - If 'ip_protocol' is '-1', both 'from_port' and 'to_port' should not be defined.
      - Ensure that 'from_port' is less or equal 'to_port'if the protocol is not '-1.
      - 'cidr_ipv4' must be a valid CIDR block (e.g., '192.168.1.0/24').
      EOT
  }
}

variable "default_tags" {
  description = "Default Tags to apply to all resources"
  type        = map(string)

  default     = {
    Project     = ""
    Owner       = ""
    Environment = ""
 }

  validation {
    condition = alltrue([
      for v in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100
    ]) && (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    error_message = <<EOT
      - Tag values must be 1-100 characters long, contain only lowercase letters, numbers, and hyphens (-), and cannot contain spaces or underscores (_).
      - Environment tag must not be empty or must be one of the allowed values ["dev", "stage", "prod", "test", "qa"].
      EOT
  }
}
