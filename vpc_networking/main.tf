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