output "project_id" {
  value       = var.atlas_project_id
  description = "MongoDB Atlas Project ID"
}

output "cluster_name" {
  value       = mongodbatlas_advanced_cluster.cluster.name
  description = "MongoDB cluster name"
}

output "cluster_type" {
  value       = mongodbatlas_advanced_cluster.cluster.cluster_type
  description = "Cluster type (REPLICASET or SHARDED)"
}

output "discovered_vnets" {
  value = {
    for region, vnet in data.azurerm_virtual_network.vnet : region => {
      vnet_name      = vnet.name
      vnet_id        = vnet.id
      address_space  = vnet.address_space
      location       = vnet.location
    }
  }
  description = "Auto-discovered VNETs per region"
}

output "discovered_subnets" {
  value = {
    for region, subnet in data.azurerm_subnet.subnet : region => {
      subnet_name      = subnet.name
      subnet_id        = subnet.id
      address_prefixes = subnet.address_prefixes
      vnet_name        = data.azurerm_virtual_network.vnet[region].name
    }
  }
  description = "Auto-discovered subnets per region"
}

output "regional_private_endpoints" {
  value = {
    for region, endpoint in mongodbatlas_privatelink_endpoint.atlas : region => {
      private_link_id              = endpoint.private_link_id
      private_link_service_name    = endpoint.private_link_service_name
      status                       = endpoint.status
      azure_resource_group         = local.vnet_info[region].resource_group
      azure_vnet                   = data.azurerm_virtual_network.vnet[region].name
      azure_subnet                 = data.azurerm_subnet.subnet[region].name
      private_endpoint_id          = azurerm_private_endpoint.atlas[region].id
      private_endpoint_ip          = azurerm_private_endpoint.atlas[region].private_service_connection[0].private_ip_address
    }
  }
  description = "All regional private endpoints with their configuration"
}

output "regional_summary" {
  value = {
    for region, config in var.regions : region => {
      atlas_region      = config.atlas_region
      azure_region      = config.azure_region
      vnet_tag_key      = config.vnet_tag_key
      vnet_tag_value    = config.vnet_tag_value
      vnet_name         = data.azurerm_virtual_network.vnet[region].name
      subnet_name       = config.subnet_name
      instance_size     = config.instance_size
      node_count        = config.node_count
    }
  }
  description = "Summary of regional configuration"
}
