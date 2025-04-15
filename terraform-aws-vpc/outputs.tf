output "output_data" {
  description = "VPC Details"
  value = {
    vpc_id                 = aws_vpc.vpc.id
    igw_id                 = aws_internet_gateway.this.id
    subnet_ids             = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    public_subnet_ids      = aws_subnet.public[*].id
    public_subnet_aznames  = aws_subnet.public[*].availability_zone
    private_subnet_ids     = aws_subnet.private[*].id
    private_subnet_aznames = aws_subnet.private[*].availability_zone
  }
}

