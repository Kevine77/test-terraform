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

output "num_shards" {
  value       = var.num_shards
  description = "Configured number of shards for the Atlas cluster"
}

output "discovered_vnets" {
  value = {
    for region, vnet in data.azurerm_virtual_network.vnet : region => {
      vnet_name     = vnet.name
      vnet_id       = vnet.id
      address_space = vnet.address_space
      location      = vnet.location
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
      private_link_id           = endpoint.private_link_id
      private_link_service_name = endpoint.private_link_service_name
      status                    = endpoint.status
      azure_resource_group      = data.azurerm_resource_group.rg[region].name
      azure_vnet                = data.azurerm_virtual_network.vnet[region].name
      azure_subnet              = data.azurerm_subnet.subnet[region].name
      private_endpoint_id       = azurerm_private_endpoint.atlas[region].id
      private_endpoint_ip       = azurerm_private_endpoint.atlas[region].private_service_connection[0].private_ip_address
    }
  }
  description = "All regional private endpoints with their configuration"
}

output "regional_summary" {
  value = {
    for region, config in var.regions : region => {
      atlas_region   = config.atlas_region
      azure_region   = config.azure_region
      vnet_tag_key   = config.vnet_tag_key
      vnet_tag_value = config.vnet_tag_value
      vnet_name      = data.azurerm_virtual_network.vnet[region].name
      subnet_name    = config.subnet_name
      instance_size  = config.instance_size
      node_count     = config.node_count
      priority       = config.priority
    }
  }
  description = "Summary of regional configuration"
}

# -------------------------------------------------------------------
# Debug outputs for VNet tag discovery
# -------------------------------------------------------------------

output "vnet_discovery_debug" {
  value = {
    for region, config in var.regions : region => {
      resource_group = config.resource_group
      tag_key        = config.vnet_tag_key
      tag_value      = config.vnet_tag_value
      match_count    = length(data.azurerm_resources.vnet_by_tag[region].resources)
      matched_names  = [
        for r in data.azurerm_resources.vnet_by_tag[region].resources : r.name
      ]
      matched_ids = [
        for r in data.azurerm_resources.vnet_by_tag[region].resources : r.id
      ]
    }
  }
  description = "Debug view of VNet discovery by tag, including match count and candidate VNets"
}

output "vnet_discovery_summary" {
  value = {
    for region, config in var.regions : region => (
      length(data.azurerm_resources.vnet_by_tag[region].resources) == 1
      ? "OK: exactly one VNet matched"
      : "ERROR: expected exactly one VNet match"
    )
  }
  description = "High-level status of VNet tag discovery per region"
}
