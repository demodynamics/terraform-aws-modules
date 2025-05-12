resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = var.pod_execution_role_arn
  subnet_ids             = var.subnet_ids
  tags                   = var.default_tags

  selector {
    namespace = var.namespace
  }
}

/*
Important! To run Fargate in EKS Cluster, it is mandatory to create Private Subnet(s) in the
VPC and NAT Gateway(s) in the VPC for that Private Subnet(s).
 */


/*
Setup	                            Requires NAT Gateway?	                   Why
EKS + Fargate (private subnet)	      ✅ Yes, for internet access	   Because subnets can’t be public
ECS + Fargate (public subnet)	        ❌ No, public IP works	         ECS allows public subnets
EKS + EC2 nodes	                      ❌ Optional	                   You can place EC2 nodes in public subnets if you want
*/

/*
Alternatives to Save Costs

If you want to avoid NAT Gateway charges, consider:
  Use ECS Fargate, where you can assign public IPs directly in public subnets.
  Use EKS with EC2 nodes, not Fargate — EC2 nodes can live in public subnets.
  Set up VPC Endpoints for things like S3 or DynamoDB — avoids internet access for those services.
  Use PrivateLink or proxy setups for fine-grained control (more complex).
*/
