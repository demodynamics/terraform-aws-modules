cluster_role_arn = "ARN of the EKS Cluster role that will be fetched from EKS Cluster role remote state"
node_goup_role_arn = "ARN of the Node Group role that will be fetched from Node Group role remote state"
subnet_ids = ["Subnet ID's of VPC Where the cluster and it's nodes will be created. Will be fetched from VPC's remote state"]
node_scale_desired_size = 1
node_scale_max_size = 2
node_scale_min_size = 1
node_capacity_type = "ON_DEMAND"
node_instance_type = ["t2.micro"]

default_tags = {
  Owner = "Demo Dynamics"
  Environment = "Dev"
  Project = "alco24"
}
