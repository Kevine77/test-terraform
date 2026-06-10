# -------------------------------------------------------------------
# Lookup Azure resource groups for each configured region
# -------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  for_each = var.regions

  name = each.value.resource_group
}

# -------------------------------------------------------------------
# Find VNETs by required tag in each resource group
# -------------------------------------------------------------------

data "azurerm_resources" "vnet_by_tag" {
  for_each = var.regions

  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  type                = "Microsoft.Network/virtualNetworks"

  required_tags = {
    (each.value.vnet_tag_key) = each.value.vnet_tag_value
  }
}

# -------------------------------------------------------------------
# Resolve the discovered VNET from the returned resource ID
# -------------------------------------------------------------------

data "azurerm_virtual_network" "vnet" {
  for_each = var.regions

  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  name                = split("/", data.azurerm_resources.vnet_by_tag[each.key].resources[0].id)[8]
}

# -------------------------------------------------------------------
# Lookup subnet for each region
# -------------------------------------------------------------------

data "azurerm_subnet" "subnet" {
  for_each = var.regions

  name                 = each.value.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = data.azurerm_resource_group.rg[each.key].name
}

# -------------------------------------------------------------------
# Create Atlas PrivateLink endpoint service in each Azure region
# IMPORTANT:
# - For Atlas cluster deployment use atlas_region (e.g. EUROPE_NORTH)
# - For Atlas PrivateLink on Azure use azure_region (e.g. northeurope)
# -------------------------------------------------------------------

resource "mongodbatlas_privatelink_endpoint" "atlas" {
  for_each = var.regions

  project_id    = var.atlas_project_id
  provider_name = "AZURE"
  region        = each.value.azure_region

  depends_on = [mongodbatlas_advanced_cluster.cluster]

  timeouts {
    create = "30m"
    delete = "20m"
  }
}

# -------------------------------------------------------------------
# Create Azure Private Endpoint connected to the Atlas service
# -------------------------------------------------------------------

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

  depends_on = [mongodbatlas_privatelink_endpoint.atlas]
}

# -------------------------------------------------------------------
# Register Azure Private Endpoint back with Atlas
# -------------------------------------------------------------------

resource "mongodbatlas_privatelink_endpoint_service" "atlas_service" {
  for_each = var.regions

  project_id                  = var.atlas_project_id
  private_link_id             = mongodbatlas_privatelink_endpoint.atlas[each.key].private_link_id
  provider_name               = "AZURE"
  endpoint_service_id         = azurerm_private_endpoint.atlas[each.key].id
  private_endpoint_ip_address = azurerm_private_endpoint.atlas[each.key].private_service_connection[0].private_ip_address

  depends_on = [azurerm_private_endpoint.atlas]
}