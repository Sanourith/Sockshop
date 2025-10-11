data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_instance" "grafana" {
  ami               = var.instance_ami
  instance_type     = var.instance_type
  user_data = <<EOF
  #! /bin/bash
  sudo apt-get install -y apt-transport-https software-properties-common wget
  sudo mkdir -p /etc/apt/keyrings/
  wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
  sudo apt-get update
  sudo apt-get install grafana -y
  EOF
  security_groups      = [aws_security_group.grafana.name]
  key_name             = var.key_name
  subnet_id            = data.terraform_remote_state.eks.outputs.public_subnets[0]
  monitoring           = true
  tags = {
    Name = "monitoring-grafana"
  }
}

resource "aws_security_group" "grafana" {
  name        = "grafana"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = data.terraform_remote_state.eks.outputs.vpc_id

  tags = {
    Name = "allow_tls"
  }

  ingress {
    description = "Allow grafana traffic"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
