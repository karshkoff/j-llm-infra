# VPC

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.tags.project}-vpc" })
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
