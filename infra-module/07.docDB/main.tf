data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/bastion/terraform.tfstate"
    region = var.aws_region
  }
}

locals {
  owners      = var.office
  environment = var.environment
  name        = "${var.office}-${var.environment}"

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${data.terraform_remote_state.eks.outputs.cluster_name}"
}

module "documentdb_cluster" {
  source = "cloudposse/documentdb-cluster/aws"
  version = "0.27.0" # Cloud Posse recommends pinning every module to a specific version
  namespace         = var.namespace
  stage             = var.stage
  name              = var.namedb
  cluster_size      = var.cluster_size
  db_port           = 27017
  storage_encrypted = false  # évite l'utilisation KMS pour la co
  master_username   = var.master_username
  master_password   = var.master_password
  instance_class    = var.instance_class
  vpc_id            = data.terraform_remote_state.eks.outputs.vpc_id
  subnet_ids        = data.terraform_remote_state.eks.outputs.private_subnets
  allowed_security_groups = [
    data.terraform_remote_state.bastion.outputs.security_group_id, 
    module.docdb-sg.security_group_id
    ]
  # zone_id                 = "Zxxxxxxxx"
}

module "docdb-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.namedb}-docdb-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = data.terraform_remote_state.eks.outputs.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = var.common_tags
}

resource "aws_security_group_rule" "allow_eks_to_docdb" {
  description              = "rattachement EKS to DocDB"
  type                     = "ingress"
  from_port                = 27017 # Changez en fonction du port de votre RDS (5432 pour PostgreSQL, 3306 pour MySQL, etc.)
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = module.docdb-sg.security_group_id # Groupe de sécurité RDS
  source_security_group_id = data.terraform_remote_state.eks.outputs.eks_security_group_id
}
