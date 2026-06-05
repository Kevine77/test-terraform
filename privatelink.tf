# Dynamically lookup data sources for each region
data "azurerm_resource_group" "rg" {
  for_each = var.regions
  
  name = each.value.resource_group
}

# Find VNETs by tag using azurerm_resources
data "azurerm_resources" "vnet_by_tag" {
  for_each = var.regions
  
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  type                = "Microsoft.Network/virtualNetworks"
  
  required_tags = {
    (each.value.vnet_tag_key) = each.value.vnet_tag_value
  }
}

# Get the VNET details from the discovered resource
data "azurerm_virtual_network" "vnet" {
  for_each = var.regions
  
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  name                = split("/", data.azurerm_resources.vnet_by_tag[each.key].resources[0].id)[8]
}

data "azurerm_subnet" "subnet" {
  for_each = var.regions
  
  name                 = each.value.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = data.azurerm_resource_group.rg[each.key].name
}

# Create MongoDB Atlas private link endpoints for each region
resource "mongodbatlas_privatelink_endpoint" "atlas" {
  for_each = var.regions
  
  project_id    = var.atlas_project_id
  provider_name = "AZURE"
  region        = lower(replace(each.value.atlas_region, "_", ""))

  depends_on = [mongodbatlas_advanced_cluster.cluster]
}

# Create Azure private endpoints for each region
resource "azurerm_private_endpoint" "atlas" {
  for_each = var.regions
  
  name                = "atlas-private-endpoint-${each.key}"
  location            = data.azurerm_resource_group.rg[each.key].location
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  subnet_id           = data.azurerm_subnet.subnet[each.key].id

  private_service_connection {
    name                           = "atlas-pls-${each.key}"
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.atlas[each.key].private_link_service_resource_id
    is_manual_connection           = true
    request_message                = "MongoDB Atlas Private Endpoint - ${each.key}"
  }
}

# Create MongoDB private link endpoint services for each region
resource "mongodbatlas_privatelink_endpoint_service" "atlas_service" {
  for_each = var.regions
  
  project_id      = var.atlas_project_id
  private_link_id = mongodbatlas_privatelink_endpoint.atlas[each.key].private_link_id
  provider_name   = "AZURE"

  endpoint_service_id = azurerm_private_endpoint.atlas[each.key].id
  private_endpoint_ip_address = azurerm_private_endpoint.atlas[each.key].private_service_connection[0].private_ip_address

  depends_on = [azurerm_private_endpoint.atlas]
}

