variable "aws_region" {
  description = "Region"
  type        = string
  default     = "eu-west-3"
}

variable "access_key" {
  description = "access_key"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  type        = string
}

variable "environment" {
  description = "Environment use as a prefix"
  type        = string
  default     = "dev"
}

variable "office" {
  description = "Office"
  type        = string
  default     = "sockshop"
}

# variable "private_subnets" {
#   type        = list(string)
#   description = ""
# }

variable "cluster_size" {
  type        = string
  description = "cluster_size"
  default     = "1"
}

variable "instance_class" {
  type        = string
  description = ""
  default     = "db.t3.medium"
}

variable "namedb" {
  type        = string
  description = "nom clusterdb"
  default     = "sockshop-db"
}

variable "namespace" {
  type        = string
  description = "namespace de notre docdb"
  default     = "sock-shop-docdb"
}

variable "stage" {
  type        = string
  description = "instance dev/prod/staging"
  default     = "staging"
}

variable "master_username" {
  type      = string
  sensitive = true
  default   = "maikiboss" # A CHANGER
}

variable "master_password" {
  type      = string
  sensitive = true
  default   = "password" # A CHANGER
}

# variable "allowed_security_groups" {
#   type        = list(string)
#   description = "liste des security group"
# }

variable "common_tags" {
  type = map(string)
  default = {
    owners      = "architect"
    environment = "dev"
  }
}