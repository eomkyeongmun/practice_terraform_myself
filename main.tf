provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

locals {
    az_a = "${var.region}a"
    az_b = "${var.region}b"

  # 서브넷
  public_a_cidr  = "10.0.1.0/24"
  public_b_cidr  = "10.0.2.0/24"
  private_a_cidr = "10.0.11.0/24"
  private_b_cidr = "10.0.12.0/24"
}

# 1) VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.name}-vpc" }
}

# 2) Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

# 3) Public Subnets (AZ a,b)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_a_cidr
  availability_zone       = local.az_a
  map_public_ip_on_launch = true # 퍼블릭 서브넷에 EC2 올리면 퍼블릭IP 자동 할당(실습 편의)

  tags = { Name = "${var.name}-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_b_cidr
  availability_zone       = local.az_b
  map_public_ip_on_launch = true

  tags = { Name = "${var.name}-public-b" }
}

# 4) Private Subnets (AZ a,b)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_a_cidr
  availability_zone = local.az_a

  tags = { Name = "${var.name}-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_b_cidr
  availability_zone = local.az_b

  tags = { Name = "${var.name}-private-b" }
}

# 5) Public Route Table (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 6) Public RT를 Public Subnet에 연결
resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}


