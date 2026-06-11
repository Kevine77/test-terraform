variable "atlas_public_key" {
  sensitive = true
  type        = string
  description = "MongoDB Atlas API public key"
}

variable "atlas_private_key" {
  sensitive = true
  type        = string
  description = "MongoDB Atlas API private key (shown only once when created)"
}

variable "atlas_project_name" {
  type    = string
  default = "prod-project"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "atlas_project_id" {
  type        = string
  sensitive   = true
  description = "MongoDB Atlas Project ID"
}

variable "cluster_name" {
  type        = string
  default     = "prod-multi-region"
  description = "Name of the MongoDB Atlas cluster"
}

# Number of shards for sharded cluster
variable "num_shards" {
  type        = number
  default     = 2
  description = "Number of shards for the Atlas sharded cluster (minimum 2 for production sharding)"
}

# Map of regions with their VNET and subnet configuration
variable "regions" {
  type = map(object({
    atlas_region      = string
    azure_region      = string
    resource_group    = string
    vnet_tag_key      = string
    vnet_tag_value    = string
    subnet_name       = string
    instance_size     = string
    node_count        = number
    priority          = number
  }))
  description = "Map of regions keyed by location, each containing VNET and cluster configuration"
  default     = {}
}
