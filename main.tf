module "vpc_networking" {
  source = "./vpc_networking"

  vpc_cidr_block = var.vpc_cidr_block

  public_subnet_1_cidr_block = var.public_subnet_1_cidr_block
  public_subnet_2_cidr_block = var.public_subnet_2_cidr_block
  public_subnet_3_cidr_block = var.public_subnet_3_cidr_block

  private_subnet_1_cidr_block = var.private_subnet_1_cidr_block
  private_subnet_2_cidr_block = var.private_subnet_2_cidr_block
  private_subnet_3_cidr_block = var.private_subnet_3_cidr_block

  eip_association_address = var.eip_association_address
  ec2_instance_type = var.ec2_instance_type
  ec2_keypair = var.ec2_keypair
}
