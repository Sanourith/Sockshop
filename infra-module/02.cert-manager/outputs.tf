output "cert_manager_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value       = helm_release.cert_manager.metadata
}