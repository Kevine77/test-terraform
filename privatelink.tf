# -------------------------------------------------------------------
# Find VNETs by required tags (both app tag AND region tag)
# This ensures we get the correct VNET for each region
# -------------------------------------------------------------------

data "azurerm_resources" "vnet_by_tag" {
  for_each = var.regions

  type = "Microsoft.Network/virtualNetworks"

  required_tags = {
    (each.value.vnet_tag_key)     = each.value.vnet_tag_value
    (each.value.region_tag_key)   = each.value.region_tag_value
  }
}

# -------------------------------------------------------------------
# Extract resource group and VNET name from the discovered resource ID
# Resource ID format: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}
# -------------------------------------------------------------------

locals {
  vnet_info = {
    for k, v in data.azurerm_resources.vnet_by_tag : k => {
      resource_group = split("/", v.resources[0].id)[4]
      vnet_name      = split("/", v.resources[0].id)[8]
    }
  }
}

# -------------------------------------------------------------------
# Resolve the discovered VNET from the returned resource ID
# -------------------------------------------------------------------

data "azurerm_virtual_network" "vnet" {
  for_each = var.regions

  resource_group_name = local.vnet_info[each.key].resource_group
  name                = local.vnet_info[each.key].vnet_name
}

# -------------------------------------------------------------------
# Lookup subnet for each region
# -------------------------------------------------------------------

data "azurerm_subnet" "subnet" {
  for_each = var.regions

  name                 = each.value.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[each.key].name
  resource_group_name  = local.vnet_info[each.key].resource_group
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
  location            = data.azurerm_virtual_network.vnet[each.key].location
  resource_group_name = local.vnet_info[each.key].resource_group
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