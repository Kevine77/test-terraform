data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

resource "mongodbatlas_privatelink_endpoint" "atlas" {
  project_id    = var.atlas_project_id
  provider_name = "AZURE"
  region        = "northeurope"

  depends_on = [mongodbatlas_advanced_cluster.cluster]
}

resource "azurerm_private_endpoint" "atlas" {
  name                = "atlas-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "atlas-pls"
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.atlas.private_link_service_resource_id
    is_manual_connection           = true
    request_message                = "MongoDB Atlas Private Endpoint"
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "atlas_service" {
  project_id      = var.atlas_project_id
  private_link_id = mongodbatlas_privatelink_endpoint.atlas.private_link_id
  provider_name   = "AZURE"

  endpoint_service_id = azurerm_private_endpoint.atlas.id

  private_endpoint_ip_address = azurerm_private_endpoint.atlas.private_service_connection[0].private_ip_address

  depends_on = [azurerm_private_endpoint.atlas]
}
