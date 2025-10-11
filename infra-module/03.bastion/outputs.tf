output "ec2_bastion_public_instance_ids" {
  description = "List of IDs of instances"
  value       = module.ec2_public.id
}

output "ec2_bastion_public_ip" {
  description = "Elastic IP associated to the Bastion"
  value       = aws_eip.bastion_eip.public_ip
}

output "security_group_id" {
  description = "ID du SG bastion"
  value       = module.public_bastion_sg.security_group_id
}

output "security_group_name" {
  description = "NAME du SG bastion"
  value       = module.public_bastion_sg.security_group_name
}