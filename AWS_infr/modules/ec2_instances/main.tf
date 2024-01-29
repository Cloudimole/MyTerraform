module "vpc" {
  source = "../vpc"

  vpc_cidr_block = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_ssh_and_web" {
  name        = "allow_ssh_and_web"
  description = "Allow SSH and HTTP/HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_servers" {
  count         = 2
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_web.id]
  key_name      = "TerraLearn"

  tags = {
    Name = "${format("web-server-%d", count.index + 1)}"
  }

  user_data = <<-EOF
    #!/bin/bash
    if [[ $HOSTNAME =~ "web-server-1" ]]; then
      sudo apt-get update -y
      sudo apt-get install -y nginx
    else
      sudo apt-get update -y
      sudo apt-get install -y apache2
    fi
  EOF
}
