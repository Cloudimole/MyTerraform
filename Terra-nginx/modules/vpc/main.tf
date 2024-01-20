variable "region" {
  default = "us-east-1"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "terragate" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "Terraform Internet Gateway"
  }
}

resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terragate.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route.id
}

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

