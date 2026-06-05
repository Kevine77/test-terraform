terraform {
  backend "azurerm" {
    resource_group_name  = "north-europa"
    storage_account_name = "tfstatekevin001"
    container_name       = "tfstate"
    key                  = "mongodb-atlas/prod.tfstate"
  }
}