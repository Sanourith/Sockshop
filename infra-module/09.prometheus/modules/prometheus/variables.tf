variable "instance_ami" {
  description = "Image AWS Linux"
  type        = string
  default     = "ami-09d83d8d719da9808"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "public_subnet_a" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
  default     = "eks-terraform-key"
}

variable "aws_region" {
  type    = string
  default = "eu-west-3"
}


variable "config_bucket_name" {
  description = "Name of S3 bucket that stores config files"
  type        = string
}

variable "password" {
  description = "Password for web frontend"
  type        = string
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt"
  type        = string
}

variable "hostname" {
  description = "Hostname"
  type        = string
}

