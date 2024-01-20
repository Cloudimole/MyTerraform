# Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "private_key_path" {}
variable "region" {
  default = "us-east-1"
}

# Provider
provider "aws" {
  region      = var.region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "instance" {
  source = "./modules/instance"
  ami                    = "ami-052efd3df9dad4825"  # Replace with your desired AMI
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = module.vpc.public_subnet_id
  security_group_ids     = [module.security_group.security_group_id]
  user_data              = file("userdata.tpl")
}

output "instance_public_ip" {
  value = module.instance.instance_public_ip
}

