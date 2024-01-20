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

# Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Custom subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Desired availability zone
  map_public_ip_on_launch = true  # Important
}

# Route table for the public subnet
resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terragate.id
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route.id
}

# Internet gateway settings
resource "aws_internet_gateway" "terragate" {
  vpc_id = aws_vpc.custom_vpc.id
}

# Security group
resource "aws_security_group" "terra_sg" {
  name        = "terra_sg"
  description = "Allow SSH on 22 & HTTP on port 80"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["151.227.41.0/24"]  # Limited SSH access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["151.227.41.0/24"]  # Limited HTTP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resources
resource "aws_instance" "aws_ubuntu" {
  instance_type          = "t2.micro"
  ami                    = "ami-052efd3df9dad4825"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.terra_sg.id]
  user_data              = file("userdata.tpl")
  associate_public_ip_address = true

  tags = {
    Name = "MyTerraInstance"
    Environment = "Testing"
  }
}

# Output
output "aws_instance_public_dns" {
  value = aws_instance.aws_ubuntu.public_dns
}