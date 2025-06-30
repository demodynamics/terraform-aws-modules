# A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group. EKS nodes are standard Amazon EC2 instances.
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-cluster-nodegroup"
  node_role_arn   = var.node_goup_role_arn
  subnet_ids      = var.subnet_ids # Subnets where the node group will be deployed
  tags            = var.default_tags

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_type

  disk_size = var.node_disk_size
  ami_type  = var.node_ami_type
  version   = var.node_k8s_version

  scaling_config {
    desired_size = var.node_scale_desired_size
    max_size     = var.node_scale_max_size
    min_size     = var.node_scale_min_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  labels = var.node_labels
  /*
If you do not set node_labels, Terraform will use their default values from variables.tf:
  node_labels will be an empty map ({}), so no labels will be applied to the nodes.
*/

  dynamic "taint" {
    for_each = var.taints_enabled && var.node_taints != [] ? var.node_taints : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
    /*
If you do not set node_taints in your root module, Terraform will use their default values from variables.tf:
  node_taints will be an empty list ([]), so no taints will be applied to the nodes
*/
  }


  dynamic "remote_access" {
    for_each = var.remote_access_enabled && var.ssh_key_name != null && var.sg_ids != null ? [1] : []
    content {
      ec2_ssh_key               = var.ssh_key_name
      source_security_group_ids = var.sg_ids
    }

    /*
This dynamic "remote_access" block in your Terraform code is used to optionally add the remote_access 
configuration to your EKS node group, but only if you provide the required variables.

**What is it for?**
- The remote_access block allows you to enable SSH access to your EKS worker nodes.
- It sets the SSH key (ec2_ssh_key) and the security groups (source_security_group_ids) that are allowed to 
connect via SSH.

**How does it work?**
- The for_each = var.node_ssh_key != null && var.node_ssh_source_sg_ids != null ? [1] : [] line means:
  - If both node_ssh_key and node_ssh_source_sg_ids are set (not null), the block is included (for_each = [1]).
  - If either is not set, the block is omitted (for_each = []).

**Where do the values come from?**
- var.node_ssh_key: This is a variable you define in your variables.tf (the name of your EC2 SSH key pair).
- var.node_ssh_source_sg_ids: This is a variable (a list of security group IDs) you define in your 
variables.tf (the security groups allowed SSH access).

**You set these values in your root module** when calling the node group module, for example:

```hcl
module "eks_node_group" {
  source = "../terraform-aws-eks-nodegroup"
  # ...other variables...
  node_ssh_key = "my-ssh-key"
  node_ssh_source_sg_ids = ["sg-12345678"]
}
```

If you do not set these variables (or set them to null), the remote_access block will not be included, and 
SSH access will not be enabled for your nodes.
*/
  }

  dynamic "launch_template" {
    for_each = var.enable_launch_template && var.launch_template_id != null ? [1] : []
    content {
      id      = var.launch_template_id
      version = var.launch_template_version
    }
  }

  /*
Here’s the flow:

1. **Create additional security groups** as needed.
2. **Pass those security group IDs** to your launch template module using the variable (e.g., sg_ids).
3. In your launch template resource, set:
   - `vpc_security_group_ids = var.sg_ids`
   - `instance_type = var.instance_type[0]`
4. The launch template will now launch EC2 instances with those security groups and instance type.
5. In your EKS node group module, add a dynamic `launch_template` block and set:
   - `id      = var.launch_template_id` (from your launch template module output)
   - `version = var.launch_template_version` (from your launch template module output)
6. Set `enable_launch_template = true` in your node group module call.

**Result:**  
Your EKS node group will use the specified launch template, and all EC2 instances in the node group will have 
the additional security groups and instance type you defined in the launch template.

This is the recommended and production-grade way to attach custom security groups to EKS node groups using 
Terraform and AWS best practices.
  */

  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }
}


/*
It’s a good practice to use create_before_destroy for EKS node groups to ensure zero-downtime updates when possible.
Keep in mind: AWS may have limits on the number of node groups per cluster, so this may not always be possible if 
you’re at the limit.
  */


/*
Note:
In the context of EKS node groups, an Auto Scaling Group (ASG) is automatically managed by AWS when you 
create an `aws_eks_node_group` resource.

**Key points:**
- Each EKS node group creates and manages its own EC2 Auto Scaling Group under the hood.
- You do not need to define the ASG directly; Terraform and AWS handle it for you.
- The node group’s scaling_config (desired_size, min_size, max_size) maps directly to the ASG’s scaling settings.
- The ASG ensures the desired number of EC2 worker nodes are always running, automatically replacing unhealthy
 nodes and scaling up/down as needed.
- If you use a launch template, it is attached to the ASG created by the node group.

**Summary:**  
You don’t manage the ASG directly in EKS node group modules—AWS creates and manages it for you based on your 
node group configuration. All scaling, health checks, and rolling updates are handled by the EKS-managed ASG.

========
Auto Scaling Groups (ASGs) exist in several AWS contexts, not just EKS node groups. Here are the main 
contexts where ASGs are used:

1. **EC2 Auto Scaling (standalone):**
   - You can create an ASG directly to manage a fleet of EC2 instances for any workload (web servers, app 
   servers, etc.).
   - The ASG automatically handles scaling, health checks, and replacement of unhealthy instances.

2. **EKS Node Groups:**
   - As discussed, each EKS managed node group creates and manages its own ASG under the hood.

3. **Elastic Beanstalk:**
   - AWS Elastic Beanstalk environments for EC2 use ASGs to manage the number of instances running your 
   application.

4. **ECS (EC2 launch type):**
   - When running ECS (Elastic Container Service) with EC2 launch type, you often use an ASG to manage the 
   EC2 instances that run your containers.

5. **Custom Launch Templates/Configurations:**
   - You can attach a launch template or launch configuration to an ASG to control how new instances are 
   launched (AMI, instance type, user data, etc.).

**Summary:**  
ASGs are a core AWS service for managing fleets of EC2 instances, providing automatic scaling, health
 management, and integration with many AWS services (EKS, ECS, Beanstalk, etc.).

*/

