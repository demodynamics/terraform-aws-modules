/*
Optional Object Type Attributes
 ==============================

variable "ingress_rules" {
   description = "A list of ingress rules to be added to the Security Group"
  type = list(object({
    cidr_ipv4       = optional(string, null)
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
}

Terraform typically returns an error when it does not receive a value for specified object attributes. When you mark an attribute as optional, Terraform instead 
inserts a default value for the missing attribute. This allows the receiving module to describe an appropriate fallback behavior.

To mark attributes as optional, use the optional modifier in the object type constraint. The following example creates optional attribute b and optional attribute 
with a default value c.

variable "with_optional_attribute" {
  type = object({
    a = string                # a required attribute
    b = optional(string)      # an optional attribute
    c = optional(number, 127) # an optional attribute with default value
  })
}

The optional modifier takes one or two arguments.

Type: (Required) The first argument specifies the type of the attribute.
Default: (Optional) The second argument defines the default value that Terraform should use if the attribute is not present. This must be compatible with the 
attribute type. If not specified, Terraform uses a null value of the appropriate type as the default.

An optional attribute with a non-null default value is guaranteed to never have the value null within the receiving module. Terraform will substitute the default 
value both when a caller omits the attribute altogether and when a caller explicitly sets it to null, thereby avoiding the need for additional checks to handle a 
possible null value.

Terraform applies object attribute defaults top-down in nested variable types. This means that Terraform applies the default value you specify in the optional 
modifier first and then later applies any nested default values to that attribute.


 ==============================

 validation {
    condition = alltrue([
      for v in values(var.default_tags) : 
        can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100
    ]) && (contains([""], var.default_tags["Environment"])
       || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]))
    

for v in values(var.default_tags) : can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100 ] -  -> This loop ensures all values in var.default_tags meet the regex 
condition (^[a-z0-9-]*$) and have a length of 1 to 100 characters.

contains([""], var.default_tags["Environment"] -> This checks if the "Environment" attribute in var.default_tags map is empty (""). If it is, it passes validation.
  If the "Environment" tag is empty, it will pass the validation without any further checks.

contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"])) -> This checks if the "Environment" attribute in var.default_tags map is one of 
the valid values in the list ["dev", "stage", "prod", "test", or "qa"]. 
    If the "Environment" tag is one of the valid values ("dev", "stage", "prod", "test", "qa"), , it will pass the validation.

alltrue() returns true if all elements in a given collection are true or "true". It also returns true if the collection is empty.
 So if in for v in values(var.default_tags) : can(regex("^[a-z0-9-]*$", v)) && length(v) <= 100 ] ` can(regex("^[a-z0-9-]*$", v)) will be true and length(v) <= 100, 
 and one of this (contains([""], var.default_tags["Environment"]) || contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"])) will true, 
 alltrue() will return true and the validation will pass.
    
 ==============================
lookup () retrieves the value of a single element from a map, given its key. If the given key does not exist, the given default value is returned instead.

lookup(var.default_tags, "Environment", "") == "": 
    This checks if the "Environment" attribute is not defined in var.default_tags map. If not, it passes validation, if it is defined, it fails validation.
  contains(["dev", "stage", "prod", "test", "qa"], lookup(var.default_tags, "Environment", "")): 
    This checks if the "Environment" attribute is defined in var.default_tags map and and it's value is one of the valid values in the list: "dev", "stage", "prod", "test", or "qa".
  lookup(var.default_tags, "Environment", "") != "": 
    This checks if the "Environment" attribute is defined ("") in var.default_tags map. If it is, it passes validation , if not defined, it fails validation.

The expression lookup(var.default_tags, "Environment", "") checks if the key "Environment" is defined in the var.default_tags map:
  If the key "Environment" is present in the map, it returns the value associated with that key.
  If the key "Environment" is not present, it returns the default value provided (in this case, an empty string "").
So, essentially:
  If "Environment" is defined, it returns its value.
  If "Environment" is not defined, it returns an empty string "".
This is useful for avoiding errors when trying to access a key that may not exist in the map.

Summary:
  lookup(var.default_tags, "Environment", "") only checks if the attribute exists and returns a default value (empty string in your case) if it's missing.
  If you need to ensure that "Environment" is both present and valid, use additional checks like lookup(..., "") != "" in your validation logic.


  ==============================
  can() evaluates the given expression and returns a boolean value indicating whether the expression produced a result without any errors.

    regex("^[a-z0-9-]*$", v) -> * (zero or more characters), allowing empty values)
      This means that no tag will contain spaces, underscores, or characters other than lowercase letters, numbers, and hyphens.
    can(regex("^[a-z0-9-]*$", v)) - can() returns true if the regex is valid.
    regex("^[a-z0-9-]+$", v) -> + (at least one character), not allowing empty values)
      This means that no tag will contain spaces, underscores, or characters other than lowercase letters, numbers, and hyphens.
    can(regex("^[a-z0-9-]+$", v)) -> * (zero or more characters), allowing empty values) 

 ==============================
  contains() determines whether the list, tuple, or set given in its first argument contains at least one element that is equal to the value in the second argument
   
    contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"]
     contains() determines whether the list given in its first argument` ["dev", "stage", "prod", "test", "qa"] contains at least one element that is equal to the 
     value in the second argument` var.default_tags["Environment"].
     If the value of Environment in the var.default_tags is not in the list`["dev", "stage", "prod", "test", "qa"], it will return false if exists true.
    
    !contains(["dev", "stage", "prod", "test", "qa"], var.default_tags["Environment"] 
     !contains() - determines whether the list given in its first argument` ["dev", "stage", "prod", "test", "qa"] NOt contains at least one element that is equal to
     the value in the second argument` var.default_tags["Environment"].
     If the value of Environment in the var.default_tags is not in the list`["dev", "stage", "prod", "test", "qa"], it will return true if exists false.
*/

 /* ==============================
  contains(keys(rule), "cidr_ipv4") &&
           can(regex("^(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$", rule.cidr_ipv4))

  Validate the CIDR block (must follow the correct format).This will successfully fail if the cidr_ipv4 is missing or incorrectly formatted.
        It ensures valid IP address ranges (0-255 per octet).
        It ensures a valid subnet mask (/0 to /32).
        It prevents incorrect CIDR formats.
*/

          
/* ==============================   
error_message = <<EOT
      Invalid ingress rule: 
      - 'ip_protocol' must be one of 'tcp', 'udp', 'icmp', 'icmpv6', '-1' (all protocols), or a number between 0-255.
      - If 'ip_protocol' is '-1', both 'from_port' and 'to_port' must be null.
      - Ensure that 'from_port' and 'to_port' are the same if the protocol is not '-1.
      - 'cidr_ipv4' must be a valid CIDR block (e.g., '192.168.1.0/24').
      EOT
      /*
      Why This is Better:
        ✅ Easier to read (bullet points help clarify each rule).
        ✅ **Uses a HEREDOC (<<EOT ... EOT) to handle multiline text properly.
        ✅ Keeps all validation errors in one structured message.
*/




/* ==============================
resource "aws_security_group" "this" {
  name        = var.security_group_name
  vpc_id      = var.vpc_id
  tags        = merge(var.default_tags, { Name = join(" ", compact([ trimspace(lookup(var.default_tags, "Project", "")), 
                trimspace(var.vpc_name), "VPC Security Group" ])) })
  lifecycle {
    create_before_destroy = true
  }
}


trimspace(...) removes any accidental leading/trailing spaces if the value exists but is empty.
compact([...]) removes any empty values from the list.
join(" ", [...]) ensures only non-empty values are concatenated with a space.

This guarantees that:
  If both Project and var.vpc_name are empty or unset, the Name will be just "VPC Security Group".
  If only Project is empty/unset, it will be "var.vpc_name VPC Security Group".
  If only var.vpc_name is empty/unset, it will be "Project VPC Security Group".
  If both are set, it will be "Project var.vpc_name VPC Security Group".
*/
          

/*
  variable "ingress_rules" {
    description = <<EOT
            A list of ingress rules to be added to the Security Group.
            - `cidr_ipv4`: Can be the VPC CIDR, the custom CIDR or IP address in CIDR notation ("192.168.100.0/24"). 
              Required if no `cidr_ipv6` or `prefix_list_id`.
            - `cidr_ipv6`: Optional, can be null.
            - `prefix_list_id`: Optional, can be null.
            - `from_port` and `to_port`: Optional, can be null.
            - `ip_protocol`: Required. Can be "tcp", "udp", "icmp", "icmpv6", "-1" (all protocols), or a number between 0-255.
            - `description`: Optional.
            - `tags`: Optional, can be null.
            EOT
      type = list(object({
      cidr_ipv4       = optional(string, null)
      from_port       = optional(number, null)
      ip_protocol     = string
      to_port         = optional(number, null)
      description     = optional(string, null)
      cidr_ipv6       = optional(string, null)
      prefix_list_id  = optional(string, null)
      tags            = optional(map(string), null)
    }))
  }


 variable "egress_rules" {
  description = <<EOT
          A list of egress rules to be added to the Security Group.
          - cidr_ipv4: required if no `cidr_ipv6` or `prefix_list_id`
              Can be: 
              The VPC CIDR: Usecase, Very rare, if you only want to allow outbound traffic to resources inside the VPC (e.g., internal services,
                databases, private APIs). 
              The custom CIDR: Most cases "0.0.0.0/0", allows full outbound access, which is typically fine unless you need strict control
                over outbound traffic.
              The custom IP address in CIDR notation: If you want to allow outbound traffic to a specific IP address or range 
                (e.g., external APIs, services, or partners).
              IP address in CIDR notation: cidr_ipv4   = "192.168.100.0/24" # On-prem network via VPN .
          - `cidr_ipv6`: Optional, can be null.
          - `prefix_list_id`: Optional, can be null.
          - `from_port` and `to_port`: Optional, can be null.
          - `ip_protocol`: Required. Can be "tcp", "udp", "icmp", "icmpv6", "-1" (all protocols), or a number between 0-255.
          - `description`: Optional.
          - `tags`: Optional, can be null.
          EOT
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
 }
*/
