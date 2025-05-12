output "output_data" {
  description = "The fargate profiele details"
  value = {
    arn  = aws_eks_fargate_profile.this.arn
    id   = aws_eks_fargate_profile.this.id
  }
  
}