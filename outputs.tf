output "project_id" {

  value = var.atlas_project_id

}

output "cluster_name" {
  value = mongodbatlas_advanced_cluster.cluster.name
}

output "atlas_private_link_id" {
  value = mongodbatlas_privatelink_endpoint.atlas.private_link_id
}

output "azure_private_endpoint_id" {
  value = azurerm_private_endpoint.atlas.id
}
