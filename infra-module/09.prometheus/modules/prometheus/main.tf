provider "aws" {
  region = "eu-west-3"
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_instance" "prometheus" {
  ami                    = var.instance_ami # AWS Linux
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  subnet_id              = data.terraform_remote_state.eks.outputs.public_subnets[0]
  # vpc_security_group_ids = [data.terraform_remote_state.eks.outputs.eks_security_group_id, aws_security_group.prom-sg.id]
  tags = {
    Name = "Prometheus-instance"
  }
  user_data = <<-EOF
            #! /bin/bash
            sudo yum update -y
            sudo yum install wget -y

            #Download Prometheus
            wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
            tar xvfz prometheus-2.45.0.linux-amd64.tar.gz
            cd prometheus-2.45.0.linux-amd64

            sudo mv prometheus /usr/local/bin/
            sudo mv promtool /usr/local/bin/

            # Create config directory
            sudo mkdir -p /etc/prometheus /var/lib/prometheus
            sudo mv consoles /etc/prometheus/
            sudo mv console_libraries /etc/prometheus/

            # Copy prometheus.yml
            sudo tee /etc/prometheus/prometheus.yml <<EOL
            global:
              scrape_interval: 15s
              evaluation_interval: 15s

            scrape_configs:
              - job_name: "prometheus"
                static_configs:
                  - targets: ["localhost:9090"]
            EOL
            # Start Prometheus
            nohup prometheus --config.file=/etc/prometheus/prometheus.yml > prometheus.log 2>&1 &
            EOF
}

# # SECURITY GROUP
# resource "aws_security_group" "prom-sg" {
#   name        = "prometheus-sg"
#   description = "Allow SSH & Prometheus ports inbound traffic and all outbound traffic"
#   # vpc_id      = aws_vpc.main.id
#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "Prometheus"
#     from_port   = 9090
#     to_port     = 9090
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }