data "aws_region" "current" {}

data "aws_availability_zones" "this" {
  state = "available"
}


locals {
  subnets_total_count  = var.public_subnets_count + var.private_subnets_count
  vpc_prefix_length    = tonumber(split("/", var.vpc_cidr)[1])
  subnet_cidrs         = [for i in range(local.subnets_total_count) : cidrsubnet(var.vpc_cidr, var.subnet_prefix - local.vpc_prefix_length, i)]
  public_subnet_cidrs  = coalesce(var.public_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : []                          # Long version: public_subnet_cidrs = var.public_subnets_count != 0 && var.public_subnets_count != null ? slice(local.subnet_cidrs, 0, var.public_subnets_count) : []
  private_subnet_cidrs = coalesce(var.private_subnets_count, 0) != 0 ? slice(local.subnet_cidrs, var.public_subnets_count, local.subnets_total_count) : [] # Long version: private_subnet_cidrs = var.private_subnets_count != 0 && var.private_subnets_count != null ? slice(local.subnet_cidrs, var.public_subnets_count, var.subnets_count):[]

  az_list = [for x in range(var.az_desired_count) : element(data.aws_availability_zones.this.names, x)]

  use_natgw_per_az     = var.natgw_per_az && var.public_subnets_count > 0 && var.private_subnets_count > 0 && !var.single_natgw
  use_natgw_per_subnet = var.natgw_per_subnet && var.private_subnets_count > 0 && var.public_subnets_count >= var.private_subnets_count && !var.natgw_per_az && !var.single_natgw
  use_single_natgw     = var.single_natgw && var.public_subnets_count > 0 && var.private_subnets_count > 0

  natgw_count = (
    local.use_natgw_per_az ? length(local.az_list) :
    local.use_natgw_per_subnet ? var.private_subnets_count :
    local.use_single_natgw ? 1
  : 0)

  public_route_count = var.per_public_sub && var.public_subnets_count > 0 ? var.public_subnets_count : !var.per_public_sub && var.public_subnets_count > 0 ? 1 : 0
}

#------------- VPC -----------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_dns
  enable_dns_hostnames = var.vpc_dns
  tags                 = merge(var.default_tags, { Name = join("-", compact([var.default_tags["Project"], "vpc"])) })

  lifecycle {
    precondition {
      condition = var.az_desired_count <= length(data.aws_availability_zones.this.names)
      # error_message = "var.az_desired_count count (${var.az_desired_count}) exceeds available AZs count (${length(data.aws_availability_zones.this.names)}) of current (${data.aws_region.current.region}) region."
      error_message = "var.az_desired_count count exceeds available AZs count of current region."

    }
  }
}

#---------------------------------------------Subnets--------------------------------------------
resource "aws_subnet" "public" {
  count                   = var.public_subnets_count != 0 ? var.public_subnets_count : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(local.az_list, count.index % length(local.az_list))
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(var.default_tags, { Name = join("-", compact([var.default_tags["Project"], "vpc public subnet ${count.index}"])) })
}

resource "aws_subnet" "private" {
  count             = var.private_subnets_count != 0 ? var.private_subnets_count : 0 # If we have count attribute in resource, so it means that it is returns a list of resources, so we have list of that type of resources.
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(local.az_list, count.index % length(local.az_list))
  tags              = merge(var.default_tags, { Name = join("-", compact([var.default_tags["Project"], "vpc private subnet ${count.index}"])) })
}

#----------------IGW--------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.default_tags, { Name = join("-", compact(["", var.default_tags["Project"], "vpc internet gateway"])) })
}

#--------Elastic IP (Static Public IP)-------
resource "aws_eip" "this" {
  count      = local.natgw_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags       = merge(var.default_tags, { Name = join("-", compact(["elastic ip ${count.index} for", var.default_tags["Project"], "vpc", "nat gateway ${count.index}"])) })
}

#----------NAT Gateway------------------------------
resource "aws_nat_gateway" "this" {
  count         = local.natgw_count
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.default_tags, { Name = join("-", compact(["nat gateway ${count.index} of ", var.default_tags["Project"], "vpc"])) })
}

#-------------Route Tables-----------------
resource "aws_route_table" "private" {
  count  = local.natgw_count
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.default_tags, { Name = join("-", compact(["private route table ${count.index} of", var.default_tags["Project"], "vpc"])) })

  route {
    cidr_block     = var.route_cidr
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
}

resource "aws_route_table" "public" {
  count  = local.public_route_count
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.default_tags, { Name = join("-", compact(["public route table ${count.index} of", var.default_tags["Project"], "vpc"])) })

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.this.id
  }
}

#----------------- Route Tables Association ---------------------

resource "aws_route_table_association" "private" {
  count          = local.natgw_count != 0 ? var.private_subnets_count : 0
  subnet_id      = aws_subnet.private[count.index].id # Required: Subnet ID
  route_table_id = aws_route_table.private[count.index % local.natgw_count].id
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnets_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index % local.public_route_count].id
}

#------------- Region AZs Count Check -----------------

# locals{
#     # creating list of availability zones by range of desired availability zones count
#     az_list = [for x in range(min(var.az_desired_count, length(data.aws_availability_zones.this.names))) : element(data.aws_availability_zones.this.names, x)]
# }                                                            

# resource "null_resource" "warn_az_count" {
#   count = var.az_desired_count > length(data.aws_availability_zones.this.names) ? 1 : 0

#   provisioner "local-exec" {
#     command = <<EOT
# echo -e "Warning: var.az_desired_count count (${var.az_desired_count}) exceeds available AZs count (${length(data.aws_availability_zones.this.names)}) of current (${data.aws_region.current.name}) region.\nSo available AZs count (${length(data.aws_availability_zones.this.names)}) of current (${data.aws_region.current.name}) region will be used instead of var.az_desired_count."
# EOT
#   }
# }


# Creating list of availability zones by range of desired availability zones count                                                            
# az_list = [for x in range(var.az_desired_count) : element(data.aws_availability_zones.this.names, x) if var.az_desired_count <= length(data.aws_availability_zones.this.names)]


/*

The i in for loop is used as the third argument to the cidrsubnet function, which is required. This argument specifies which subnet to generate within the 
parent CIDR block.
The for loop (for i in range(local.subnets_total_count)) generates a sequence of numbers (0, 1, 2, ...).
For each i, cidrsubnet creates a unique subnet by incrementing the network address.
This way, you get a list of non-overlapping subnet CIDRs inside your VPC.
Great question!  
The `i` at the end of the for loop in this line:

```hcl
subnet_cidrs = [for i in range(local.subnets_total_count) : cidrsubnet(var.vpc_cidr, var.subnet_prefix - local.vpc_prefix_length, i)]
```

is used as the **subnet number** for the `cidrsubnet` function.

### Why do we use `i`?

- The `for i in range(local.subnets_total_count)` part loops from `0` up to the number of subnets you want.
- For each `i`, `cidrsubnet` generates a **unique subnet** by incrementing the network address.
- The `i` is the index that tells `cidrsubnet` which subnet to generate within the VPC block.

### What does this produce?

It creates a **list of subnet CIDRs**.  
For example, if you want 4 subnets in a `10.0.0.0/16` VPC with `/24` subnets, you get:

- `cidrsubnet("10.0.0.0/16", 8, 0)` → `10.0.0.0/24`
- `cidrsubnet("10.0.0.0/16", 8, 1)` → `10.0.1.0/24`
- `cidrsubnet("10.0.0.0/16", 8, 2)` → `10.0.2.0/24`
- `cidrsubnet("10.0.0.0/16", 8, 3)` → `10.0.3.0/24`

So, the `i` ensures each subnet is unique and sequential within the VPC.

---

**Summary:**  
The `i` is needed to generate a different CIDR block for each subnet, resulting in a list of non-overlapping subnets inside your VPC.
Summary:
The i is both the loop index and the required subnet number for cidrsubnet, ensuring each subnet CIDR is unique.


If you use cidrsubnet without a for loop, you must set the third argument (i) manually. It will generate just one subnet CIDR, based on the index you provide.

For example:

This will produce:

If you set i = 0, you get 10.0.0.0/24
If you set i = 1, you get 10.0.1.0/24
If you set i = 6, you get 10.0.6.0/24
Summary:

Without a loop, cidrsubnet creates only one subnet.
The third argument (i) selects which subnet to generate within the parent CIDR
*/
