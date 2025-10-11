# variable "vpc_id" {
#   type = string
# }

variable "name" {
  type    = string
  default = "bastion-dev"
}

# variable "public_subnet" {
#   type = string
# }

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "access_key" {
  description = "access_key"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
  default     = "eks-terraform-key"
}

variable "common_tags" {
  type = map(string)
  default = {
    owners      = "architect"
    environment = "dev"
  }
}

