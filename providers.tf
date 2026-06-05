provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
