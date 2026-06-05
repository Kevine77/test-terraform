terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatekevin001"
    container_name       = "tfstate"
    key                  = "mongodb-atlas/prod.tfstate"
  }
}