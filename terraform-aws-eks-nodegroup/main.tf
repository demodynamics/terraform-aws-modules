# A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group. EKS nodes are standard Amazon EC2 instances.
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-cluster-nodegroup"
  node_role_arn   = var.node_goup_role_arn
  subnet_ids      = var.subnet_ids # Subnets where the node group will be deployed
  tags            = var.default_tags

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_type

  scaling_config {
    desired_size = var.node_scale_desired_size
    max_size     = var.node_scale_max_size
    min_size     = var.node_scale_min_size
  }
}
