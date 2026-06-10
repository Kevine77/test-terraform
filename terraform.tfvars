atlas_public_key  = "iukfdmyg"
atlas_private_key = "96fd7cc6-a74d-4a99-8c23-98a68845a13e"

atlas_project_name = "prod-project"
atlas_project_id   = "6a22265f8cc901c2e2b486d2"
subscription_id    = "3519cc60-0b7c-4a1b-8e5c-57775b73f035"
cluster_name       = "prod-multi-region"

# Regional configuration map - keyed by location for easy pairing
regions = {
  north_europe = {
    atlas_region      = "EUROPE_NORTH"
    azure_region      = "northeurope"
    vnet_tag_key      = "EA_APPID"
    vnet_tag_value    = "SS12"
    region_tag_key    = "Azure_Region"
    region_tag_value  = "northeurope"
    subnet_name       = "default"
    instance_size     = "M10"
    node_count        = 3
    priority          = 7
  }

 # west_europe = {
 #   atlas_region      = "EUROPE_WEST"
 #   azure_region      = "westeurope"
 #   vnet_tag_key      = "EA_APPID"
 #   vnet_tag_value    = "SS13"
 #   region_tag_key    = "Azure_Region"
 #   region_tag_value  = "westeurope"
 #   subnet_name       = "default"
 #   instance_size     = "M10"
 #   node_count        = 2
 #   priority          = 6
 # }
}