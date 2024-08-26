output "endpoint" {
  description = "endpoint of doc-db"
  value       = module.documentdb_cluster.endpoint
}

# output "master_password" {
#   description = "password"
#   value       = module.documentdb_cluster.master_password
# }

# output "master_username" {
#   description = "username"
#   value       = module.documentdb_cluster.master_username
# }

output "cluster_security_group_id" {
  description = "endpoint of doc-db"
  value       = module.documentdb_cluster.security_group_id
}

output "security_group_name" {
  description = "endpoint of doc-db"
  value       = module.documentdb_cluster.security_group_name
}