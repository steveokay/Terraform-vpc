provider "aws" {
  region = var.region
}

resource "aws_vpc" "module_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true #aplies to publicly available ec2 instances

  tags = {
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
  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "module_public_subnet_2" {
  vpc_id = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_2_cidr_block
  availability_zone = "${var.region}b"
  tags = {
    Name = "Public-Subnet-2"
  }
}

resource "aws_subnet" "module_public_subnet_3" {
  vpc_id = aws_vpc.module_vpc.id
  cidr_block = var.public_subnet_3_cidr_block
  availability_zone = "${var.region}c"
  tags = {
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

  tags = {
    Name = "Public-Route-Table"
  }
}

# create route table for public subnets/routes
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.module_vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

# Associate Route Table with public subnets
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.module_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id = aws_subnet.module_public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  subnet_id = aws_subnet.module_public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Route Table with private subnets
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id = aws_subnet.module_private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id = aws_subnet.module_private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id = aws_subnet.module_private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

# create elastic ip for our nat gateway
# elastic ip gives flexibility for nat gateway to scale properly
resource "aws_eip" "elastic_ip_for_nat_gateway" {

  vpc = true # To use it for our vpc networking set vpc true
  associate_with_private_ip = var.eip_association_address

  tags = {
    Name = "Production-EIP"
  }
}

# create NAT Gateway and add to our routing table
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_for_nat_gateway.id
  subnet_id = aws_subnet.module_public_subnet_1.id

  tags = {
    Name = "Production-NAT-Gateway"
  }
}

# nat gw route
resource "aws_route" "nat_gateway_route" {
  route_table_id = aws_route_table.private_route_table.id
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# create internet gateway and add to routing table
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.module_vpc.id

  tags = {
    Name = "Production-Internet-Gateway"
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id = aws_route_table.public_route_table.id
  gateway_id = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

#implementing EC2 instance
#1.  ami
data "aws_ami" "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true # to get latest image

  filter {
    name = "virtualization-type"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    values = ["hvm"]
  }
}

#2.generate keypair using aws cli
# cmd :-> aws ec2 create-key-pair --key-name my-first-ec2-instance --region us-east-2 --query 'KeyMaterial' --output text > my-first-ec2-instance.pem

#3.create security group
resource "aws_security_group" "ec2-security-group" {
  name = "EC2-Instance-Security-Group"
  vpc_id = aws_vpc.module_vpc.id

  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#4. define resource for our aws instance
resource "aws_instance" "my-first-ec2-instance" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.ec2-security-group.id]
  subnet_id = aws_subnet.module_public_subnet_1.id
}