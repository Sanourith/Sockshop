data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

module "prometheus" {
  source                 = "./modules/prometheus"
  vpc_security_group_ids = [data.terraform_remote_state.eks.outputs.eks_security_group_id, aws_security_group.prom-sg.id]
  public_subnet_a        = data.terraform_remote_state.eks.outputs.public_subnets[0]
}

# SECURITY GROUP
resource "aws_security_group" "prom-sg" {
  name        = "prometheus-sg"
  description = "Allow SSH & Prometheus ports inbound traffic and all outbound traffic"
  # vpc_id      = aws_vpc.main.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
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

module "grafana" {
  source              = "./modules/grafana"
  # hostname            = var.hostname_grafana
  # password            = var.password
  # config_bucket_name  = var.config_bucket_name
  # letsencrypt_email   = var.letsencrypt_email
  # key_name            = var.key_name
  # instance_ami        = data.aws_ami.ubuntu.id
  # instance_profile    = aws_iam_instance_profile.ec2_profile.name
  # instance_type       = var.instance_type_grafana
}

