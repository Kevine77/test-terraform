variable "atlas_public_key" { sensitive = true }
variable "atlas_private_key" { sensitive = true }
variable "atlas_project_name" {}
variable "subscription_id" {}
variable "atlas_project_id" {}
variable "cluster_name" { default = "prod-multi-region" }

# Map of regions with their VNET and subnet configuration
variable "regions" {
  type = map(object({
    atlas_region      = string
    azure_region      = string
    resource_group    = string
    vnet_tag_key      = string        # Tag key to discover VNET
    vnet_tag_value    = string        # Tag value to discover VNET
    subnet_name       = string
    instance_size     = string
    node_count        = number
    priority          = number
  }))
  description = "Map of regions keyed by location, each containing VNET and cluster configuration"
  
  default = {}
}