
resource "aws_launch_template" "this" {
  name_prefix            = var.prefix
  description            = var.description
  image_id               = var.image_id ## If null, AWS will let EKS pick the AMI.# image_id is optional, if not provided, EKS will use the default AMI
  instance_type          = var.instance_type[0]
  vpc_security_group_ids = var.sg_ids
}


/*
The line name_prefix = "${var.cluster_name}-ng-" sets a prefix for the name of the launch template.

name_prefix: This argument tells AWS to generate a unique name for the launch template that starts with the 
given prefix.
"${var.cluster_name}-ng-": This uses the value of your cluster_name variable, followed by "-ng-", to create a 
meaningful and unique prefix (e.g., "mycluster-ng-12345").
This helps you easily identify which launch template belongs to which EKS cluster and node group, and ensures 
name uniqueness in AWS.
*/


/*
The line vpc_security_group_ids = var.node_additional_sg_ids in your launch template resource assigns a list 
of security group IDs to the EC2 instances created by the launch template.

vpc_security_group_ids: This argument specifies which security groups will be attached to the EC2 instances 
launched by this template.
var.sg_ids: This is a variable (a list of security group IDs) that you provide, allowing you 
to attach custom or additional security groups to your worker nodes.
This is useful for adding extra network rules (e.g., allowing access from monitoring, logging, or other 
services) beyond the default security groups that EKS attaches to node groups. By making this a variable, 
your module is more flexible and production-ready.*/


/*
The line instance_type = var.instance_type[0] sets the EC2 instance type for the launch template.

- instance_type: This argument defines the type of EC2 instance (e.g., t3.medium, m5.large) that will be 
launched.
- var.instance_type[0]: This takes the first value from the instance_type variable, which is a list 
of instance types. By using [0], you select the primary/default instance type for the launch template.

This approach allows you to pass a list of instance types (for flexibility in the EKS node group), but the 
launch template itself only supports a single instance type, so you use the first one from the list.*/
