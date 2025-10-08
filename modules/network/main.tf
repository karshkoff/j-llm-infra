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
