output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for accessing the EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}