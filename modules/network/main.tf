# VPC

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.tags.project}-vpc" })
}

# Public subnets

resource "aws_subnet" "public_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.101.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "us-east-1a-public-01"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.tags.project}" = "shared"
  })
}

resource "aws_subnet" "public_02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.102.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "us-east-1b-public-02"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.tags.project}" = "shared"
  })
}

# Private subnets

resource "aws_subnet" "private_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = merge(var.tags, {
    Name                                        = "us-east-1a-private-01"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.tags.project}" = "shared"
  })
}

resource "aws_subnet" "private_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = merge(var.tags, {
    Name                                        = "us-east-1b-private-02"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.tags.project}" = "shared"
  })
}

# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.tags.project}-igw" })
}

# NAT Gateway

resource "aws_eip" "nat_01" {
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "nat_01" {
  allocation_id = aws_eip.nat_01.id
  subnet_id     = aws_subnet.public_01.id

  tags = merge(var.tags, { Name = "${var.tags.project}-nat-az1" })
}

# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name    = "${var.tags.project}-public-subnets",
    Network = "public"
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_01" {
  subnet_id      = aws_subnet.public_01.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_02" {
  subnet_id      = aws_subnet.public_02.id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables

# AZ1

resource "aws_route_table" "private_01" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name    = "${var.tags.project}-private-subnet-az1",
    Network = "private01"
  })
}

resource "aws_route" "private_01" {
  route_table_id         = aws_route_table.private_01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_01.id
}

resource "aws_route_table_association" "private_01" {
  subnet_id      = aws_subnet.private_01.id
  route_table_id = aws_route_table.private_01.id
}

# AZ2

resource "aws_route_table" "private_02" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name    = "${var.tags.project}-private-subnet-az2",
    Network = "private02"
  })
}

resource "aws_route" "private_02" {
  route_table_id         = aws_route_table.private_02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_01.id
}

resource "aws_route_table_association" "private_02" {
  subnet_id      = aws_subnet.private_02.id
  route_table_id = aws_route_table.private_02.id
}

# ALB for EKS Ingress

resource "aws_lb" "main" {
  name               = "${var.tags.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_01.id, aws_subnet.public_02.id]

  tags = merge(var.tags, { Name = "${var.tags.project}-alb" })
}

resource "aws_lb_target_group" "main" {
  name     = "${var.tags.project}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.tags.project}-tg" })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.self_signed_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Security Group for ALB

resource "aws_security_group" "alb_sg" {
  name        = "${var.tags.project}-alb-sg"
  description = "Security group for eks ingress"
  vpc_id      = aws_vpc.main.id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "specific_ip_tls_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "188.91.152.191/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols
}

# Route53 Record for ALB

resource "aws_route53_zone" "main" {
  name = "${var.tags.project}.com"

  tags = var.tags
}

resource "aws_route53_record" "alb-record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "chat.${var.tags.project}.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
