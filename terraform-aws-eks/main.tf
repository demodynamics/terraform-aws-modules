# ---------------------------------------------------------- EKS Cluster ---------------------------------------------------------- #
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  tags     = var.default_tags

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

# ---------------------------------------------------------- Node Group (Nodes) ---------------------------------------------------------- #
# A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group. EKS nodes are standard Amazon EC2 instances.
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-cluster-nodegroup"
  node_role_arn   = var.node_goup_role_arn
  subnet_ids      = var.subnet_ids
  tags            = var.default_tags
  
  capacity_type   = var.node_capacity_type
  instance_types  = var.node_instance_type

  scaling_config {
    desired_size  = var.node_scale_desired_size
    max_size      = var.node_scale_max_size
    min_size      = var.node_scale_min_size
  }
}


