resource "aws_security_group" "this" {
  name   = "${var.vpc_name}-${var.security_group_name}"
  vpc_id = var.vpc_id
  tags   = merge(var.default_tags, { Name = join(" ", compact([var.default_tags["Project"], var.vpc_name, var.security_group_name])) })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.ingress_rules : k => v }

  security_group_id = aws_security_group.this.id

  cidr_ipv4      = each.value.cidr_ipv4
  ip_protocol    = each.value.ip_protocol
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  description    = each.value.description
  cidr_ipv6      = each.value.cidr_ipv6
  prefix_list_id = each.value.prefix_list_id
  tags           = each.value.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.egress_rules : k => v }

  security_group_id = aws_security_group.this.id

  cidr_ipv4      = each.value.cidr_ipv4
  ip_protocol    = each.value.ip_protocol
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  description    = each.value.description
  cidr_ipv6      = each.value.cidr_ipv6
  prefix_list_id = each.value.prefix_list_id
  tags           = each.value.tags

  lifecycle {
    create_before_destroy = true
  }
}
