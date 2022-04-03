provider "aws" {
  region = var.region
}

resource "aws_vpc" "module_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true #aplies to publicly available ec2 instances

  tags{
    Name = "Production_VPC"
  }
}

#create public subnet
resource "aws_subnet" "module_public_subnet_1" {
  vpc_id = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_1_cidr_block
  # we will extend our availability to 3 availability zones
  availability_zone = "${var.region}a"
#  map_public_ip_on_launch = true
  tags{
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "module_public_subnet_2" {
  vpc_id = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_2_cidr_block
  availability_zone = "${var.region}b"
  tags{
    Name = "Public-Subnet-2"
  }
}

resource "aws_subnet" "module_public_subnet_3" {
  vpc_id = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_3_cidr_block
  availability_zone = "${var.region}c"
  tags{
    Name = "Public-Subnet-3"
  }
}

# create our private subnets
resource "aws_subnet" "module_private_subnet_1" {
  cidr_block = var.private_subnet_1_cidr_block
  vpc_id = aws_vpc.module_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "module_private_subnet_2" {
  cidr_block = var.private_subnet_2_cidr_block
  vpc_id = aws_vpc.module_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

resource "aws_subnet" "module_private_subnet_3" {
  cidr_block = var.private_subnet_3_cidr_block
  vpc_id = aws_vpc.module_vpc.id
  availability_zone = "${var.region}c"

  tags = {
    Name = "Private-Subnet-3"
  }
}

# create route table for public subnets/routes
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.module_vpc.id

  tags{
    Name = "Public-Route-Table"
  }
}