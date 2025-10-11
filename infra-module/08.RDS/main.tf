data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "shopshosty-bucket-terraform-s3"
    key    = "shopshosty/eks-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

# locals {
#   owners      = var.office
#   environment = var.environment
#   name        = "${var.office}-${var.environment}"

#   common_tags = {
#     owners      = local.owners
#     environment = local.environment
#   }
#   # eks_cluster_name = "${local.name}-${var.cluster_name}"
# }

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "db-rds"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.medium"
  allocated_storage = 20

  db_name  = "sockshop"
  username = "maikiboss"
  password = "password"
  port     = 3306

  # Les paramètres maléables :
  iam_database_authentication_enabled = false # suppression IAM, co uniquement credentials
  storage_encrypted                   = false # suppr le chiffrement données pour éviter KMS
  skip_final_snapshot                 = true  # évite la sauvegarde au changement d'état
  manage_master_user_password         = false # force l'utilisation user/motdepasse

  vpc_security_group_ids = [module.mysql_security_group.security_group_id]
  db_subnet_group_name   = data.terraform_remote_state.eks.outputs.vpc_database_subnet_group_name

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  #   monitoring_interval    = "30"
  #   monitoring_role_name   = "MyRDSMonitoringRole"
  #   create_monitoring_role = true

  #   tags = {
  #     Owner       = "user"
  #     Environment = "dev"
  #   }

  # DB subnet group
  create_db_subnet_group = false
  subnet_ids             = ["subnet-038adaf0f4aee9a81", "subnet-0a02c674b9a968513"]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

  #   parameters = [
  #     {
  #       name  = "character_set_client"
  #       value = "utf8mb4"
  #     },
  #     {
  #       name  = "character_set_server"
  #       value = "utf8mb4"
  #     }
  #   ]

  #   options = [
  #     {
  #       option_name = "MARIADB_AUDIT_PLUGIN"

  #       option_settings = [
  #         {
  #           name  = "SERVER_AUDIT_EVENTS"
  #           value = "CONNECT"
  #         },
  #         {
  #           name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #           value = "37"
  #         },
  #       ]
  #     },
  #   ]
}


module "mysql_security_group" {
  name    = "mysql-rds"
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  version = "~> 5.0"
  vpc_id  = data.terraform_remote_state.eks.outputs.vpc_id
  # availability_zone = "eu-west-3a"
  # from_port = 3306
  # to_port = 3306
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # omitted...
}

# # Joindre l'auto-scaling à la RDS :
# resource "aws_security_group_rule" "allow_mysql_access_from_wordpress" {
#   description              = "rattachement ec2rds"
#   type                     = "ingress"
#   from_port                = 3306
#   to_port                  = 3306
#   protocol                 = "tcp"
#   security_group_id        = module.mysql_security_group
#   source_security_group_id = module.autoscaling.autoscaling_security_group_id

#   depends_on = [module.autoscaling]
# }

resource "aws_security_group_rule" "allow_eks_to_rds" {
  description              = "rattachement EKS to RDS"
  type                     = "ingress"
  from_port                = 3306 # Changez en fonction du port de votre RDS (5432 pour PostgreSQL, 3306 pour MySQL, etc.)
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.mysql_security_group.security_group_id # Groupe de sécurité RDS
  source_security_group_id = data.terraform_remote_state.eks.outputs.eks_security_group_id
}

