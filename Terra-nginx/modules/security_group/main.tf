variable "vpc_id" {}

resource "aws_security_group" "terra_sg" {
  name        = "terra_sg"
  description = "Allow SSH on 22 & HTTP on port 80"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["151.227.41.0/24"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["151.227.41.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform Security Group"
  }
}

output "security_group_id" {
  value = aws_security_group.terra_sg.id
}

