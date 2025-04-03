data "aws_availability_zones" "available" {
  state = "available"
 
}


locals {

  subnets_total_count = var.public_subnets_count + var.private_subnets_count
  
  /* Extracts 16 from "10.0.0.0/16" - Terraform's split() function splits a string into a list` ["10.0.0.0", "16"] based on a delimiter and 
   we access the second element using [1]. In this case, "/" is the delimiter. split("/", "10.0.0.0/16")[1] returns string "16", but tonumber() 
   function makes it a number`16. split("/", "10.0.0.0/16")[1] > "16" and  tonumber(split("/", "10.0.0.0/16")[1]) > 16 */
  vpc_prefix_length = tonumber(split("/", var.vpc_cidr)[1])
  
  #This for expression returns a list of strings` list of cidrs.
  subnet_cidrs = [for i in range(local.subnets_total_count) : cidrsubnet(var.vpc_cidr, var.subnet_prefix - local.vpc_prefix_length, i)] 

  # coalesce(var.public_subnets_count, 0): If var.public_subnets_count is null, it returns 0.  
  # != 0 -  Ensures the value is not 0. his effectively checks that var.public_subnets_count is not null and not 0 in a more concise way.
  # In Terraform (and most programming languages), the end index in a slice function is not included. So, when you use: slice(local.subnet_cidrs, 0, 3), It will return the elements from index 0 up to, but not including, index 3. That means it will return the elements at indices 0, 1, and 2—which is 3 elements in total.
  public_subnet_cidrs = coalesce(var.public_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : [] # Long version: public_subnet_cidrs = var.public_subnets_count != 0 && var.public_subnets_count != null ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : []
  private_subnet_cidrs = coalesce(var.private_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, var.public_subnets_count, local.subnets_total_count):[] # Long version: private_subnet_cidrs = var.private_subnets_count != 0 && var.private_subnets_count != null ? slice(local.subnet_cidrs, var.public_subnets_count, var.subnets_count):[]
}

# Nat Gateway status Conditions
locals {
  nat_status = {
    per_az     = var.natgw_per_az && (var.natgw_per_subnet || !var.natgw_per_subnet) && !var.single_natgw # Logical negations (!) replace explicit == false for better readability. Avoid unnecessary conditions that are always true when another condition is met
    per_subnet = !var.natgw_per_az && var.natgw_per_subnet && !var.single_natgw
    single_nat = var.single_natgw  # Covers all cases where single_natgw is true
  }
}

locals {
    public_subnets_count = length(local.public_subnet_cidrs)
    private_subnets_count = length(local.private_subnet_cidrs)
}

# creating list of availability zones by length of seted availability zones count                                                            
locals {
    az_list = [for x in range(var.az_desired_count) : element(data.aws_availability_zones.available.names, x)]
/* 
  If we want to use var.az_count without range, so var.az_count should be a list or a range. (range(var.az_count)) is correct and recommended because It 
avoids errors when var.az_count is a number and ensures Terraform can iterate properly.
  As In this case, as var.az_count is a number, x would be itterate in range of that number, and would be and index from that range. For example` 
if var.az_count is 3, x would be 0, 1, 2`
  So, if var.az_count would be alist, x would be an element from that list. x would be an object from var.az_count list, not an object that contains element 
from var.az_count list. For example , if var.az_count is ["a", "b", "c"], x would be "a", "b", "c" and not {"a", "b", "c"}
*/
 }

locals {
  natgw_count = (local.nat_status.per_az && local.public_subnets_count > 0 && local.private_subnets_count > 0
  ? min(var.az_desired_count, local.public_subnets_count, local.private_subnets_count) 
  : local.nat_status.per_subnet && local.public_subnets_count >= local.private_subnets_count 
  ? local.private_subnets_count 
  : local.nat_status.single_nat && local.public_subnets_count > 0 
  ? 1 
  : 0
  )
  }

 locals {
   public_route_count = (var.public_route_per_sub && local.public_subnets_count > 0 
   ? local.public_subnets_count 
   : !var.public_route_per_sub && local.public_subnets_count > 0 
   ? 1 
   : 0)
 }



#------------- VPC -----------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_dns
  enable_dns_hostnames = var.vpc_dns
  tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC"})

  lifecycle {
    precondition {
      condition     = var.az_desired_count <= length(data.aws_availability_zones.available.names) # If var.az_desired_count exceeds available AZs, Terraform stops with an error.
      error_message = "Error: var.az_desired_count exceeds the available AZs in this region!"
    }
    precondition {
      condition =  local.nat_status.single_nat && local.public_subnets_count > 0 && local.private_subnets_count > 0 || !local.nat_status.single_nat
      error_message = "Error: when single_natgw = true,  local.public_subnet_count must be > 0  and local.private_subnet_count must be > 0"
    }
    precondition {
      condition = local.nat_status.per_az && local.public_subnets_count > 0 && local.private_subnets_count > 0 || !local.nat_status.per_az
      error_message = "Error: when natgw_per_az = true,  local.public_subnet_count must be > 0  and local.private_subnet_count must be > 0"
    }
    precondition {
      condition = local.nat_status.per_subnet && local.public_subnets_count >= local.private_subnets_count || !local.nat_status.per_subnet
      error_message = "Error: when natgw_per_subnet = true,  local.public_subnet_count must be >= local.private_subnet_count"
    }
  }

}

#---------------------------------------------Subnets--------------------------------------------
resource "aws_subnet" "public" {
  count                   = local.public_subnets_count!=0?local.public_subnets_count:0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(local.az_list, count.index % var.az_desired_count)
  map_public_ip_on_launch = var.map_public_ip_on_launch
   
   #Adding new key "Name" and its value "Public Subnet ${count.index}" to default_tags
   tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC Public Subnet ${count.index}" } ) 
}

resource "aws_subnet" "private" {
  count             = local.private_subnets_count!=0?local.private_subnets_count:0 # If we have count attribute in resource, so it means that it is returns a list of resources, so we have list of that type of resources.
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(local.az_list, count.index % var.az_desired_count)

 tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC Private Subnet ${count.index}" } )
}

#----------------IGW--------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC Internet Gateway" } )
}

#--------Elastic IP (Static Public IP)-------
resource "aws_eip" "eip" {
  count      = local.natgw_count
  domain     = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = merge(var.default_tags, { Name = "Elastic IP ${count.index} for NAT Gateway ${count.index} in ${var.vpc_name} VPC" } )
}

#----------NAT Gateway------------------------------
resource "aws_nat_gateway" "nat" {
  count         = local.natgw_count
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC NAT Gateway ${count.index}" } )
}

#-------------Route Tables-----------------
resource "aws_route_table" "private" {
  count  = local.natgw_count
  vpc_id = aws_vpc.vpc.id

  route {
     cidr_block     = var.route_cidr
     nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC Private Route Table ${count.index}" } )
}

resource "aws_route_table" "public" {
  count = local.public_route_count
  vpc_id = aws_vpc.vpc.id

  route {
     cidr_block     = var.route_cidr
     gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.default_tags, { Name = "${var.vpc_name} VPC Public Route Table" } )
}

#----------------- Route Tables Association ---------------------

resource "aws_route_table_association" "private_association" {
  count          = local.natgw_count!=0 ? local.private_subnets_count : 0
  subnet_id      = aws_subnet.private[count.index].id # Required: Subnet ID
  route_table_id = aws_route_table.private[count.index % local.natgw_count].id
}

resource "aws_route_table_association" "public_association" {
  count          = local.public_subnets_count
  subnet_id      = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public[count.index % local.public_route_count].id
}

/*
When local.public_route_count = 1, it means there is only one route table (aws_route_table.public[0]).

Behavior of count.index % 1
count.index % 1 always results in 0 regardless of count.index because any number modulo 1 is always 0.

Example Calculation:
If count.index iterates over multiple subnets (count = local.public_cidr_count), let's see how % 1 behaves:

count.index	   count.index % 1	     Selected aws_route_table.public Index
0	             0 % 1 = 0	           aws_route_table.public[0]
1	             1 % 1 = 0	           aws_route_table.public[0]
2	             2 % 1 = 0	           aws_route_table.public[0]
3	             3 % 1 = 0	           aws_route_table.public[0]
n	             n % 1 = 0	           aws_route_table.public[0]

Since public_route_count = 1, Terraform only creates one route table (aws_route_table.public[0]).
Thus, every subnet will always be associated with aws_route_table.public[0].id.



When local.public_route_count > 1, it means there will be more than one route table (aws_route_table.public[n]).
 For example : local.public_route_count = 4

Behavior of count.index % 1
count.index % 1  will distribute subnets across multiple route tables.

Example Calculation:
If count.index iterates over multiple subnets (count = local.public_cidr_count), let's see how % 4 behaves:

count.index	   count.index % 1	     Selected aws_route_table.public Index
0	             0 % 4 = 0	           aws_route_table.public[0]
1	             1 % 4 = 1	           aws_route_table.public[1]
2	             2 % 4 = 2	           aws_route_table.public[2]
3	             3 % 4 = 3	           aws_route_table.public[3]
4	             4 % 4 = 3	           aws_route_table.public[0]
5	             5 % 4 = 3	           aws_route_table.public[1]
6	             6 % 4 = 2	           aws_route_table.public[2]
7	             7 % 4 = 3	           aws_route_table.public[3]
8	             8 % 4 = 0	           aws_route_table.public[0]
9	             9 % 4 = 1	           aws_route_table.public[1]
10	           10 % 4 = 2	           aws_route_table.public[2]
11	           11 % 4 = 3	           aws_route_table.public[3]
n	              n % 4 = 0 or 1 or 2 or 3  aws
*/

resource "aws_security_group" "security_group" {
    vpc_id = aws_vpc.vpc.id

    dynamic "ingress" {
        for_each = var.sg_ports
        content {
          from_port   = ingress.value
          to_port     = ingress.value
          protocol    = "tcp"
          cidr_blocks = [var.vpc_cidr]
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Adding new key "Name" and its value "var.default_tags["Environment"]} Security Group" to default_tags, where var.default_tags["Environment"] takes value of Environment key from default.tags and put it in front of " Security Group".
    tags = merge(var.default_tags, { Name = "${var.default_tags["Environment"]} ${var.vpc_name} VPC Security Group" }) 
  

  lifecycle {
    create_before_destroy = true
  }

}