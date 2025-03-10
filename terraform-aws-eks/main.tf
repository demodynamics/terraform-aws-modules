terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------------------- EKS Cluster ---------------------------------------------------------- #
resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.default_tags["Project"]}_eks_cluster"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling. Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment,
  ]
}

# ---------------------------------------------------------- Node Group (Nodes) ---------------------------------------------------------- #
# A node group is one or more EC2 instances that are deployed in an EC2 Auto Scaling group. EKS nodes are standard Amazon EC2 instances.
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.default_tags["Project"]}_node_goup"
  node_role_arn   = var.node_goup_role_arn
  subnet_ids      = var.subnet_ids
  
  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_type

  scaling_config {
    desired_size = var.node_scale_desired_size
    max_size     = var.node_scale_max_size
    min_size     = var.node_scale_min_size
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_role_attachment,
  ]
}
