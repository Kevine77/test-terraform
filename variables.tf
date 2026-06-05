variable "atlas_public_key" { sensitive = true }
variable "atlas_private_key" { sensitive = true }
variable "atlas_project_name" {}
variable "subscription_id" {}
variable "resource_group_name" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "azure_region" { default = "North Europe" }
variable "atlas_project_id" {}