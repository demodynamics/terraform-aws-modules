output "output_data" {
  description = "VPC Details"
  value = {
    "VPC ID"                  = aws_vpc.vpc.id
    "VPC Inetrnet Gateway ID" = aws_internet_gateway.igw.id
    "Subnet ID's"             = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    "Public Subnet ID"        = aws_subnet.public[*].id
    "Public Subenet AZNames"  = aws_subnet.public[*].availability_zone
    "Private Subnet ID"       = aws_subnet.private[*].id
    "Private Subenet AZNames" = aws_subnet.private[*].availability_zone
  }
}

