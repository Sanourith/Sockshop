
variable "instance_type" {
  description = "Instance type for EC2 instance"
  type        = string
  default     = "t2.nano"
}

variable "instance_ami" {
  description = "AMI for EC2 instance"
  type        = string
  default = "ami-09d83d8d719da9808"
}


variable "key_name" {
  description = "Key name for EC2 instance"
  type        = string
  default = "eks-terraform-key.pem"
}
